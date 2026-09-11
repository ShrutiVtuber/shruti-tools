// SPDX-License-Identifier: AGPL-3.0-only
//
// From where a planet is around the Sun, to where it appears from here.
//
// ⚠ **Three corrections separate the two, and leaving any of them out looks
// like a bad ephemeris rather than a missing step.**
//
//   1. The Earth's own position, subtracted — heliocentric to geocentric.
//   2. Light time. A planet is seen where it WAS when the light left it, which
//      for Saturn is over an hour ago and more than a minute of arc.
//   3. Aberration and nutation — the Earth's motion tilts the apparent
//      direction, and the axis wobbles. Together about 20 arcseconds.
//
// The result is apparent geocentric ecliptic longitude of date, which is what
// "tropical longitude" means and what every screen in this app displays.
library;

import 'dart:math' as math;

import 'time.dart';
import 'vsop.dart';
import 'vsop_data.dart';

/// The three series for one body.
class Tables {
  const Tables(this.l, this.b, this.r);
  final Series l;
  final Series b;
  final Series r;
}

const earth = Tables(earthL, earthB, earthR);

const planets = <String, Tables>{
  'Mercury': Tables(mercuryL, mercuryB, mercuryR),
  'Venus': Tables(venusL, venusB, venusR),
  'Mars': Tables(marsL, marsB, marsR),
  'Jupiter': Tables(jupiterL, jupiterB, jupiterR),
  'Saturn': Tables(saturnL, saturnB, saturnR),
};

/// Rectangular ecliptic coordinates from spherical ones.
({double x, double y, double z}) _rect(Helio h) {
  final cosB = math.cos(h.latitude);
  return (
    x: h.radius * cosB * math.cos(h.longitude),
    y: h.radius * cosB * math.sin(h.longitude),
    z: h.radius * math.sin(h.latitude),
  );
}

/// Julian millennia of TT since J2000.
double _tau(double jdUt) => centuriesTT(jdUt) / 10;

/// The nutation in longitude, in degrees.
///
/// ⚠ The short form: the two largest terms of the series, which together are
/// good to about half an arcsecond. The full series has 63 terms and buys
/// hundredths of an arcsecond that nothing here can see.
double nutation(double jdUt) {
  final t = centuriesTT(jdUt);
  // Mean elongation of the Moon from the Sun, and the Moon's ascending node.
  final d = (297.85036 + 445267.111480 * t) * radians;
  final omega = (125.04452 - 1934.136261 * t) * radians;
  final lSun = (280.4665 + 36000.7698 * t) * radians;
  final lMoon = (218.3165 + 481267.8813 * t) * radians;
  return (-17.20 * math.sin(omega) -
          1.32 * math.sin(2 * lSun) -
          0.23 * math.sin(2 * lMoon) +
          0.21 * math.sin(2 * omega) +
          0 * d) /
      3600;
}

/// The Sun's apparent geocentric longitude, in degrees.
///
/// ⚠ The Sun is the Earth's heliocentric position turned round — plus the
/// same light time and aberration every other body gets. Skipping them puts
/// the Sun about 20 arcseconds out, which is small enough to look like
/// rounding and large enough to fail an agreement test.
double sunLongitude(double jdUt) {
  final tau = _tau(jdUt);
  final e = helio(earth.l, earth.b, earth.r, tau);

  // Heliocentric Earth → geocentric Sun.
  var lon = e.longitude * degrees + 180;

  // ⚠ VSOP87 is referred to the dynamical equinox of date; the conversion to
  // the FK5 frame is a fixed small offset. It is a fraction of an arcsecond,
  // and it is here because the website's engine applies it too.
  final t = centuriesTT(jdUt);
  final lPrime = lon - 1.397 * t - 0.00031 * t * t;
  lon +=
      (-0.09033 +
          0.03916 *
              (math.cos(lPrime * radians) + math.sin(lPrime * radians)) *
              math.tan(-e.latitude)) /
      3600;

  // Aberration: the light left the Sun about 8.3 minutes ago, and the Earth
  // has moved since.
  lon += nutation(jdUt) - 20.4898 / 3600 / e.radius;

  return turn(lon);
}

/// A planet's apparent geocentric ecliptic longitude, in degrees.
double planetLongitude(String name, double jdUt) {
  final tables = planets[name]!;
  final tau = _tau(jdUt);
  final earthAt = _rect(helio(earth.l, earth.b, earth.r, tau));

  // ⚠ Light time, solved by iterating rather than guessed. Two passes is
  // plenty: the correction changes the distance by less than the distance
  // changes in the time it takes light to cross it.
  var lightDays = 0.0;
  var lon = 0.0;
  for (var pass = 0; pass < 3; pass++) {
    final at = _tau(jdUt - lightDays);
    final p = _rect(helio(tables.l, tables.b, tables.r, at));
    final dx = p.x - earthAt.x;
    final dy = p.y - earthAt.y;
    final dz = p.z - earthAt.z;
    final distance = math.sqrt(dx * dx + dy * dy + dz * dz);
    // 0.0057755183 days is how long light takes to cross one AU.
    lightDays = 0.0057755183 * distance;
    lon = math.atan2(dy, dx) * degrees;
  }

  return turn(lon + nutation(jdUt) + aberration(lon, jdUt));
}

/// Annual aberration in longitude, in degrees.
///
/// ⚠ **Not a constant.** The first version of this file subtracted a flat
/// 20.49 arcseconds — which is the figure for the SUN, where the geometry
/// happens to make it constant. For a planet the shift depends on the angle
/// between the body and the direction the Earth is travelling, so a flat
/// subtraction is right twice a year and wrong by up to twice itself the rest
/// of the time. It showed as Mars, Jupiter and Saturn all being out by about
/// 41 arcseconds — the same number for three unrelated bodies, which is the
/// shape of a systematic mistake rather than of truncation.
///
/// κ is the constant of aberration; the second term is the small part due to
/// the Earth's orbit being an ellipse rather than a circle.
double aberration(double longitude, double jdUt) {
  const kappa = 20.49552 / 3600;
  final t = centuriesTT(jdUt);
  final sun = sunLongitude(jdUt);
  // Eccentricity of the Earth's orbit, and the longitude of its perihelion.
  final e = 0.016708634 - 0.000042037 * t - 0.0000001267 * t * t;
  final pi = 102.93735 + 1.71946 * t + 0.00046 * t * t;
  return (-kappa * math.cos((sun - longitude) * radians) +
      e * kappa * math.cos((pi - longitude) * radians));
}

/// Degrees per day, by differencing.
///
/// ⚠ Numerically rather than analytically. The series give position; their
/// derivative would be another series to transcribe and another place to be
/// wrong. A symmetric difference over a fraction of a day is accurate to far
/// better than the arcminute this app is held to, and cannot disagree with the
/// position it is differentiating.
double speedOf(double Function(double) longitudeAt, double jd) {
  const h = 0.02; // about half an hour
  final before = longitudeAt(jd - h);
  final after = longitudeAt(jd + h);
  var d = after - before;
  // ⚠ Folded: a body crossing 0° otherwise appears to move 360° in an hour.
  if (d > 180) d -= 360;
  if (d < -180) d += 360;
  return d / (2 * h);
}
