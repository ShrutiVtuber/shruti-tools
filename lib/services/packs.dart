// SPDX-License-Identifier: AGPL-3.0-only
//
// Language packs: what is on offer, what is installed, and getting one.
//
// Isopsephy needs two things per language — the letter values for the script,
// and a corpus of words to find matches in. Both are theourgia's packs, served
// from shrutivtuber.com, and neither ships with the app.
//
// That is a size decision and a licence one. The letter tables are two to four
// kilobytes each and could reasonably be bundled; the corpora cannot, since
// Greek alone is 4.3MB and most people want one language rather than five. And
// the packs are All Rights Reserved while this app is AGPL with a public
// repository — they cannot live in it at all.
//
// So: a chooser that says what each one costs before anybody spends it, and a
// download that keeps the unpacked JSON rather than the container.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'site.dart';

/// One pack, as the site describes it.
class PackInfo {
  const PackInfo({
    required this.file,
    required this.url,
    required this.name,
    required this.description,
    required this.kinds,
    required this.bytes,
  });

  final String file;
  final String url;
  final String name;
  final String description;

  /// `gematria-systems` is a letter table; `gematria-word-lists` is a corpus.
  final List<String> kinds;
  final int bytes;

  bool get isTable => kinds.contains('gematria-systems');
  bool get isCorpus => kinds.contains('gematria-word-lists');

  /// What a person is about to spend, said the way a person says it.
  String get size => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
      : '${(bytes / 1024).round()} KB';
}

/// What the site has.
Future<List<PackInfo>> availablePacks() async {
  try {
    final r = await http
        .get(Uri.parse('$siteOrigin/api/packs'))
        .timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) return const [];
    final body = jsonDecode(utf8.decode(r.bodyBytes));
    if (body is! Map) return const [];
    final list = body['packs'];
    if (list is! List) return const [];
    return [
      for (final p in list)
        if (p is Map)
          PackInfo(
            file: (p['file'] ?? '') as String,
            url: (p['url'] ?? '') as String,
            name: (p['name'] ?? '') as String,
            description: (p['description'] ?? '') as String,
            kinds: [
              for (final k in (p['kinds'] as List? ?? const [])) k as String,
            ],
            bytes: (p['bytes'] as num?)?.toInt() ?? 0,
          ),
    ];
  } catch (_) {
    // No signal. The packs already installed still work — the whole point of
    // unpacking them at download time rather than reading them over the wire.
    return const [];
  }
}

Future<Directory> _store() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory('${base.path}/packs');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  return dir;
}

/// The files already unpacked on this phone.
Future<Set<String>> installedPacks() async {
  final dir = await _store();
  return dir
      .listSync()
      .whereType<Directory>()
      .map((d) => d.path.split('/').last)
      .toSet();
}

/// Fetch a pack and unpack it. Returns null on success, or why it failed.
///
/// A reason rather than a bare `false`. A download can fail because the site
/// is unreachable, because the phone has no room, or because the container is
/// not what it claims — and "false" tells the person holding the phone none of
/// those, nor the person reading a test failure.
///
/// The JSON is kept and the container thrown away. A .mbf is a zip, and
/// re-opening one on every reckoning would mean inflating four megabytes to
/// answer a question about six letters.
Future<String?> installPack(PackInfo pack) async {
  http.Response r;
  try {
    r = await http
        .get(Uri.parse('$siteOrigin${pack.url}'))
        .timeout(const Duration(minutes: 2));
  } catch (e) {
    return 'could not reach ${pack.url} ($e)';
  }
  if (r.statusCode != 200) {
    return '${pack.url} answered ${r.statusCode}';
  }

  Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(r.bodyBytes);
  } catch (e) {
    return 'not a readable pack (${r.bodyBytes.length} bytes): $e';
  }

  try {
    final dir = Directory('${(await _store()).path}/${pack.file}');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);

    for (final entry in zip) {
      if (!entry.isFile) continue;
      // ⚠ A zip entry names its own path, and a crafted one can name `..`.
      // These come from her site over TLS, which is not a threat model — but a
      // routine that writes wherever it is told becomes one the first time
      // something else feeds it.
      final name = entry.name;
      if (name.contains('..') || name.startsWith('/')) continue;
      final out = File('${dir.path}/$name');
      out.parent.createSync(recursive: true);
      out.writeAsBytesSync(entry.content as List<int>);
    }
    return null;
  } catch (e) {
    return 'could not write ${pack.file}: $e';
  }
}

Future<void> removePack(String file) async {
  final dir = Directory('${(await _store()).path}/$file');
  if (dir.existsSync()) dir.deleteSync(recursive: true);
}

/// Everything unpacked, as parsed JSON, for one payload kind.
Future<List<Map<String, dynamic>>> loadItems(String kind) async {
  final dir = await _store();
  final out = <Map<String, dynamic>>[];
  for (final pack in dir.listSync().whereType<Directory>()) {
    final payload = File('${pack.path}/payloads/$kind.json');
    if (!payload.existsSync()) continue;
    try {
      final body = jsonDecode(payload.readAsStringSync());
      if (body is! Map) continue;
      for (final item in (body['items'] as List? ?? const [])) {
        if (item is Map<String, dynamic>) {
          // Where the pack lives, so an entries asset can be found later.
          out.add({...item, '_dir': pack.path});
        }
      }
    } catch (_) {
      // A half-written pack — an interrupted download — is skipped rather than
      // fatal. It can be installed again.
      continue;
    }
  }
  return out;
}

/// The word entries an item points at, read only when they are wanted.
///
/// Kept out of [loadItems] on purpose: the Greek corpus is four megabytes of
/// entries and the chooser only ever needs the item's name.
List<List<dynamic>> entriesFor(Map<String, dynamic> item) {
  final asset = item['entries_asset'];
  final dir = item['_dir'];
  if (asset is! String || dir is! String) return const [];
  final file = File('$dir/$asset');
  if (!file.existsSync()) return const [];
  try {
    final body = jsonDecode(file.readAsStringSync());
    return body is List ? body.cast<List<dynamic>>() : const [];
  } catch (_) {
    return const [];
  }
}
