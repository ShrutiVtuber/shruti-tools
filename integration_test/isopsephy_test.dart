// SPDX-License-Identifier: AGPL-3.0-only
//
// Letter-reckoning, against values anybody can check.
//
// ΙΗΣΟΥΣ is 888, ἀγάπη is 93 and ΑΒΡΑΣΑΞ is 365 — the three most-cited
// isopsephic sums there are, attested from the Sibylline oracles onward and
// agreeing with her own engine. A table loaded wrong gives a confident number
// that is simply not the one two thousand years of people arrived at.
//
// The packs are downloaded, not faked. A fake table would prove the arithmetic
// around it and nothing about the arithmetic itself, which is the trap
// astropractise recorded about its ephemeris.
//
// ⚠ Point it at the local stack, not at production:
//
//     adb reverse tcp:8200 tcp:8200
//     flutter test integration_test/isopsephy_test.dart -d <device> \
//       --dart-define=SHRUTI_SITE=http://127.0.0.1:8200
//
// Run against shrutivtuber.com it fails on whatever the phone's DNS is doing —
// which it did, and the failure said "No address associated with hostname"
// rather than anything about isopsephy.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shruti_tools/services/isopsephy.dart';
import 'package:shruti_tools/services/packs.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late NumberSystem greek;

  setUpAll(() async {
    final offered = await availablePacks();
    expect(offered, isNotEmpty, reason: 'the site listed no packs');

    // Only what this test needs: the Greek letter values, and the smallest
    // corpus that uses them. Downloading the 4.3MB Diorisis corpus to check a
    // sum would be spending somebody's afternoon to prove nothing extra.
    for (final want in ['numbers-greek', 'words-sepher-sephiroth']) {
      final pack = offered.firstWhere((p) => p.file.contains(want));
      expect(await installPack(pack), isNull, reason: 'installing $want');
    }

    final systems = await installedSystems();
    greek = systems.firstWhere((s) => s.id == 'greek-milesian');
  });

  group('the reckoning agrees with two thousand years of people', () {
    test('ΙΗΣΟΥΣ is 888', () {
      expect(greek.reckon('ΙΗΣΟΥΣ').total, 888);
    });

    test('ΑΒΡΑΣΑΞ is 365', () {
      expect(greek.reckon('ΑΒΡΑΣΑΞ').total, 365);
    });

    test('ἀγάπη is 93, accents and all', () {
      // The fold is the point: ἀ is a different codepoint from α and carries
      // no value of its own. Without the folding this comes out short and
      // still looks like a number.
      expect(greek.reckon('ἀγάπη').total, 93);
    });

    test('lower case counts the same as upper', () {
      expect(greek.reckon('ιησους').total, greek.reckon('ΙΗΣΟΥΣ').total);
    });
  });

  group('what it refuses to do', () {
    test('a character with no value is reported, not silently zero', () {
      // "ΑΒΓ!" and "ΑΒΓ" are the same number for different reasons, and only
      // one of them is what somebody meant to type.
      final r = greek.reckon('ΑΒΓ!');
      expect(r.total, 6);
      expect(r.ignored, contains('!'));
    });

    test('Latin letters in a Greek reckoning are called out', () {
      // The commonest real mistake: a Latin A looks exactly like Alpha and is
      // worth nothing at all.
      final r = greek.reckon('ABΓ');
      expect(r.ignored, isNotEmpty);
    });

    test('spaces are not an error', () {
      expect(greek.reckon('ΑΒΓ ΑΒΓ').ignored, isEmpty);
      expect(greek.reckon('ΑΒΓ ΑΒΓ').total, 12);
    });
  });

  group('words are only ever found inside one system', () {
    test('a Hebrew corpus is never searched for a Greek number', () async {
      // The one rule this tool must not break: a Greek 598 and a Hebrew 598
      // are two different questions that happen to have the same answer.
      // Sepher Sephiroth is Hebrew, and it is installed.
      final found = await wordsAt('greek-milesian', 26);
      expect(found.every((m) => m.corpus != 'Sepher Sephiroth'), isTrue);
    });

    test('and a Hebrew number does find the Hebrew corpus', () async {
      // 26 is יהוה, the most-cited value in the whole index.
      final found = await wordsAt('hebrew', 26);
      expect(found, isNotEmpty, reason: 'Sepher Sephiroth should answer at 26');
      expect(found.first.corpus, 'Sepher Sephiroth');
    });
  });
}
