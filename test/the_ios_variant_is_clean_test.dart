// SPDX-License-Identifier: AGPL-3.0-only
//
// The iOS build must not contain the Swiss Ephemeris.
//
// ⚠ **Not "must not call it" — must not CONTAIN it.** A package listed in
// pubspec.yaml has its native side compiled into the binary whether or not a
// line of Dart touches it, so a runtime switch would leave AGPL code inside an
// App Store binary and the whole exercise pointless. The dependency has to be
// absent, which is what tool/make_ios_variant.sh removes.
//
// ⚠ These guards run on the ANDROID checkout and check the script, not its
// output — the variant is made in CI on a throwaway tree. What they protect is
// the property that makes the script possible: exactly one file names the
// library, and exactly one file names an engine.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String s) => s
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), ' ');

void main() {
  test('only one file imports the library', () {
    // ⚠ The property the variant script depends on. If a second file imports
    // it, deleting the first leaves the build broken and the script's one-line
    // removal silently insufficient.
    final importers = <String>[];
    for (final e in Directory('lib').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      if (_code(e.readAsStringSync()).contains('package:sweph')) {
        importers.add(e.path);
      }
    }
    // ⚠ Two trees, two right answers. On the Android checkout exactly one file
    // imports it; on a tree the variant script has been run over, NONE does —
    // which is the whole point, and is the stronger statement. Asserting the
    // first everywhere makes this test fail on the very tree it certifies.
    final swissExists = File('lib/sky/swiss.dart').existsSync();
    expect(
      importers,
      equals(swissExists ? ['lib/sky/swiss.dart'] : <String>[]),
      reason: swissExists
          ? 'the Swiss Ephemeris is imported by more than the one file the '
                'iOS variant removes: ${importers.join(", ")}'
          : 'this is the iOS variant and it still imports the Swiss '
                'Ephemeris: ${importers.join(", ")}',
    );
  });

  test('only one file names an engine', () {
    // Everything else asks `sky` and does not know what is behind it.
    final namers = <String>[];
    for (final e in Directory('lib').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      if (e.path.endsWith('sky/current.dart')) continue;
      if (e.path.endsWith('sky/swiss.dart')) continue;
      if (e.path.endsWith('sky/public.dart')) continue;
      final code = _code(e.readAsStringSync());
      if (code.contains('SwissSky(') || code.contains('PublicSky(')) {
        namers.add(e.path);
      }
    }
    expect(
      namers,
      isEmpty,
      reason:
          'these files pick an engine themselves, so the variant script '
          'cannot switch the app by rewriting one file: ${namers.join(", ")}',
    );
  });

  test('the variant picks the public-domain engine', () {
    // ⚠ Only meaningful on a tree the script has been run over; on the Android
    // checkout current.dart rightly names the other one.
    if (File('lib/sky/swiss.dart').existsSync()) return;
    final code = _code(File('lib/sky/current.dart').readAsStringSync());
    expect(
      code.contains('PublicSky()'),
      isTrue,
      reason:
          'the Swiss implementation is gone but the app still asks for '
          'it, so this build does not start at all',
    );
  });

  test('the script removes the package and its assets', () {
    // ⚠ Both. Leaving the asset lines makes the build fail with "unable to find
    // directory entry in pubspec.yaml", which names the assets and not the
    // missing package — an error that sends you looking in the wrong file.
    final script = File('tool/make_ios_variant.sh').readAsStringSync();
    expect(
      script.contains(r'^\s+sweph:.*\n'),
      isTrue,
      reason: 'the script does not remove the dependency',
    );
    expect(
      script.contains(r'^\s+- packages/sweph/.*\n'),
      isTrue,
      reason: 'the script leaves the asset lines behind',
    );
    expect(
      script.contains('rm -f lib/sky/swiss.dart'),
      isTrue,
      reason: 'the script leaves the Swiss implementation in place',
    );
  });

  test('CI makes the variant before it builds for Apple', () {
    // ⚠ The script existing is not the same as the workflow running it. A
    // pipeline that skips this step builds a perfectly good binary with AGPL
    // code inside it, uploads it, and the first anybody knows is a complaint.
    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();
    expect(
      wf.contains('./tool/make_ios_variant.sh'),
      isTrue,
      reason:
          'the iOS workflow never makes the variant, so it ships the '
          'Swiss Ephemeris inside an App Store binary',
    );
    expect(
      wf.contains("grep -q 'sweph' pubspec.lock"),
      isTrue,
      reason:
          'nothing checks the dependency actually went; the script could '
          'fail silently and the build would still be made',
    );
  });

  test('generated output is not analysed', () {
    // ⚠ It fails on macOS and passes on Linux, which is the most misleading
    // shape a CI failure can have. Swift Package Manager resolves dependencies
    // into build/ios/SourcePackages, each with its own `test/` directory
    // written against a different mockito — so `flutter analyze` reports eighty
    // errors in somebody else's tests, on a tree where nothing of ours is
    // wrong. The directory does not exist on Linux, so the gate goes green and
    // the Mac goes red on identical code.
    final options = File('analysis_options.yaml').readAsStringSync();
    expect(
      options.contains('build/**'),
      isTrue,
      reason:
          'the analyzer will walk build/, where macOS keeps other '
          "people's package sources, and fail on their code",
    );
  });

  test('the licences screen follows the engine', () {
    // ⚠ A build that does not contain a library must not reproduce its notice.
    // That screen exists to be accurate about what the app is made of, and the
    // two builds are made of different things.
    final code = _code(File('lib/screens/licences.dart').readAsStringSync());
    expect(
      code.contains('sky.noticeRequired'),
      isTrue,
      reason:
          'the licences screen shows one notice regardless of which '
          'engine is in the build, so one of the two builds lies about what '
          'it contains',
    );
  });

  test('the engine names itself rather than being named', () {
    // The version string on six screens used to be a constant reading
    // "Swiss Ephemeris 2.10.03", which is wrong in the iOS build.
    final code = _code(File('lib/services/ephemeris.dart').readAsStringSync());
    expect(
      code.contains('sky.engine'),
      isTrue,
      reason:
          'the engine version is hard-coded, so it is wrong on one of '
          'the two builds',
    );
  });
}
