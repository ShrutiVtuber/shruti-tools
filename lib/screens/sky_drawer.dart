// SPDX-License-Identifier: AGPL-3.0-only
//
// The sky in full — a month of it, as a printed ephemeris would give it.
//
// This is the reference the writing screens open beside them: every day's
// positions, the retrogrades marked, the phase, and the month drawn as a wheel
// underneath. It is deliberately a full-screen sheet rather than a tab: it is
// something you consult and close, not somewhere you live.
//
// ⚠ **It fits.** Seven columns of a month on a phone is only possible at
// thirteen-point tabular figures with no sideways scroll, which is exactly
// what the design system asks for and exactly what a practitioner wants. If a
// column will not fit, the column goes — never the density.
import 'package:flutter/material.dart';

import '../services/chart.dart' show signGlyphs;
import '../services/ephemeris.dart';
import '../services/events.dart';
import '../services/period_sky.dart';
import '../theme/tokens.dart';
import '../widgets/data.dart';
import '../widgets/forms.dart';
import '../widgets/eyebrow.dart';
import '../widgets/parts.dart';
import '../widgets/period_events.dart';
import '../widgets/period_wheel.dart';

/// [opensOn] is the month to land on — the period being written for, when it
/// is opened from the writing screen. ⚠ Opening on "today" beside a reading
/// for next March is a reference for the wrong sky, which is worse than none.
Future<void> showSkyDrawer(BuildContext context, {DateTime? opensOn}) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => SkyDrawer(opensOn: opensOn),
      ),
    );

class SkyDrawer extends StatefulWidget {
  const SkyDrawer({super.key, this.opensOn});

  final DateTime? opensOn;

  @override
  State<SkyDrawer> createState() => _SkyDrawerState();
}

class _SkyDrawerState extends State<SkyDrawer> {
  late DateTime _month = DateTime.utc(
    (widget.opensOn ?? DateTime.now()).year,
    (widget.opensOn ?? DateTime.now()).month,
  );
  bool _retrogradesOnly = false;
  List<SkyDay> _days = const [];
  List<SkyEvent> _events = const [];

  @override
  void initState() {
    super.initState();
    _read();
  }

  void _read() {
    final from = _month;
    final to = DateTime.utc(_month.year, _month.month + 1, 0);
    setState(() {
      _days = skyAcross(from, to);
      _events = eventsAcross(from, to);
    });
  }

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Which bodies are retrograde on a given day — from the motion itself,
  /// rather than from a table of station dates somebody has to maintain.
  Set<String> _retrograde(int index) {
    if (index + 1 >= _days.length) return const {};
    final out = <String>{};
    for (final body in periodBodies) {
      final a = _days[index].longitudes[body];
      final b = _days[index + 1].longitudes[body];
      if (a == null || b == null) continue;
      var step = b - a;
      if (step < -180) step += 360;
      if (step > 180) step -= 360;
      if (step < 0) out.add(body);
    }
    return out;
  }

  static String _position(double longitude) {
    final degrees = (longitude % 30).floor();
    final sign = signGlyphs[((longitude ~/ 30) % 12).toInt()];
    return '${degrees.toString().padLeft(2, "0")}°$sign';
  }

  @override
  Widget build(BuildContext context) {
    // ⚠ All seven, not five. The table stopped after Mars, so Jupiter and
    // Saturn were not missing from the screen — they were missing from the
    // ephemeris, with nothing to say so.
    final shown = [
      'Sun',
      'Moon',
      'Mercury',
      'Venus',
      'Mars',
      'Jupiter',
      'Saturn',
    ];
    const marks = {
      'Sun': '☉',
      'Moon': '☾',
      'Mercury': '☿',
      'Venus': '♀',
      'Mars': '♂',
      'Jupiter': '♃',
      'Saturn': '♄',
    };
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);

    final rows = <Line>[];
    for (var i = 0; i < _days.length; i++) {
      final back = _retrograde(i);
      if (_retrogradesOnly && back.isEmpty) continue;
      final day = _days[i];
      rows.add(
        Line([
          Cell(
            '${int.parse(day.date.substring(8))} '
            '${_months[_month.month - 1].substring(0, 3)}',
          ),
          for (final body in shown)
            Cell(
              _position(day.longitudes[body] ?? 0),
              retrograde: back.contains(body),
            ),
          Cell('${(day.lit * 100).round()}%'),
        ], now: day.date == today),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sky drawer'),
            Text(
              'Ephemeris · ${_months[_month.month - 1]} ${_month.year}',
              style: const TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: 12,
                height: 1.3,
                color: Tone.faint,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Gap.gutterDense,
          Gap.md,
          Gap.gutterDense,
          Gap.huge,
        ),
        children: [
          TagRow(
            children: [
              for (var step = -1; step <= 1; step++)
                Builder(
                  builder: (context) {
                    final m = DateTime.utc(
                      _month.year,
                      DateTime.now().month + step,
                    );
                    return Tag(
                      label: _months[m.month - 1],
                      selected: m.month == _month.month,
                      onTap: () {
                        setState(() => _month = m);
                        _read();
                      },
                    );
                  },
                ),
              Tag(
                label: 'Show ℞ only',
                kind: ChipKind.filter,
                selected: _retrogradesOnly,
                onTap: () =>
                    setState(() => _retrogradesOnly = !_retrogradesOnly),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),

          if (rows.isEmpty)
            const EmptyState(
              mark: '℞',
              title: 'Nothing retrograde this month',
              body:
                  'Every body in the table is direct for the whole month. '
                  'That is worth knowing too.',
            )
          else
            Reference(
              zebra: true,
              caption: 'Geocentric, apparent · midnight UT · tropical',
              // 62 for the day, then a readable column each.
              minWidth: 62 + (shown.length + 1) * 58,
              columns: [
                const Heading(label: 'Day', flex: 6),
                for (final body in shown)
                  Heading(
                    label: body,
                    mark: marks[body],
                    numeric: true,
                    flex: 5,
                  ),
                const Heading(label: 'Lit', numeric: true, flex: 4),
              ],
              rows: rows,
            ),

          // ⚠ The margin notes a printed ephemeris puts beside the columns —
          // ingresses, stations, phases and eclipses. The website has them as
          // a column because it has the width; on a phone they go below,
          // because the alternative is an eighth column and the table must
          // FIT. Same facts, same order, the Moon kept out of the planets'
          // way.
          const SizedBox(height: Gap.lg),
          const Eyebrow('What happens in it'),
          const SizedBox(height: Gap.md),
          PeriodEvents(events: _events),

          const SizedBox(height: Gap.md),
          if (_days.length > 1)
            Pressable(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Eyebrow('The month, drawn'),
                  const SizedBox(height: Gap.md),
                  AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: PeriodWheelPainter(
                        days: _days,
                        events: _events,
                        rising: 0,
                        houseNumbers: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: Gap.xxl),
          Provenance(
            facts: [
              ('Engine', engineVersion),
              ('Computed', 'on this phone · nothing sent, nothing stored'),
              ('Positions', 'geocentric, apparent, midnight UT'),
              ('Zodiac', 'tropical'),
              (
                '℞',
                'read from the motion itself, not from a table of station '
                    'dates that would have to be kept',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
