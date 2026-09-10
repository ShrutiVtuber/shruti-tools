// SPDX-License-Identifier: AGPL-3.0-only
//
// You can get to every tab, and back out of every screen.
//
// Both of these shipped broken and both looked like something else:
//
//   ⚠ **A tab that would not change.** The cross-fade wrapped each screen in a
//   TickerMode, so a tab being left behind had its tickers muted in the same
//   frame it was deselected — including its own fade-out. It stayed at full
//   opacity forever, and a Stack paints in order, so every screen ABOVE the one
//   you asked for went on covering it. The tab bar changed and the screen did
//   not, and only in one direction, which is why it read as a glitch.
//
//   ⚠ **A screen with no way out.** Sign-in was pushed as a bare body with no
//   app bar, so there was no back arrow and the tab bar was gone: the only way
//   out of the app's one modal flow was the system gesture.
//
// Neither is visible to an analyzer and neither throws. They are only findable
// by driving the app, which is what this does.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrolabe/screens/account.dart';
import 'package:astrolabe/screens/notifications.dart';
import 'package:astrolabe/screens/shell.dart';
import 'package:astrolabe/services/account.dart';
import 'package:astrolabe/services/ephemeris.dart';
import 'package:astrolabe/services/notifications.dart';
import 'package:astrolabe/services/settings.dart';
import 'package:astrolabe/theme/theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => startEphemeris());

  Future<void> open(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await Settings.load();
    final account = await Account.load();
    final notices = await Notifications.load(account);
    await tester.pumpWidget(
      SettingsScope(
        notifier: settings,
        child: AccountScope(
          notifier: account,
          child: NoticeScope(
            notifier: notices,
            child: MaterialApp(theme: shrutiTheme(), home: const Shell()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// What each of the six screens is ACTUALLY painting at, right now.
  ///
  /// ⚠ Not `AnimatedOpacity.opacity` — that is the target the animation is
  /// heading for, always 0 or 1, and reading it mid-flight says the screen
  /// being left is already gone while it is still half on the glass. The
  /// painted value is on the FadeTransition the widget builds.
  List<double> painted(WidgetTester tester) => [
    for (var i = 0; i < 6; i++)
      tester
          .widget<FadeTransition>(
            find
                .descendant(
                  of: find.byKey(ValueKey('tab-fade-$i')),
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value,
  ];

  Finder tab(String label) => find.descendant(
    of: find.byKey(const Key('tab-bar')),
    matching: find.text(label),
  );

  testWidgets('every tab shows its own screen, in both directions', (
    tester,
  ) async {
    await open(tester);

    // ⚠ Each tab is identified by something ONLY IT shows. Its own name will
    // not do: the tab bar says all six of them all the time, and the bug being
    // guarded against is precisely a screen that is not the one named.
    const mark = {
      'Home': 'Latest readings',
      'Sky': 'Stations',
      'Chart': 'Date of birth',
      'Letters': 'Reckoning',
      'Practice': 'Read',
      'Settings': 'Sunrise convention',
    };

    // ⚠ Forwards AND backwards. The failure was directional — leaving a tab
    // for a LOWER index left the higher one painting on top — so a walk in one
    // direction passes over it without noticing.
    final order = [...mark.keys, ...mark.keys.toList().reversed];
    for (final name in order) {
      await tester.tap(tab(name));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(
        find.text(mark[name]!),
        findsWidgets,
        reason:
            '$name was asked for and $name is not what is on screen — a '
            'screen above it in the stack never faded out',
      );

      // ⚠ And nothing ELSE is on view. Finding the right screen is not enough:
      // every tab stays in the tree at opacity 0, so a ghost left at any
      // opacity above zero is invisible to a finder and perfectly visible to a
      // person. The opacities are the only place the truth is.
      final shown = painted(tester);
      expect(
        shown.where((o) => o > 0).length,
        1,
        reason:
            'on $name, ${shown.where((o) => o > 0).length} screens are '
            'visible at once: $shown',
      );
    }
  });

  testWidgets('one screen at a time, mid-transition as well as after', (
    tester,
  ) async {
    await open(tester);

    // ⚠ Sampled DURING the change, not after it. `pumpAndSettle` waits for the
    // animation to finish, so a screen that fades out perfectly correctly over
    // 240ms and a screen that is half-visible the whole way both look
    // identical once it has settled — and the second is the one that reads as
    // ghosting on a dark screen full of figures.
    //
    // The rule being tested is FADE THROUGH: the screen being left goes at
    // once, and the one arriving fades up from the page colour. At no instant
    // are two of them on view.
    await tester.tap(tab('Settings'));
    for (var step = 0; step < 8; step++) {
      await tester.pump(const Duration(milliseconds: 30));
      final shown = painted(tester);
      expect(
        shown.where((o) => o > 0.02).length,
        lessThanOrEqualTo(1),
        reason:
            'at ${(step + 1) * 30}ms into the change, two screens are on view '
            'at once: $shown',
      );
    }
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Sunrise convention'), findsWidgets);
  });

  testWidgets('sign-in can be left without signing in', (tester) async {
    await open(tester);

    await tester.tap(tab('Settings'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(
      find.text('An account is only for the practice room'),
      findsOneWidget,
    );

    // ⚠ A BackButton, on the screen. Not the system gesture: a flow whose only
    // exit is a platform gesture is a flow that traps anybody who does not
    // know the gesture, and it is the one modal flow in the whole app.
    expect(
      find.byType(BackButton),
      findsOneWidget,
      reason: 'sign-in had no way out but the system gesture',
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Sunrise convention'), findsWidgets);
    expect(find.text('An account is only for the practice room'), findsNothing);
  });

  testWidgets('the practice room offers the same way back', (tester) async {
    await open(tester);

    await tester.tap(tab('Practice'));
    // ⚠ `pump`, not `pumpAndSettle`. The room shows breathing skeletons while
    // it fetches, and a repeating animation NEVER settles — `pumpAndSettle`
    // waits for every animation to finish and this one never does, so the test
    // hangs until the harness kills it and reports "did not complete", which
    // looks like a crash and is not one.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.text('Sign in').evaluate().isNotEmpty) break;
    }
    await tester.tap(find.text('Sign in').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Read'), findsWidgets);
  });
}
