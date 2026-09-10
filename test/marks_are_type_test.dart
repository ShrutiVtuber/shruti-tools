// SPDX-License-Identifier: AGPL-3.0-only
//
// Every astronomical mark is set as TYPE, never handed to an emoji font.
//
// ⚠ This is a real defect and it was shipping: the ephemeris table came back
// as a grid of green and orange circles, because Commissioner has no ♈ and
// the platform fell through to the colour-emoji font — which ignores `color`
// outright, so the mark arrives in somebody else's palette at somebody else's
// weight. On a table of positions it destroys the whole figure.
//
// Two halves, and both are easy to forget:
//
//   1. U+FE0E on the character — the request for text presentation.
//   2. AstroSymbols in the family stack — which face answers.
//
// A style that names a family without the fallback is the leak, so the test
// reads the source rather than a rendering: a rendering only fails on the
// screen somebody happens to have opened.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no text style names a face without the glyph fallback', () {
    final offenders = <String>[];

    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!RegExp(r'fontFamily: Face\.(body|display)').hasMatch(line)) {
          continue;
        }
        // The fallback may be on this line or the next — the formatter moves
        // it depending on how much room the line has.
        final next = i + 1 < lines.length ? lines[i + 1] : '';
        if (!line.contains('fontFamilyFallback') &&
            !next.contains('fontFamilyFallback')) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These styles name a face with no AstroSymbols fallback, so any '
          'astronomical mark in them is handed to the emoji font:\n'
          '${offenders.join("\n")}',
    );
  });

  test('the glyph helper emits the variation selector', () {
    final source = File('lib/theme/glyph.dart').readAsStringSync();
    // ⚠ U+FE0E itself, not the escape: the point is that the real character is
    // in the string that ships.
    expect(source.contains('︎'), isTrue);
    expect(source.contains("fontFamily: Face.glyph"), isTrue);
  });
}
