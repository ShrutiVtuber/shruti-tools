// SPDX-License-Identifier: AGPL-3.0-only
//
// The sky across a span of days, computed here.
//
// ⚠ **On the device, not from the site.** The website's period wheel asks the
// ephemeris daemon for a month of positions; this app already carries Swiss
// Ephemeris and can work it out itself. So the writing desk draws a full month
// on a train with no signal, which is the whole reason the instruments are on
// the phone in the first place.
//
// ⚠ It must AGREE with the site. Same bodies, same daily instant (midnight UT),
// same events — a reading written on the phone and the same reading opened on
// the website must be about the same sky.
import 'dart:math' as math;

import 'package:sweph/sweph.dart';

import '../models/place.dart';
import 'chart.dart';
import 'events.dart';

/// One day's worth: where each body was at midnight, and the Moon's phase.
class SkyDay {
  const SkyDay({
    required this.date,
    required this.longitudes,
    required this.lit,
  });

  /// ISO date, so it lines up with the site's rows exactly.
  final String date;

  /// Body name → ecliptic longitude at midnight UT.
  final Map<String, double> longitudes;

  /// The Moon's illuminated fraction, 0..1.
  final double lit;
}

/// Which bodies the period wheel draws, outermost band first.
const periodBodies = [
  'Saturn',
  'Jupiter',
  'Mars',
  'Venus',
  'Mercury',
  'Sun',
  'Moon',
];

const _swe = {
  'Sun': HeavenlyBody.SE_SUN,
  'Moon': HeavenlyBody.SE_MOON,
  'Mercury': HeavenlyBody.SE_MERCURY,
  'Venus': HeavenlyBody.SE_VENUS,
  'Mars': HeavenlyBody.SE_MARS,
  'Jupiter': HeavenlyBody.SE_JUPITER,
  'Saturn': HeavenlyBody.SE_SATURN,
};

double _julian(DateTime utc) => Sweph.swe_julday(
  utc.year,
  utc.month,
  utc.day,
  utc.hour + utc.minute / 60 + utc.second / 3600,
  CalendarType.SE_GREG_CAL,
);

/// The days between two dates, inclusive of both.
///
/// ⚠ **Midnight UT**, matching the site's default. Noon would move the Moon
/// about seven degrees, which is a quarter of a sign — enough for the two to
/// disagree about which sign it was in on a given day.
List<SkyDay> skyAcross(DateTime from, DateTime to) {
  final out = <SkyDay>[];
  var day = DateTime.utc(from.year, from.month, from.day);
  final last = DateTime.utc(to.year, to.month, to.day);

  // ⚠ A year is 365 calls per body and the guard is what stops a mistyped
  // range from asking for a century. It is deliberately just past a year: the
  // wheel thins its phase ring rather than refusing long periods, so a year
  // has to be computable.
  var guard = 0;
  while (!day.isAfter(last) && guard < 400) {
    guard++;
    final jd = _julian(day);
    final flags = SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED;

    final longitudes = <String, double>{};
    for (final entry in _swe.entries) {
      final c = Sweph.swe_calc_ut(jd, entry.value, flags);
      longitudes[entry.key] = (c.longitude % 360 + 360) % 360;
    }

    // The illuminated fraction, from the elongation. A phase angle of 0 is
    // new and 180 is full, and the lit fraction is (1 - cos)/2 of it.
    final sun = longitudes['Sun']!;
    final moon = longitudes['Moon']!;
    final elongation = ((moon - sun) % 360 + 360) % 360;
    final lit = (1 - math.cos(elongation * math.pi / 180)) / 2;

    out.add(
      SkyDay(
        date: day.toIso8601String().substring(0, 10),
        longitudes: longitudes,
        lit: lit,
      ),
    );
    day = day.add(const Duration(days: 1));
  }
  return out;
}

/// What happens inside the span — the same events the site lists.
List<SkyEvent> eventsAcross(DateTime from, DateTime to) =>
    eventsBetween(from, to);

/// The chart at the start of the period, for the rising sign's houses.
Chart chartAtStart(DateTime from, Place place) => castChart(
  when: DateTime.utc(from.year, from.month, from.day, 12),
  place: place,
);
