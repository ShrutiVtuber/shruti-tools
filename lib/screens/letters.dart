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
import '../widgets/brand.dart';
import '../widgets/parts.dart';
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
  Widget build(BuildContext context) => Scaffold(
    appBar: const Bar(title: 'Letters'),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.sm),
          child: Segmented<int>(
            options: const [(0, 'Reckoning'), (1, 'Sigil')],
            chosen: _which,
            onChosen: (i) => setState(() => _which = i),
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
    ),
  );
}
