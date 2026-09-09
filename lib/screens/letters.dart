// SPDX-License-Identifier: AGPL-3.0-only
//
// The letter-work tab: reckoning and sigils under one roof.
//
// Two instruments, one bar. Seven bottom tabs on a phone is a row of things
// nobody can read, and these two belong together anyway — both take letters and
// turn them into something that is not letters. Reckoning gives a number,
// sigils give a figure.
//
// ⚠ The two do NOT share their input. The sigil screen promises that what is
// typed on it is never stored or sent; carrying its text across to the
// reckoning field — even in memory, even helpfully — would quietly break that.
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'isopsephy.dart';
import 'sigil.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> {
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
              label: Text('Reckoning'),
              icon: Icon(Icons.tag_outlined, size: 18),
            ),
            ButtonSegment(
              value: 1,
              label: Text('Sigil'),
              icon: Icon(Icons.gesture_outlined, size: 18),
            ),
          ],
          selected: {_which},
          onSelectionChanged: (s) => setState(() => _which = s.first),
          showSelectedIcon: false,
        ),
      ),
      Expanded(
        // IndexedStack, not a swap: an installed pack list and a typed
        // statement both survive flipping between the two.
        child: IndexedStack(
          index: _which,
          children: const [IsopsephyScreen(), SigilScreen()],
        ),
      ),
    ],
  );
}
