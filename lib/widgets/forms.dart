// SPDX-License-Identifier: AGPL-3.0-only
//
// Buttons, chips, fields, switches and choices — the app's controls, built to
// the design system rather than to Material's defaults.
//
// Where these differ from Material it is because the system asks for something
// Material does not do: a button that sinks a pixel rather than rippling, a
// chip row that wraps rather than scrolls, a switch whose knob carries a tick
// so its state survives a monochrome screen.
//
// ⚠ **Press deepens and sinks; it never scales.** A control that grows under a
// thumb reads as a toy, and this app is an instrument.
import 'package:flutter/material.dart';

import '../theme/motion.dart';
import '../theme/tokens.dart';

/// Filled is the one action a screen is for; outlined is the alternative; text
/// is everything else.
///
/// ⚠ Destructive is outlined-only. Nothing irreversible gets a filled button —
/// a big blue rectangle is what a thumb lands on by accident.
enum Weight { filled, outlined, text }

/// ⚠ Named Bulk rather than Size: `Size` is a Flutter type, and a control that
/// shadows the geometry class is a compile error waiting for the first widget
/// that needs both.
enum Bulk { sm, md, lg }

class Push extends StatefulWidget {
  const Push({
    super.key,
    required this.label,
    this.onTap,
    this.weight = Weight.filled,
    this.size = Bulk.md,
    this.destructive = false,
    this.loading = false,
    this.full = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final Weight weight;
  final Bulk size;
  final bool destructive;
  final bool loading;
  final bool full;
  final IconData? icon;

  @override
  State<Push> createState() => _PushState();
}

class _PushState extends State<Push> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null && !widget.loading;
    final tint = widget.destructive ? Tone.live : Tone.accent;

    final (height, textSize, padding) = switch (widget.size) {
      Bulk.sm => (36.0, Type.caption, 14.0),
      Bulk.md => (48.0, Type.label, 20.0),
      Bulk.lg => (56.0, Type.body, 24.0),
    };

    final (fill, ink, edge) = switch (widget.weight) {
      Weight.filled => (
        widget.destructive ? Tone.live : Tone.accent,
        widget.destructive ? const Color(0xFF2A0F16) : Tone.onAccent,
        Colors.transparent,
      ),
      Weight.outlined => (
        _down ? tint.withValues(alpha: 0.12) : Colors.transparent,
        tint,
        tint.withValues(alpha: 0.55),
      ),
      Weight.text => (
        _down ? Tone.veil : Colors.transparent,
        tint,
        Colors.transparent,
      ),
    };

    Widget child = widget.loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ink,
              backgroundColor: ink.withValues(alpha: 0.28),
            ),
          )
        : Row(
            mainAxisSize: widget.full ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: ink),
                const SizedBox(width: Gap.sm),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontWeight: FontWeight.w600,
                    fontSize: textSize,
                    height: 1,
                    color: ink,
                  ),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: GestureDetector(
        onTap: enabled ? widget.onTap : null,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.quick),
          curve: Motion.ease,
          // ⚠ A one-pixel sink, not a scale.
          transform: Matrix4.translationValues(0, _down ? 1 : 0, 0),
          height: height,
          width: widget.full ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: padding),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(Corner.sm),
            border: Border.all(color: edge),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// An icon on its own, in the app bar or beside a title.
class Tap extends StatelessWidget {
  const Tap({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.badge,
    this.tone = Tone.soft,
  });

  final IconData icon;

  /// ⚠ Not decoration: an icon with no label is unreachable by anybody using a
  /// screen reader, and this app has icon-only actions in its chrome.
  final String label;
  final VoidCallback? onTap;
  final int? badge;
  final Color tone;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: InkResponse(
      onTap: onTap,
      radius: 24,
      child: SizedBox(
        width: Target.min,
        height: Target.min,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: tone),
            if (badge != null && badge! > 0)
              Positioned(
                top: 11,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 15),
                  height: 15,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Tone.accent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Tone.page, width: 1.5),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      fontFamily: Face.body,
                      fontFamilyFallback: [Face.glyph],
                      fontSize: 9,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: Tone.onAccent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// ⚠ Three kinds, and they do not mix on one row.
///
///   choice — pick one of a set
///   filter — pick any number; selected carries a tick, not just a tint
///   meta   — not interactive; a fact with a size on it
enum ChipKind { choice, filter, meta }

class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.label,
    this.kind = ChipKind.choice,
    this.selected = false,
    this.disabled = false,
    this.meta,
    this.leading,
    this.onTap,
  });

  final String label;
  final ChipKind kind;
  final bool selected;
  final bool disabled;
  final String? meta;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fact = kind == ChipKind.meta;
    return Opacity(
      opacity: disabled ? 0.38 : 1,
      child: GestureDetector(
        onTap: disabled || fact ? null : onTap,
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.quick),
          curve: Motion.ease,
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: Gap.md),
          decoration: BoxDecoration(
            color: selected
                ? Tone.accentWash
                : fact
                ? Tone.inset
                : Colors.transparent,
            borderRadius: BorderRadius.circular(Corner.sm),
            border: Border.all(
              color: selected ? Tone.accent.withValues(alpha: 0.55) : Tone.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⚠ A tick as well as a tint. A filter that is only a colour is
              // a filter half the room cannot see is on.
              if (kind == ChipKind.filter && selected) ...[
                const Text(
                  '✓',
                  style: TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: Tone.accent,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: TextStyle(
                  fontFamily: Face.body,
                  fontFamilyFallback: [Face.glyph],
                  fontSize: Type.caption,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? Tone.accent
                      : fact
                      ? Tone.faint
                      : Tone.soft,
                ),
              ),
              if (meta != null) ...[
                const SizedBox(width: 6),
                Text(
                  meta!,
                  style: const TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: Type.caption,
                    height: 1,
                    color: Tone.faint,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ⚠ Chips WRAP. They never scroll sideways — a row that scrolls hides its own
/// last option, and on a reference screen that is an option nobody finds.
class TagRow extends StatelessWidget {
  const TagRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: Gap.sm, runSpacing: Gap.sm, children: children);
}

/// An inset well with its label above it.
///
/// ⚠ Not a floating label. Birth data and a two-thousand-word reading both go
/// in here, and a label that jumps out of the way when the field fills is a
/// label that is gone exactly when somebody looks up to check what they are
/// typing.
class Field extends StatelessWidget {
  const Field({
    super.key,
    this.label,
    this.controller,
    this.hint,
    this.helper,
    this.error,
    this.multiline = false,
    this.rows = 4,
    this.enabled = true,
    this.figures = false,
    this.maxLength,
    this.counter = false,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.secret = false,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? error;
  final bool multiline;
  final int rows;
  final bool enabled;

  /// Tabular figures — for a date, a time, a coordinate.
  final bool figures;
  final int? maxLength;
  final bool counter;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  /// Dots instead of characters — for a password.
  ///
  /// ⚠ **This did not exist until 12 September 2026**, so every password in
  /// the app was typed in the clear. She spotted it in the screen recording
  /// made for App Review, where her own password is legible on the video.
  ///
  /// ⚠ It also turns off autocorrect and suggestions. A password is not a
  /// word, and a keyboard that offers to complete it puts it in a strip above
  /// the keys — which is how one ends up in a screenshot somebody else takes.
  final bool secret;

  @override
  Widget build(BuildContext context) {
    final wrong = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontFamily: Face.body,
              fontFamilyFallback: [Face.glyph],
              fontSize: Type.caption,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: Tone.soft,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Container(
            constraints: const BoxConstraints(minHeight: Target.min),
            padding: EdgeInsets.symmetric(
              horizontal: Gap.md,
              vertical: multiline ? 10 : 0,
            ),
            decoration: BoxDecoration(
              color: Tone.inset,
              borderRadius: BorderRadius.circular(Corner.sm),
              border: Border.all(color: wrong ? Tone.live : Tone.line),
            ),
            child: Row(
              crossAxisAlignment: multiline
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                if (prefix != null) ...[prefix!, const SizedBox(width: Gap.sm)],
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    obscureText: secret,
                    autocorrect: !secret,
                    enableSuggestions: !secret,
                    maxLines: multiline ? rows : 1,
                    minLines: multiline ? rows : 1,
                    maxLength: maxLength,
                    onChanged: onChanged,
                    cursorColor: Tone.accent,
                    style: TextStyle(
                      fontFamily: Face.body,
                      fontFamilyFallback: [Face.glyph],
                      fontSize: Type.body,
                      height: 1.5,
                      color: Tone.ink,
                      fontFeatures: figures
                          ? const [FontFeature.tabularFigures()]
                          : null,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: hint,
                      hintStyle: const TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: Type.body,
                        color: Tone.faint,
                      ),
                    ),
                  ),
                ),
                if (suffix != null) ...[const SizedBox(width: Gap.sm), suffix!],
              ],
            ),
          ),
        ),
        if (helper != null || error != null || counter) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  // ⚠ An error is a MESSAGE and a colour and a mark — never a
                  // red border on its own.
                  error != null ? 'Error · $error' : (helper ?? ''),
                  style: TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: Type.caption,
                    height: 1.45,
                    color: wrong ? Tone.live : Tone.faint,
                  ),
                ),
              ),
              if (counter && maxLength != null && controller != null)
                ValueListenableBuilder(
                  valueListenable: controller!,
                  builder: (context, value, _) => Text(
                    '${value.text.characters.length}/$maxLength',
                    style: const TextStyle(
                      fontFamily: Face.body,
                      fontFamilyFallback: [Face.glyph],
                      fontSize: Type.caption,
                      color: Tone.faint,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A settings switch on its own row.
///
/// ⚠ The whole row is the target; the switch is the affordance. State is
/// position AND fill AND a tick on the knob, so it survives a screen somebody
/// cannot see colour on.
class Switcher extends StatelessWidget {
  const Switcher({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.enabled = true,
  });

  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    child: Opacity(
      opacity: enabled ? 1 : 0.38,
      child: InkWell(
        onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: Target.row),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: Type.body,
                        height: 1.35,
                        color: Tone.ink,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        description!,
                        style: const TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: Type.caption,
                          height: 1.4,
                          color: Tone.faint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Gap.lg),
              _Track(on: value),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Track extends StatelessWidget {
  const _Track({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: Motion.of(context, Motion.normal),
    curve: Motion.ease,
    width: 48,
    height: 28,
    decoration: BoxDecoration(
      color: on ? Tone.accent : Tone.inset,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: on ? Tone.accent : Tone.lineStrong, width: 1.5),
    ),
    child: Stack(
      children: [
        AnimatedAlign(
          duration: Motion.of(context, Motion.normal),
          curve: Motion.ease,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 19,
              height: 19,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? Tone.onAccent : Tone.faint,
                shape: BoxShape.circle,
              ),
              child: on
                  ? const Text(
                      '✓',
                      style: TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: Tone.inset,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    ),
  );
}

/// One row of a choice: a radio, or a consent checkbox.
///
/// ⚠ Both carry a `rule` line, because the app's disagreement controls are
/// never bare labels — each option states the rule it applies. And consents are
/// never pre-ticked and never bundled: one row, one decision.
class ChoiceRow extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.label,
    required this.checked,
    this.rule,
    this.radio = true,
    this.enabled = true,
    this.onChanged,
  });

  final String label;
  final String? rule;
  final bool checked;
  final bool radio;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: enabled ? 1 : 0.38,
    child: InkWell(
      onTap: enabled && onChanged != null ? () => onChanged!(!checked) : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: Target.min),
        padding: const EdgeInsets.symmetric(vertical: Gap.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: Motion.of(context, Motion.quick),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: checked ? Tone.accent : Tone.inset,
                borderRadius: BorderRadius.circular(radio ? 999 : 5),
                border: Border.all(
                  color: checked ? Tone.accent : Tone.lineStrong,
                  width: 1.5,
                ),
              ),
              child: !checked
                  ? null
                  : radio
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Tone.onAccent,
                        shape: BoxShape.circle,
                      ),
                    )
                  : const Text(
                      '✓',
                      style: TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: 13,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: Tone.onAccent,
                      ),
                    ),
            ),
            const SizedBox(width: Gap.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: Face.body,
                      fontFamilyFallback: [Face.glyph],
                      fontSize: Type.body,
                      height: 1.35,
                      fontWeight: checked ? FontWeight.w500 : FontWeight.w400,
                      color: Tone.ink,
                    ),
                  ),
                  if (rule != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      rule!,
                      style: const TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: Type.caption,
                        height: 1.5,
                        color: Tone.faint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
