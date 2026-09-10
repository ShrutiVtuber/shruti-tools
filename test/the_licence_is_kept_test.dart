// SPDX-License-Identifier: AGPL-3.0-only
//
// The licence notice is an obligation, and obligations need tests.
//
// Swiss Ephemeris is dual-licensed. This app takes the AGPL option, which
// requires the whole project to be AGPL, the source to be available, and "the
// copyright notices and this notice to be preserved on all copies". A compiled
// APK is a copy — so the notice has to survive into the binary, not merely sit
// in the repository.
//
// ⚠ And one prohibition that is easy to break by being friendly: Astrodienst
// and the authors may appear ONLY inside that notice. A "powered by" line in a
// store listing, on a stream, or anywhere in the app's own copy would breach
// it. Naming the SOFTWARE is fine; naming them is not.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final licences = File('lib/screens/licences.dart').readAsStringSync();

  test('the notice is kept, and kept whole', () {
    for (final line in [
      'Copyright (C) 1997 - 2021 Astrodienst AG',
      'NO WARRANTY OF ANY KIND',
      'dual licensing',
      'Dieter Koch and Alois Treindl',
      'must not be',
    ]) {
      expect(
        licences,
        contains(line),
        reason: 'the Swiss Ephemeris notice has lost: $line',
      );
    }
  });

  test('which licence was chosen is stated', () {
    // The licence requires the choice to be made before distributing, and
    // saying which one is how anybody can check the rest follows.
    expect(licences, contains('AGPL option'));
  });

  test('the source is offered, because the AGPL requires it', () {
    expect(licences, contains('github.com/ShrutiVtuber/astrolabe'));
  });

  test('their names appear NOWHERE but the notice', () {
    // Every Dart file in the app, and the store-facing strings with it.
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('screens/licences.dart')) continue;
      final source = entity.readAsStringSync();
      for (final name in ['Astrodienst', 'Treindl', 'Dieter Koch']) {
        if (source.contains(name)) offenders.add('${entity.path}: $name');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'the copyright notice is the ONLY place these names may '
          'legally appear:\n  ${offenders.join("\n  ")}',
    );
  });

  test('the app describes itself as AGPL where a reader can see it', () {
    expect(licences, contains('Affero'));
    expect(File('pubspec.yaml').readAsStringSync(), contains('astrolabe'));
  });

  test('the packs are excluded from the licence, in writing', () {
    // ⚠ The language packs are all-rights-reserved and are downloaded rather
    // than bundled. Somebody reading the AGPL notice must not conclude the
    // packs came with it.
    expect(licences, contains('all rights reserved'));
    expect(licences, contains('not covered by the licence'));
  });
}
