// SPDX-License-Identifier: AGPL-3.0-only
//
// The four solar stations of a day, computed here on the phone.
//
// Liber Resh marks sunrise, noon, sunset and midnight. The adorations are hers
// to publish; the arithmetic is the same arithmetic anyone's ephemeris does,
// and doing it on the device means the app works on a train, in a basement,
// and on the day her server is down.
//
// Swiss Ephemeris is asked for the rise and set directly rather than being
// re-implemented. `swe_rise_trans` already accounts for refraction and for the
// sun's disc, which are the two things a hand-rolled version gets wrong — and
// gets wrong by minutes, which is exactly the size of error that makes someone
// miss a dawn without ever realising the table was lying.
import 'package:sweph/sweph.dart';

/// One station: what it is, and when.
class Station {
  const Station(this.kind, this.at);

  final StationKind kind;

  /// UTC. The screen converts; the model never guesses a zone.
  final DateTime at;
}

enum StationKind {
  dawn('Dawn', 'Ra'),
  noon('Noon', 'Hathoor'),
  dusk('Dusk', 'Tum'),
  midnight('Midnight', 'Khephra');

  const StationKind(this.label, this.godform);

  /// What the hour is called.
  final String label;

  /// The form addressed at it. Named here rather than in a screen because two
  /// screens want it and one of them is a notification.
  final String godform;
}

/// Julian day (UT) for an instant.
double _jd(DateTime utc) => Sweph.swe_julday(
  utc.year,
  utc.month,
  utc.day,
  utc.hour + utc.minute / 60 + utc.second / 3600,
  CalendarType.SE_GREG_CAL,
);

/// `swe_revjul` already hands back a DateTime, but a LOCAL one — the fields
/// are UT and the flag is not set. Reading it as local would shift every
/// station by the phone's own offset, which looks entirely plausible and is
/// wrong by hours.
DateTime _fromJd(double jd) {
  final d = Sweph.swe_revjul(jd, CalendarType.SE_GREG_CAL);
  return DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second);
}

/// Sunrise, noon, sunset and midnight for the local day containing [when].
///
/// [lat] north-positive, [lon] EAST-positive. That sign convention is the one
/// Swiss Ephemeris uses and the one the site's API uses; a west longitude
/// entered positive puts a London dawn in the Pacific and the table still
/// looks entirely plausible.
///
/// Returns fewer than four entries above the Arctic and Antarctic circles,
/// where the sun may not rise or set at all. The screen says so rather than
/// printing a blank — a station that does not occur is a fact, not a gap.
List<Station> stationsFor(DateTime when, double lat, double lon) {
  final utc = when.toUtc();
  // Start the search from the previous midnight UT, so a call late in the day
  // still finds today's dawn rather than tomorrow's.
  final from = _jd(DateTime.utc(utc.year, utc.month, utc.day));
  final at = GeoPosition(lon, lat, 0);

  Station? one(StationKind kind, RiseSetTransitFlag what) {
    try {
      final jd = Sweph.swe_rise_trans(
        from,
        HeavenlyBody.SE_SUN,
        SwephFlag.SEFLG_SWIEPH,
        what,
        at,
        0, // atmospheric pressure: 0 means "use the standard"
        0, // temperature, likewise
      );
      // Null rather than a throw is how this reports "it does not happen
      // today" — the circumpolar case, which is a fact about the latitude and
      // not a failure.
      return jd == null ? null : Station(kind, _fromJd(jd));
    } catch (_) {
      return null;
    }
  }

  final found = <Station>[
    ?one(StationKind.dawn, RiseSetTransitFlag.SE_CALC_RISE),
    ?one(StationKind.noon, RiseSetTransitFlag.SE_CALC_MTRANSIT),
    ?one(StationKind.dusk, RiseSetTransitFlag.SE_CALC_SET),
    ?one(StationKind.midnight, RiseSetTransitFlag.SE_CALC_ITRANSIT),
  ];
  found.sort((a, b) => a.at.compareTo(b.at));
  return found;
}

/// The station a person opening the app at this moment actually wants.
///
/// The NEXT one, not the last one: someone checking at four in the afternoon
/// wants "sunset in 2h 14m". If today's are all past, the first of tomorrow.
Station? nextStation(List<Station> today, DateTime now) {
  final utc = now.toUtc();
  for (final s in today) {
    if (s.at.isAfter(utc)) return s;
  }
  return null;
}
