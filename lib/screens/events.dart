// SPDX-License-Identifier: AGPL-3.0-only
//
// What the sky does next.
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/events.dart';
import '../services/settings.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  Place _place = Place.london;
  List<SkyEvent> _events = const [];
  int _days = 30;
  bool _working = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final place = await savedPlace();
    if (place != null && mounted) setState(() => _place = place);
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

        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 7, label: Text('Week')),
            ButtonSegment(value: 30, label: Text('Month')),
            ButtonSegment(value: 90, label: Text('Season')),
          ],
          selected: {_days},
          showSelectedIcon: false,
          onSelectionChanged: (s) {
            setState(() => _days = s.first);
            _compute();
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: Tone.card,
            foregroundColor: Tone.soft,
            selectedBackgroundColor: Tone.accentWash,
            selectedForegroundColor: Tone.accent,
            side: const BorderSide(color: Tone.line),
          ),
        ),
        const SizedBox(height: Gap.xl),

        if (_working)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Gap.xxl),
            child: Center(child: CircularProgressIndicator(color: Tone.accent)),
          )
        else if (_events.isEmpty)
          Text(
            'Nothing in this window.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          ..._grouped(context),
      ],
    );
  }

  /// Grouped by day, because "what is happening this week" is read a day at a
  /// time and a flat list of forty rows is not read at all.
  List<Widget> _grouped(BuildContext context) {
    final out = <Widget>[];
    String? lastDay;
    for (final e in _events) {
      final there = _place.tell(e.at);
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
      out.add(_EventRow(event: e, place: _place));
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
