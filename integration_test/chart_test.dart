// SPDX-License-Identifier: AGPL-3.0-only
//
// The chart must agree with her own engine.
//
// The app and shrutivtuber.com are two implementations of the same claim, and
// somebody WILL cast the same chart in both. Reference values below come from
// shruti-astro — her AGPL daemon — for 1990-05-04 14:30 in London, which is
// 13:30 UT because British Summer Time applies.
//
// A tenth of a degree is the tolerance. That is far tighter than any reading
// depends on and far looser than a real disagreement would be: a wrong flag or
// a dropped leap second moves things by degrees, not by hundredths.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:astrolabe/models/place.dart';
import 'package:astrolabe/services/chart.dart';
import 'package:astrolabe/services/ephemeris.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async => startEphemeris());

  late Chart chart;

  setUpAll(() {
    chart = castChart(when: DateTime(1990, 5, 4, 14, 30), place: Place.london);
  });

  double lon(String name) =>
      chart.bodies.firstWhere((b) => b.name == name).longitude;

  group('positions agree with shruti-astro', () {
    const expected = {
      'Sun': 43.8259,
      'Moon': 165.7280,
      'Mercury': 42.9115,
      'Saturn': 295.3388,
      'Rahu': 311.9183,
      'Ketu': 131.9183,
    };
    expected.forEach((name, want) {
      test(name, () => expect(lon(name), closeTo(want, 0.1)));
    });
  });

  test('the angles agree too', () {
    // These are the values that depend on the birth TIME and PLACE rather than
    // only the date, so they are the ones that catch a timezone mistake. An
    // hour out moves the ascendant about fifteen degrees.
    expect(chart.ascendant, closeTo(162.1595, 0.1));
    expect(chart.midheaven, closeTo(66.5315, 0.1));
  });

  test('a wall clock is read in the PLACE, not in UTC', () {
    // The same reading an hour earlier must give a different chart. If the
    // zone were ignored this would come back identical, and every angle would
    // be quietly an hour wrong.
    final earlier = castChart(
      when: DateTime(1990, 5, 4, 13, 30),
      place: Place.london,
    );
    expect((earlier.ascendant! - chart.ascendant!).abs(), greaterThan(5));
  });

  test('Mercury is retrograde, and says so', () {
    final m = chart.bodies.firstWhere((b) => b.name == 'Mercury');
    expect(m.retrograde, isTrue);
    expect(chart.bodies.firstWhere((b) => b.name == 'Sun').retrograde, isFalse);
  });

  test('Ketu is exactly opposite Rahu — derived, never computed twice', () {
    expect((lon('Ketu') - lon('Rahu') + 360) % 360, closeTo(180, 1e-9));
  });

  group('whole sign houses', () {
    test('the ascendant sign is the first house, entire', () {
      // ASC 162.16 is Virgo (150–180), so Virgo is house 1.
      expect(chart.risingSign, 5);
      expect(chart.houseOf(150.0), 1);
      expect(chart.houseOf(179.99), 1);
      expect(chart.houseOf(180.0), 2);
    });

    test('houses wrap the long way round', () {
      expect(chart.houseOf(149.99), 12);
      expect(chart.houseOf(0.0), 8); // Aries, eight signs on from Virgo
    });
  });

  group('an unknown birth time', () {
    late Chart vague;
    setUpAll(() {
      vague = castChart(
        when: DateTime(1990, 5, 4),
        place: Place.london,
        timeKnown: false,
      );
    });

    test('leaves the angles undefined rather than guessing', () {
      // A fabricated ascendant looks exactly as authoritative as a real one,
      // which is what makes it worse than none.
      expect(vague.ascendant, isNull);
      expect(vague.midheaven, isNull);
      expect(vague.risingSign, isNull);
      expect(vague.houseOf(100), isNull);
    });

    test('still gives every planet a sign', () {
      expect(vague.bodies.length, 12);
      // Noon, so the Sun is close to where it was at 14:30 but not identical.
      expect(vague.bodies.first.longitude, closeTo(43.7, 0.3));
    });
  });
}
