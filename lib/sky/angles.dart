// SPDX-License-Identifier: AGPL-3.0-only
//
// Where the sky meets the horizon: the ascendant, and the Sun's comings and
// goings.
//
// ⚠ Whole-sign houses need ONE number — the degree rising. The sign it falls
// in is the first place and the rest follow round the zodiac in order. There
// are no cusps to compute and no house system to choose, which is why this file
// is short and the equivalent in most astrology software is not.
library;

import 'dart:math' as math;

import 'planets.dart' show nutation;
import 'time.dart';

/// The mean obliquity of the ecliptic, in degrees — the tilt of the Earth's
/// axis, which is slowly decreasing.
double obliquity(double jdUt) {
  final t = centuriesTT(jdUt);
  // In arcseconds, from the IAU expression, then folded into degrees.
  final seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * 0.001813));
  return 23 + (26 + seconds / 60) / 60 + nutationInObliquity(jdUt);
}

/// Nutation in obliquity, in degrees — the short form.
double nutationInObliquity(double jdUt) {
  final t = centuriesTT(jdUt);
  final omega = (125.04452 - 1934.136261 * t) * radians;
  final lSun = (280.4665 + 36000.7698 * t) * radians;
  final lMoon = (218.3165 + 481267.8813 * t) * radians;
  return (9.20 * math.cos(omega) +
          0.57 * math.cos(2 * lSun) +
          0.10 * math.cos(2 * lMoon) -
          0.09 * math.cos(2 * omega)) /
      3600;
}

/// Apparent sidereal time at Greenwich, in degrees.
///
/// ⚠ APPARENT, not mean: the equation of the equinoxes is the nutation in
/// longitude projected onto the equator, and leaving it out moves the ascendant
/// by up to about a second of arc — small, and exactly the kind of small that
/// accumulates into a disagreement nobody can explain.
double siderealTime(double jdUt) {
  final t = (jdUt - 2451545.0) / 36525.0;
  final mean =
      280.46061837 +
      360.98564736629 * (jdUt - 2451545.0) +
      0.000387933 * t * t -
      t * t * t / 38710000;
  return turn(mean + nutation(jdUt) * math.cos(obliquity(jdUt) * radians));
}

/// The degree of the ecliptic rising at [lat], [lon] — the ascendant.
///
/// ⚠ The sign convention on longitude is the one trap here: east is positive,
/// which is what this app and the website both use. Getting it backwards moves
/// the ascendant by twice the longitude and is invisible in Greenwich.
double ascendantAt(double jdUt, double lat, double lon) {
  final e = obliquity(jdUt) * radians;
  final phi = lat * radians;
  // Local apparent sidereal time.
  final ramc = turn(siderealTime(jdUt) + lon) * radians;

  // ⚠ atan2 rather than atan: the ascendant is wanted over the whole circle,
  // and the single-argument form collapses two quadrants onto one. That is the
  // classic astrology-software bug where charts are right for half the day.
  final y = math.cos(ramc);
  final x = -(math.sin(ramc) * math.cos(e) + math.tan(phi) * math.sin(e));
  return turn(math.atan2(y, x) * degrees);
}

/// The Sun's declination and equation of time are not needed; rise and set come
/// from its longitude, which the planets file already knows.
///
/// ⚠ Null is a real answer. Above the Arctic and Antarctic circles the Sun does
/// not always rise, and a caller that treats null as failure will report a bug
/// on every midsummer in Reykjavík.
double? sunTurn(
  double jdUt,
  double Function(double) sunLongitudeAt, {
  required double lat,
  required double lon,
  required bool rising,
  bool refracted = true,
}) {
  // ⚠ The standard altitude: the Sun's centre is a little below the horizon
  // when its upper limb appears, because the atmosphere bends the light and
  // the disc has a radius. -0°50' is the convention both engines use.
  final h0 = (refracted ? -0.8333 : 0.0) * radians;
  final phi = lat * radians;

  // Start from local noon of the day [jdUt] falls in and iterate. Three passes
  // is ample: each one lands within a few seconds of the last.
  var guess = jdUt.floorToDouble() + 0.5 - lon / 360;

  for (var pass = 0; pass < 4; pass++) {
    final e = obliquity(guess) * radians;
    final lambda = sunLongitudeAt(guess) * radians;
    final declination = math.asin(math.sin(e) * math.sin(lambda));
    final ra =
        math.atan2(math.cos(e) * math.sin(lambda), math.cos(lambda)) * degrees;

    final cosH =
        (math.sin(h0) - math.sin(phi) * math.sin(declination)) /
        (math.cos(phi) * math.cos(declination));
    // ⚠ Out of range means it never happens today — circumpolar day or night.
    if (cosH < -1 || cosH > 1) return null;

    final hourAngle = math.acos(cosH) * degrees;
    final transit = turn(ra - lon - siderealTime(guess)) / 360;
    var when = guess.floorToDouble() + 0.5 + transit;
    when += (rising ? -hourAngle : hourAngle) / 360;
    guess = when;
  }
  return guess;
}
