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

/// The default surface.
///
/// ⚠ Press DEEPENS, never lifts and never scales. A card that grows under a
/// thumb is a toy; a card that darkens is a thing being pressed.
class Plaque extends StatefulWidget {
  const Plaque({
    super.key,
    required this.child,
    this.onTap,
    this.tone = PlaqueTone.plain,
    this.padding = const EdgeInsets.all(Gap.lg),
  });

  final Widget child;
  final VoidCallback? onTap;
  final PlaqueTone tone;
  final EdgeInsets padding;

  @override
  State<Plaque> createState() => _PlaqueState();
}

/// ⚠ Four, and no more. Gold sells exactly one thing — an offer — and a fifth
/// tone would be a fifth meaning nobody has been taught.
enum PlaqueTone { plain, inset, offer, warning }

class _PlaqueState extends State<Plaque> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final pressed = _down && widget.onTap != null;
    final (fill, edge) = switch (widget.tone) {
      PlaqueTone.plain => (
        pressed ? Tone.veil : Tone.card,
        pressed ? Tone.lineStrong : Tone.line,
      ),
      PlaqueTone.inset => (Tone.inset, Tone.line),
      PlaqueTone.offer => (pressed ? Tone.veil : Tone.card, Gilt.dim),
      PlaqueTone.warning => (Tone.liveWash, Tone.live.withValues(alpha: 0.5)),
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
        padding: widget.padding,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(Corner.md),
          border: Border.all(color: edge),
        ),
        child: widget.child,
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
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.mark = '☾',
    this.action,
  });

  final String title;
  final String body;
  final String mark;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.xxl),
    child: Column(
      children: [
        Glyph(mark, size: 26, color: Gilt.dim),
        const SizedBox(height: Gap.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: Gap.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (action != null) ...[const SizedBox(height: Gap.lg), action!],
      ],
    ),
  );
}

/// Something the reader should know before they carry on.
///
/// ⚠ Named Notice rather than Banner: Flutter already has a Banner, and two
/// things called the same thing in one file is a bug waiting for a hurry.
class Notice extends StatelessWidget {
  const Notice({
    super.key,
    required this.text,
    this.tone = BannerTone.note,
    this.action,
    this.onAction,
  });

  final String text;
  final BannerTone tone;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (fill, edge, mark, tint) = switch (tone) {
      BannerTone.note => (Tone.card, Tone.line, Icons.info_outlined, Tone.soft),
      BannerTone.offline => (
        Tone.card,
        Tone.line,
        Icons.cloud_off_outlined,
        Tone.faint,
      ),
      BannerTone.warning => (
        Tone.liveWash,
        Tone.live.withValues(alpha: 0.5),
        Icons.error_outlined,
        Tone.live,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: edge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(mark, size: 18, color: tint),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
          if (action != null) ...[
            const SizedBox(width: Gap.sm),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
              ),
              child: Text(action!),
            ),
          ],
        ],
      ),
    );
  }
}

enum BannerTone { note, offline, warning }

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
