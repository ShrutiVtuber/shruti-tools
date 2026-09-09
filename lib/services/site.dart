// SPDX-License-Identifier: AGPL-3.0-only
//
// Everything the app reads from shrutivtuber.com.
//
// Two rules hold this together.
//
// **Nothing here is required for the app to work.** The instruments compute on
// the device against a bundled ephemeris; the site is for what only she knows
// — whether she is streaming, what she has posted, what she has written. A
// phone on a train with no signal still casts a chart and still tells you when
// the sun sets. So every call returns null or an empty list on failure and no
// screen may treat that as an error worth shouting about.
//
// **The shapes are checked, not assumed.** `/api/videos` answers with an
// object holding a `videos` key, not with a bare list; `/api/newsletter/archive`
// answers with a bare list. Getting that backwards on the site produced a
// sitemap that silently listed nothing, and the comment recording it is still
// there. Each parser below states which shape it expects.
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/place.dart';

const siteOrigin = String.fromEnvironment(
  'SHRUTI_SITE',
  defaultValue: 'https://shrutivtuber.com',
);

/// How long to wait before deciding the site is not going to answer.
///
/// Short on purpose. This is never on the path to something the user asked
/// for — it decorates a screen that already works without it.
const _timeout = Duration(seconds: 8);

Future<dynamic> _get(String path) async {
  try {
    final r = await http
        .get(
          Uri.parse('$siteOrigin$path'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(_timeout);
    if (r.statusCode != 200) return null;
    // While the holding page is up, everything not on the middleware's
    // pass-through list answers 200 with HTML. Decoding that throws, which is
    // caught below and reported as "nothing" — which is the truth.
    return jsonDecode(utf8.decode(r.bodyBytes));
  } catch (_) {
    return null;
  }
}

/// Whether she is streaming, and where.
class LiveStatus {
  const LiveStatus({
    required this.isLive,
    this.title = '',
    this.game = '',
    this.viewers,
    this.url = 'https://twitch.tv/shrutivtuber',
  });

  final bool isLive;
  final String title;
  final String game;
  final int? viewers;
  final String url;

  static const offline = LiveStatus(isLive: false);

  /// `/api/live` → `{anyLive, primary, platforms: [{platform, isLive, …}]}`.
  static LiveStatus? parse(dynamic body) {
    if (body is! Map) return null;
    final platforms = body['platforms'];
    Map? best;
    if (platforms is List) {
      for (final p in platforms) {
        if (p is Map && p['isLive'] == true) {
          best = p;
          break;
        }
      }
      best ??= platforms.isNotEmpty && platforms.first is Map
          ? platforms.first as Map
          : null;
    }
    return LiveStatus(
      isLive: body['anyLive'] == true,
      title: (best?['title'] ?? '') as String,
      game: (best?['game'] ?? '') as String,
      viewers: best?['viewers'] as int?,
      url: (best?['url'] ?? 'https://twitch.tv/shrutivtuber') as String,
    );
  }
}

Future<LiveStatus> liveStatus() async =>
    LiveStatus.parse(await _get('/api/live')) ?? LiveStatus.offline;

/// One of her videos.
class Video {
  const Video({
    required this.title,
    required this.href,
    required this.platform,
    this.thumb,
    this.date = '',
    this.duration = '',
  });

  final String title;
  final String href;
  final String platform;
  final String? thumb;
  final String date;
  final String duration;

  /// The thumbnail is proxied by the site rather than fetched from YouTube,
  /// which is deliberate there and worth keeping here: it means opening the
  /// app does not announce the reader to Google before a word is drawn.
  String? get thumbUrl => thumb == null ? null : '$siteOrigin$thumb';
}

/// The parser, exposed so a test can hand it a shape without a network.
///
/// The shape is the thing worth testing here: `/api/videos` answers with an
/// OBJECT holding a `videos` key, while `/api/newsletter/archive` answers with
/// a bare list. Assuming the wrong one produced a sitemap on the site that
/// silently listed nothing at all, and the note recording it is still there.
List<Video> parseVideosForTest(dynamic body) => _videos(body);

List<Video> _videos(dynamic body) {
  if (body is! Map) return const [];
  final list = body['videos'];
  if (list is! List) return const [];
  return [
    for (final v in list)
      if (v is Map)
        Video(
          title: (v['title'] ?? '') as String,
          href: (v['href'] ?? '') as String,
          platform: (v['platform'] ?? '') as String,
          thumb: v['thumb'] as String?,
          date: (v['date'] ?? '') as String,
          duration: (v['duration'] ?? '') as String,
        ),
  ];
}

Future<List<Video>> videos() async => _videos(await _get('/api/videos'));

/// Searching for somewhere to compute stations for.
///
/// The site's lookup is used rather than a bundled gazetteer, and rather than
/// the phone's geocoder, because it returns the one field that is easy to
/// forget and impossible to guess: the IANA timezone. Coordinates decide when
/// the sun rises; the zone decides what that instant is called.
///
/// This is the one thing in the app that genuinely needs a network. The chosen
/// place is remembered, so only CHANGING it does — a phone with no signal
/// still has yesterday's answer and still computes today's stations from it.
Future<List<Place>> searchPlaces(String query) async {
  final q = query.trim();
  if (q.length < 2) return const [];
  final body = await _get('/api/places?q=${Uri.encodeQueryComponent(q)}');
  if (body is! Map) return const [];
  final list = body['places'];
  if (list is! List) return const [];
  return [
    for (final r in list)
      if (r is Map && r['timezone'] is String)
        Place(
          name: [
            r['name'],
            // The region disambiguates the eight Athenses. Country alone does
            // not: four of them are in the United States.
            if ((r['region'] ?? '') != '') r['region'],
            if ((r['country'] ?? '') != '') r['country'],
          ].whereType<String>().join(', '),
          lat: (r['lat'] as num).toDouble(),
          lon: (r['lon'] as num).toDouble(),
          zone: r['timezone'] as String,
        ),
  ];
}

/// A piece of her writing.
class Writing {
  const Writing({required this.title, required this.slug, this.sentAt});

  final String title;
  final String slug;
  final String? sentAt;

  String get url => '$siteOrigin/newsletter/archive/$slug';
}

/// `/api/newsletter/archive` → a BARE LIST. Not an object with an `issues` key.
Future<List<Writing>> writing() async {
  final body = await _get('/api/newsletter/archive');
  if (body is! List) return const [];
  return [
    for (final w in body)
      if (w is Map)
        Writing(
          title: (w['subject'] ?? w['slug'] ?? '') as String,
          slug: (w['slug'] ?? '') as String,
          sentAt: w['sentAt'] as String?,
        ),
  ];
}
