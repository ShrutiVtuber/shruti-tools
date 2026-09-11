// SPDX-License-Identifier: AGPL-3.0-only
//
// Turning a moment into the numbers an ephemeris wants.
//
// ⚠ **Three different times live in here and they are not interchangeable.**
//
//   UTC   what a clock says; jumps by a leap second now and then
//   UT1   the Earth's actual rotation; what positions are asked for
//   TT    a smooth atomic scale; what the planetary theories are written in
//
// TT − UT1 is ΔT, and it is not small: about 69 seconds now, over two minutes
// in 1800, and unknowable in the future. Getting it wrong moves the Moon by
// half an arcsecond per second of error — which is how a body ends up a
// noticeable distance from where the website puts it, with nothing to say why.
library;

import 'dart:math' as math;

/// Julian day of an instant, treating it as UT1.
///
/// ⚠ The Gregorian calendar, always. This app's dates start in 1800 and the
/// Julian/Gregorian changeover is 1582, so the branch for the old calendar
/// would be dead code that only ever hid a mistake.
double julianDayFromUtc(DateTime utc) {
  var y = utc.year;
  var m = utc.month;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final a = (y / 100).floor();
  final b = 2 - a + (a / 4).floor();
  final day =
      utc.day +
      (utc.hour +
              utc.minute / 60 +
              (utc.second + utc.millisecond / 1000) / 3600) /
          24;
  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      day +
      b -
      1524.5;
}

/// The instant a Julian day names, to the second.
DateTime instantFromJulianDay(double jd) {
  final z = (jd + 0.5).floor();
  final f = jd + 0.5 - z;
  var a = z;
  if (z >= 2299161) {
    final alpha = ((z - 1867216.25) / 36524.25).floor();
    a = z + 1 + alpha - (alpha / 4).floor();
  }
  final b = a + 1524;
  final c = ((b - 122.1) / 365.25).floor();
  final d = (365.25 * c).floor();
  final e = ((b - d) / 30.6001).floor();

  final dayWithFraction = b - d - (30.6001 * e).floor() + f;
  final day = dayWithFraction.floor();
  final month = e < 14 ? e - 1 : e - 13;
  final year = month > 2 ? c - 4716 : c - 4715;

  // ⚠ Rounded to the second, then normalised. Letting DateTime take 59.9999
  // seconds and floor it turns a time one microsecond before midnight into the
  // previous day — which showed up once as an event listed a day early.
  final seconds = ((dayWithFraction - day) * 86400).round();
  return DateTime.utc(year, month, day).add(Duration(seconds: seconds));
}

/// ΔT in seconds: TT − UT1.
///
/// ⚠ **Polynomials, because ΔT is measured rather than derived.** The Earth's
/// rotation is not predictable from theory; it is observed, and the observations
/// are fitted. These are the NASA/Espenak–Meeus fits, which are the standard
/// public-domain expressions and cover −1999 to +3000.
///
/// The app accepts 1800 to 2100. Inside that the fits are good to a second or
/// two, which moves the Moon by about an arcsecond — inside the arcminute the
/// agreement test allows, and far inside anything a reading turns on.
double deltaT(double year) {
  double poly(double t, List<double> c) {
    var out = 0.0;
    for (var i = c.length - 1; i >= 0; i--) {
      out = out * t + c[i];
    }
    return out;
  }

  if (year < 1600) {
    // Only reachable if the date picker is ever widened; kept honest rather
    // than left to extrapolate a fit off its end.
    final u = (year - 1000) / 100;
    return poly(u, [
      1574.2,
      -556.01,
      71.23472,
      0.319781,
      -0.8503463,
      -0.005050998,
      0.0083572073,
    ]);
  }
  if (year < 1700) {
    final t = year - 1600;
    return poly(t, [120, -0.9808, -0.01532, 1 / 7129]);
  }
  if (year < 1800) {
    final t = year - 1700;
    return poly(t, [8.83, 0.1603, -0.0059285, 0.00013336, -1 / 1174000]);
  }
  if (year < 1860) {
    final t = year - 1800;
    return poly(t, [
      13.72,
      -0.332447,
      0.0068612,
      0.0041116,
      -0.00037436,
      0.0000121272,
      -0.0000001699,
      0.000000000875,
    ]);
  }
  if (year < 1900) {
    final t = year - 1860;
    return poly(t, [
      7.62,
      0.5737,
      -0.251754,
      0.01680668,
      -0.0004473624,
      1 / 233174,
    ]);
  }
  if (year < 1920) {
    final t = year - 1900;
    return poly(t, [-2.79, 1.494119, -0.0598939, 0.0061966, -0.000197]);
  }
  if (year < 1941) {
    final t = year - 1920;
    return poly(t, [21.20, 0.84493, -0.076100, 0.0020936]);
  }
  if (year < 1961) {
    final t = year - 1950;
    return poly(t, [29.07, 0.407, -1 / 233, 1 / 2547]);
  }
  if (year < 1986) {
    final t = year - 1975;
    return poly(t, [45.45, 1.067, -1 / 260, -1 / 718]);
  }
  if (year < 2005) {
    final t = year - 2000;
    return poly(t, [
      63.86,
      0.3345,
      -0.060374,
      0.0017275,
      0.000651814,
      0.00002373599,
    ]);
  }
  if (year < 2050) {
    final t = year - 2000;
    return poly(t, [62.92, 0.32217, 0.005589]);
  }
  if (year < 2150) {
    // ⚠ An extrapolation, and it says so. Nobody knows what the Earth will do.
    return -20 + 32 * math.pow((year - 1820) / 100, 2) - 0.5628 * (2150 - year);
  }
  final u = (year - 1820) / 100;
  return -20 + 32 * u * u;
}

/// The decimal year a Julian day falls in — enough for ΔT, which changes slowly.
double yearOf(double jd) => 2000.0 + (jd - 2451545.0) / 365.25;

/// Julian centuries of TT since J2000, from a UT Julian day.
///
/// ⚠ This is where ΔT is applied, and it is the only place. The planetary
/// theories are written in TT; the app asks its questions in UT.
double centuriesTT(double jdUt) =>
    (jdUt + deltaT(yearOf(jdUt)) / 86400 - 2451545.0) / 36525.0;

/// Degrees folded into [0, 360).
double turn(double degrees) => (degrees % 360 + 360) % 360;

const degrees = 180 / math.pi;
const radians = math.pi / 180;
