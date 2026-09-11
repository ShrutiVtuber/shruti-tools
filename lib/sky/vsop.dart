// SPDX-License-Identifier: AGPL-3.0-only
//
// VSOP87: where the planets are, from a series rather than from a data file.
//
// ⚠ **Public domain, and that is the whole point.** VSOP87 is Bretagnon and
// Francou's analytic theory, published openly and reimplemented everywhere. It
// carries no licence that Apple's App Store terms can conflict with, which is
// why the iOS build can ship it and cannot ship the Swiss Ephemeris.
//
// ⚠ **These are the TRUNCATED series.** The full theory runs to tens of
// thousands of terms and is accurate to milliarcseconds over six millennia.
// What is here keeps the terms that matter over 1800–2100 and is good to about
// an arcsecond — which is inside the arcminute the agreement test allows, and
// about sixty times finer than any reading is written to.
//
// ⚠ The numbers are transcription, and transcription is where this kind of
// work goes wrong. Every body is checked against the website's own engine
// across three centuries before it is believed: see
// integration_test/agrees_with_the_website_test.dart.
//
// Each series is a list of terms [A, B, C] evaluated as A·cos(B + C·τ), where τ
// is Julian millennia of TT since J2000. Longitude and latitude come out in
// radians, the radius vector in AU.
library;

import 'dart:math' as math;

/// One VSOP87 series: the terms grouped by power of τ.
typedef Series = List<List<List<double>>>;

/// Sum a series at time [tau] (Julian millennia TT since J2000).
///
/// ⚠ Horner in τ, not a sum of independent groups. The powers run to τ⁵ and at
/// the ends of the range τ is around ±0.3, so the higher groups are small but
/// not negligible — dropping them shows up as a slow drift that looks like a
/// bad epoch rather than a missing term.
double sum(Series series, double tau) {
  var total = 0.0;
  for (var power = series.length - 1; power >= 0; power--) {
    var group = 0.0;
    for (final t in series[power]) {
      group += t[0] * math.cos(t[1] + t[2] * tau);
    }
    total = total * tau + group;
  }
  return total;
}

/// A heliocentric position, as VSOP87 gives it.
class Helio {
  const Helio(this.longitude, this.latitude, this.radius);

  /// Radians.
  final double longitude;

  /// Radians.
  final double latitude;

  /// AU.
  final double radius;
}

/// ⚠ **The published coefficients are in units of 1e-8** — radians for
/// longitude and latitude, AU for the radius vector. Forgetting it is not a
/// small error: the first version of this file did, and every body came out
/// wrong by something like 179 degrees, which reads as a geometry mistake
/// rather than a scale one.
///
/// The check that catches it by eye: Earth's first radius term is 100013989,
/// and the Earth is one astronomical unit from the Sun.
const _unit = 1e-8;

/// Evaluate one planet's three series at [tau].
Helio helio(Series l, Series b, Series r, double tau) =>
    Helio(sum(l, tau) * _unit, sum(b, tau) * _unit, sum(r, tau) * _unit);
