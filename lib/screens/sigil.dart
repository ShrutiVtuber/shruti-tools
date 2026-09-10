// SPDX-License-Identifier: AGPL-3.0-only
//
// The sigil desk.
//
// ⚠ **Nothing typed on this screen is stored, sent or logged.** No autosave, no
// draft in shared_preferences, no analytics event, and the field is cleared
// when the screen is left. The website says the same thing on its own version
// and means it; the phone has to mean it too, or the promise is worth nothing.
// If you add a "recent statements" convenience here, you have broken the tool.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/sigil.dart' as sigil;
import '../theme/tokens.dart';
import '../widgets/forms.dart';
import '../widgets/parts.dart';
import '../widgets/sigil_figure.dart';

class SigilScreen extends StatefulWidget {
  const SigilScreen({super.key});

  @override
  State<SigilScreen> createState() => _SigilScreenState();
}

class _SigilScreenState extends State<SigilScreen> {
  final _field = TextEditingController();
  bool _keepVowels = false;
  String _weight = 'hairline';
  String _enclosure = 'none';

  @override
  void dispose() {
    // Not just tidiness — the statement should not outlive the screen.
    _field.clear();
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = sigil.reduce(_field.text, keepVowels: _keepVowels);

    // ⚠ A single remaining letter draws NOTHING, matching the website. The
    // engine will happily cast one point — `draw()` over there does too — but
    // both screens refuse it, because a dot and a cross on the same spot is a
    // figure invented to fill the space rather than one the sentence gave. The
    // refusal belongs here and not in the engine, so the two ports stay
    // identical.
    final figure = (r.exhausted || r.tooShort)
        ? null
        : sigil.cast(r.unique, weight: _weight, enclosure: _enclosure);

    return ListView(
      padding: const EdgeInsets.all(Gap.lg),
      children: [
        Field(
          label: 'Statement of intent',
          controller: _field,
          multiline: true,
          rows: 3,
          hint: 'My will is to finish the work',
          helper:
              'Repeated letters are struck out before the figure is '
              'drawn. Nothing typed here is sent, saved, or written into the '
              'figure you export.',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: Gap.md),
        _Options(
          keepVowels: _keepVowels,
          weight: _weight,
          enclosure: _enclosure,
          onVowels: (v) => setState(() => _keepVowels = v),
          onWeight: (v) => setState(() => _weight = v),
          onEnclosure: (v) => setState(() => _enclosure = v),
        ),
        if (_field.text.trim().isNotEmpty) ...[
          const SizedBox(height: Gap.xl),
          _Reduction(r: r),
          const SizedBox(height: Gap.lg),
          _FigureCard(figure: figure, r: r),
        ],
        const SizedBox(height: Gap.xl),
        const Text(
          'The tool is a convenience, never a requirement. Every step is shown '
          'so the same figure can be drawn by hand.',
          style: TextStyle(color: Tone.faint, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: Gap.xxl),
        const Provenance(
          facts: [
            ('the method', 'the rose of the magi, on the Latin alphabet'),
            (
              'the rule',
              'vowels and repeats struck out, then each remaining letter '
                  'placed on the rose and joined in order',
            ),
            (
              'computed',
              'on this phone · the statement is never sent and never kept',
            ),
            ('agrees with', 'shrutivtuber.com, to the same SVG'),
          ],
        ),
        const SizedBox(height: Gap.xxl),
      ],
    );
  }
}

class _Options extends StatelessWidget {
  const _Options({
    required this.keepVowels,
    required this.weight,
    required this.enclosure,
    required this.onVowels,
    required this.onWeight,
    required this.onEnclosure,
  });

  final bool keepVowels;
  final String weight;
  final String enclosure;
  final ValueChanged<bool> onVowels;
  final ValueChanged<String> onWeight;
  final ValueChanged<String> onEnclosure;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: keepVowels,
        onChanged: onVowels,
        title: const Text('Keep vowels'),
        subtitle: const Text(
          'Spare struck them out. Keeping them is a real choice, not a '
          'mistake.',
          style: TextStyle(color: Tone.faint, fontSize: 12),
        ),
      ),
      const SizedBox(height: Gap.md),
      const _Label('Line'),
      const SizedBox(height: Gap.sm),
      _Chips(options: sigil.weightOptions, chosen: weight, onPick: onWeight),
      const SizedBox(height: Gap.lg),
      const _Label('Enclosure'),
      const SizedBox(height: Gap.sm),
      _Chips(
        options: sigil.enclosureOptions,
        chosen: enclosure,
        onPick: onEnclosure,
      ),
    ],
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      color: Tone.faint,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.1,
    ),
  );
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.options,
    required this.chosen,
    required this.onPick,
  });

  final List<(String, String)> options;
  final String chosen;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Gap.sm,
    runSpacing: Gap.sm,
    children: [
      for (final (value, label) in options)
        ChoiceChip(
          label: Text(label),
          selected: chosen == value,
          onSelected: (_) => onPick(value),
        ),
    ],
  );
}

/// Every stage of the reduction, shown.
class _Reduction extends StatelessWidget {
  const _Reduction({required this.r});
  final sigil.Reduction r;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Gap.lg),
    decoration: BoxDecoration(
      color: Tone.inset,
      borderRadius: BorderRadius.circular(Corner.md),
      border: Border.all(color: Tone.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('The reduction'),
        const SizedBox(height: Gap.md),
        _Step('Letters', r.lettersOnly.join(' ')),
        if (!identical(r.lettersOnly, r.afterVowels))
          _Step(
            r.afterVowels.length == r.lettersOnly.length
                ? 'Vowels kept'
                : 'Vowels struck',
            r.afterVowels.join(' '),
          ),
        _Step('Repeats struck', r.unique.join(' ')),
        if (r.exhausted)
          const Padding(
            padding: EdgeInsets.only(top: Gap.md),
            child: Text(
              'The reduction consumed the whole sentence — every letter a '
              'vowel or a repeat. Say it another way, or keep the vowels.',
              style: TextStyle(color: Tone.rose, height: 1.45),
            ),
          )
        else if (r.tooShort)
          const Padding(
            padding: EdgeInsets.only(top: Gap.md),
            child: Text(
              'One letter is left, and one point is not a line. Say it '
              'another way, or keep the vowels.',
              style: TextStyle(color: Tone.rose, height: 1.45),
            ),
          ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step(this.name, this.value);
  final String name;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gap.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 116,
          child: Text(
            name,
            style: const TextStyle(color: Tone.faint, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              color: Tone.ink,
              fontFamily: Face.display,
              fontFamilyFallback: [Face.glyph],
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class _FigureCard extends StatelessWidget {
  const _FigureCard({required this.figure, required this.r});
  final sigil.Figure? figure;
  final sigil.Reduction r;

  @override
  Widget build(BuildContext context) {
    if (figure == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: Tone.card,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: Tone.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('The figure'),
          const SizedBox(height: Gap.lg),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(painter: SigilPainter(figure!)),
          ),
          const SizedBox(height: Gap.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _share(context, figure!),
                  icon: const Icon(Icons.ios_share_outlined, size: 18),
                  label: const Text('Keep the figure'),
                ),
              ),
              const SizedBox(width: Gap.sm),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: sigil.toSvg(figure!)),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SVG copied.')),
                    );
                  }
                },
                icon: const Icon(Icons.code_outlined, size: 18),
                label: const Text('SVG'),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(
            'Drawn from ${r.unique.length} letters: ${r.unique.join(' ')}',
            style: const TextStyle(color: Tone.faint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Draw the figure at export size and hand it to the share sheet.
///
/// ⚠ The file is called `sigil.png` and never anything derived from the
/// statement. A filename travels further than the file does — into notification
/// shades, chat previews and file listings — and the statement is not going
/// with it. For the same reason nothing is passed as share text or subject.
Future<void> _share(BuildContext context, sigil.Figure figure) async {
  final bytes = await pngOf(figure);
  if (bytes == null || !context.mounted) return;
  final file = File('${(await getTemporaryDirectory()).path}/sigil.png');
  await file.writeAsBytes(bytes, flush: true);
  if (!context.mounted) return;
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}
