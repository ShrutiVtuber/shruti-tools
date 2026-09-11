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
  test('one enum defines the bodies, and it is the Hellenistic set', () {
    // ⚠ Stronger than checking each service. The body list used to be written
    // out in four places — the chart, the month's sky, the events scan and the
    // sky drawer — and four copies of a doctrine is four chances to disagree
    // with it. There is one now, and this is it.
    // ⚠ Comments stripped first, then sliced at the brace. The enum's own
    // documentation explains why the outer planets are absent — by naming them
    // — so a search of the raw file finds exactly the words it is looking for
    // and passes when the enum is wrong.
    final code = _code(File('lib/sky/sky.dart').readAsStringSync());
    final from = code.indexOf('enum Body');
    final body = code.substring(from, code.indexOf('}', from));

    for (final wanted in [
      'sun',
      'moon',
      'mercury',
      'venus',
      'mars',
      'jupiter',
      'saturn',
      'rahu',
    ]) {
      expect(body.contains('  $wanted'), isTrue, reason: '$wanted is missing');
    }
    for (final unwanted in ['uranus', 'neptune', 'pluto']) {
      expect(
        body.contains(unwanted),
        isFalse,
        reason: '$unwanted is in the enum, so every service can ask for it',
      );
    }
  });

  test('no service keeps its own list of bodies', () {
    // ⚠ The way the doctrine comes undone is not by someone adding Pluto to the
    // enum — it is by a service quietly keeping its own list again.
    for (final path in [
      'lib/services/chart.dart',
      'lib/services/period_sky.dart',
      'lib/services/events.dart',
    ]) {
      final code = _code(File(path).readAsStringSync());
      expect(
        code.contains('HeavenlyBody.SE_'),
        isFalse,
        reason:
            '$path names library constants directly again, so it can '
            'ask for a body the enum does not offer',
      );
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
