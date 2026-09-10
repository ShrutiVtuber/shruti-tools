// SPDX-License-Identifier: AGPL-3.0-only
//
// What the sky does next.
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/events.dart';
import '../services/ephemeris.dart';
import '../services/settings.dart';
import '../theme/glyph.dart';
import '../theme/tokens.dart';
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
      padding: const EdgeInsets.fromLTRB(
        Gap.gutterDense,
        Gap.md,
        Gap.gutterDense,
        Gap.huge,
      ),
      children: [
        Segmented<int>(
          options: const [(7, 'Week'), (30, 'Month'), (90, 'Season')],
          chosen: _days,
          onChosen: (d) {
            setState(() => _days = d);
            _compute();
          },
        ),
        const SizedBox(height: Gap.md),

        if (_working)
          const Column(
            children: [
              Pressable(padding: EdgeInsets.all(14), child: Skeleton(lines: 1)),
              SizedBox(height: 10),
              Pressable(padding: EdgeInsets.all(14), child: Skeleton(lines: 1)),
              SizedBox(height: 10),
              Pressable(padding: EdgeInsets.all(14), child: Skeleton(lines: 1)),
            ],
          )
        // ⚠ Authored, not "No data". A quiet sky is a fact about the sky, and
        // a reader should be told which quiet they are looking at.
        else if (_events.isEmpty)
          EmptyState(
            mark: '♄',
            title: 'Nothing in the next $_days days',
            body: 'The sky is quiet. That happens, and it is not an error.',
          )
        else
          for (final e in _events)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Coming(event: e, place: place),
            ),

        const SizedBox(height: Gap.xxl),
        Provenance(
          facts: [
            ('Engine', engineVersion),
            ('Computed', 'on this phone · nothing sent, nothing stored'),
            (
              'found by',
              'a coarse scan for the crossing, then bisection to the minute',
            ),
            ('Told in', place.zone),
          ],
        ),
      ],
    );
  }
}

/// One thing the sky is about to do.
///
/// ⚠ A station is CAUTION and everything else is plain — and the caution is a
/// rose ring and a rose mark and the word "stations", never the tint alone.
class _Coming extends StatelessWidget {
  const _Coming({required this.event, required this.place});

  final SkyEvent event;
  final Place place;

  @override
  Widget build(BuildContext context) {
    final loud =
        event.kind == EventKind.retrograde || event.kind == EventKind.direct;
    final there = place.tell(event.at);
    return Pressable(
      tone: loud ? Surface.warning : Surface.plain,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Tone.inset,
              shape: BoxShape.circle,
              border: Border.all(
                color: loud ? Tone.rose.withValues(alpha: 0.4) : Tone.line,
              ),
            ),
            child: Glyph(
              event.glyph,
              size: 15,
              color: loud ? Tone.rose : Gilt.gilt,
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_weekday(there.weekday)} ${there.day} '
                          '${_month(there.month)}'
                      .toUpperCase(),
                  style: TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: Type.eyebrow,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.54,
                    color: loud ? Tone.rose : Tone.faint,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontFamily: Face.display,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: 17,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Tone.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${there.hour.toString().padLeft(2, "0")}:'
                  '${there.minute.toString().padLeft(2, "0")} ${place.shortName}',
                  style: const TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: Type.caption,
                    height: 1.4,
                    color: Tone.faint,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
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
