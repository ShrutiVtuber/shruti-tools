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
import '../sky/current.dart';
import '../sky/sky.dart';

/// One station: what it is, and when.
class Station {
  const Station(this.kind, this.at);

  final StationKind kind;

  /// UTC. The screen converts; the model never guesses a zone.
  final DateTime at;
}

/// Where sunrise IS.
///
/// The traditions disagree and the disagreement is real: about four and a half
/// minutes at Athens, which is enough to move a planetary-hour boundary and
/// therefore enough to change which planet rules the moment you are standing
/// in. Picking one globally silently corrupts the other, so it is carried
/// rather than assumed — the same choice the engine makes, under the same two
/// names.
enum RiseConvention {
  /// Upper limb of the apparent disc, WITH refraction. The standard almanac
  /// sunrise, and the Greco-Egyptian basis for planetary hours.
  visibleDisc('Hellenistic', 'upper limb, with refraction'),

  /// Centre of the disc, NO refraction. What Indian pañcāṅgas print, and what
  /// the Vedic day boundary uses.
  hindu('Vedic', 'centre of the disc, no refraction');

  const RiseConvention(this.label, this.detail);

  final String label;
  final String detail;
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
double _jd(DateTime utc) => sky.julianDay(utc);

/// `swe_revjul` already hands back a DateTime, but a LOCAL one — the fields
/// are UT and the flag is not set. Reading it as local would shift every
/// station by the phone's own offset, which looks entirely plausible and is
/// wrong by hours.
DateTime _fromJd(double jd) => sky.instant(jd);

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
List<Station> stationsFor(
  DateTime when,
  double lat,
  double lon, {
  RiseConvention convention = RiseConvention.visibleDisc,
}) {
  final utc = when.toUtc();
  // Start the search from the previous midnight UT, so a call late in the day
  // still finds today's dawn rather than tomorrow's.
  final from = _jd(DateTime.utc(utc.year, utc.month, utc.day));

  // ⚠ The convention is one flag rather than a library constant: the visible
  // disc (upper limb, refracted), or the centre of the disc with no refraction,
  // which is what the Indian tradition computes with. It applies to rise and
  // set only — a transit has no limb and no refraction in it, and the engine
  // ignores the flag there.
  final refracted = convention != RiseConvention.hindu;

  Station? one(StationKind kind, Turn what) {
    // ⚠ Null rather than a throw is how this reports "it does not happen
    // today" — the circumpolar case, which is a fact about the latitude and
    // not a failure.
    final jd = sky.turn(from, what, lat, lon, refracted: refracted);
    return jd == null ? null : Station(kind, _fromJd(jd));
  }

  final found = <Station>[
    ?one(StationKind.dawn, Turn.rise),
    ?one(StationKind.noon, Turn.noon),
    ?one(StationKind.dusk, Turn.set),
    ?one(StationKind.midnight, Turn.midnight),
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
