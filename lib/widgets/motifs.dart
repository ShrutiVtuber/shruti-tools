// SPDX-License-Identifier: AGPL-3.0-only
//
// The brand layer: four motifs, and they are the whole of it.
//
// Taken from her own artwork — a cloak of night-blue edged in a thin gold
// line, scattered thinly with stars. The restraint is the point: one colour
// and three shapes, small enough to survive being on a stations table, which
// is what a brand layer for an instrument has to be.
//
//   1. Hem      the gold edge-line       — one per screen, at the top of a surface
//   2. Scatter  the star field           — brand surfaces only, never behind data
//   3. Rule     a hairline with a mark   — closes a section
//   4. Veil     a protection capsule     — text over a plate or over artwork
//
// ⚠ **Gold is ornament and never interactive.** Blue keeps that job. Nothing
// in this file is ever the thing you tap.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/glyph.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';

/// The gold edge-line, fading out at both ends as the trim on the cloak does
/// where the fabric turns.
///
/// Its colour is the shell's ornament colour, so it follows the ruling hour
/// and turns rose the moment she goes live — which is how one hairline tells
/// you the time of day and whether she is streaming without saying either.
class Hem extends StatelessWidget {
  const Hem({super.key, this.colour, this.strong = false});

  final Color? colour;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final tint = colour ?? Ornament.of(context);
    return AnimatedContainer(
      duration: Motion.of(context, Motion.slow),
      curve: Motion.inOut,
      height: strong ? 1.5 : 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tint.withValues(alpha: 0),
            tint.withValues(alpha: strong ? 1 : 0.75),
            tint.withValues(alpha: strong ? 1 : 0.75),
            tint.withValues(alpha: 0),
          ],
          stops: const [0, 0.18, 0.82, 1],
        ),
      ),
    );
  }
}

/// Stars, the way they sit on the cloak.
///
/// ⚠ Fixed positions, never random and never animated: a field that shimmers
/// is a field the eye keeps going back to, and this one has to be quiet enough
/// to put a heading on. ⚠ Never behind a table.
class Scatter extends StatelessWidget {
  const Scatter({super.key, required this.child, this.faint = false});

  final Widget child;
  final bool faint;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(painter: _ScatterPainter(faint ? 0.42 : 0.9)),
        ),
      ),
      child,
    ],
  );
}

/// x, y as fractions of the surface, radius in logical pixels, and how bright.
const _stars = <(double, double, double, double, bool)>[
  (0.09, 0.16, 2.0, 1.0, true),
  (0.17, 0.41, 1.0, 0.72, false),
  (0.24, 0.08, 1.5, 1.0, true),
  (0.31, 0.63, 1.0, 0.50, false),
  (0.38, 0.27, 2.5, 1.0, true),
  (0.44, 0.78, 1.0, 0.42, false),
  (0.47, 0.11, 1.0, 0.60, false),
  (0.55, 0.47, 1.5, 1.0, true),
  (0.61, 0.19, 1.0, 0.55, false),
  (0.67, 0.69, 2.0, 1.0, true),
  (0.72, 0.34, 1.0, 0.50, false),
  (0.79, 0.13, 1.5, 1.0, true),
  (0.84, 0.55, 1.0, 0.62, false),
  (0.91, 0.30, 2.0, 1.0, true),
  (0.95, 0.74, 1.0, 0.45, false),
  (0.06, 0.62, 1.0, 0.40, false),
  (0.13, 0.87, 1.5, 1.0, true),
  (0.27, 0.92, 1.0, 0.38, false),
  (0.52, 0.86, 1.0, 0.44, false),
  (0.74, 0.90, 1.5, 1.0, true),
  (0.88, 0.84, 1.0, 0.40, false),
  (0.35, 0.52, 1.0, 0.30, false),
  (0.64, 0.05, 1.0, 0.50, false),
];

class _ScatterPainter extends CustomPainter {
  const _ScatterPainter(this.opacity);

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (fx, fy, radius, alpha, gold) in _stars) {
      canvas.drawCircle(
        Offset(fx * size.width, fy * size.height),
        radius,
        Paint()
          ..color = (gold ? Gilt.bright : Tone.ink).withValues(
            alpha: alpha * opacity,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_ScatterPainter old) => old.opacity != opacity;
}

/// Closes a section: a hairline either side of a small mark.
class Rule extends StatelessWidget {
  const Rule({super.key, this.mark = '☾', this.plain = false});

  final String mark;

  /// A plain rule is grey and unmarked — for a section that is structure
  /// rather than voice.
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final tint = plain ? Tone.lineStrong : Gilt.gilt;
    Widget side(bool leading) => Expanded(
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: leading ? Alignment.centerLeft : Alignment.centerRight,
            end: leading ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              tint.withValues(alpha: 0),
              tint.withValues(alpha: plain ? 0.8 : 0.42),
            ],
          ),
        ),
      ),
    );

    return Row(
      children: [
        side(true),
        if (!plain) ...[
          const SizedBox(width: Gap.md),
          Glyph(mark, size: 13, color: Gilt.gilt),
          const SizedBox(width: Gap.md),
        ],
        side(false),
      ],
    );
  }
}

/// A protection capsule for text over the plate or over her artwork.
///
/// ⚠ A capsule, not a gradient scrim. A gradient laid over a drawing muddies
/// the drawing; a blurred capsule leaves it intact and puts the text on
/// something of its own.
class Veil extends StatelessWidget {
  const Veil({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gap.md),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(Corner.lg),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Tone.page.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(Corner.lg),
          border: Border.all(color: Tone.line.withValues(alpha: 0.7)),
        ),
        child: child,
      ),
    ),
  );
}

/// The one brand-coloured surface in the app.
///
/// ⚠ Exactly one. Cloak navy at full area appears on Home's masthead and
/// nowhere else — a second plate and neither is special. The light caught at
/// the top-left is the light the cloak catches in her drawing; without it flat
/// navy reads as a dead panel.
class Plate extends StatelessWidget {
  const Plate({
    super.key,
    required this.child,
    this.scattered = true,
    this.radius = Corner.lg,
  });

  final Widget child;
  final bool scattered;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.68, -1),
            radius: 1.2,
            colors: [
              Color(0xFF4A5878),
              Gilt.cloth,
              Gilt.clothDeep,
              Color(0xFF1B2238),
            ],
            stops: [0, 0.34, 0.66, 1],
          ),
        ),
        child: Stack(
          children: [
            if (scattered)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: const _ScatterPainter(0.75)),
                ),
              ),
            child,
            // The plate's own foot: a gold hairline closing it against the
            // page, so it is a surface rather than a rectangle of colour.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Hem(colour: Gilt.gilt),
            ),
          ],
        ),
      ),
    );
    return inner;
  }
}

/// What colour the ornament is, right now.
///
/// Gilt normally; the hour's tint where the hour is known; rose the whole time
/// she is live. One inherited colour, so the hem under the app bar, the hem
/// over the tab bar and the plate's foot all agree without any of them asking
/// what is going on.
class Ornament extends InheritedWidget {
  const Ornament({super.key, required this.colour, required super.child});

  final Color colour;

  static Color of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Ornament>()?.colour ??
      Gilt.gilt;

  @override
  bool updateShouldNotify(Ornament old) => old.colour != colour;
}

/// A star, drawn — eight points, as on the cloak.
///
/// Used at size in the art-absent states, where a drawing will eventually go.
class StarMark extends StatelessWidget {
  const StarMark({super.key, this.size = 24, this.colour = Gilt.gilt});

  final double size;
  final Color colour;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _StarPainter(colour));
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.colour);

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2;
    // ⚠ A deep waist. An eight-pointed star with a shallow one is a cog; the
    // needle points are what make it read as a star at 12 pixels.
    final inner = outer * 0.28;
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 8;
      final p = Offset(
        c.dx + radius * math.cos(angle),
        c.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = colour);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.colour != colour;
}
