// SPDX-License-Identifier: AGPL-3.0-only
//
// What can be checked WITHOUT the ephemeris.
//
// The station arithmetic lives in integration_test/ because it needs the real
// Swiss Ephemeris and a real target. Everything here is pure Dart: formatting,
// and the shapes the site's API answers with. Both have produced real bugs —
// "0h 14m" is a rendering the site had to fix, and reading `/api/videos` as a
// bare list would return nothing at all while looking like it worked.
import 'package:flutter_test/flutter_test.dart';
import 'package:astrolabe/services/site.dart';

void main() {
  group('the videos endpoint answers with an object, not a list', () {
    test('a well-formed response is read', () {
      final got = parseVideosForTest({
        'videos': [
          {
            'platform': 'youtube',
            'title': 'Advice to New Programmers',
            'href': 'https://youtube.com/watch?v=x',
            'thumb': '/api/videos/thumb/youtube/x',
            'date': '2024-12-18',
          },
        ],
        'counts': {'youtube': 1},
      });
      expect(got.length, 1);
      expect(got.first.title, 'Advice to New Programmers');
      // The site proxies thumbnails so opening the app does not announce the
      // reader to Google. Keep the proxy, do not rewrite to the origin.
      expect(got.first.thumbUrl, '$siteOrigin/api/videos/thumb/youtube/x');
    });

    test(
      'a bare list is NOT the shape, and yields nothing rather than crashing',
      () {
        expect(
          parseVideosForTest([
            {'title': 'x'},
          ]),
          isEmpty,
        );
      },
    );

    test('the holding page, which answers 200 with HTML, yields nothing', () {
      expect(parseVideosForTest(null), isEmpty);
    });
  });

  group('live status', () {
    test('offline when nothing is live', () {
      final s = LiveStatus.parse({
        'anyLive': false,
        'platforms': [
          {'platform': 'twitch', 'isLive': false, 'url': 'https://twitch.tv/x'},
        ],
      });
      expect(s!.isLive, isFalse);
      expect(s.url, 'https://twitch.tv/x');
    });

    test('picks the platform that is actually live, not the first one', () {
      final s = LiveStatus.parse({
        'anyLive': true,
        'platforms': [
          {'platform': 'youtube', 'isLive': false, 'url': 'https://yt/x'},
          {
            'platform': 'twitch',
            'isLive': true,
            'title': 'writing the ephemeris',
            'url': 'https://twitch.tv/shrutivtuber',
          },
        ],
      });
      expect(s!.isLive, isTrue);
      expect(s.title, 'writing the ephemeris');
      expect(s.url, contains('twitch.tv'));
    });

    test('unreachable site reads as offline, never as an error', () {
      expect(LiveStatus.parse(null), isNull);
    });
  });
}
