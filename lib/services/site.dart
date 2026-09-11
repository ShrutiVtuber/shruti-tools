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

Future<dynamic> _get(
  String path, {
  Map<String, String> headers = const {},
}) async {
  try {
    final r = await http
        .get(
          Uri.parse('$siteOrigin$path'),
          // ⚠ The account's bearer token where one is given. Some answers
          // depend on who is asking — an offer only for members is not in the
          // list at all for anybody else.
          headers: {'Accept': 'application/json', ...headers},
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

/// ⚠ Null when the site could not be reached — NOT `offline`.
///
/// "She is not streaming" and "we could not find out" are different facts, and
/// rendering the second as the first is a small lie told several times a week
/// to exactly the people who care most. The screen has a third state for it.
Future<LiveStatus?> liveStatus() async =>
    LiveStatus.parse(await _get('/api/live'));

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

/// One of her published readings, newest first.
class Reading {
  const Reading({
    required this.sign,
    required this.period,
    required this.covers,
    required this.opening,
    required this.publishedAt,
  });

  final String sign;
  final String period;
  final String covers;
  final String opening;
  final String publishedAt;

  String get path => '/horoscopes/$sign/$period/$covers';
}

/// The readings she has published, newest first.
///
/// ⚠ `/published` and not `/archive`. The archive groups by period and carries
/// no timestamp, so a list built on it comes out in an order that has nothing
/// to do with when anything was published — which was shipped once already, in
/// a feed and a sitemap.
Future<List<Reading>> publishedReadings({int limit = 12}) async {
  final body = await _get('/api/horoscopes/published?limit=$limit');
  if (body is! List) return const [];
  return [
    for (final r in body)
      if (r is Map)
        Reading(
          sign: (r['sign'] ?? '') as String,
          period: (r['period'] ?? '') as String,
          covers: (r['covers'] ?? '') as String,
          opening: (r['opening'] ?? '') as String,
          publishedAt: (r['publishedAt'] ?? '') as String,
        ),
  ];
}

/// Her twelve readings for one period, as the app shows them.
///
/// ⚠ **The CURRENT period only, by her decision.** Anything older opens the
/// website — the same boundary as the five tools that stayed off the app, and
/// for the same reason: the app carries what somebody wants now, and the site
/// is where the archive and the search live. The endpoint would serve any
/// period just as happily, which is exactly why the line has to be drawn here
/// deliberately rather than left to whatever gets called.
class Twelve {
  const Twelve({
    required this.period,
    required this.covers,
    required this.readings,
  });

  final String period;
  final String covers;

  /// Every sign she has published for this period, in zodiacal order.
  ///
  /// ⚠ Only the published ones. A sign she has not written yet comes back with
  /// an empty body, and showing it as a blank reading would say she had
  /// written nothing for you rather than not yet.
  final List<SignReading> readings;

  bool get isEmpty => readings.isEmpty;
}

class SignReading {
  const SignReading({required this.sign, required this.bodyMd});

  final String sign;
  final String bodyMd;
}

/// The twelve for the period we are in now.
///
/// Returns null when the site cannot be reached, which the screen shows as
/// "her side is out of reach" rather than as "she has written nothing".
Future<Twelve?> theTwelve({String period = 'monthly'}) async {
  final body = await _get(
    '/api/horoscopes?period=${Uri.encodeComponent(period)}',
  );
  if (body is! Map) return null;
  final rows = body['readings'];
  return Twelve(
    period: (body['period'] ?? period) as String,
    covers: (body['covers'] ?? '') as String,
    readings: [
      if (rows is List)
        for (final r in rows)
          if (r is Map &&
              (r['published'] ?? false) == true &&
              ((r['bodyMd'] ?? '') as String).trim().isNotEmpty)
            SignReading(
              sign: (r['sign'] ?? '') as String,
              bodyMd: (r['bodyMd'] ?? '') as String,
            ),
    ],
  );
}

/// Which periods she has anything published for, newest kind first.
///
/// ⚠ Read from the same answer rather than guessed. She may write monthly and
/// not weekly, and a tab for a period she never uses is a tab that always says
/// nothing is there.
Future<List<String>> periodsShePublishes() async {
  final body = await _get('/api/horoscopes');
  if (body is! Map) return const [];
  final list = body['availablePeriods'];
  return [
    if (list is List)
      for (final p in list) p as String,
  ];
}

/// An article from the journal.
class Article {
  const Article({
    required this.title,
    required this.opening,
    required this.url,
    required this.publishedAt,
  });

  final String title;
  final String opening;
  final String url;
  final String publishedAt;
}

/// Her latest writing.
///
/// ⚠ Over the API, not the RSS feed. The feed is a PAGE, and pages are behind
/// the holding gate — the app has no session for that and would silently get
/// the "site is being built" placeholder instead of her articles.
Future<List<Article>> articles({int limit = 6}) async {
  final body = await _get('/api/journal/recent?limit=$limit');
  if (body is! List) return const [];
  return [
    for (final a in body)
      if (a is Map)
        Article(
          title: (a['title'] ?? '') as String,
          opening: (a['opening'] ?? '') as String,
          url: (a['url'] ?? '') as String,
          publishedAt: (a['publishedAt'] ?? '') as String,
        ),
  ];
}

/// Something worth having, offered in the app.
class Offer {
  const Offer({
    required this.title,
    required this.blurb,
    required this.kind,
    required this.code,
    required this.url,
    required this.from,
    required this.endsAt,
  });

  final String title;
  final String blurb;
  final String kind;

  /// The code to type at the till. Empty where the offer is just a link.
  final String code;
  final String url;

  /// Whose deal it is, for a sponsor's. Empty for hers.
  final String from;
  final String? endsAt;
}

/// What is on right now.
///
/// ⚠ The site decides what this person may see — an offer only for members
/// never arrives here at all, rather than arriving and being hidden. A code on
/// the phone is a code that can be read off it.
Future<List<Offer>> offers({Map<String, String> headers = const {}}) async {
  final body = await _get('/api/offers', headers: headers);
  if (body is! List) return const [];
  return [
    for (final o in body)
      if (o is Map)
        Offer(
          title: (o['title'] ?? '') as String,
          blurb: (o['blurb'] ?? '') as String,
          kind: (o['kind'] ?? 'shop') as String,
          code: (o['code'] ?? '') as String,
          url: (o['url'] ?? '') as String,
          from: (o['from'] ?? '') as String,
          endsAt: o['endsAt'] as String?,
        ),
  ];
}
