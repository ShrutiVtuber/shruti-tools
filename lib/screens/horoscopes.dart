// SPDX-License-Identifier: AGPL-3.0-only
//
// Her twelve readings for the period we are in now.
//
// ⚠ **The current period is read HERE; anything older opens the website.** Her
// decision, and it is the same boundary as the five site tools that stayed off
// the app: the app carries what somebody wants now, and the site is where the
// archive, the search and the back-catalogue live. The endpoint would serve any
// period just as happily, which is exactly why the line is drawn deliberately
// rather than left to whatever happens to get called.
//
// ⚠ The link out says where it goes. A link that silently leaves the app —
// which on Android means a browser opening over it with no warning — reads as
// the app crashing.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/periods.dart';
import '../services/site.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/content.dart';
import '../widgets/forms.dart';
import '../widgets/motifs.dart';
import '../widgets/parts.dart';

class HoroscopesScreen extends StatefulWidget {
  const HoroscopesScreen({super.key, this.period = 'monthly', this.sign});

  /// Which kind of period. Only ever a current one — see the note above.
  final String period;

  /// Which sign to open at. Null means the first she has written.
  final String? sign;

  @override
  State<HoroscopesScreen> createState() => _HoroscopesScreenState();
}

class _HoroscopesScreenState extends State<HoroscopesScreen> {
  late Future<Twelve?> _twelve;
  late String _period;
  String? _showing;

  @override
  void initState() {
    super.initState();
    _period = widget.period;
    _showing = widget.sign?.toLowerCase();
    _twelve = theTwelve(period: _period);
  }

  void _switchTo(String period) {
    setState(() {
      _period = period;
      // ⚠ Cleared, not kept. She may write all twelve monthly and only four
      // weekly, and holding on to a sign she has not written for the new
      // period lands on a tab with nothing behind it.
      _showing = null;
      _twelve = theTwelve(period: period);
    });
  }

  Future<void> _openTheArchive() async {
    final url = '$siteOrigin/horoscopes';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Tone.page,
    appBar: const Bar(title: 'Her readings'),
    body: SafeArea(
      child: FutureBuilder<Twelve?>(
        future: _twelve,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(Gap.lg),
              child: Column(
                children: [
                  Pressable(
                    padding: EdgeInsets.all(14),
                    child: Skeleton(lines: 2),
                  ),
                  SizedBox(height: 10),
                  Pressable(
                    padding: EdgeInsets.all(14),
                    child: Skeleton(lines: 4),
                  ),
                ],
              ),
            );
          }

          final twelve = snap.data;
          // ⚠ Null is "her side is out of reach", empty is "she has not written
          // them yet". Two different sentences, and telling somebody she has
          // written nothing when the truth is that the network is gone is the
          // one that makes her look absent.
          if (twelve == null) {
            return const Padding(
              padding: EdgeInsets.all(Gap.lg),
              child: EmptyState(
                mark: '☾',
                title: 'Her half is out of reach',
                body:
                    'The instruments all still work. Her readings need her '
                    'side, and it is not answering just now.',
              ),
            );
          }

          final shown =
              _showing ??
              (twelve.readings.isEmpty ? null : twelve.readings.first.sign);
          final reading = twelve.readings
              .where((r) => r.sign == shown)
              .cast<SignReading?>()
              .firstWhere((r) => true, orElse: () => null);

          return ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.xl),
            children: [
              SectionHeader(
                eyebrow: 'From Shruti',
                title: periodLabel(twelve.period, twelve.covers),
              ),
              const SizedBox(height: Gap.md),

              _Periods(chosen: _period, onPick: _switchTo),
              const SizedBox(height: Gap.md),

              if (twelve.isEmpty)
                const EmptyState(
                  compact: true,
                  mark: '☾',
                  title: 'Nothing written for this one yet',
                  body: 'She writes them in one sitting. They arrive together.',
                )
              else ...[
                TagRow(
                  children: [
                    for (final r in twelve.readings)
                      Tag(
                        label: titled(r.sign),
                        kind: ChipKind.filter,
                        selected: r.sign == shown,
                        leading: Text(
                          signGlyph[r.sign] ?? '',
                          style: TextStyle(
                            fontFamily: Face.glyph,
                            fontSize: 13,
                            color: r.sign == shown ? Tone.accent : Gilt.gilt,
                          ),
                        ),
                        onTap: () => setState(() => _showing = r.sign),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                if (reading != null) ...[
                  Row(
                    children: [
                      Text(
                        signGlyph[reading.sign] ?? '',
                        style: const TextStyle(
                          fontFamily: Face.glyph,
                          fontSize: 20,
                          color: Gilt.gilt,
                        ),
                      ),
                      const SizedBox(width: Gap.sm),
                      Text(
                        titled(reading.sign).toUpperCase(),
                        style: const TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: Type.caption,
                          letterSpacing: 1.1,
                          color: Tone.faint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  Prose(text: reading.bodyMd, drop: true),
                ],
              ],

              const SizedBox(height: Gap.xl),
              const Rule(mark: '☾'),
              const SizedBox(height: Gap.md),
              // ⚠ Named for where it goes. Her decision was that the archive
              // lives on the site, and a person tapping this deserves to know
              // a browser is about to open rather than to think the app broke.
              Tap(
                icon: Icons.open_in_new,
                label: 'Earlier readings, on shrutivtuber.com',
                onTap: _openTheArchive,
              ),
              const SizedBox(height: Gap.sm),
              const Text(
                'This month is here. Past months, and every sign she has ever '
                'written, are on the site.',
                style: TextStyle(
                  fontFamily: Face.body,
                  fontFamilyFallback: [Face.glyph],
                  fontSize: Type.caption,
                  height: 1.6,
                  color: Tone.faint,
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

/// Which kind of period to read, limited to the ones she actually publishes.
class _Periods extends StatelessWidget {
  const _Periods({required this.chosen, required this.onPick});

  final String chosen;
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<String>>(
    future: periodsShePublishes(),
    builder: (context, snap) {
      final kinds = snap.data ?? const <String>[];
      // ⚠ One kind is not a choice. Showing a single chip that cannot be
      // unpicked is a control that does nothing, which is worse than no
      // control at all.
      if (kinds.length < 2) return const SizedBox.shrink();
      return TagRow(
        children: [
          for (final k in kinds)
            Tag(
              label: _kindName(k),
              kind: ChipKind.filter,
              selected: k == chosen,
              onTap: () => onPick(k),
            ),
        ],
      );
    },
  );

  static String _kindName(String period) => switch (period) {
    'daily' => 'Today',
    'weekly' => 'This week',
    'monthly' => 'This month',
    'yearly' => 'This year',
    _ => period,
  };
}
