// SPDX-License-Identifier: AGPL-3.0-only
//
// The Moon's phase, drawn.
//
// ⚠ **Not a character.** ○ ◐ ● are three shapes for a continuous quantity, and
// they are not in the bundled cut anyway — left to a fallback font they arrive
// from whatever face the phone has, at whatever weight, and a row of them is a
// row of mismatched circles. A drawn disc is correct at every fraction of the
// cycle and matches the palette exactly, because it is made of it.
//
// The same figure the period wheel draws in its inner ring and the website
// draws in its own. One shape, three places.
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class MoonDisc extends StatelessWidget {
  const MoonDisc({
    super.key,
    required this.lit,
    this.waxing = true,
    this.size = 24,
    this.gilded = false,
  });

  /// Illuminated fraction, 0 new to 1 full.
  final double lit;

  /// Which limb is lit. Waxing is lit on the right in the northern hemisphere.
  final bool waxing;
  final double size;

  /// Gold rather than ink — for the brand surfaces, never for a table.
  final bool gilded;

  @override
  Widget build(BuildContext context) => Semantics(
    label: _said,
    child: CustomPaint(
      size: Size.square(size),
      painter: _DiscPainter(lit: lit, waxing: waxing, gilded: gilded),
    ),
  );

  /// ⚠ The shape is not enough on its own: a screen reader gets nothing from a
  /// CustomPaint, so the phase is also a sentence.
  String get _said {
    final percent = (lit * 100).round();
    final name = switch (lit) {
      < 0.03 => 'new',
      < 0.47 => waxing ? 'waxing crescent' : 'waning crescent',
      < 0.53 => waxing ? 'first quarter' : 'last quarter',
      < 0.97 => waxing ? 'waxing gibbous' : 'waning gibbous',
      _ => 'full',
    };
    return '$name moon, $percent per cent lit';
  }
}

class _DiscPainter extends CustomPainter {
  const _DiscPainter({
    required this.lit,
    required this.waxing,
    required this.gilded,
  });

  final double lit;
  final bool waxing;
  final bool gilded;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final light = gilded ? Gilt.bright : Tone.soft;

    // The dark disc, so a new moon is a ring rather than nothing at all.
    canvas.drawCircle(c, r - 0.5, Paint()..color = Tone.page);
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..color = gilded ? Gilt.dim : Tone.lineStrong
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    if (lit <= 0.01) return;

    // The lit half.
    final half = Path()
      ..moveTo(c.dx, c.dy - r)
      ..arcToPoint(
        Offset(c.dx, c.dy + r),
        radius: Radius.circular(r),
        clockwise: waxing,
      )
      ..close();
    canvas.drawPath(half, Paint()..color = light);

    // The terminator: an ellipse as wide as the phase is far from half, adding
    // to the lit half when gibbous and taking from it when crescent.
    final k = (1 - 2 * lit).abs() * r;
    final gibbous = lit > 0.5;
    final term = Path()
      ..moveTo(c.dx, c.dy - r)
      ..arcToPoint(
        Offset(c.dx, c.dy + r),
        radius: Radius.elliptical(k < 0.01 ? 0.01 : k, r),
        clockwise: gibbous != waxing,
      )
      ..close();
    canvas.drawPath(term, Paint()..color = gibbous ? light : Tone.page);
  }

  @override
  bool shouldRepaint(_DiscPainter old) =>
      old.lit != lit || old.waxing != waxing || old.gilded != gilded;
}
