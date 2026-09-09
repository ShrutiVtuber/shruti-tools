// SPDX-License-Identifier: AGPL-3.0-only
//
// Planetary hours.
//
// The day from sunrise to sunset is divided into twelve equal parts and the
// night into twelve more, so an "hour" is sixty minutes twice a year and
// something else the rest of the time. In an English December a day hour is
// about forty minutes and a night hour about eighty.
//
// The first hour of the day belongs to the planet the day is named for, and
// the rest follow the Chaldean order — Saturn, Jupiter, Mars, Sun, Venus,
// Mercury, Moon — wrapping round. Twenty-four hours is three full turns of a
// seven-step cycle plus three, which is exactly why the day rulers advance the
// way they do: Sunday, Monday, Tuesday is ☉ ☾ ♂, three apart each time.
import 'stations.dart';

/// The Chaldean order: slowest apparent motion to fastest.
const chaldean = [
  'Saturn',
  'Jupiter',
  'Mars',
  'Sun',
  'Venus',
  'Mercury',
  'Moon',
];

/// Ruler of each weekday, Monday first to match DateTime.weekday.
const _dayRulers = [
  'Moon', // Monday
  'Mars', // Tuesday
  'Mercury', // Wednesday
  'Jupiter', // Thursday
  'Venus', // Friday
  'Saturn', // Saturday
  'Sun', // Sunday
];

/// One planetary hour.
class PlanetaryHour {
  const PlanetaryHour({
    required this.index,
    required this.ruler,
    required this.from,
    required this.to,
    required this.byDay,
  });

  /// 1–12 within its own half. Not 1–24: the twelfth hour of the day and the
  /// twelfth of the night are both "the twelfth", and numbering them 1–24
  /// loses which half you are in.
  final int index;
  final String ruler;

  /// UTC, both. The screen converts through the place's zone.
  final DateTime from;
  final DateTime to;

  /// Day hours run sunrise to sunset; night hours sunset to the next sunrise.
  final bool byDay;

  /// 1–24 across the whole planetary day, the way her engine and the site
  /// number them. Kept as a view rather than as the stored value, because
  /// "the twelfth hour of the night" is a thing people say and "hour 24" is
  /// not — but an app and a site numbering the same hour differently is worse
  /// than either choice.
  int get displayIndex => byDay ? index : index + 12;

  Duration get length => to.difference(from);
  bool contains(DateTime instant) {
    final t = instant.toUtc();
    return !t.isBefore(from) && t.isBefore(to);
  }
}

/// The twenty-four hours of the planetary day containing [when].
///
/// A planetary day begins at SUNRISE, not at midnight. Someone checking at one
/// in the morning is still in yesterday's night hours, and telling them
/// otherwise is the single most common way this is got wrong.
///
/// Returns an empty list where the sun does not rise or set — above the Arctic
/// circle in summer there is no sunset to divide at, and there is no honest
/// answer to give.
List<PlanetaryHour> hoursFor(
  DateTime when,
  double lat,
  double lon, {
  RiseConvention convention = RiseConvention.visibleDisc,
}) {
  final t = when.toUtc();

  DateTime? riseOn(DateTime day) =>
      _pick(day, lat, lon, StationKind.dawn, convention);
  DateTime? setOn(DateTime day) =>
      _pick(day, lat, lon, StationKind.dusk, convention);

  final today = DateTime.utc(t.year, t.month, t.day);
  var sunrise = riseOn(today);

  // Before today's sunrise, the planetary day is still yesterday's.
  if (sunrise == null || t.isBefore(sunrise)) {
    final yesterday = today.subtract(const Duration(days: 1));
    final earlier = riseOn(yesterday);
    if (earlier != null) sunrise = earlier;
  }
  if (sunrise == null) return const [];

  final sunset = setOn(DateTime.utc(sunrise.year, sunrise.month, sunrise.day));
  final nextRise = riseOn(
    DateTime.utc(
      sunrise.year,
      sunrise.month,
      sunrise.day,
    ).add(const Duration(days: 1)),
  );
  if (sunset == null || nextRise == null) return const [];
  if (!sunset.isAfter(sunrise) || !nextRise.isAfter(sunset)) return const [];

  // The ruler belongs to the day the SUNRISE falls on, in local reckoning —
  // which is why the sunrise instant is what gets asked, not `when`.
  final ruler = _dayRulers[(sunrise.toLocal().weekday - 1) % 7];
  var step = chaldean.indexOf(ruler);

  final dayHour = sunset.difference(sunrise) ~/ 12;
  final nightHour = nextRise.difference(sunset) ~/ 12;

  final hours = <PlanetaryHour>[];
  for (var i = 0; i < 12; i++) {
    hours.add(
      PlanetaryHour(
        index: i + 1,
        ruler: chaldean[step % 7],
        from: sunrise.add(dayHour * i),
        to: i == 11 ? sunset : sunrise.add(dayHour * (i + 1)),
        byDay: true,
      ),
    );
    step++;
  }
  for (var i = 0; i < 12; i++) {
    hours.add(
      PlanetaryHour(
        index: i + 1,
        ruler: chaldean[step % 7],
        from: sunset.add(nightHour * i),
        to: i == 11 ? nextRise : sunset.add(nightHour * (i + 1)),
        byDay: false,
      ),
    );
    step++;
  }
  return hours;
}

/// The hour somebody is standing in.
PlanetaryHour? hourNow(List<PlanetaryHour> hours, DateTime instant) {
  for (final h in hours) {
    if (h.contains(instant)) return h;
  }
  return null;
}

DateTime? _pick(
  DateTime day,
  double lat,
  double lon,
  StationKind kind,
  RiseConvention convention,
) {
  final found = stationsFor(
    day.add(const Duration(hours: 12)),
    lat,
    lon,
    convention: convention,
  );
  for (final s in found) {
    if (s.kind == kind) return s.at;
  }
  return null;
}
