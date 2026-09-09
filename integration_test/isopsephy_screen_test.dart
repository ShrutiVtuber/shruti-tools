// SPDX-License-Identifier: AGPL-3.0-only
//
// The screen, not just the arithmetic.
//
// isopsephy_test.dart proves the reckoning. This proves somebody can reach it:
// choose a language, type a word, and see the number. Those are different
// claims, and the second one has failed twice in this project while the first
// was perfectly sound — a release build with no network permission, and a set
// of tracking attributes silently dropped from twelve links.
//
// Driven as a widget test rather than by tapping coordinates through adb.
// Blind taps opened Google Keep twice earlier in this session, and Greek does
// not survive `adb shell input text` anyway.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shruti_tools/screens/isopsephy.dart';
import 'package:shruti_tools/services/packs.dart';
import 'package:shruti_tools/theme/theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // The Greek letter values, so the screen has something to offer.
    final offered = await availablePacks();
    final greek = offered.firstWhere((p) => p.file.contains('numbers-greek'));
    expect(await installPack(greek), isNull, reason: 'installing Greek');
  });

  testWidgets('choose a language, type a word, see the number', (tester) async {
    await tester.pumpWidget(
      // A Scaffold, because that is what the screen actually lives in — Shell
      // provides one and the chips paint their ink on it. Without it the build
      // throws "No Material widget found", which is a fact about the test
      // rather than about the screen.
      MaterialApp(
        theme: shrutiTheme(),
        home: const Scaffold(body: SafeArea(child: IsopsephyScreen())),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // The language is installed, so the tool itself is on screen rather than
    // the "first, a language" note.
    expect(find.text('Reckon'), findsOneWidget);
    expect(find.text('First, a language'.toUpperCase()), findsNothing);

    await tester.enterText(find.byType(TextField), 'ΙΗΣΟΥΣ');
    await tester.tap(find.text('Reckon'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('888'), findsOneWidget);
    expect(find.text('6 letters counted'), findsOneWidget);
  });

  testWidgets('a character with no value is named, not swallowed', (
    tester,
  ) async {
    await tester.pumpWidget(
      // A Scaffold, because that is what the screen actually lives in — Shell
      // provides one and the chips paint their ink on it. Without it the build
      // throws "No Material widget found", which is a fact about the test
      // rather than about the screen.
      MaterialApp(
        theme: shrutiTheme(),
        home: const Scaffold(body: SafeArea(child: IsopsephyScreen())),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // A Latin A looks exactly like Alpha and is worth nothing at all. The
    // total gives no sign of it, so the screen has to.
    await tester.enterText(find.byType(TextField), 'ABΓ');
    await tester.tap(find.text('Reckon'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.textContaining('No value in this system'), findsOneWidget);
  });

  testWidgets('every language says what it costs before it is taken', (
    tester,
  ) async {
    // The reason this list exists at all. Somebody choosing between Greek and
    // Hebrew word lists is choosing between 4.3MB and 260KB of their data, and
    // the names do not say so.
    await tester.pumpWidget(
      // A Scaffold, because that is what the screen actually lives in — Shell
      // provides one and the chips paint their ink on it. Without it the build
      // throws "No Material widget found", which is a fact about the test
      // rather than about the screen.
      MaterialApp(
        theme: shrutiTheme(),
        home: const Scaffold(body: SafeArea(child: IsopsephyScreen())),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Every row says its kind and its size. Not a specific number — that
    // is the pack's business, and asserting one would make this a test of
    // arithmetic on kilobytes rather than of the row saying anything.
    expect(
      find.textContaining(RegExp(r'(letter values|word list) · ')),
      findsWidgets,
    );
    expect(
      find.textContaining(RegExp(r'· \d+(\.\d+)? MB')),
      findsWidgets,
      reason: 'the large corpora must say what they weigh',
    );
  });
}
