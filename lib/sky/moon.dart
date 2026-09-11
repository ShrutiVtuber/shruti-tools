// SPDX-License-Identifier: AGPL-3.0-only
//
// The Moon, and the point where its path crosses the ecliptic.
//
// ⚠ **The Moon is the hardest body in the sky and the one people look at
// most.** It moves half an arcsecond a second, so a mistake in the time reaches
// it before anything else; it is close, so its parallax is enormous compared to
// a planet's; and its orbit is perturbed by the Sun to a degree no other body
// suffers. The abridged theory here is good to about ten arcseconds, which is
// six times finer than the agreement this app is held to.
library;

import 'dart:math' as math;

import 'moon_data.dart';
import 'time.dart';

/// The Moon's fundamental arguments at [t] Julian centuries of TT.
class _Arguments {
  _Arguments(double t)
    : // Mean longitude, referred to the mean equinox of date.
      lPrime = turn(
        218.3164477 +
            481267.88123421 * t -
            0.0015786 * t * t +
            t * t * t / 538841 -
            t * t * t * t / 65194000,
      ),
      // Mean elongation of the Moon from the Sun.
      d = turn(
        297.8501921 +
            445267.1114034 * t -
            0.0018819 * t * t +
            t * t * t / 545868 -
            t * t * t * t / 113065000,
      ),
      // The Sun's mean anomaly.
      m = turn(
        357.5291092 +
            35999.0502909 * t -
            0.0001536 * t * t +
            t * t * t / 24490000,
      ),
      // The Moon's mean anomaly.
      mPrime = turn(
        134.9633964 +
            477198.8675055 * t +
            0.0087414 * t * t +
            t * t * t / 69699 -
            t * t * t * t / 14712000,
      ),
      // Argument of latitude: the Moon's distance from its ascending node.
      f = turn(
        93.2720950 +
            483202.0175233 * t -
            0.0036539 * t * t -
            t * t * t / 3526000 +
            t * t * t * t / 863310000,
      ),
      // ⚠ The eccentricity correction. Terms involving the Sun's anomaly are
      // multiplied by this, because the Earth's orbit is slowly becoming less
      // eccentric. Leaving it out is a fraction of an arcsecond now and grows
      // steadily with distance from 2000.
      e = 1 - 0.002516 * t - 0.0000074 * t * t;

  final double lPrime, d, m, mPrime, f, e;
}

/// The three additive arguments, in degrees.
///
/// ⚠ Venus, Jupiter and the flattening of the Earth, which the main series
/// does not carry. Together they are a few arcseconds — small, and the sort of
/// thing whose absence looks like a slow drift.
({double l, double b}) _additive(double t, _Arguments a) {
  final a1 = turn(119.75 + 131.849 * t);
  final a2 = turn(53.09 + 479264.290 * t);
  final a3 = turn(313.45 + 481266.484 * t);
  return (
    l:
        3958 * math.sin(a1 * radians) +
        1962 * math.sin((a.lPrime - a.f) * radians) +
        318 * math.sin(a2 * radians),
    b:
        -2235 * math.sin(a.lPrime * radians) +
        382 * math.sin(a3 * radians) +
        175 * math.sin((a1 - a.f) * radians) +
        175 * math.sin((a1 + a.f) * radians) +
        127 * math.sin((a.lPrime - a.mPrime) * radians) -
        115 * math.sin((a.lPrime + a.mPrime) * radians),
  );
}

/// The Moon's apparent geocentric ecliptic longitude, in degrees.
double moonLongitude(double jdUt) {
  final t = centuriesTT(jdUt);
  final a = _Arguments(t);

  var sumL = 0.0;
  for (final row in lunarLongitudeAndDistance) {
    final arg = row[0] * a.d + row[1] * a.m + row[2] * a.mPrime + row[3] * a.f;
    // ⚠ The eccentricity correction applies once per power of the Sun's
    // anomaly in the argument, not once per term. Applying it flatly is a
    // mistake that grows with distance from 2000 and is invisible near it.
    final e = switch (row[1].abs()) {
      1 => a.e,
      2 => a.e * a.e,
      _ => 1.0,
    };
    sumL += row[4] * e * math.sin(arg * radians);
  }

  final extra = _additive(t, a);
  final longitude = a.lPrime + (sumL + extra.l) / 1000000;

  // ⚠ Nutation, but NOT aberration. The Moon is close enough that the light
  // time is about a second and a quarter, and the usual annual aberration is
  // already inside the theory's own terms. Adding the planetary correction
  // here would be double-counting — it moves the Moon by 20 arcseconds and
  // looks like a plausible small fix.
  return turn(longitude + _nutationInLongitude(t));
}

/// The Moon's ecliptic latitude, in degrees. Needed for the true node.
double moonLatitude(double jdUt) {
  final t = centuriesTT(jdUt);
  final a = _Arguments(t);

  var sumB = 0.0;
  for (final row in lunarLatitude) {
    final arg = row[0] * a.d + row[1] * a.m + row[2] * a.mPrime + row[3] * a.f;
    final e = switch (row[1].abs()) {
      1 => a.e,
      2 => a.e * a.e,
      _ => 1.0,
    };
    sumB += row[4] * e * math.sin(arg * radians);
  }

  return (sumB + _additive(t, a).b) / 1000000;
}

/// Nutation in longitude, in degrees — the short form.
double _nutationInLongitude(double t) {
  final omega = (125.04452 - 1934.136261 * t) * radians;
  final lSun = (280.4665 + 36000.7698 * t) * radians;
  final lMoon = (218.3165 + 481267.8813 * t) * radians;
  return (-17.20 * math.sin(omega) -
          1.32 * math.sin(2 * lSun) -
          0.23 * math.sin(2 * lMoon) +
          0.21 * math.sin(2 * omega)) /
      3600;
}

/// The Moon's distance from the Earth, in kilometres.
///
/// Needed only to place the Moon in rectangular coordinates, which is what the
/// true node is worked out from.
double moonDistance(double jdUt) {
  final t = centuriesTT(jdUt);
  final a = _Arguments(t);
  var sumR = 0.0;
  for (final row in lunarLongitudeAndDistance) {
    final arg = row[0] * a.d + row[1] * a.m + row[2] * a.mPrime + row[3] * a.f;
    final e = switch (row[1].abs()) {
      1 => a.e,
      2 => a.e * a.e,
      _ => 1.0,
    };
    sumR += row[5] * e * math.cos(arg * radians);
  }
  return 385000.56 + sumR / 1000;
}

/// The TRUE ascending node — in degrees.
///
/// ⚠ **Not "where the Moon's latitude reaches zero".** That was the first
/// version of this function and it is a different thing: the Moon crosses the
/// ecliptic twice a month, and between crossings that definition has no value
/// at all. It came out 1.8 degrees wrong, which looked exactly like the
/// mean-versus-true difference and was not.
///
/// The true node is the ascending node of the Moon's INSTANTANEOUS orbit — the
/// plane it is moving in right now. That plane is fixed by the Moon's position
/// and velocity together, so this takes both and reads the node off the
/// orbital angular momentum: h = r × v points along the pole of the orbit, and
/// the node is a quarter turn from where that pole lies.
///
/// ⚠ The velocity is differenced rather than derived. A symmetric step of an
/// hour is far finer than the arcminute this is held to, and it cannot
/// disagree with the position it is differentiating.
double trueNode(double jdUt) {
  ({double x, double y, double z}) at(double jd) {
    final lon = moonLongitude(jd) * radians;
    final lat = moonLatitude(jd) * radians;
    final r = moonDistance(jd);
    final cosLat = math.cos(lat);
    return (
      x: r * cosLat * math.cos(lon),
      y: r * cosLat * math.sin(lon),
      z: r * math.sin(lat),
    );
  }

  const h = 1 / 24; // one hour
  final before = at(jdUt - h);
  final now = at(jdUt);
  final after = at(jdUt + h);

  final vx = (after.x - before.x) / (2 * h);
  final vy = (after.y - before.y) / (2 * h);
  final vz = (after.z - before.z) / (2 * h);

  // The orbital pole, r × v.
  final hx = now.y * vz - now.z * vy;
  final hy = now.z * vx - now.x * vz;

  // ⚠ atan2(hx, -hy), not atan2(hy, hx). The node lies a quarter turn round
  // from the pole's own direction, and getting that wrong gives a node that is
  // always ninety degrees out — which reads as a completely broken theory
  // rather than as a sign convention.
  return turn(math.atan2(hx, -hy) * degrees);
}
