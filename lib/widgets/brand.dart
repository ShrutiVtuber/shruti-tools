// SPDX-License-Identifier: AGPL-3.0-only
//
// The brand layer made concrete: the pieces a screen actually places.
//
// Two surfaces exist in the whole app and they are deliberately different —
// Home's plate and Sky's arc. That difference is doing work: with one surface
// repeated, six tabs read as one stack of cards and the app has no shape. With
// two, Home is hers and Sky is an instrument, which is what they are.

import 'package:flutter/material.dart';

import '../services/shell_state.dart';
import '../theme/glyph.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'moon_disc.dart';
import 'motifs.dart';

const _rulerNames = {
  HourRuler.sun: 'Sun',
  HourRuler.moon: 'Moon',
  HourRuler.mars: 'Mars',
  HourRuler.mercury: 'Mercury',
  HourRuler.jupiter: 'Jupiter',
  HourRuler.venus: 'Venus',
  HourRuler.saturn: 'Saturn',
};

const _rulerMarks = {
  HourRuler.sun: '☉',
  HourRuler.moon: '☾',
  HourRuler.mars: '♂',
  HourRuler.mercury: '☿',
  HourRuler.jupiter: '♃',
  HourRuler.venus: '♀',
  HourRuler.saturn: '♄',
};

/// The screen's top bar, with the hour's hem beneath it.
///
/// ⚠ The hem is the only thing on this bar that is ever gold, and it is one
/// pixel. That is the entire ambient signal: the app looks different at three
/// in the morning than at noon, without a single element changing place.
class Bar extends StatelessWidget implements PreferredSizeWidget {
  const Bar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.hour = true,
    this.leading,
  });

  final String title;

  /// One line under the title — the place a table is computed for, the period
  /// being read. Never a sentence; it is a label, and it is truncated.
  final String? subtitle;
  final List<Widget>? actions;

  /// Set false where the tint would compete with the content — the wheel, the
  /// writing screen.
  final bool hour;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(Target.appBar + 1);

  @override
  Widget build(BuildContext context) => AppBar(
    title: subtitle == null
        ? Text(title)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, overflow: TextOverflow.ellipsis),
              Text(
                subtitle!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: Face.body,
                  fontSize: 12,
                  height: 1.3,
                  color: Tone.faint,
                ),
              ),
            ],
          ),
    actions: actions,
    leading: leading,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Hem(colour: hour ? null : Tone.line),
    ),
  );
}

/// The planetary hour now in force.
///
/// ⚠ The planet is NAMED as well as marked and tinted. Somebody who cannot
/// tell Venus's rose from Mars's clay — which is most people, and everybody in
/// sunlight — still reads the word.
class HourChip extends StatelessWidget {
  const HourChip({
    super.key,
    required this.ruler,
    this.ordinal,
    this.diurnal = true,
    this.ends,
    this.onTap,
  });

  final HourRuler ruler;
  final int? ordinal;
  final bool diurnal;

  /// Local clock time this hour gives way, already formatted.
  final String? ends;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tint = hourTint[ruler]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.slow),
        curve: Motion.inOut,
        padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: 7),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: tint.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Glyph(_rulerMarks[ruler]!, size: 14, color: tint),
            const SizedBox(width: Gap.sm),
            Text(
              [
                _rulerNames[ruler]!,
                if (ordinal != null)
                  '· ${_ordinal(ordinal!)} ${diurnal ? "hour of the day" : "hour of the night"}',
                if (ends != null) '· until $ends',
              ].join(' '),
              style: const TextStyle(
                fontFamily: Face.body,
                fontSize: 12.5,
                color: Tone.soft,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }
}

/// Whether she is live — the first thing most people open the app for.
///
/// ⚠ Three states, and `unknown` is never rendered as `off`. "We could not
/// reach Twitch" and "she is not streaming" are different facts, and an app
/// that shows the first as the second is lying quietly, several times a week,
/// to the people who care most.
class LiveBanner extends StatelessWidget {
  const LiveBanner({
    super.key,
    required this.status,
    this.title,
    this.next,
    this.onOpen,
  });

  final Liveness status;

  /// The stream's title, when live.
  final String? title;

  /// When she is next expected, when known and not live.
  final String? next;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final still = Motion.stilled(context);
    return switch (status) {
      Liveness.live => _shell(
        context,
        edge: Tone.live,
        fill: Tone.liveWash,
        lead: _Dot(pulsing: !still),
        head: 'Live now',
        body: title ?? 'She is streaming.',
        action: 'Watch',
      ),
      Liveness.off => _shell(
        context,
        edge: Tone.line,
        fill: Tone.card,
        lead: const Glyph('☾', size: 15, color: Tone.faint),
        head: 'Not live',
        body: next == null ? 'No stream scheduled yet.' : 'Next: $next',
        action: null,
      ),
      // ⚠ Says what it could not do, and offers the way round it. The reader
      // can go and look for themselves, which is more use than a guess.
      Liveness.unknown => _shell(
        context,
        edge: Tone.line,
        fill: Tone.card,
        lead: const Icon(Icons.cloud_off_outlined, size: 15, color: Tone.faint),
        head: 'Status unavailable',
        body: 'Could not reach Twitch. Check the channel directly.',
        action: 'Open Twitch',
      ),
    };
  }

  Widget _shell(
    BuildContext context, {
    required Color edge,
    required Color fill,
    required Widget lead,
    required String head,
    required String body,
    required String? action,
  }) => Container(
    padding: const EdgeInsets.all(Gap.lg),
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(Corner.md),
      border: Border.all(color: edge),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 3), child: lead),
        const SizedBox(width: Gap.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(head, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(body, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (action != null && onOpen != null) ...[
          const SizedBox(width: Gap.sm),
          FilledButton(
            onPressed: onOpen,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
            ),
            child: Text(action),
          ),
        ],
      ],
    ),
  );
}

/// The live dot. Pulses, except where the reader has asked it not to — and
/// there the WORD carries the meaning, which it was always doing anyway.
class _Dot extends StatefulWidget {
  const _Dot({required this.pulsing});

  final bool pulsing;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _beat,
    builder: (context, _) {
      final glow = widget.pulsing ? 0.35 + 0.45 * _beat.value : 0.6;
      return Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: Tone.live,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Tone.live.withValues(alpha: glow),
              blurRadius: 3,
              spreadRadius: 1.5,
            ),
          ],
        ),
      );
    },
  );
}

/// The top of Home — the only place in the app that uses the cloak at full
/// area.
///
/// ⚠ Test it with no portrait first: that is the state that ships, and it has
/// to look finished rather than look like something is missing. The art-absent
/// state is a drawn star over the plate, which is a composition rather than a
/// gap.
class Masthead extends StatelessWidget {
  const Masthead({
    super.key,
    required this.greeting,
    required this.line,
    this.portrait,
    this.child,
  });

  final String greeting;

  /// One sentence about the sky right now, in her voice.
  final String line;

  /// Her drawing, when there is one. Null until then, by design.
  final ImageProvider? portrait;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Plate(
    child: SizedBox(
      height: 200,
      child: Stack(
        children: [
          if (portrait != null)
            Positioned(
              right: -8,
              bottom: 0,
              top: 12,
              child: Image(image: portrait!, fit: BoxFit.fitHeight),
            )
          else
            const Positioned(
              right: 26,
              top: 30,
              child: StarMark(size: 44, colour: Gilt.bright),
            ),
          Padding(
            padding: const EdgeInsets.all(Gap.ml),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                SizedBox(
                  width: 210,
                  child: Text(
                    greeting,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: Gap.xs),
                SizedBox(
                  width: 210,
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontFamily: Face.display,
                      fontSize: 15.5,
                      height: 1.45,
                      color: Tone.soft,
                    ),
                  ),
                ),
                if (child != null) ...[
                  const SizedBox(height: Gap.md),
                  Align(alignment: Alignment.centerLeft, child: child!),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Sky's header: the day as an arc, the Sun on it, the Moon's phase beside it.
///
/// ⚠ Outside daylight the Sun is NOT drawn. An arc with a sun parked at one
/// end would be a picture of a fact that is not true; an empty arc says night,
/// which is the fact.
class DayArc extends StatelessWidget {
  const DayArc({
    super.key,
    required this.sunrise,
    required this.sunset,
    required this.now,
    required this.lit,
    this.waxing = true,
  });

  final DateTime sunrise;
  final DateTime sunset;
  final DateTime now;

  /// The Moon's illuminated fraction, 0..1.
  final double lit;
  final bool waxing;

  @override
  Widget build(BuildContext context) {
    final span = sunset.difference(sunrise).inSeconds;
    final into = now.difference(sunrise).inSeconds;
    final daylight = span > 0 && into >= 0 && into <= span;
    final along = daylight ? into / span : null;

    String clock(DateTime t) =>
        '${t.hour.toString().padLeft(2, "0")}:'
        '${t.minute.toString().padLeft(2, "0")}';

    return Container(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.md),
      decoration: BoxDecoration(
        color: Tone.card,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: Tone.line),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 92,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomPaint(
                    size: const Size.fromHeight(92),
                    painter: _ArcPainter(along),
                  ),
                ),
                const SizedBox(width: Gap.lg),
                Padding(
                  padding: const EdgeInsets.only(bottom: Gap.md),
                  child: MoonDisc(lit: lit, waxing: waxing, size: 34),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Foot(label: 'Sunrise', value: clock(sunrise)),
              Text(
                daylight ? 'Daylight' : 'Night',
                style: const TextStyle(
                  fontFamily: Face.body,
                  fontSize: 12,
                  color: Tone.faint,
                ),
              ),
              _Foot(label: 'Sunset', value: clock(sunset), trailing: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _Foot extends StatelessWidget {
  const _Foot({
    required this.label,
    required this.value,
    this.trailing = false,
  });

  final String label;
  final String value;
  final bool trailing;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: trailing
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: Face.body,
          fontSize: 11,
          color: Tone.faint,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontFamily: Face.body,
          fontSize: 14,
          color: Tone.ink,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    ],
  );
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter(this.along);

  /// Where the Sun is between rise and set, or null outside daylight.
  final double? along;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = h - 10;
    final peak = 8.0;

    Offset at(double t) {
      // A parabola, not a circle: the Sun's path across a day is a shallow
      // curve and a semicircle would put noon absurdly high.
      final x = t * w;
      final y = base - 4 * (base - peak) * t * (1 - t);
      return Offset(x, y);
    }

    final path = Path()..moveTo(0, base);
    for (var i = 1; i <= 60; i++) {
      final p = at(i / 60);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Tone.line
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    // The horizon.
    canvas.drawLine(
      Offset(0, base),
      Offset(w, base),
      Paint()
        ..color = Tone.line
        ..strokeWidth = 1,
    );

    if (along == null) return;

    // The travelled part, in gold, so the day reads as a quantity.
    final done = Path()..moveTo(0, base);
    for (var i = 1; i <= 60; i++) {
      final t = i / 60 * along!;
      final p = at(t);
      done.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      done,
      Paint()
        ..color = Gilt.gilt.withValues(alpha: 0.75)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    final sun = at(along!);
    canvas.drawCircle(sun, 7, Paint()..color = Tone.page);
    canvas.drawCircle(sun, 6, Paint()..color = Gilt.bright);
    canvas.drawCircle(
      sun,
      1.6,
      Paint()..color = Tone.page.withValues(alpha: 0.8),
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.along != along;
}

/// A number set the way the app sets numbers.
TextStyle figures({
  double size = 15,
  Color colour = Tone.ink,
  bool bold = false,
}) => TextStyle(
  fontFamily: Face.body,
  fontSize: size,
  color: colour,
  fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
  fontFeatures: const [
    FontFeature.tabularFigures(),
    FontFeature.liningFigures(),
  ],
);
