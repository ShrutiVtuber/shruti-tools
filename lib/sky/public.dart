// SPDX-License-Identifier: AGPL-3.0-only
//
// The sky, from public-domain theory rather than from a licensed library.
//
// ⚠ **This exists because AGPL software cannot be distributed through Apple's
// App Store.** Apple's terms impose restrictions the GPL family forbids adding,
// and the Swiss Ephemeris belongs to its own authors rather than to her, so
// no permission of hers can cover it. Everything here — VSOP87 for the planets,
// the abridged lunar theory for the Moon — is published theory under no
// software licence at all.
//
// ⚠ **Temporary. Written to be deleted.** When the Swiss Ephemeris commercial
// licence is bought, iOS returns to the same engine as Android and this whole
// directory comes out. Nothing above `Sky` may depend on which engine answered.
//
// How accurate, measured against shrutivtuber.com's own engine across
// 1800–2100 and 108 moments:
//
//   Sun        5"      Jupiter    1"      ascendant   2-7"  (four latitudes)
//   Mercury    7"      Saturn     1"      true node   43"
//   Venus      6"      Mars       3"      Moon        3" to 2050
//
// ⚠ The Moon after about 2050 is a different matter, and it is not this
// theory's fault: see the note on `begin`.
import 'angles.dart';
import 'moon.dart';
import 'planets.dart';
import 'sky.dart';
import 'time.dart';

class PublicSky implements Sky {
  const PublicSky();

  @override
  Future<void> begin() async {
    // ⚠ Nothing to load, and that is the point. No data files, no native
    // library, no asset path to get wrong — the theory is the code.
    //
    // ⚠ The one honest caveat, recorded here because there is nowhere better:
    // beyond about 2050 this engine and the Swiss Ephemeris disagree about ΔT,
    // the difference between atomic time and the Earth's actual rotation. ΔT is
    // MEASURED, not derived, so every model's future is a guess — and the two
    // guess differently, by a couple of minutes by 2100. The Moon moves half an
    // arcsecond a second, so that shows up as the Moon drifting to about an
    // arcminute from where the site puts it.
    //
    // Nothing before 2050 is affected, which is every birth chart anybody
    // casting one will have, and every sky anyone will look at for a while.
  }

  @override
  double julianDay(DateTime utc) => julianDayFromUtc(utc);

  @override
  DateTime instant(double jd) => instantFromJulianDay(jd);

  @override
  Placed at(double jd, Body body) {
    final longitudeAt = _longitude(body);
    return Placed(longitude: longitudeAt(jd), speed: speedOf(longitudeAt, jd));
  }

  /// The one function that knows which theory answers for which body.
  double Function(double) _longitude(Body body) => switch (body) {
    Body.sun => sunLongitude,
    Body.moon => moonLongitude,
    Body.rahu => trueNode,
    // ⚠ The planets share one series evaluator and differ only by their
    // tables, so there is no per-planet code to get wrong.
    _ => (jd) => planetLongitude(body.label, jd),
  };

  @override
  double ascendant(double jd, double lat, double lon) =>
      ascendantAt(jd, lat, lon);

  @override
  double? turn(
    double jd,
    Turn which,
    double lat,
    double lon, {
    bool refracted = true,
  }) {
    if (which == Turn.transit) {
      // ⚠ Not implemented, and it says so rather than returning something
      // plausible. Nothing in this app asks for the Sun's culmination; the
      // stations screen asks only for rise and set. A wrong answer here would
      // be worse than none.
      return null;
    }
    return sunTurn(
      jd,
      sunLongitude,
      lat: lat,
      lon: lon,
      rising: which == Turn.rise,
      refracted: refracted,
    );
  }
}
