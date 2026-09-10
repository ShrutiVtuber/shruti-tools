// SPDX-License-Identifier: AGPL-3.0-only
//
// What happens in a period, with the Moon out of the planets' way.
//
// ⚠ The Moon is separated because it OUTNUMBERS everything else, not because
// it matters less. It crosses a sign every two and a half days: across a month
// it contributes thirteen crossings to a list where the planets contribute two
// or three, and somebody looking for "Mars enters Leo" scrolls past twelve
// lines about the Moon to find it. On a phone that is most of a screen.
//
// Its loud events keep full rows — a new moon is the spine of a monthly
// reading. Only the crossings compress, into a chain, which is what a lunar
// month actually is: one continuous movement.
//
// The same split, the same wording and the same hues as the website's writing
// desk. Somebody who writes at a desk and then on a train is looking at one
// instrument.
import 'package:flutter/material.dart';

import '../services/chart.dart' show signGlyphs;
import '../services/events.dart';
import '../theme/tokens.dart';

/// Cold to warm, in the order the wheel bands them.
const _hue = {
  'Saturn': Color(0xFF7C86A8),
  'Jupiter': Color(0xFF6E93C4),
  'Mercury': Color(0xFF86BFD6),
  'Venus': Color(0xFFB9A6D8),
  'Mars': Color(0xFFD98C93),
  'Sun': Color(0xFFE0B978),
  'Moon': Color(0xFF8A93B5),
};

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _day(DateTime at) => '${at.day} ${_months[at.month - 1]}';

class PeriodEvents extends StatelessWidget {
  const PeriodEvents({super.key, required this.events});

  final List<SkyEvent> events;

  @override
  Widget build(BuildContext context) {
    final planets = events.where((e) => e.body != 'Moon').toList();
    final moonLoud = events
        .where((e) => e.body == 'Moon' && e.kind != EventKind.ingress)
        .toList();
    final crossings = events
        .where((e) => e.body == 'Moon' && e.kind == EventKind.ingress)
        .toList();

    if (events.isEmpty) {
      return const Text(
        'Nothing ingresses, stations or lunates inside it. That is itself '
        'worth saying in a reading — a quiet period reads differently from a '
        'loud one.',
        style: TextStyle(color: Tone.faint, fontSize: 13, height: 1.5),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (planets.isNotEmpty) ...[
          const _Sub('The planets'),
          for (final e in planets) _Row(event: e),
        ],
        if (moonLoud.isNotEmpty || crossings.isNotEmpty) ...[
          const SizedBox(height: Gap.md),
          const _Sub('The Moon'),
          for (final e in moonLoud) _Row(event: e),
          if (crossings.isNotEmpty) ...[
            const SizedBox(height: Gap.sm),
            const Text(
              'and it crosses',
              style: TextStyle(color: Tone.faint, fontSize: 12),
            ),
            const SizedBox(height: Gap.xs),
            Wrap(
              spacing: Gap.xs,
              runSpacing: Gap.xs,
              children: [for (final e in crossings) _Chip(event: e)],
            ),
          ],
        ],
      ],
    );
  }
}

class _Sub extends StatelessWidget {
  const _Sub(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Gap.sm),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Tone.faint,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.event});
  final SkyEvent event;

  @override
  Widget build(BuildContext context) {
    final hue = _hue[event.body] ?? Tone.faint;
    final loud =
        event.kind == EventKind.retrograde ||
        event.kind == EventKind.direct ||
        event.kind == EventKind.newMoon ||
        event.kind == EventKind.fullMoon;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Tone.card,
        borderRadius: BorderRadius.circular(Corner.sm),
        border: Border.all(color: Tone.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // The hue rides the left edge, never the text — colour that can be
          // scanned down a column without ever being what carries the meaning.
          Container(width: 3, height: 38, color: hue),
          const SizedBox(width: Gap.md),
          SizedBox(
            width: 22,
            child: Text(
              event.glyph,
              style: TextStyle(
                fontFamily: 'AstroSymbols',
                fontSize: 15,
                color: hue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              event.title,
              style: TextStyle(
                color: loud ? Tone.ink : Tone.soft,
                fontSize: 13.5,
                fontWeight: loud ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: Gap.md),
            child: Text(
              _day(event.at),
              style: const TextStyle(
                color: Tone.faint,
                fontSize: 12,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.event});
  final SkyEvent event;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: Tone.card,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Tone.line),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          signGlyphs[event.sign ?? 0],
          style: const TextStyle(
            fontFamily: 'AstroSymbols',
            fontSize: 13,
            color: Color(0xFF8A93B5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          _day(event.at),
          style: const TextStyle(
            color: Tone.faint,
            fontSize: 11.5,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}
