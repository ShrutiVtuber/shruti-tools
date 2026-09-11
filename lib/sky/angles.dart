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

/// The degree culminating — the midheaven, in degrees.
///
/// ⚠ Latitude does not enter it. The midheaven is where the meridian crosses
/// the ecliptic, and the meridian is a function of time and longitude only —
/// which is why somebody in Athens and somebody in Cape Town at the same
/// instant share a midheaven and not an ascendant.
double midheavenAt(double jdUt, double lon) {
  final e = obliquity(jdUt) * radians;
  final ramc = turn(siderealTime(jdUt) + lon) * radians;
  return turn(
    math.atan2(math.sin(ramc), math.cos(ramc) * math.cos(e)) * degrees,
  );
}

/// The Sun's altitude above the horizon, in degrees, at [jd].
///
/// ⚠ Everything below is a root of this one function, which is the point. The
/// version this replaces computed rise and set from a transit time and an hour
/// angle, and got a systematic four minutes wrong in both hemispheres —
/// because the Sun's place was read at one instant while the angle was measured
/// from another, and no amount of staring at it made that visible. A crossing
/// of a curve is a thing that can be checked by evaluating the curve.
double sunAltitude(
  double jd,
  double Function(double) sunLongitudeAt, {
  required double lat,
  required double lon,
}) {
  final e = obliquity(jd) * radians;
  final lambda = sunLongitudeAt(jd) * radians;
  final declination = math.asin(math.sin(e) * math.sin(lambda));
  final ra =
      math.atan2(math.cos(e) * math.sin(lambda), math.cos(lambda)) * degrees;
  // Local hour angle: how far west of the meridian the Sun is.
  final h = turn(siderealTime(jd) + lon - ra) * radians;
  final phi = lat * radians;
  return math.asin(
        math.sin(phi) * math.sin(declination) +
            math.cos(phi) * math.cos(declination) * math.cos(h),
      ) *
      degrees;
}

/// How far the Sun is past the meridian, in degrees, folded to (-180, 180].
///
/// Zero at upper transit, ±180 at lower. Rises steadily through the day, so a
/// sign change from negative to positive is a crossing.
double _pastTheMeridian(
  double jd,
  double Function(double) sunLongitudeAt,
  double lon, {
  required bool upper,
}) {
  final e = obliquity(jd) * radians;
  final lambda = sunLongitudeAt(jd) * radians;
  final ra =
      math.atan2(math.cos(e) * math.sin(lambda), math.cos(lambda)) * degrees;
  final h = siderealTime(jd) + lon - ra;
  return turn(h + (upper ? 180 : 0)) - 180;
}

/// ⚠ Ten minutes. Fine enough that no crossing inside a day is stepped over,
/// including the brief dip below the horizon at high latitudes near midsummer,
/// and coarse enough that a day costs 144 evaluations rather than thousands.
const _step = 1 / 144;

/// The first [t] in the UT day at [midnight] where [f] crosses zero upwards.
double? _crossing(double midnight, double Function(double) f) {
  var t0 = midnight;
  var f0 = f(t0);
  for (var i = 1; i <= 144; i++) {
    final t1 = midnight + i * _step;
    final f1 = f(t1);
    if (f0 <= 0 && f1 > 0) {
      // ⚠ Bisection, not Newton: the derivative near a grazing sunrise at high
      // latitude is almost zero, which is where Newton throws the answer into
      // the next week. Forty halvings of ten minutes is well under a second.
      var lo = t0, hi = t1;
      for (var k = 0; k < 40; k++) {
        final mid = (lo + hi) / 2;
        if (f(mid) > 0) {
          hi = mid;
        } else {
          lo = mid;
        }
      }
      return (lo + hi) / 2;
    }
    t0 = t1;
    f0 = f1;
  }
  return null;
}

/// When the Sun rises or sets, or null when it does neither that day.
///
/// ⚠ Null is a real answer. Above the Arctic and Antarctic circles the Sun does
/// not always rise, and a caller that treats null as failure will report a bug
/// on every midsummer in Reykjavík.
///
/// ⚠ The day is the UT day containing [jdUt], which is the website's own
/// convention: for Anchorage on 4 May it reports a sunset at 06:11 UT, the
/// evening before in local terms. Matching it is what makes the app and the
/// site agree.
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
  final h0 = refracted ? -0.8333 : 0.0;
  final midnight = jdUt.floorToDouble() + 0.5;

  double f(double t) {
    final above = sunAltitude(t, sunLongitudeAt, lat: lat, lon: lon) - h0;
    // Rising is the upward crossing; setting is the same curve inverted, so
    // one search serves both.
    return rising ? above : -above;
  }

  return _crossing(midnight, f);
}

/// When the Sun crosses the meridian — noon if [upper], midnight if not.
double sunTransit(
  double jdUt,
  double Function(double) sunLongitudeAt, {
  required double lon,
  required bool upper,
}) {
  final midnight = jdUt.floorToDouble() + 0.5;
  final found = _crossing(
    midnight,
    (t) => _pastTheMeridian(t, sunLongitudeAt, lon, upper: upper),
  );
  // ⚠ A transit always happens; a null here would mean the search stepped over
  // it. Falling back to the start of the day would be a silent wrong answer,
  // so this says so instead.
  if (found == null) {
    throw StateError('no meridian crossing found in the day at $midnight');
  }
  return found;
}
