// SPDX-License-Identifier: AGPL-3.0-only
//
// The shared parts every screen is built from.
//
// One place, so a row on Settings and a row on Notifications are the same row.
// Where a component here differs from Material's default it is because the
// design system asks for something Material does not do: a card that deepens
// rather than lifts, a tab bar marked by a hem rather than a pill, a chip row
// that wraps rather than scrolls.
//
// ⚠ **Colour is never the only signal.** Retrograde is ℞ and rose; today is a
// wash and the word; a selected tab is a filled icon and a gilt hem and a
// full-ink label. Anything here that takes a colour takes a shape or a word
// with it.
import 'package:flutter/material.dart';

import '../theme/glyph.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import 'eyebrow.dart';
import 'motifs.dart';

/// Opens a section on a scrolling screen.
///
/// ⚠ The rule is for at most two sections on a screen. Gold that appears
/// everywhere is not ornament, it is a background.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.action,
    this.onAction,
    this.rule = false,
    this.mark = '☾',
  });

  final String title;
  final String? eyebrow;
  final String? action;
  final VoidCallback? onAction;
  final bool rule;
  final String mark;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (rule) ...[Rule(mark: mark), const SizedBox(height: Gap.lg)],
      if (eyebrow != null) ...[
        Eyebrow(eyebrow!),
        const SizedBox(height: Gap.xs),
      ],
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
              ),
              child: Text(action!),
            ),
        ],
      ),
    ],
  );
}

/// The app's surface.
///
/// ⚠ Press DEEPENS and strengthens the hairline. It never lifts and never
/// scales — a card that grows under a thumb reads as a toy, and on a
/// #121829 page a Material shadow barely reads anyway, so fill and hairline do
/// the structural work.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.tone = Surface.plain,
    this.padding = const EdgeInsets.all(Gap.lg),
    this.hem = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Surface tone;
  final EdgeInsets padding;

  /// A hairline along the top edge, in the ornament colour.
  final bool hem;

  @override
  State<Pressable> createState() => _PressableState();
}

/// ⚠ Four tones and no more. Gold sells exactly one thing — an offer — and a
/// fifth tone would be a fifth meaning nobody has been taught.
enum Surface { plain, inset, offer, warning }

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final pressed = _down && widget.onTap != null;
    final (fill, edge) = switch (widget.tone) {
      Surface.plain => (
        pressed ? Tone.veil : Tone.card,
        pressed ? Tone.lineStrong : Tone.line,
      ),
      Surface.inset => (Tone.inset, Tone.line),
      Surface.offer => (
        pressed ? Tone.veil : Tone.card,
        Gilt.gilt.withValues(alpha: 0.38),
      ),
      Surface.warning => (
        Tone.rose.withValues(alpha: 0.10),
        Tone.rose.withValues(alpha: 0.40),
      ),
    };

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _down = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _down = false),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.quick),
        curve: Motion.ease,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(Corner.md),
          border: Border.all(color: edge),
          boxShadow: widget.tone == Surface.inset
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x52000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.hem) const Hem(),
            Padding(padding: widget.padding, child: widget.child),
          ],
        ),
      ),
    );
  }
}

/// A row in a group. The workhorse of Settings, Account and the place picker.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.label,
    this.description,
    this.value,
    this.onTap,
    this.external = false,
    this.danger = false,
    this.leading,
    this.trailing,
  });

  final String label;
  final String? description;
  final String? value;
  final VoidCallback? onTap;

  /// ⚠ Required for anything that leaves the app — and everything that takes
  /// money leaves the app. The mark says so before the tap, not after it.
  final bool external;
  final bool danger;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Target.row),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.lg,
            vertical: Gap.md,
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: Gap.md)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: text.bodyMedium!.copyWith(
                        color: danger ? Tone.live : Tone.ink,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(description!, style: text.bodySmall),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: Gap.md),
                Text(
                  value!,
                  style: text.bodySmall!.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: Gap.sm),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: Gap.sm),
                Icon(
                  external ? Icons.open_in_new_outlined : Icons.chevron_right,
                  size: 18,
                  color: Tone.faint,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rows, joined by hairlines, inside one rounded surface.
class ListGroup extends StatelessWidget {
  const ListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Tone.card,
      borderRadius: BorderRadius.circular(Corner.md),
      border: Border.all(color: Tone.line),
    ),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(height: 1, indent: Gap.lg),
          children[i],
        ],
      ],
    ),
  );
}

/// Nothing here yet — and the copy says which nothing.
///
/// ⚠ "No data" is not copy. Every use of this writes the sentence for its own
/// case, because an empty room and an empty sky are different facts and a
/// reader can tell.
///
/// ⚠ The drawing is optional and its absence is DESIGNED: with no art the mark
/// ring holds the same height, so the screen does not reflow when her artwork
/// lands.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.mark = '☾',
    this.action,
    this.secondary,
    this.compact = false,
  });

  final String title;
  final String body;
  final String mark;
  final Widget? action;
  final Widget? secondary;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? Gap.ml : Gap.xl,
      vertical: compact ? 28 : Gap.huge,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Column(
          children: [
            Container(
              width: compact ? 56 : 72,
              height: compact ? 56 : 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Tone.inset,
                shape: BoxShape.circle,
                border: Border.all(color: Gilt.gilt.withValues(alpha: 0.34)),
              ),
              child: Scatter(
                faint: true,
                child: Center(
                  child: Glyph(mark, size: compact ? 22 : 28, color: Gilt.gilt),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: Face.display,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.title,
                height: 1.25,
                fontWeight: FontWeight.w500,
                color: Tone.ink,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.label,
                height: 1.55,
                color: Tone.faint,
              ),
            ),
            if (action != null || secondary != null) ...[
              const SizedBox(height: 16),
              ?action,
              if (secondary != null) ...[
                const SizedBox(height: Gap.sm),
                secondary!,
              ],
            ],
          ],
        ),
      ),
    ),
  );
}

/// An inline notice, pinned under the app bar.
///
/// ⚠ Named NoticeBar: Flutter already has a Banner, and the app already has
/// a Notice — a notification KIND, in services/notifications.dart. Three
/// things called the same thing is a bug waiting for a hurry.
///
/// ⚠ **Offline does not mean broken.** Every instrument still computes on the
/// device, so the offline copy says which HALF is missing — never "no
/// connection", which is a sentence about the network rather than about what
/// the reader can still do.
class NoticeBar extends StatelessWidget {
  const NoticeBar({
    super.key,
    required this.text,
    this.title,
    this.tone = BannerTone.note,
    this.action,
    this.onAction,
    this.onDismiss,
  });

  final String text;
  final String? title;
  final BannerTone tone;
  final String? action;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final (mark, tint, fill) = switch (tone) {
      BannerTone.offline => (Icons.cloud_off_outlined, Gilt.gilt, Gilt.wash),
      BannerTone.warning => (Icons.error_outlined, Tone.live, Tone.liveWash),
      BannerTone.caution => (
        Icons.priority_high,
        Tone.rose,
        Tone.rose.withValues(alpha: 0.10),
      ),
      BannerTone.note => (Icons.info_outlined, Tone.accent, Tone.accentWash),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: tint.withValues(alpha: 0.36)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(mark, size: 19, color: tint),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontFamily: Face.body,
                      fontFamilyFallback: [Face.glyph],
                      fontSize: Type.label,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: tint,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: Type.caption,
                    height: 1.5,
                    color: Tone.soft,
                  ),
                ),
                if (action != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: GestureDetector(
                      onTap: onAction,
                      child: Text(
                        action!,
                        style: TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: Type.caption,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: tint,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Padding(
                padding: EdgeInsets.only(left: Gap.sm),
                child: Icon(Icons.close, size: 17, color: Tone.faint),
              ),
            ),
        ],
      ),
    );
  }
}

enum BannerTone { note, offline, warning, caution }

/// A choice between a few things, sitting directly under the app bar.
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.chosen,
    required this.onChosen,
  });

  final List<(T, String)> options;
  final T chosen;
  final ValueChanged<T> onChosen;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: Tone.inset,
      borderRadius: BorderRadius.circular(Corner.sm),
      border: Border.all(color: Tone.line),
    ),
    child: Row(
      children: [
        for (final (value, label) in options)
          Expanded(
            child: GestureDetector(
              onTap: () => onChosen(value),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: Motion.of(context, Motion.normal),
                curve: Motion.ease,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == chosen ? Tone.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(Corner.sm - 2),
                  border: Border.all(
                    color: value == chosen
                        ? Tone.lineStrong
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: 14,
                    fontWeight: value == chosen
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: value == chosen ? Tone.ink : Tone.faint,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Engine, rule, and where it was reckoned — closing every instrument screen.
///
/// ⚠ Not decoration. A number with no provenance is a number somebody has to
/// take on trust, and this app's whole argument is that they should not have
/// to.
class Provenance extends StatelessWidget {
  const Provenance({super.key, required this.facts});

  /// Left is the label, right is the fact.
  final List<(String, String)> facts;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Rule(plain: true),
      const SizedBox(height: Gap.md),
      for (final (label, fact) in facts)
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: 12,
                    color: Tone.faint,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  fact,
                  style: const TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: 12,
                    height: 1.5,
                    color: Tone.soft,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

/// The shape of what is coming, while it comes.
///
/// ⚠ Not a spinner. A spinner says "wait"; a skeleton says what is arriving
/// and how much of it, and the screen does not jump when the answer lands. It
/// breathes, unless the reader has asked for stillness.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.height = 72, this.width});

  final double height;
  final double? width;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = Motion.stilled(context);
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, _) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Color.lerp(Tone.card, Tone.veil, still ? 0.4 : _breath.value),
          borderRadius: BorderRadius.circular(Corner.md),
          border: Border.all(color: Tone.line),
        ),
      ),
    );
  }
}
