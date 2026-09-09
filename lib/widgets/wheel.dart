// SPDX-License-Identifier: AGPL-3.0-only
//
// The chart wheel.
//
// The geometry is the site's, deliberately: nine o'clock is 0° and the zodiac
// runs ANTICLOCKWISE from there, which is the direction it runs on paper.
// Canvas y grows downward, so the sine is subtracted.
//
// That subtraction is the whole of it, and it is the part that goes wrong.
// `180 - angle` and `180 + angle` both draw a plausible chart; one of them
// runs the zodiac backwards, and the only way to notice is to know that Taurus
// belongs below Aries and to go and look. Two files on the website had it
// inverted for months, both under a comment claiming anticlockwise.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/chart.dart';
import '../theme/tokens.dart';

class WheelPainter extends CustomPainter {
  WheelPainter({required this.chart, required this.rising});

  final Chart chart;

  /// Which sign begins the wheel. Presentation only — the same chart seen from
  /// a different starting sign, never a different chart.
  final int rising;

  /// Degrees measured from the start of the first house.
  double _relative(double longitude) =>
      ((longitude - rising * 30) % 360 + 360) % 360;

  /// A point on the wheel. See the note at the top before touching this.
  Offset _at(double degrees, double radius, Offset centre) {
    final a = (180 + degrees) * math.pi / 180;
    return Offset(
      centre.dx + radius * math.cos(a),
      centre.dy - radius * math.sin(a),
    );
  }

  void _glyph(Canvas canvas, String text, Offset at, double size, Color tone) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'AstroSymbols',
          fontSize: size,
          color: tone,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final c = Offset(size.width / 2, size.height / 2);

    final hair = Paint()
      ..color = Tone.line
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final strong = Paint()
      ..color = Tone.lineStrong
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(c, r, Paint()..color = Tone.inset);
    canvas.drawCircle(c, r, hair);
    canvas.drawCircle(c, r * 0.78, hair);
    canvas.drawCircle(c, r * 0.30, hair);

    // Twelve spokes and twelve sign glyphs, rotated so the rising sign begins.
    for (var i = 0; i < 12; i++) {
      final deg = i * 30.0;
      canvas.drawLine(_at(deg, r * 0.30, c), _at(deg, r, c), hair);
      final sign = (rising + i) % 12;
      _glyph(
        canvas,
        signGlyphs[sign],
        _at(deg + 15, r * 0.89, c),
        r * 0.13,
        i == 0 ? Tone.accent : Tone.faint,
      );
    }

    // Five-degree ticks, longer every thirty.
    for (var i = 0; i < 72; i++) {
      final deg = i * 5.0;
      final long = i % 6 == 0;
      canvas.drawLine(
        _at(deg, r * 0.78, c),
        _at(deg, r * 0.78 - (long ? r * 0.05 : r * 0.025), c),
        strong,
      );
    }

    // Bodies, spread so two a degree apart do not print on top of each other.
    //
    // Deterministic: sorted by angle, pushed apart until every neighbour
    // clears the minimum, and joined to the true position by a leader line so
    // the spreading never lies about where a planet is.
    const minGap = 13.0;
    final placed = [
      for (final b in chart.bodies)
        (body: b, trueAngle: _relative(b.longitude)),
    ]..sort((a, b) => a.trueAngle.compareTo(b.trueAngle));
    final shown = [for (final p in placed) p.trueAngle];

    for (var pass = 0; pass < 60; pass++) {
      var moved = false;
      for (var i = 0; i < shown.length; i++) {
        final j = (i + 1) % shown.length;
        var gap = shown[j] - shown[i];
        if (j == 0) gap += 360;
        if (gap < minGap) {
          final push = (minGap - gap) / 2;
          shown[i] = (shown[i] - push + 360) % 360;
          shown[j] = (shown[j] + push) % 360;
          moved = true;
        }
      }
      if (!moved) break;
    }

    for (var i = 0; i < placed.length; i++) {
      final trueAt = _at(placed[i].trueAngle, r * 0.78, c);
      final shownAt = _at(shown[i], r * 0.62, c);
      canvas.drawLine(trueAt, shownAt, strong);
      canvas.drawCircle(trueAt, 2, Paint()..color = Tone.accent);
      _glyph(
        canvas,
        bodyGlyphs[placed[i].body.name] ?? '?',
        shownAt,
        r * 0.12,
        Tone.ink,
      );
      if (placed[i].body.retrograde) {
        _glyph(
          canvas,
          '℞',
          shownAt + Offset(r * 0.075, r * 0.065),
          r * 0.06,
          Tone.faint,
        );
      }
    }

    // The ascendant, drawn last so nothing covers it. Only when it is known —
    // there is no line for a time nobody has.
    if (chart.ascendant != null) {
      final asc = Paint()
        ..color = Tone.rose
        ..strokeWidth = 1.6;
      canvas.drawLine(_at(0, r * 0.30, c), _at(0, r, c), asc);
    }
  }

  @override
  bool shouldRepaint(WheelPainter old) =>
      old.chart != chart || old.rising != rising;
}

/// The wheel, square and centred.
class Wheel extends StatelessWidget {
  const Wheel({super.key, required this.chart, this.rising});

  final Chart chart;

  /// Defaults to the chart's own rising sign, or Aries when the time is
  /// unknown — an unrotated wheel is the zodiac itself, which is the honest
  /// picture when there are no houses.
  final int? rising;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: CustomPaint(
      painter: WheelPainter(
        chart: chart,
        rising: rising ?? chart.risingSign ?? 0,
      ),
    ),
  );
}
