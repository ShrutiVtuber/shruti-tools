// SPDX-License-Identifier: AGPL-3.0-only
//
// Every tab answers for the same place.
//
// The tabs are an IndexedStack, so all four are alive at once — deliberately,
// so a cast chart survives a visit to another tab. That is exactly what made
// per-screen state a bug: each one read the saved place in initState and never
// heard about a change, so Stations could say Athens while Hours went on
// computing London and printing "LONDON" at the top of its card.
//
// A widget test rather than a driven screenshot: the claim is about state, and
// tapping blind coordinates through adb opened Google Keep twice while I was
// trying to demonstrate it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shruti_tools/models/place.dart';
import 'package:shruti_tools/screens/shell.dart';
import 'package:shruti_tools/services/ephemeris.dart';
import 'package:shruti_tools/services/settings.dart';
import 'package:shruti_tools/services/stations.dart';
import 'package:shruti_tools/theme/theme.dart';

const _athens = Place(
  name: 'Athens, Attica, Greece',
  lat: 37.98376,
  lon: 23.72784,
  zone: 'Europe/Athens',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => startEphemeris());

  testWidgets('changing the place reaches every tab', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await Settings.load();

    await tester.pumpWidget(
      SettingsScope(
        notifier: settings,
        child: MaterialApp(theme: shrutiTheme(), home: const Shell()),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Stations opens on the default.
    expect(find.textContaining('LONDON'), findsWidgets);

    // Change it the way the picker does.
    await settings.setPlace(_athens);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.textContaining('ATHENS'), findsWidgets);
    expect(find.textContaining('LONDON'), findsNothing);

    // Hours is a different tab, alive the whole time, and must agree.
    await tester.tap(find.text('Hours'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(
      find.textContaining('ATHENS'),
      findsWidgets,
      reason: 'Hours kept its own copy and went on answering for London',
    );
    expect(find.textContaining('LONDON'), findsNothing);
  });

  testWidgets('the sunrise convention reaches the stations too', (
    tester,
  ) async {
    // Chosen on the Hours screen, and it moves sunrise — which is the first
    // row of the Stations table. One setting, one answer.
    SharedPreferences.setMockInitialValues({});
    final settings = await Settings.load();
    await tester.pumpWidget(
      SettingsScope(
        notifier: settings,
        child: MaterialApp(theme: shrutiTheme(), home: const Shell()),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    String dawn() {
      final row = find.textContaining(RegExp(r'^\d\d:\d\d$'));
      return (tester.widgetList<Text>(row).first).data ?? '';
    }

    final before = dawn();
    await settings.setConvention(RiseConvention.hindu);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(
      dawn(),
      isNot(before),
      reason: 'the Vedic sunrise is minutes later; the table must follow',
    );
  });
}
