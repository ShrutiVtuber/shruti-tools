// SPDX-License-Identifier: AGPL-3.0-only
//
// A tab with nothing behind it, and a screen nobody can reach.
//
// Two screens in this app hold several instruments behind a segmented control —
// Sky, and Letters — because a bottom bar holds about six labels before they
// stop being readable. Both have a list of segments and a list of children, and
// nothing in Dart makes them the same length.
//
// Get it wrong and there is no error: an extra segment shows an empty page, and
// an extra child is an instrument nobody can open. Both look like a bug in the
// instrument rather than in the bar.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  /// The files that pair a segmented control with an IndexedStack.
  ///
  /// ⚠ Practice is deliberately NOT here. Its two halves are built by a
  /// ternary rather than kept in a stack, because "Mine" should re-fetch when
  /// you switch to it — you may have just submitted something. Adding it to
  /// this list tests a pattern that file does not use.
  const paired = {
    'lib/screens/day.dart': 'Sky',
    'lib/screens/letters.dart': 'Letters',
  };

  for (final entry in paired.entries) {
    test('${entry.value}: every segment has a screen behind it', () {
      final source = File(entry.key).readAsStringSync();

      // ⚠ Reads the app's OWN control, not Material's. The segmented control
      // was Material's `SegmentedButton` and is now `Segmented`, which takes
      // its options as `(value, 'Label')` records — this test kept passing
      // against `ButtonSegment(` for exactly as long as it took somebody to
      // notice it was counting zero of them.
      final options = RegExp(
        r'options: const \[(.*?)\]',
        dotAll: true,
      ).firstMatch(source);
      expect(options, isNotNull, reason: '${entry.key} has no Segmented');
      final segments = RegExp(
        r"\(\s*\d+\s*,\s*'",
      ).allMatches(options!.group(1)!).length;
      // The children of the IndexedStack, whatever the trailing punctuation.
      final stack = RegExp(
        r'IndexedStack\((.*?)\n\s*\),',
        dotAll: true,
      ).firstMatch(source);
      expect(stack, isNotNull, reason: '${entry.key} has no IndexedStack');
      final children = RegExp(
        r'\w+Screen\(\)',
      ).allMatches(stack!.group(1)!).length;

      expect(
        children,
        segments,
        reason:
            '${entry.key}: $segments segments but $children screens. '
            'A spare segment opens an empty page; a spare screen is an '
            'instrument with no way in.',
      );
      expect(
        segments,
        greaterThanOrEqualTo(2),
        reason: 'a segmented control with one segment is not a control',
      );
    });

    test('${entry.value}: the segment values are 0..n with no gaps', () {
      final source = File(entry.key).readAsStringSync();
      final options = RegExp(
        r'options: const \[(.*?)\]',
        dotAll: true,
      ).firstMatch(source);
      final values = RegExp(r"\(\s*(\d+)\s*,\s*'")
          .allMatches(options!.group(1)!)
          .map((m) => int.parse(m.group(1)!))
          .toList();
      // ⚠ The value indexes the IndexedStack directly. A gap or a repeat is a
      // segment that opens the wrong instrument, silently.
      expect(values, [
        for (var i = 0; i < values.length; i++) i,
      ], reason: '${entry.key}: segment values are $values');
    });
  }
}
