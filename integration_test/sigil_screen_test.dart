// SPDX-License-Identifier: AGPL-3.0-only
//
// The sigil desk, as somebody actually uses it.
//
// `test/sigil_agrees_test.dart` proves the geometry matches the website. This
// proves a person can reach it — type a statement, watch the reduction, see a
// figure — and, just as importantly, that the statement does not end up
// anywhere it was promised not to go.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrolabe/screens/letters.dart';
import 'package:astrolabe/screens/sigil.dart';
import 'package:astrolabe/theme/theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget desk() => MaterialApp(
    theme: shrutiTheme(),
    home: const Scaffold(body: SafeArea(child: SigilScreen())),
  );

  /// The field belonging to the sigil screen specifically.
  ///
  /// ⚠ Scoped on purpose. `LettersScreen` holds both tools in an IndexedStack,
  /// which keeps the unselected one in the tree — a bare `find.byType(TextField)`
  /// matches the reckoning field too, and `enterText` then fails as ambiguous.
  final field = find.descendant(
    of: find.byType(SigilScreen),
    matching: find.byType(TextField),
  );

  /// Scroll down until [what] is on screen, then return.
  ///
  /// ⚠ Two traps here, both of which cost a run each. A ListView only builds
  /// what is in the viewport, so anything below the fold — on a phone, the
  /// whole reduction — is invisible to a finder even though it is "there".
  /// And the same lazy building works in reverse: once you have scrolled down,
  /// the TEXT FIELD is gone from the tree, and a second `enterText` fails with
  /// "Bad state: No element". So every test below types once, then scrolls.
  Future<void> scrollTo(WidgetTester tester, Finder what) => tester
      .scrollUntilVisible(what, 200, scrollable: find.byType(Scrollable).first);

  Future<void> toTheFoot(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.drag(
        find.byType(ListView).first,
        const Offset(0, -260),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
    }
  }

  testWidgets('a statement becomes a figure, showing its working', (
    tester,
  ) async {
    await tester.pumpWidget(desk());
    await tester.pumpAndSettle();

    // Nothing is drawn before there is anything to draw.
    expect(find.text('THE REDUCTION'), findsNothing);

    await tester.enterText(field, 'My will is to finish the work');
    await tester.pumpAndSettle();

    // Every stage, because a sigil you cannot reconstruct is one you have to
    // take somebody's word for. MYWILLISTOFINISHTHEWORK, vowels struck, then
    // repeats.
    await scrollTo(tester, find.text('THE REDUCTION'));
    expect(find.text('M Y W L S T F N H R K'), findsOneWidget);

    await scrollTo(tester, find.text('THE FIGURE'));
    expect(find.byType(CustomPaint), findsWidgets);
    await scrollTo(tester, find.textContaining('11 letters'));
  });

  testWidgets('a reduction that eats the sentence says so', (tester) async {
    await tester.pumpWidget(desk());
    await tester.pumpAndSettle();

    await tester.enterText(field, 'AEIOU');
    await tester.pumpAndSettle();

    // A designed outcome with something to say, not a blank frame and not an
    // error. The reader is told what happened and what to do about it.
    await scrollTo(tester, find.textContaining('consumed the whole sentence'));
    await toTheFoot(tester);
    expect(find.text('THE FIGURE'), findsNothing);
  });

  testWidgets('one letter left is not a line, and says so', (tester) async {
    // A separate pump rather than a second enterText: see scrollTo's note.
    await tester.pumpWidget(desk());
    await tester.pumpAndSettle();

    // "I AM" → strike the vowels → M. One point is not a line.
    // (Not "banana", which the first draft of this test used: B A N A N A
    // strikes down to B N, two letters, and draws perfectly well.)
    await tester.enterText(field, 'I am');
    await tester.pumpAndSettle();

    await scrollTo(tester, find.textContaining('One letter is left'));
    await toTheFoot(tester);
    expect(find.text('THE FIGURE'), findsNothing);
  });

  testWidgets('the statement is not written anywhere', (tester) async {
    // The screen's whole promise. Many hold that a statement of intent is
    // spent once drawn; an autosave added later "for convenience" would break
    // that silently, so it breaks this test loudly instead.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const secret = 'MY WILL IS TO OPEN THE DOOR';

    await tester.pumpWidget(desk());
    await tester.pumpAndSettle();
    await tester.enterText(field, secret);
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('M Y W L S T P N H D R'));

    await prefs.reload();
    for (final key in prefs.getKeys()) {
      final value = prefs.get(key).toString().toUpperCase();
      for (final word in secret.split(' ')) {
        expect(
          value.contains(word),
          isFalse,
          reason: '"$word" was saved under "$key"',
        );
      }
    }
  });

  testWidgets('the two letter tools do not share what is typed', (
    tester,
  ) async {
    // Carrying the statement across to the reckoning field would be a helpful
    // little feature that quietly breaks the promise above.
    await tester.pumpWidget(
      MaterialApp(
        theme: shrutiTheme(),
        home: const Scaffold(body: SafeArea(child: LettersScreen())),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text('Sigil'));
    await tester.pumpAndSettle();
    await tester.enterText(field, 'My will is to be unheard');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reckoning'));
    await tester.pumpAndSettle();
    await toTheFoot(tester);
    expect(find.textContaining('unheard'), findsNothing);
  });
}
