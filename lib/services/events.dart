// SPDX-License-Identifier: AGPL-3.0-only
//
// What the sky does next, found on the phone.
//
// Three kinds, and they are the three an ephemeris is opened for:
//
//   ingress   a body enters a sign
//   station   a body turns retrograde, or turns direct again
//   lunation  new moon and full moon
//
// All three are the same shape of problem: a smooth function crosses a value,
// and the crossing has to be found to the minute rather than to the sampling
// step. So each is a coarse scan for a sign change, then bisection inside the
// bracket. Sixty halvings puts a day-long interval inside a millisecond, which
// is far past anything an ephemeris prints, and the functions here are smooth
// enough that nothing cleverer than halving buys anything.
//
// The same method her engine uses, and the same step sizes: the Moon moves
// thirteen degrees a day and needs a quarter-day step, Jupiter outward can be
// sampled daily without stepping over a sign.
import 'package:sweph/sweph.dart';

import 'chart.dart';

enum EventKind { ingress, retrograde, direct, newMoon, fullMoon }

class SkyEvent {
  const SkyEvent({
    required this.kind,
    required this.at,
    required this.body,
    this.sign,
  });

  final EventKind kind;

  /// UTC. The screen tells it in the reader's place.
  final DateTime at;
  final String body;

  /// The sign entered, for an ingress; the sign it happens in otherwise.
  final int? sign;

  String get title => switch (kind) {
    EventKind.ingress => '$body enters ${signNames[sign!]}',
    EventKind.retrograde => '$body turns retrograde',
    EventKind.direct => '$body turns direct',
    EventKind.newMoon => 'New moon in ${signNames[sign!]}',
    EventKind.fullMoon => 'Full moon in ${signNames[sign!]}',
  };

  String get glyph => switch (kind) {
    EventKind.newMoon => '☽',
    EventKind.fullMoon => '☽',
    _ => bodyGlyphs[body] ?? '',
  };
}

/// How coarsely each body is sampled, in days.
///
/// Small enough that a crossing cannot hide between two samples. The Moon
/// covers thirteen degrees a day, so a half-day step could step clean over a
/// sign boundary and miss the ingress entirely — and missing one looks exactly
/// like there not being one.
const _step = <String, double>{
  'Moon': 0.25,
  'Sun': 0.5,
  'Mercury': 0.5,
  'Venus': 0.5,
  'Mars': 0.5,
  'Jupiter': 1.0,
  'Saturn': 1.0,
  'Uranus': 1.0,
  'Neptune': 1.0,
  'Pluto': 1.0,
};

const _scanned = <String, HeavenlyBody>{
  'Sun': HeavenlyBody.SE_SUN,
  'Moon': HeavenlyBody.SE_MOON,
  'Mercury': HeavenlyBody.SE_MERCURY,
  'Venus': HeavenlyBody.SE_VENUS,
  'Mars': HeavenlyBody.SE_MARS,
  'Jupiter': HeavenlyBody.SE_JUPITER,
  'Saturn': HeavenlyBody.SE_SATURN,
};

double _jd(DateTime utc) => Sweph.swe_julday(
  utc.year,
  utc.month,
  utc.day,
  utc.hour + utc.minute / 60 + utc.second / 3600,
  CalendarType.SE_GREG_CAL,
);

DateTime _at(double jd) {
  final d = Sweph.swe_revjul(jd, CalendarType.SE_GREG_CAL);
  return DateTime.utc(d.year, d.month, d.day, d.hour, d.minute, d.second);
}

double _lon(double jd, HeavenlyBody b) {
  final c = Sweph.swe_calc_ut(jd, b, SwephFlag.SEFLG_SWIEPH);
  return (c.longitude % 360 + 360) % 360;
}

double _speed(double jd, HeavenlyBody b) => Sweph.swe_calc_ut(
  jd,
  b,
  SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED,
).speedInLongitude;

/// A separation folded into (-180, 180].
double _wrapped(double delta) => ((delta + 180) % 360) - 180;

/// Narrow a bracketed sign change to a fraction of a second.
///
/// `f` must already be known to change sign across the interval — this does
/// not search, it only refines, and handed an interval with no crossing it
/// will return a confident answer that means nothing.
double _bisect(double Function(double) f, double lo, double hi) {
  final loNegative = f(lo) < 0;
  for (var i = 0; i < 60; i++) {
    final mid = (lo + hi) / 2;
    if ((f(mid) < 0) == loNegative) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}

/// Everything between two instants, in time order.
List<SkyEvent> eventsBetween(DateTime from, DateTime to) {
  final events = <SkyEvent>[
    ..._ingressesAndStations(from, to),
    ..._lunations(from, to),
  ]..sort((a, b) => a.at.compareTo(b.at));
  return events;
}

List<SkyEvent> _ingressesAndStations(DateTime from, DateTime to) {
  final start = _jd(from.toUtc());
  final end = _jd(to.toUtc());
  final out = <SkyEvent>[];

  for (final entry in _scanned.entries) {
    final name = entry.key;
    final body = entry.value;
    final step = _step[name] ?? 0.5;

    var jd = start;
    var lon = _lon(jd, body);
    var speed = _speed(jd, body);

    while (jd < end) {
      final next = (jd + step).clamp(start, end);
      if (next <= jd) break;
      final nextLon = _lon(next, body);
      final nextSpeed = _speed(next, body);

      // An ingress: the sign index changed across the step.
      final signNow = lon ~/ 30;
      final signNext = nextLon ~/ 30;
      if (signNow != signNext) {
        // WHICH boundary was crossed depends on the direction of travel.
        //
        // Going forwards into Libra, the body crossed 180° — the start of the
        // sign it is entering. Going BACKWARDS out of Libra into Virgo, it
        // crossed 180° as well: the start of the sign it is leaving. Bisecting
        // on the entered sign's start in the retrograde case searches an
        // interval the body never touched, and bisection handed an interval
        // with no crossing returns a confident answer that means nothing.
        //
        // Mercury, Venus and Mars all make retrograde ingresses. The Moon
        // never does, which is why a scan dominated by the Moon can look
        // entirely correct with this wrong.
        final entering = signNext % 12;
        final boundary = ((nextSpeed >= 0 ? signNext : signNow) * 30)
            .toDouble();
        final t = _bisect((x) => _wrapped(_lon(x, body) - boundary), jd, next);
        out.add(
          SkyEvent(
            kind: EventKind.ingress,
            at: _at(t),
            body: name,
            sign: entering % 12,
          ),
        );
      }

      // A station: the speed changed sign. The Sun and Moon never do.
      if (name != 'Sun' && name != 'Moon' && (speed < 0) != (nextSpeed < 0)) {
        final t = _bisect((x) => _speed(x, body), jd, next);
        out.add(
          SkyEvent(
            kind: nextSpeed < 0 ? EventKind.retrograde : EventKind.direct,
            at: _at(t),
            body: name,
            sign: (_lon(t, body) ~/ 30) % 12,
          ),
        );
      }

      jd = next;
      lon = nextLon;
      speed = nextSpeed;
    }
  }
  return out;
}

/// New and full moons.
///
/// Found from the Moon's elongation from the Sun rather than from either body
/// alone: new moon is that difference at zero, full at 180. Scanning the Moon's
/// longitude for a value would find the right instant only by accident, since
/// the Sun has moved too.
List<SkyEvent> _lunations(DateTime from, DateTime to) {
  final start = _jd(from.toUtc());
  final end = _jd(to.toUtc());
  final out = <SkyEvent>[];
  const step = 0.25;

  double elong(double jd) =>
      _wrapped(_lon(jd, HeavenlyBody.SE_MOON) - _lon(jd, HeavenlyBody.SE_SUN));
  // Folded the other way, so the full moon is the zero crossing of THIS.
  double opposition(double jd) => _wrapped(
    _lon(jd, HeavenlyBody.SE_MOON) - _lon(jd, HeavenlyBody.SE_SUN) - 180,
  );

  var jd = start;
  var a = elong(jd);
  var b = opposition(jd);
  while (jd < end) {
    final next = (jd + step).clamp(start, end);
    if (next <= jd) break;
    final aNext = elong(next);
    final bNext = opposition(next);

    // Only a crossing from behind to ahead — the fold makes the other
    // direction a jump from +180 to -180, which is not a conjunction.
    if (a < 0 && aNext >= 0) {
      final t = _bisect(elong, jd, next);
      out.add(
        SkyEvent(
          kind: EventKind.newMoon,
          at: _at(t),
          body: 'Moon',
          sign: (_lon(t, HeavenlyBody.SE_SUN) ~/ 30) % 12,
        ),
      );
    }
    if (b < 0 && bNext >= 0) {
      final t = _bisect(opposition, jd, next);
      out.add(
        SkyEvent(
          kind: EventKind.fullMoon,
          at: _at(t),
          body: 'Moon',
          sign: (_lon(t, HeavenlyBody.SE_MOON) ~/ 30) % 12,
        ),
      );
    }

    jd = next;
    a = aNext;
    b = bNext;
  }
  return out;
}
