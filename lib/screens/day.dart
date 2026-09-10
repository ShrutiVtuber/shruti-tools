// SPDX-License-Identifier: AGPL-3.0-only
//
// The sky over time: the day's stations, its hours, and what is coming.
//
// Three instruments under one tab. They belong together — each answers "where
// are we in something", and the first two are read from the same sunrise — and
// grouping them leaves room in a bar that holds about six before nobody can
// read the labels.
//
// ⚠ They share the sunrise convention through Settings, not through here. The
// two disagreeing about when the day starts is the bug `tabs_agree_test.dart`
// exists to catch.
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'events.dart';
import 'home.dart';
import 'hours.dart';

class SkyScreen extends StatefulWidget {
  const SkyScreen({super.key});

  @override
  State<SkyScreen> createState() => _SkyScreenState();
}

class _SkyScreenState extends State<SkyScreen> {
  int _which = 0;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 0),
        child: SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              label: Text('Stations'),
              icon: Icon(Icons.wb_twilight_outlined, size: 18),
            ),
            ButtonSegment(
              value: 1,
              label: Text('Hours'),
              icon: Icon(Icons.schedule_outlined, size: 18),
            ),
            ButtonSegment(
              value: 2,
              label: Text('Coming'),
              icon: Icon(Icons.auto_awesome_outlined, size: 18),
            ),
          ],
          selected: {_which},
          onSelectionChanged: (s) => setState(() => _which = s.first),
          showSelectedIcon: false,
        ),
      ),
      Expanded(
        // IndexedStack: flipping between them must not recompute a table
        // that was right a second ago.
        child: IndexedStack(
          index: _which,
          children: const [StationsScreen(), HoursScreen(), EventsScreen()],
        ),
      ),
    ],
  );
}
