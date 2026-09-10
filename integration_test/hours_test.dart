// SPDX-License-Identifier: AGPL-3.0-only
//
// Planetary hours must agree with her engine, in BOTH conventions.
//
// Reference values from shruti-astro for Athens on 2026-09-09. The two
// conventions differ by about four and a half minutes — small, and enough to
// move an hour boundary, which is the whole reason the choice is carried
// rather than assumed.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:astrolabe/services/ephemeris.dart';
import 'package:astrolabe/services/hours.dart';
import 'package:astrolabe/services/stations.dart';

const _lat = 37.9838;
const _lon = 23.7275;
final _noon = DateTime.utc(2026, 9, 9, 12);

String _hm(DateTime t) =>
    '${t.toUtc().hour.toString().padLeft(2, '0')}:'
    '${t.toUtc().minute.toString().padLeft(2, '0')}';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => startEphemeris());

  group('Hellenistic — upper limb, with refraction', () {
    late List<PlanetaryHour> hours;
    setUpAll(() => hours = hoursFor(_noon, _lat, _lon));

    test('twenty-four of them', () => expect(hours.length, 24));

    test('the day begins at sunrise, 04:01 UT', () {
      expect(_hm(hours.first.from), '04:01');
    });

    test('the night begins at sunset, 16:42 UT', () {
      expect(_hm(hours[12].from), '16:42');
      expect(hours[12].byDay, isFalse);
    });

    test('Wednesday is Mercury, and hour one is the day ruler', () {
      expect(hours.first.ruler, 'Mercury');
    });

    test('the Chaldean order follows', () {
      // Mercury, Moon, Saturn, Jupiter, Mars, Sun — slowest to fastest,
      // wrapping. This is the sequence her engine returns.
      expect(hours.take(6).map((h) => h.ruler).toList(), [
        'Mercury',
        'Moon',
        'Saturn',
        'Jupiter',
        'Mars',
        'Sun',
      ]);
      expect(hours[12].ruler, 'Sun');
      expect(hours[13].ruler, 'Venus');
    });

    test('hour boundaries match', () {
      expect(_hm(hours[1].from), '05:04');
      expect(_hm(hours[5].from), '09:18');
      expect(_hm(hours[13].from), '17:39');
    });

    test('noon falls in the eighth hour of the day, ruled by Mercury', () {
      final now = hourNow(hours, _noon);
      expect(now, isNotNull);
      expect(now!.index, 8);
      expect(now.byDay, isTrue);
      expect(now.ruler, 'Mercury');
      expect(now.displayIndex, 8);
    });

    test('a day hour is not sixty minutes', () {
      // Athens in September: about sixty-three. An hour that is always sixty
      // means the division is being done on the clock rather than on the sun.
      expect(hours.first.length.inMinutes, closeTo(63, 1));
      expect(hours[12].length.inMinutes, closeTo(56, 1));
    });
  });

  group('Vedic — centre of the disc, no refraction', () {
    late List<PlanetaryHour> hours;
    setUpAll(
      () =>
          hours = hoursFor(_noon, _lat, _lon, convention: RiseConvention.hindu),
    );

    test('sunrise is later and sunset earlier, by minutes', () {
      expect(_hm(hours.first.from), '04:05');
      expect(_hm(hours[12].from), '16:38');
    });

    test('which moves every boundary after it', () {
      final hellenistic = hoursFor(_noon, _lat, _lon);
      expect(hours.first.from, isNot(hellenistic.first.from));
      // The point of carrying the choice: a moment can be in a different hour.
      expect(
        hours.first.from.difference(hellenistic.first.from).inMinutes,
        closeTo(4, 1),
      );
    });
  });

  group('the planetary day begins at sunrise, not midnight', () {
    test(
      'one in the morning is still in the night hours of the day before',
      () {
        // The most common way this is got wrong. At 01:00 on the 9th the sun
        // has not risen, so the ruling day is Tuesday's — Mars.
        final small = DateTime.utc(2026, 9, 9, 1);
        final hours = hoursFor(small, _lat, _lon);
        expect(hours.first.ruler, 'Mars', reason: 'Tuesday, not Wednesday');
        final now = hourNow(hours, small);
        expect(now, isNotNull);
        expect(now!.byDay, isFalse, reason: 'it is night');
      },
    );
  });

  test('no sunset means no honest answer', () {
    // Tromsø in midsummer: nothing to divide. An empty list rather than
    // twenty-four hours of a made-up length.
    expect(hoursFor(DateTime.utc(2026, 6, 21, 12), 69.6496, 18.9560), isEmpty);
  });
}
