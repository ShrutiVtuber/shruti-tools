// SPDX-License-Identifier: AGPL-3.0-only
//
// The sky, asked of the Swiss Ephemeris.
//
// ⚠ **This is the Android implementation, and the reference the other one is
// measured against.** It wraps the library the app has always used; nothing
// about its answers changes by being behind an interface.
//
// ⚠ **It must not be compiled into the iOS build.** Apple's App Store terms
// impose restrictions the AGPL forbids adding, and the Swiss Ephemeris is
// Astrodienst's rather than hers, so no exception of hers can cover it. A
// runtime switch is not enough: a package listed in pubspec.yaml has its pod
// compiled in whether or not anything calls it. The iOS variant removes the
// dependency, which removes this file with it.
import 'package:sweph/sweph.dart';

import '../services/ephemeris.dart' show startEphemeris;
import 'sky.dart';

/// What the library calls each of the bodies she reads.
const _swiss = <Body, HeavenlyBody>{
  Body.sun: HeavenlyBody.SE_SUN,
  Body.moon: HeavenlyBody.SE_MOON,
  Body.mercury: HeavenlyBody.SE_MERCURY,
  Body.venus: HeavenlyBody.SE_VENUS,
  Body.mars: HeavenlyBody.SE_MARS,
  Body.jupiter: HeavenlyBody.SE_JUPITER,
  Body.saturn: HeavenlyBody.SE_SATURN,
  // ⚠ TRUE, not mean. The two differ by up to 1.8° and can disagree about
  // which sign Rahu is in; the site was corrected to match on 11 September.
  Body.rahu: HeavenlyBody.SE_TRUE_NODE,
};

class SwissSky implements Sky {
  const SwissSky();

  @override
  Future<void> begin() => startEphemeris();

  @override
  double julianDay(DateTime utc) {
    final jd = Sweph.swe_utc_to_jd(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second + utc.millisecond / 1000,
      CalendarType.SE_GREG_CAL,
    );
    // [TT, UT1]. Positions are asked for in UT.
    return jd[1];
  }

  @override
  DateTime instant(double jd) {
    final d = Sweph.swe_revjul(jd, CalendarType.SE_GREG_CAL);
    return DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second);
  }

  @override
  Placed at(double jd, Body body) {
    // ⚠ SEFLG_SPEED always. The library fills the speed slot only when asked,
    // and leaves it zero otherwise — which reads as "not retrograde" for every
    // body that is.
    final c = Sweph.swe_calc_ut(
      jd,
      _swiss[body]!,
      SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED,
    );
    return Placed(
      longitude: (c.longitude % 360 + 360) % 360,
      speed: c.speedInLongitude,
    );
  }

  @override
  double ascendant(double jd, double lat, double lon) =>
      Sweph.swe_houses(jd, lat, lon, Hsys.W).ascmc[0];

  @override
  double? turn(
    double jd,
    Turn which,
    double lat,
    double lon, {
    bool refracted = true,
  }) {
    final what = switch (which) {
      Turn.rise => RiseSetTransitFlag.SE_CALC_RISE,
      Turn.set => RiseSetTransitFlag.SE_CALC_SET,
      Turn.transit => RiseSetTransitFlag.SE_CALC_MTRANSIT,
    };
    try {
      return Sweph.swe_rise_trans(
        jd,
        HeavenlyBody.SE_SUN,
        SwephFlag.SEFLG_SWIEPH,
        refracted ? what : (what | RiseSetTransitFlag.SE_BIT_NO_REFRACTION),
        GeoPosition(lon, lat, 0),
        0, // atmospheric pressure: 0 means "use the standard"
        0, // temperature, likewise
      );
    } catch (_) {
      // ⚠ Null rather than a throw: above the Arctic circle the Sun does not
      // always rise, and that is a fact about the latitude, not a failure.
      return null;
    }
  }
}
