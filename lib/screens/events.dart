// SPDX-License-Identifier: AGPL-3.0-only
//
// What the sky does next.
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/events.dart';
import '../services/ephemeris.dart';
import '../services/settings.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';
import '../widgets/parts.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<SkyEvent> _events = const [];
  int _days = 30;
  bool _working = true;

  @override
  void initState() {
    super.initState();
    _compute();
  }

  void _compute() {
    setState(() => _working = true);
    final now = DateTime.now().toUtc();
    // Synchronous and a little slow — a month of scanning is a few thousand
    // ephemeris calls. Fast enough not to need an isolate, slow enough that
    // the screen says it is working rather than appearing to have frozen.
    final found = eventsBetween(now, now.add(Duration(days: _days)));
    if (!mounted) return;
    setState(() {
      _events = found;
      _working = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only for TELLING the time — the events themselves are the same sky
    // everywhere, and their instants do not depend on where anyone is.
    final place = SettingsScope.of(context).place;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
      children: [
        Text('What next', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: Gap.xs),
        Text(
          'Ingresses, stations and lunations — computed here, so this page '
          'works with no signal.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Gap.lg),

        Segmented<int>(
          options: const [(7, 'Week'), (30, 'Month'), (90, 'Season')],
          chosen: _days,
          onChosen: (d) {
            setState(() => _days = d);
            _compute();
          },
        ),
        const SizedBox(height: Gap.xl),

        if (_working)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Gap.xxl),
            child: Center(child: CircularProgressIndicator(color: Tone.accent)),
          )
        // ⚠ Authored, not "No data". A quiet sky is a fact about the sky,
        // and a reader should be told which quiet they are looking at.
        else if (_events.isEmpty)
          EmptyState(
            mark: '♄',
            title: 'The sky is quiet',
            body:
                'Nothing ingresses, stations or lunates in the next '
                '$_days days. That is not an error — some stretches are '
                'simply uneventful, and that is worth knowing too.',
          )
        else
          ..._grouped(context, place),

        const SizedBox(height: Gap.xxl),
        Provenance(
          facts: [
            ('engine', engineVersion),
            ('computed', 'on this phone · nothing sent, nothing stored'),
            (
              'found by',
              'a coarse scan for the crossing, then bisection to the minute',
            ),
            ('told in', place.zone),
          ],
        ),
      ],
    );
  }

  /// Grouped by day, because "what is happening this week" is read a day at a
  /// time and a flat list of forty rows is not read at all.
  List<Widget> _grouped(BuildContext context, Place place) {
    final out = <Widget>[];
    String? lastDay;
    for (final e in _events) {
      final there = place.tell(e.at);
      final day = '${there.year}-${there.month}-${there.day}';
      if (day != lastDay) {
        if (lastDay != null) out.add(const SizedBox(height: Gap.lg));
        out.add(
          Eyebrow(
            '${_weekday(there.weekday)} '
            '${there.day} ${_month(there.month)}',
          ),
        );
        out.add(const SizedBox(height: Gap.sm));
        lastDay = day;
      }
      out.add(_EventRow(event: e, place: place));
      out.add(const SizedBox(height: Gap.sm));
    }
    return out;
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.place});

  final SkyEvent event;
  final Place place;

  @override
  Widget build(BuildContext context) {
    final there = place.tell(event.at);
    final notable =
        event.kind == EventKind.newMoon ||
        event.kind == EventKind.fullMoon ||
        event.kind == EventKind.retrograde ||
        event.kind == EventKind.direct;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      decoration: BoxDecoration(
        color: Tone.card,
        borderRadius: BorderRadius.circular(Corner.sm),
        border: Border.all(color: notable ? Tone.lineStrong : Tone.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              event.glyph,
              style: TextStyle(
                fontFamily: 'AstroSymbols',
                fontSize: 17,
                color: notable ? Tone.accent : Tone.soft,
              ),
            ),
          ),
          Expanded(
            child: Text(
              event.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            '${there.hour.toString().padLeft(2, '0')}:'
            '${there.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

String _weekday(int w) => const [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][w - 1];

String _month(int m) => const [
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
][m - 1];
