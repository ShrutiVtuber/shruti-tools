// SPDX-License-Identifier: AGPL-3.0-only
//
// The sky moving through a period — the phone's copy of the website's wheel.
//
// ⚠ **The same figure, deliberately.** Same radii, same bands, same colours,
// same marks, same two answers for the Moon. Somebody who writes at a desk and
// then on a train must be looking at the same drawing, or the second one is a
// different instrument wearing the first one's clothes.
//
// The Moon is answered TWICE, because it is two questions:
//   - WHERE it is — its glyph on a track, so its sign reads like everything
//     else's.
//   - WHAT PHASE — the inner ring, which is a clock of the period's DAYS. One
//     drawn disc per day, so the waxing and waning is a shape at a glance.
//
// ⚠ House numbers rotate with the rising sign. That rotation is the whole
// reason a reading for Leo differs from the same sky read for Aries.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/chart.dart' show signGlyphs;
import '../services/events.dart';
import '../services/period_sky.dart';
import '../theme/tokens.dart';

/// Cold to warm, in band order — the same seven as the site.
const _hue = {
  'Saturn': Color(0xFF7C86A8),
  'Jupiter': Color(0xFF6E93C4),
  'Mercury': Color(0xFF86BFD6),
  'Venus': Color(0xFFB9A6D8),
  'Mars': Color(0xFFD98C93),
  'Sun': Color(0xFFE0B978),
  'Moon': Color(0xFF8A93B5),
};

const _glyphs = {
  'Sun': '☉︎',
  'Moon': '☾︎',
  'Mercury': '☿︎',
  'Venus': '♀︎',
  'Mars': '♂︎',
  'Jupiter': '♃︎',
  'Saturn': '♄︎',
};

/// The 2nd, 6th, 8th and 12th cannot see the rising sign.
const _averse = {2, 6, 8, 12};

class PeriodWheelPainter extends CustomPainter {
  PeriodWheelPainter({
    required this.days,
    required this.events,
    required this.rising,
    this.houseNumbers = true,
  });

  final List<SkyDay> days;
  final List<SkyEvent> events;

  /// Which sign begins the wheel, 0..11.
  final int rising;
  final bool houseNumbers;

  double _relative(double longitude) =>
      ((longitude - rising * 30) % 360 + 360) % 360;

  /// See the note at the top of widgets/wheel.dart before touching this.
  Offset _at(double degrees, double radius, Offset c) {
    final a = (180 + degrees) * math.pi / 180;
    return Offset(c.dx + radius * math.cos(a), c.dy - radius * math.sin(a));
  }

  void _text(
    Canvas canvas,
    String s,
    Offset at,
    double size,
    Color tone, {
    String? family,
    FontWeight weight = FontWeight.normal,
    double halo = 0,
  }) {
    // ⚠ Painted twice when haloed: once as a thick stroke in the ground
    // colour, then filled. A glyph landing on its own track and on the one
    // beside it is unreadable without the ground drawn behind it — the website
    // does this with paint-order, which has no equivalent here.
    if (halo > 0) {
      final under = TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            fontFamily: family,
            fontSize: size,
            fontWeight: weight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = halo
              ..strokeJoin = StrokeJoin.round
              ..color = Tone.page,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      under.paint(canvas, at - Offset(under.width / 2, under.height / 2));
    }
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: family,
          fontSize: size,
          color: tone,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  /// Unwrap so 359° → 1° reads as +2 and not −358.
  List<double> _unwrapped(List<double> longitudes) {
    final out = <double>[];
    var turns = 0.0;
    for (var i = 0; i < longitudes.length; i++) {
      if (i > 0) {
        final step = longitudes[i] - longitudes[i - 1];
        // A day's real motion is never near 180°, so a jump that big is a wrap.
        if (step < -180) {
          turns += 360;
        } else if (step > 180) {
          turns -= 360;
        }
      }
      out.add(longitudes[i] + turns);
    }
    return out;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (days.length < 2) return;
    final r = math.min(size.width, size.height) / 2;
    final c = Offset(size.width / 2, size.height / 2);

    // ⚠ The website draws this in a 200-unit box with R = 100, so every size
    // it names is that value × r / 100. Getting the conversion wrong halves
    // every stroke and every glyph, which is exactly the "unreadably small"
    // wheel she sent back the first time — so: `u(n)`, once, for all of them.
    double u(double n) => n * r / 100;

    final hair = Paint()
      ..color = Tone.line
      ..strokeWidth = u(0.4)
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(c, r * 0.96, hair);
    canvas.drawCircle(c, r * 0.80, hair);
    // ⚠ The spokes terminate HERE. Without this circle they end in mid-air.
    canvas.drawCircle(c, r * 0.42, hair);
    canvas.drawCircle(
      c,
      r * 0.35,
      Paint()
        ..color = Tone.line.withValues(alpha: 0.5)
        ..strokeWidth = u(0.25)
        ..style = PaintingStyle.stroke,
    );

    // Signs, houses, and the aversions.
    for (var i = 0; i < 12; i++) {
      final deg = i * 30.0;
      canvas.drawLine(
        _at(deg, r * 0.42, c),
        _at(deg, r * 0.96, c),
        Paint()
          ..color = Tone.line
          ..strokeWidth = u(0.3),
      );
      final sign = (rising + i) % 12;
      final house = i + 1;
      final dim = _averse.contains(house);
      _text(
        canvas,
        signGlyphs[sign],
        _at(deg + 15, r * 0.88, c),
        u(8),
        dim ? Tone.faint.withValues(alpha: 0.5) : Tone.soft,
        family: 'AstroSymbols',
      );
      if (houseNumbers) {
        _text(
          canvas,
          '$house',
          _at(deg + 15, r * 0.47, c),
          u(5),
          dim ? Tone.faint.withValues(alpha: 0.5) : Tone.faint,
        );
      }
    }

    // ── the walks ────────────────────────────────────────────────────────
    final present = periodBodies
        .where((b) => days.first.longitudes.containsKey(b))
        .toList();
    const bandOuter = 0.76, bandInner = 0.47;

    final ends = <({String name, double angle, double radius})>[];

    for (var i = 0; i < present.length; i++) {
      final name = present[i];
      final band = present.length <= 1
          ? bandOuter
          : bandOuter - (bandOuter - bandInner) * (i / (present.length - 1));
      final path = _unwrapped([for (final d in days) d.longitudes[name] ?? 0]);
      final laps = (path.last - path.first).abs() / 360;
      // A body that laps cannot be one arc without landing on its own tail.
      final spiral = laps > 0.98;
      final hue = _hue[name] ?? Tone.accent;

      final line = Path();
      for (var k = 0; k < path.length; k++) {
        final along = k / (path.length - 1);
        final radius =
            r * (spiral ? band - 0.07 * along * math.min(1, laps) : band);
        final p = _at(_relative(path[k]), radius, c);
        k == 0 ? line.moveTo(p.dx, p.dy) : line.lineTo(p.dx, p.dy);
      }
      final stroke = Paint()
        ..color = hue
        ..strokeWidth = u(name == 'Moon' ? 1.2 : 1.5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      if (name == 'Moon') {
        // Dashed, so a lap of the whole zodiac never reads as one more planet
        // quietly having an enormous month.
        _dashed(canvas, line, stroke, u(2.5), u(2));
      } else {
        canvas.drawPath(line, stroke);
      }

      // Where it began — hollow, against the filled glyph at the other end.
      final start = _at(_relative(path.first), r * band, c);
      canvas.drawCircle(start, u(1.5), Paint()..color = Tone.page);
      canvas.drawCircle(
        start,
        u(1.5),
        Paint()
          ..color = hue
          ..strokeWidth = u(0.8)
          ..style = PaintingStyle.stroke,
      );

      // ⚠ Not the Moon's ingresses: it crosses a sign every two and a half
      // days, so thirteen ticks a month across the busiest band — and its
      // track laps the zodiac anyway, so every boundary is crossed by
      // definition and marking them says nothing.
      if (name != 'Moon') {
        for (final e in events.where(
          (e) => e.body == name && e.kind == EventKind.ingress,
        )) {
          final lon = (e.sign ?? 0) * 30.0;
          canvas.drawLine(
            _at(_relative(lon), r * band - u(1.5), c),
            _at(_relative(lon), r * band + u(1.5), c),
            Paint()
              ..color = Tone.ink
              ..strokeWidth = u(1.2),
          );
        }
      }

      for (final e in events.where(
        (e) =>
            e.body == name &&
            (e.kind == EventKind.retrograde || e.kind == EventKind.direct),
      )) {
        final lon = (e.sign ?? 0) * 30.0;
        final at = _at(_relative(lon), r * band, c);
        final back = e.kind == EventKind.retrograde;
        canvas.drawCircle(at, u(3.2), Paint()..color = Tone.page);
        canvas.drawCircle(
          at,
          u(3.2),
          Paint()
            ..color = back ? Tone.rose : Tone.ink
            ..strokeWidth = u(back ? 1.1 : 0.9)
            ..style = PaintingStyle.stroke,
        );
        _text(
          canvas,
          back ? '℞' : 'D',
          at,
          u(3.6),
          Tone.ink,
          weight: FontWeight.w700,
        );
      }

      final endRadius = spiral ? band - 0.07 * math.min(1, laps) : band;
      ends.add((
        name: name,
        angle: _relative(path.last),
        radius: r * endRadius,
      ));
    }

    // ⚠ Glyphs on adjacent bands collide — five units apart, nine tall. Nudged
    // apart along their own tracks, and joined back by a leader so the nudge
    // never lies about a position.
    final shown = {for (final e in ends) e.name: e.angle};
    const minAngle = 11.0;
    final minRadius = u(8);
    for (var pass = 0; pass < 30; pass++) {
      var moved = false;
      for (var i = 0; i < ends.length; i++) {
        for (var j = i + 1; j < ends.length; j++) {
          final a = ends[i], b = ends[j];
          if ((a.radius - b.radius).abs() >= minRadius) continue;
          var gap = shown[b.name]! - shown[a.name]!;
          while (gap > 180) {
            gap -= 360;
          }
          while (gap < -180) {
            gap += 360;
          }
          if (gap.abs() >= minAngle) continue;
          final push = (minAngle - gap.abs()) / 2 * (gap < 0 ? -1 : 1);
          shown[a.name] = shown[a.name]! - push;
          shown[b.name] = shown[b.name]! + push;
          moved = true;
        }
      }
      if (!moved) break;
    }

    for (final e in ends) {
      final hue = _hue[e.name] ?? Tone.accent;
      final trueAt = _at(e.angle, e.radius, c);
      final glyphAt = _at(shown[e.name]!, e.radius, c);
      if ((shown[e.name]! - e.angle).abs() > 0.25) {
        canvas.drawLine(
          trueAt,
          glyphAt,
          Paint()
            ..color = hue.withValues(alpha: 0.7)
            ..strokeWidth = u(0.35),
        );
      }
      _text(
        canvas,
        _glyphs[e.name] ?? e.name[0],
        glyphAt,
        u(9),
        hue,
        family: 'AstroSymbols',
        weight: FontWeight.w600,
        halo: u(1.6),
      );
    }

    // ── the Moon's phases, as a clock of days ────────────────────────────
    // ⚠ This ring is TIME, not longitude. First day at the top, clockwise.
    final phaseR = r * 0.30;
    final disc = u(2.6);
    // ⚠ Thinned when there are more days than the ring can hold. A disc is 2.6
    // units across a ring of circumference 2π×30 ≈ 188, so about thirty-six fit
    // before they overlap. A year is 365, and drawn un-thinned it is not a ring
    // of phases at all — it is a grey smear. The angle comes from the ORIGINAL
    // index, so thinning changes the spacing and never the dates.
    const ringDiscs = 36;
    final step = math.max(1, (days.length / ringDiscs).ceil());
    for (var i = 0; i < days.length; i += step) {
      final angle = 90 - (i / days.length) * 360;
      final at = _at(angle, phaseR, c);
      final lit = days[i].lit;
      final waxing = i == 0 ? true : days[i].lit >= days[i - step].lit;
      _moon(canvas, at, disc, lit, waxing);
    }

    // ⚠ The new and full moons ticked on the ring itself. Without them the
    // ring is a gradient of discs and the reader has to decide by eye which
    // one is exactly full — the one date a monthly reading is hung on.
    final firstDay = DateTime.parse(days.first.date);
    for (final e in events.where(
      (e) => e.kind == EventKind.newMoon || e.kind == EventKind.fullMoon,
    )) {
      final i = e.at.toUtc().difference(firstDay).inHours / 24;
      if (i < 0 || i > days.length) continue;
      final angle = 90 - (i / days.length) * 360;
      canvas.drawLine(
        _at(angle, phaseR + u(4), c),
        _at(angle, phaseR + u(7), c),
        Paint()
          ..color = Tone.ink
          ..strokeWidth = u(0.9),
      );
    }
  }

  /// One moon, drawn rather than glyphed.
  ///
  /// ⚠ Not a character. ☾ renders from whatever font the device has and is one
  /// shape for eight states; a drawn disc says how full it actually is.
  void _moon(Canvas canvas, Offset at, double r, double lit, bool waxing) {
    canvas.drawCircle(at, r, Paint()..color = Tone.page);
    canvas.drawCircle(
      at,
      r,
      Paint()
        ..color = Tone.lineStrong
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );

    final light = Paint()..color = Tone.soft;
    final dark = Paint()..color = Tone.page;

    // The lit half.
    final half = Path()
      ..moveTo(at.dx, at.dy - r)
      ..arcToPoint(
        Offset(at.dx, at.dy + r),
        radius: Radius.circular(r),
        clockwise: waxing,
      )
      ..close();
    canvas.drawPath(half, light);

    // The terminator: an ellipse whose width is how far from half it is,
    // adding to the lit half when gibbous and taking from it when crescent.
    final k = (1 - 2 * lit).abs() * r;
    final gibbous = lit > 0.5;
    final term = Path()
      ..moveTo(at.dx, at.dy - r)
      ..arcToPoint(
        Offset(at.dx, at.dy + r),
        radius: Radius.elliptical(k < 0.01 ? 0.01 : k, r),
        clockwise: gibbous == waxing ? false : true,
      )
      ..close();
    canvas.drawPath(term, gibbous ? light : dark);
  }

  void _dashed(Canvas canvas, Path path, Paint paint, double on, double off) {
    for (final metric in path.computeMetrics()) {
      var at = 0.0;
      while (at < metric.length) {
        final next = math.min(at + on, metric.length);
        canvas.drawPath(metric.extractPath(at, next), paint);
        at = next + off;
      }
    }
  }

  @override
  bool shouldRepaint(PeriodWheelPainter old) =>
      old.rising != rising ||
      old.days.length != days.length ||
      old.events.length != events.length ||
      (days.isNotEmpty &&
          old.days.isNotEmpty &&
          old.days.first.date != days.first.date);
}
