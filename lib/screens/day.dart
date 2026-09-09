// SPDX-License-Identifier: AGPL-3.0-only
//
// The day, divided: its stations and its hours.
//
// Two instruments under one tab, the same arrangement as Letters. They belong
// together — both answer "where is the day now" and both are read from the same
// sunrise — and pairing them leaves a slot in a bar that only holds six before
// nobody can read the labels.
//
// ⚠ They share the sunrise convention through Settings, not through here. The
// two disagreeing about when the day starts is the bug `tabs_agree_test.dart`
// exists to catch.
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'home.dart';
import 'hours.dart';

class DayScreen extends StatefulWidget {
  const DayScreen({super.key});

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
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
          children: const [StationsScreen(), HoursScreen()],
        ),
      ),
    ],
  );
}
