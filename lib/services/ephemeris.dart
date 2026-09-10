// SPDX-License-Identifier: AGPL-3.0-only
//
// Starting Swiss Ephemeris, once, before anything asks it a question.
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sweph/sweph.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class _BundleLoader implements AssetLoader {
  @override
  Future<Uint8List> load(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}

/// The files the arithmetic needs: planets, Moon, and the leap-second table.
const _assets = [
  'packages/sweph/assets/ephe/sepl_18.se1',
  'packages/sweph/assets/ephe/semo_18.se1',
  'packages/sweph/assets/ephe/seleapsec.txt',
];

bool _ready = false;

/// What the arithmetic was done by, named once.
///
/// ⚠ This string appears on every instrument screen, and the licence requires
/// the notice be preserved on all copies — so it is a constant, not a sentence
/// re-typed on six screens where one of them will eventually say the wrong
/// version.
const engineVersion = 'Swiss Ephemeris 2.10.03';

/// Unpack the ephemeris and point the library at it.
///
/// ⚠ **`epheFilesPath` must be ABSOLUTE.**
///
/// `Sweph.init` defaults it to the relative string 'ephe_files' and uses it
/// verbatim. On a desktop the working directory is the project folder, so the
/// relative path happens to resolve and everything passes. On Android the
/// working directory is '/', and the copy fails with "Read-only file system" —
/// so the whole app ships with a green suite and no ephemeris at all.
///
/// This is inherited knowledge: astropractise hit it, wrote it down, and the
/// note is the only reason it is not being rediscovered here.
/// [into] overrides where the files are unpacked. The app never passes it —
/// it is for tests, which have no platform channels and so cannot ask
/// path_provider anything. Without this the suite can only run against a fake,
/// and a fake ephemeris proves the arithmetic around it and nothing about the
/// arithmetic itself.
Future<void> startEphemeris({String? into}) async {
  if (_ready) return;
  final path =
      into ?? '${(await getApplicationSupportDirectory()).path}/ephe_files';
  // The zone rules, so a station computed for a place can be told in that
  // place's time rather than in the phone's. Loaded here because it is the
  // same kind of thing — data the arithmetic needs before anything asks.
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));
  await Sweph.init(
    epheAssets: _assets,
    assetLoader: _BundleLoader(),
    epheFilesPath: path,
  );
  _ready = true;
}
