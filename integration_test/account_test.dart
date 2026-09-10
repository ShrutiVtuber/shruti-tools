// SPDX-License-Identifier: AGPL-3.0-only
//
// One account, two places.
//
// She asked that somebody make a site account from the phone rather than being
// sent to the website, and that the account then work in both. The claim worth
// testing is exactly that: a token minted here is accepted by the site, and the
// account it names is the same one.
//
// ⚠ Runs against the LOCAL stack. `adb reverse tcp:8200 tcp:8200` and
// --dart-define=SHRUTI_SITE=http://127.0.0.1:8200. Against the real site this
// would make junk accounts on shrutivtuber.com.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrolabe/screens/account.dart';
import 'package:astrolabe/services/account.dart';
import 'package:astrolabe/services/site.dart' show siteOrigin;
import 'package:astrolabe/theme/theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// ⚠ example.com, not example.invalid. A reserved TLD is refused by the
  /// site's own email validation, which made one of these tests pass for
  /// entirely the wrong reason: it expected a wrong-password failure and got
  /// "that is not an email address".
  String freshEmail() =>
      'app-${DateTime.now().microsecondsSinceEpoch}@example.com';

  setUpAll(() {
    // A guard, not a nicety: this test creates accounts.
    expect(
      siteOrigin.contains('127.0.0.1') || siteOrigin.contains('localhost'),
      isTrue,
      reason: 'refusing to make test accounts against $siteOrigin',
    );
  });

  Future<Account> fresh() async {
    SharedPreferences.setMockInitialValues({});
    return Account.load();
  }

  testWidgets('the words shown are the words the site files', (tester) async {
    // Not a copy in Dart. What a person reads must be what gets stored, and the
    // site keeps that in one place for that reason.
    final account = await fresh();
    final consents = await account.consents();

    expect(consents.map((c) => c.kind).toSet(), {
      'account',
      'nativity',
      'newsletter',
    });
    for (final c in consents) {
      expect(c.wording.trim(), isNotEmpty, reason: '${c.kind} has no wording');
      expect(c.label.trim(), isNotEmpty);
    }
    // The rule the site states: only the contract consent may be required,
    // because a special-category consent that blocked the button would not be
    // freely given.
    for (final c in consents.where((c) => c.required)) {
      expect(c.basis, 'contract', reason: '${c.kind} is required');
    }
    expect(consents.where((c) => c.required).map((c) => c.kind), ['account']);
  });

  testWidgets('an account made on the phone is an account on the site', (
    tester,
  ) async {
    final account = await fresh();
    final email = freshEmail();

    final how = await account.signUp(
      email: email,
      password: 'a-long-enough-password',
      name: 'On The Phone',
      granted: const {'account': true, 'nativity': false, 'newsletter': false},
    );
    expect(how, SignUpOutcome.signedIn);
    expect(account.signedIn, isTrue);
    expect(account.reader?.email, email);
    expect(account.reader?.name, 'On The Phone');

    // The site itself, asked directly with the token the app is holding —
    // this is the half that says the two are the same account rather than two
    // that happen to agree.
    final r = await http.get(
      Uri.parse('$siteOrigin/api/account/me'),
      headers: account.headers,
    );
    expect(r.statusCode, 200);
    expect((jsonDecode(r.body) as Map)['email'], email);
  });

  testWidgets('the token outlives the app being closed', (tester) async {
    final email = freshEmail();
    final first = await fresh();
    await first.signUp(
      email: email,
      password: 'a-long-enough-password',
      name: 'Comes Back',
      granted: const {'account': true},
    );
    expect(first.signedIn, isTrue);

    // A second Account over the same preferences is what the next launch does.
    final next = await Account.load();
    expect(next.signedIn, isTrue, reason: 'signed out by restarting the app');
    await next.refresh();
    expect(next.reader?.email, email);

    await next.signOut();
    expect(
      (await Account.load()).signedIn,
      isFalse,
      reason: 'signing out did not survive the restart either',
    );
  });

  testWidgets('a wrong password is told plainly and signs nobody in', (
    tester,
  ) async {
    final account = await fresh();
    await expectLater(
      account.signIn(email: freshEmail(), password: 'not-the-password'),
      throwsA(isA<AccountTrouble>()),
    );
    expect(account.signedIn, isFalse);
  });

  testWidgets('somebody with no password can ask for one', (tester) async {
    // The hole this closes: the website lets an account be made with a magic
    // link and no password, and a phone has nowhere for a magic link to land.
    // That person could sign in on the site and never on the app.
    final account = await fresh();

    await tester.pumpWidget(
      MaterialApp(
        theme: shrutiTheme(),
        home: AccountScope(
          notifier: account,
          child: const Scaffold(body: SafeArea(child: AccountScreen())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final ask = find.text('Email me a link to set a password');
    expect(ask, findsOneWidget);

    // With nothing typed, it says what is missing rather than doing nothing.
    await tester.tap(ask);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Put your email address in first'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      freshEmail(),
    );
    await tester.pumpAndSettle();
    await tester.tap(ask);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ⚠ The same answer whether or not the address has an account. Saying
    // "no such account" here would make the form an oracle about who has one.
    expect(find.textContaining('Check your email'), findsOneWidget);
    expect(account.signedIn, isFalse);
  });

  testWidgets('the screen makes an account and says who is signed in', (
    tester,
  ) async {
    final account = await fresh();
    final email = freshEmail();

    await tester.pumpWidget(
      MaterialApp(
        theme: shrutiTheme(),
        home: AccountScope(
          notifier: account,
          child: const Scaffold(body: SafeArea(child: AccountScreen())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('I need an account'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // The wording came from the site, so it is on screen before anything is
    // agreed to.
    expect(
      find.textContaining('I want an account on shrutivtuber.com'),
      findsOneWidget,
    );

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Typed In');
    await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'a-long-enough-password',
    );
    await tester.pumpAndSettle();

    // ⚠ Scroll to the button. A ListView only builds what is in the viewport,
    // and with three consent tiles on screen the button is below the fold —
    // "Found 0 widgets" there is a fact about the test, not the screen. Fields
    // first, then scroll: scrolling unbuilds the fields.
    await tester.scrollUntilVisible(
      find.text('Make the account'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Make the account'));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    expect(account.signedIn, isTrue);
    expect(find.text('Your account'), findsOneWidget);
    expect(find.text('Typed In'), findsOneWidget);
  });
}
