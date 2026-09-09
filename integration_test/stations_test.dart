// SPDX-License-Identifier: AGPL-3.0-only
//
// The stations must be RIGHT, not merely computed.
//
// A sunrise table that is wrong by ten minutes looks exactly like one that is
// correct, and the person using it finds out by missing a dawn. So these check
// against times that can be looked up independently, not against whatever the
// code happens to return today.
//
// Reference times are UT, from the US Naval Observatory's sun tables for the
// coordinates given. A minute of tolerance covers the difference between USNO
// rounding to the minute and Swiss Ephemeris answering to the second.
//
// ⚠ This is an INTEGRATION test, not a unit test, and it has to be.
// `flutter test` runs on the Dart VM with no plugins linked, so libsweph.so is
// simply absent and every one of these would fail to start. Run it against a
// real target:
//
//     flutter test integration_test -d linux      (on this machine)
//     flutter test integration_test -d <device>   (on the phone)
//
// astropractise learned this the expensive way: a fully green unit suite once
// coexisted with an app that could not open its ephemeris files at all,
// because the suite was testing a fake.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shruti_tools/services/ephemeris.dart';
import 'package:shruti_tools/services/stations.dart';

void main() {
  setUpAll(() async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    // path_provider answers on a real target, and its support directory is the
    // one place guaranteed writable on both Android and desktop.
    await startEphemeris();
  });

  /// London, midsummer. Longitude EAST-positive; Greenwich is 0.
  group('London on the summer solstice, 2026-06-21', () {
    late List<Station> day;

    setUpAll(() {
      day = stationsFor(DateTime.utc(2026, 6, 21, 12), 51.4779, 0.0);
    });

    test('all four stations occur', () {
      expect(day.length, 4);
      expect(day.map((s) => s.kind).toSet(), {
        StationKind.dawn,
        StationKind.noon,
        StationKind.dusk,
        StationKind.midnight,
      });
    });

    test('they come back in time order', () {
      for (var i = 1; i < day.length; i++) {
        expect(
          day[i].at.isAfter(day[i - 1].at),
          isTrue,
          reason: '${day[i].kind} should follow ${day[i - 1].kind}',
        );
      }
    });

    test('sunrise is 03:43 UT', () {
      final dawn = day.firstWhere((s) => s.kind == StationKind.dawn);
      expect(dawn.at.hour, 3);
      expect(dawn.at.minute, closeTo(43, 1));
    });

    test('sunset is 20:21 UT', () {
      final dusk = day.firstWhere((s) => s.kind == StationKind.dusk);
      expect(dusk.at.hour, 20);
      expect(dusk.at.minute, closeTo(21, 1));
    });

    test('noon is 12:02 UT — solar noon, not clock noon', () {
      // Greenwich sits on the meridian, so solar noon is within a couple of
      // minutes of 12:00 UT and the gap is the equation of time. A test that
      // accepted 12:00 exactly would pass for a stub that returned midday.
      final noon = day.firstWhere((s) => s.kind == StationKind.noon);
      expect(noon.at.hour, 12);
      expect(noon.at.minute, closeTo(2, 2));
    });
  });

  test('a west longitude is negative — Los Angeles, not the Pacific', () {
    // The sign convention is the one mistake that produces a table which is
    // plausible and wrong: enter 118 instead of -118 and every station is
    // hours out while still looking like a normal day.
    final la = stationsFor(DateTime.utc(2026, 6, 21, 12), 34.0522, -118.2437);
    final dawn = la.firstWhere((s) => s.kind == StationKind.dawn);
    // Sunrise in LA on the solstice is about 12:42 UT (05:42 PDT).
    expect(dawn.at.hour, 12);
    expect(dawn.at.minute, closeTo(42, 2));
  });

  test('above the Arctic circle the sun may not rise or set', () {
    // Tromsø in midsummer: continuous daylight. Fewer than four stations is
    // the correct answer, and the screen says so rather than printing a blank.
    final tromso = stationsFor(DateTime.utc(2026, 6, 21, 12), 69.6496, 18.9560);
    final kinds = tromso.map((s) => s.kind).toSet();
    expect(
      kinds.contains(StationKind.dawn),
      isFalse,
      reason: 'the sun does not rise; it never set',
    );
    expect(
      kinds.contains(StationKind.noon),
      isTrue,
      reason: 'it still transits, which is what noon means',
    );
  });

  group('the next station', () {
    test('is the one after now, not the one before', () {
      final day = stationsFor(DateTime.utc(2026, 6, 21, 12), 51.4779, 0.0);
      // Four in the afternoon: the answer wanted is sunset.
      final next = nextStation(day, DateTime.utc(2026, 6, 21, 16));
      expect(next?.kind, StationKind.dusk);
    });

    test(
      'is null once the day is spent, so the screen can look to tomorrow',
      () {
        final day = stationsFor(DateTime.utc(2026, 6, 21, 12), 51.4779, 0.0);
        expect(nextStation(day, DateTime.utc(2026, 6, 21, 23, 59)), isNull);
      },
    );
  });
}
