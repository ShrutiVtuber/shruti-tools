// SPDX-License-Identifier: AGPL-3.0-only
//
// A chart, cast on the phone.
//
// Whole sign houses throughout, as everywhere else in her work. The method
// does not change and there is no setting for it: a house system is a claim
// about how the sky is divided, not a preference.
import 'package:sweph/sweph.dart';

import '../models/place.dart';

/// One body, where it is.
class Body {
  const Body({
    required this.name,
    required this.longitude,
    required this.retrograde,
  });

  final String name;

  /// Ecliptic longitude, 0–360, Aries 0° at the vernal point.
  final double longitude;
  final bool retrograde;

  int get signIndex => (longitude ~/ 30) % 12;

  /// Degrees into its own sign.
  double get degreeInSign => longitude % 30;
}

/// What a reading needs from a moment.
class Chart {
  const Chart({
    required this.bodies,
    required this.ascendant,
    required this.midheaven,
    required this.timeKnown,
  });

  final List<Body> bodies;

  /// Null when the birth time is unknown. Not zero, and not a guess: the
  /// ascendant moves a degree every four minutes, so a fabricated one is worse
  /// than an absent one — it looks exactly as authoritative as a real one.
  final double? ascendant;
  final double? midheaven;
  final bool timeKnown;

  /// Whole sign: the ascendant's sign is the first house, entire.
  int? get risingSign => ascendant == null ? null : (ascendant! ~/ 30) % 12;

  /// Which house a longitude falls in, 1–12, or null with no ascendant.
  int? houseOf(double longitude) {
    final rising = risingSign;
    if (rising == null) return null;
    return ((longitude ~/ 30) % 12 - rising + 12) % 12 + 1;
  }
}

/// The bodies a Hellenistic reading uses, in the traditional order.
///
/// The **true** node rather than the mean — where the Moon's path actually
/// crosses the ecliptic. Ketu is derived from Rahu by opposition and never
/// computed separately, so the two cannot disagree with each other.
const _bodies = <String, HeavenlyBody>{
  'Sun': HeavenlyBody.SE_SUN,
  'Moon': HeavenlyBody.SE_MOON,
  'Mercury': HeavenlyBody.SE_MERCURY,
  'Venus': HeavenlyBody.SE_VENUS,
  'Mars': HeavenlyBody.SE_MARS,
  'Jupiter': HeavenlyBody.SE_JUPITER,
  'Saturn': HeavenlyBody.SE_SATURN,
  'Rahu': HeavenlyBody.SE_TRUE_NODE,
};

// ⚠ **No Uranus, Neptune or Pluto, and that is the tradition rather than an
// omission.** Her practice is Hellenistic, which has seven wandering stars and
// the two nodes; the outer three were not known and are not read. Her words,
// 11 September 2026: "we don't track uranus neptune or pluto".
//
// It is also what the website returns — its chart engine offers the seven and
// the nodes in every tradition it accepts — so the app and the site now agree
// about what exists, which they did not before.
//
// They come back as an OPTION, not as a default, if the Swiss Ephemeris is
// ever licensed commercially. Until then the app must not ship that library at
// all: Apple's terms and the AGPL cannot both be satisfied in one binary.

/// Julian day from a UTC instant.
///
/// Through `swe_utc_to_jd`, which applies leap seconds. Building one from
/// calendar fields by hand silently drops that correction — small, and wrong
/// in a way nothing reports.
double _julianDay(DateTime utc) {
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

/// Cast a chart.
///
/// [when] is a wall-clock time in [place] — the way a birth certificate gives
/// it. It is converted to an instant through the place's own zone, which is
/// the only way to get it right: the same clock reading is a different moment
/// in every timezone, and summer time moves it again.
///
/// [timeKnown] false computes the bodies for noon and leaves the angles null.
/// Noon rather than midnight because it halves the worst-case error on the
/// Moon, which is the only body that moves enough for the choice to matter.
Chart castChart({
  required DateTime when,
  required Place place,
  bool timeKnown = true,
}) {
  final local = place.at(
    when.year,
    when.month,
    when.day,
    timeKnown ? when.hour : 12,
    timeKnown ? when.minute : 0,
  );
  final jd = _julianDay(local.toUtc());
  final flags = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED;

  final bodies = <Body>[];
  for (final entry in _bodies.entries) {
    final c = Sweph.swe_calc_ut(jd, entry.value, flags);
    bodies.add(
      Body(
        name: entry.key,
        longitude: (c.longitude % 360 + 360) % 360,
        // The nodes always move backwards; saying so on every chart is noise,
        // so only the planets carry the mark.
        retrograde: c.speedInLongitude < 0 && entry.key != 'Rahu',
      ),
    );
  }

  // Ketu, derived. Opposite Rahu by definition.
  final rahu = bodies.firstWhere((b) => b.name == 'Rahu');
  bodies.add(
    Body(
      name: 'Ketu',
      longitude: (rahu.longitude + 180) % 360,
      retrograde: false,
    ),
  );

  if (!timeKnown) {
    return Chart(
      bodies: bodies,
      ascendant: null,
      midheaven: null,
      timeKnown: false,
    );
  }

  final houses = Sweph.swe_houses(jd, place.lat, place.lon, Hsys.W);
  return Chart(
    bodies: bodies,
    ascendant: houses.ascmc[0],
    midheaven: houses.ascmc[1],
    timeKnown: true,
  );
}

const signNames = [
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
];

const signGlyphs = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];

const bodyGlyphs = <String, String>{
  'Sun': '☉',
  'Moon': '☽',
  'Mercury': '☿',
  'Venus': '♀',
  'Mars': '♂',
  'Jupiter': '♃',
  'Saturn': '♄',
  'Uranus': '♅',
  'Neptune': '♆',
  'Pluto': '♇',
  'Rahu': '☊',
  'Ketu': '☋',
};
