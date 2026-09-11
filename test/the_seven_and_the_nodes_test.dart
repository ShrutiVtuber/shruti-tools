// SPDX-License-Identifier: AGPL-3.0-only
//
// Seven wandering stars and two nodes. Not ten.
//
// ⚠ **This is doctrine, not a shortcut.** Her practice is Hellenistic, which
// reads the seven visible wanderers and the lunar nodes; Uranus, Neptune and
// Pluto were not known to it and are not read. Her words, 11 September 2026:
// "we don't track uranus neptune or pluto so it's fine for them not to be
// included and they shouldn't be in the app anyway".
//
// It is also what the WEBSITE returns — its chart engine offers the seven and
// the nodes in every tradition it accepts, and never the outer three. Before
// this the app drew ten bodies where the site drew seven, and nothing said so.
//
// ⚠ And it is what makes the app shippable on iOS. The outer three are the
// only bodies a public-domain ephemeris cannot cover cleanly: VSOP87 has no
// Pluto at all, and the usual public-domain series for it is valid only from
// 1885 while the app accepts birth dates from 1800. Removing them is not a
// concession to that — it is doctrine that happens to also remove the hardest
// part of leaving the Swiss Ephemeris behind.
//
// They may return as an OPTION if the Swiss Ephemeris is ever licensed
// commercially. Never as a default.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source with comments stripped — this file's own prose names all three.
String _code(String s) => s
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), ' ');

const outer = ['SE_URANUS', 'SE_NEPTUNE', 'SE_PLUTO'];

void main() {
  test('the chart draws the seven and the nodes', () {
    final code = _code(File('lib/services/chart.dart').readAsStringSync());
    for (final body in outer) {
      expect(
        code.contains(body),
        isFalse,
        reason:
            '$body is in the natal chart, which reads Hellenistically '
            'and which the website does not return',
      );
    }
    for (final body in [
      'SE_SUN',
      'SE_MOON',
      'SE_MERCURY',
      'SE_VENUS',
      'SE_MARS',
      'SE_JUPITER',
      'SE_SATURN',
      'SE_TRUE_NODE',
    ]) {
      expect(code.contains(body), isTrue, reason: '$body is missing');
    }
  });

  test("the month's sky draws the same seven", () {
    final code = _code(File('lib/services/period_sky.dart').readAsStringSync());
    for (final body in outer) {
      expect(
        code.contains(body),
        isFalse,
        reason: '$body is computed for the sky drawer',
      );
    }
  });

  test('no switch offers them', () {
    // ⚠ A chip that turns them on is the same thing as shipping them: the
    // ephemeris still has to be able to answer for them.
    final code = _code(File('lib/screens/sky_drawer.dart').readAsStringSync());
    expect(
      code.contains('_modern'),
      isFalse,
      reason: 'the modern-planets switch is still there',
    );
    expect(
      code.contains('Uranus'),
      isFalse,
      reason: 'the sky drawer still names an outer planet',
    );
  });
}
