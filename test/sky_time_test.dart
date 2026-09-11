// SPDX-License-Identifier: AGPL-3.0-only
//
// Time, checked against values that are not in dispute.
//
// ⚠ Julian day conversions are the foundation everything else stands on. An
// error here moves every body at once, which reads as "the ephemeris is wrong"
// rather than "the clock is wrong" — so it is worth pinning to arithmetic
// anybody can check by hand.
import 'package:flutter_test/flutter_test.dart';
import 'package:astrolabe/sky/time.dart';

void main() {
  test('the standard epochs come out right', () {
    // J2000.0 is 2000 January 1 at 12:00 TT, JD 2451545.0 — the number every
    // other epoch is defined against.
    expect(
      julianDayFromUtc(DateTime.utc(2000, 1, 1, 12)),
      closeTo(2451545.0, 1e-9),
    );
    // The start of the range this app accepts.
    expect(
      julianDayFromUtc(DateTime.utc(1800, 1, 1)),
      closeTo(2378496.5, 1e-9),
    );
    // Today, checked by counting: 9750 days after J2000 (26 years, 7 of them
    // leap, plus 253 days into 2026).
    expect(
      julianDayFromUtc(DateTime.utc(2026, 9, 11, 12)),
      closeTo(2451545.0 + 9750, 1e-6),
    );
  });

  test('a day is a day', () {
    final a = julianDayFromUtc(DateTime.utc(1955, 3, 14, 7, 23, 11));
    final b = julianDayFromUtc(DateTime.utc(1955, 3, 15, 7, 23, 11));
    expect(b - a, closeTo(1.0, 1e-9));
  });

  test('it survives a round trip, to the second', () {
    // ⚠ Including the awkward ones: the instant before midnight, a leap day,
    // and a date before 1900 where the century correction bites.
    for (final at in [
      DateTime.utc(1800, 1, 1),
      DateTime.utc(1899, 12, 31, 23, 59, 59),
      DateTime.utc(1900, 3, 1),
      DateTime.utc(2000, 2, 29, 12, 30, 45),
      DateTime.utc(2026, 9, 11, 17, 42, 3),
      DateTime.utc(2100, 12, 31, 23, 59, 59),
    ]) {
      final back = instantFromJulianDay(julianDayFromUtc(at));
      expect(
        back.difference(at).inSeconds.abs(),
        lessThanOrEqualTo(1),
        reason: '$at came back as $back',
      );
    }
  });

  test('delta T is roughly right where it is measured', () {
    // ⚠ Not to the millisecond — these are fits to observation, and the point
    // is that the shape is right rather than that a digit matches.
    expect(deltaT(2000), closeTo(63.8, 1.0)); // observed: 63.83s
    expect(deltaT(1900), closeTo(-2.8, 1.5)); // observed: -2.72s
    expect(deltaT(1800), closeTo(13.7, 1.5)); // observed: 13.72s
    expect(deltaT(2026), closeTo(72, 4)); // extrapolated
  });

  test('delta T has no cliffs at the joins', () {
    // ⚠ The polynomials are pieced together at named years. A discontinuity
    // there would move every body by seconds of time as a date crossed it —
    // invisible in a test of one date, obvious in a chart that jumps.
    for (final year in [
      1700,
      1800,
      1860,
      1900,
      1920,
      1941,
      1961,
      1986,
      2005,
      2050,
    ]) {
      final before = deltaT(year - 0.001);
      final after = deltaT(year + 0.001);
      expect(
        (after - before).abs(),
        lessThan(2.0),
        reason: 'delta T jumps by ${(after - before).abs()} seconds at $year',
      );
    }
  });
}
