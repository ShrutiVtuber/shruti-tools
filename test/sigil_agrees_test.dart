// SPDX-License-Identifier: AGPL-3.0-only
//
// The phone and the website must draw the SAME SIGIL.
//
// A practitioner types a statement into shrutivtuber.com, then types it again
// into the app, and gets two different figures — which one is theirs? The whole
// claim of the tool is that the geometry is deterministic and reproducible by
// hand, and two engines that disagree make that claim false.
//
// So this holds the Dart port against output captured from the site's own
// JavaScript, byte for byte, including the SVG.
//
// ⚠ **To regenerate after changing either engine:**
//   node shurtiwebsite/frontend/site/scripts/gen-sigil-fixture.mjs \
//     > test/fixtures/sigil_agreement.json
// and copy the same file to shurtiwebsite/frontend/site/test/fixtures/, where
// the site's own suite checks the JS against it. Both halves matter: this test
// alone would pass happily if the JS moved and the fixture moved with it.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shruti_tools/services/sigil.dart';

void main() {
  final cases =
      (jsonDecode(File('test/fixtures/sigil_agreement.json').readAsStringSync())
              as List)
          .cast<Map<String, dynamic>>();

  test('the fixture actually covers the corners', () {
    // Guards the guard. A fixture that quietly shrank to two happy cases would
    // still pass every assertion below.
    expect(cases.length, greaterThanOrEqualTo(10));
    expect(
      cases.where((c) => c['exhausted'] == true),
      isNotEmpty,
      reason: 'no case where the reduction eats the whole sentence',
    );
    expect(
      cases.where((c) => c['tooShort'] == true),
      isNotEmpty,
      reason: 'no case that reduces to a single letter',
    );
    expect(cases.map((c) => c['weight']).toSet(), hasLength(3));
    expect(cases.map((c) => c['enclosure']).toSet(), hasLength(3));
    expect(cases.where((c) => c['keepVowels'] == true), isNotEmpty);
  });

  for (final c in cases) {
    final statement = c['statement'] as String;
    final keepVowels = c['keepVowels'] as bool;
    final label =
        '"$statement"${keepVowels ? ' (vowels kept)' : ''} '
        'as ${c['weight']}/${c['enclosure']}';

    test('the reduction agrees with the website — $label', () {
      final r = reduce(statement, keepVowels: keepVowels);
      expect(r.lettersOnly, (c['lettersOnly'] as List).cast<String>());
      expect(r.afterVowels, (c['afterVowels'] as List).cast<String>());
      expect(r.unique, (c['unique'] as List).cast<String>());
      expect(r.exhausted, c['exhausted']);
      expect(r.tooShort, c['tooShort']);
    });

    test('the figure agrees with the website — $label', () {
      final r = reduce(statement, keepVowels: keepVowels);
      final f = cast(
        r.unique,
        weight: c['weight'] as String,
        enclosure: c['enclosure'] as String,
      );
      if (c['svg'] == null) {
        // The site returns null when there is nothing left to draw. So must we
        // — a blank 512×512 frame would be a figure the reader could export.
        expect(f, isNull, reason: 'drew something from an empty reduction');
        return;
      }
      expect(f, isNotNull);
      expect(toSvg(f!), c['svg'] as String);
    });
  }

  test('the exported file carries the letters and not the statement', () {
    // The screen promises the statement never leaves the device. Someone will
    // send this SVG to a friend.
    const secret = 'MY WILL IS TO OPEN THE DOOR';
    final r = reduce(secret);
    final svg = toSvg(cast(r.unique)!);
    expect(svg.contains('<title'), isFalse);
    expect(svg.contains('<desc'), isFalse);
    expect(svg.contains('<metadata'), isFalse);
    for (final word in secret.split(' ')) {
      expect(
        svg.toUpperCase().contains(word),
        isFalse,
        reason: '"$word" of the statement travelled with the file',
      );
    }
  });
}
