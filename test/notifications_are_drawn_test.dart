// SPDX-License-Identifier: AGPL-3.0-only
//
// A notification that arrives and is not drawn.
//
// ⚠ **This is the most misleading failure this app has produced.** Firebase
// answered 200, the phone logged the delivery, the token was valid, the
// permission was granted — and nothing appeared on screen, three times. The
// cause: Android draws an FCM notification by itself ONLY when the app is in
// the background. In the foreground it hands the message to the app and draws
// nothing, and an app that does not handle that shows the user nothing at all.
//
// Source-level, because the alternative is a real phone with a real FCM
// message, which is exactly the test that was run by hand to find this and
// exactly the one that cannot run in CI.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

/// Source with its comments stripped.
///
/// ⚠ Every guard below looks for a token that this file's own prose also
/// contains. Twice in one day a guard elsewhere in this project passed on
/// deleted code because it found the word in the paragraph explaining it.
String _code(String source) => source
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), ' ');

void main() {
  final service = _code(_read('lib/services/notifications.dart'));
  final manifest = _read('android/app/src/main/AndroidManifest.xml');

  test('a message arriving while the app is open is drawn', () {
    expect(
      service.contains('FirebaseMessaging.onMessage.listen'),
      isTrue,
      reason:
          'nothing listens for foreground messages, so a notification '
          'that arrives while the app is open is silently dropped',
    );
    expect(
      service.contains('_local.show('),
      isTrue,
      reason: 'the foreground message is received and never displayed',
    );
  });

  test(
    'the listener is started at launch, not only when the switch is used',
    () {
      // ⚠ It lives in memory and dies with the process. A phone that registered
      // last week would receive every message and draw none until the app was
      // next backgrounded.
      final load = service.substring(
        service.indexOf('static Future<Notifications> load'),
      );
      expect(
        load.substring(0, 400).contains('_watchWhileOpen'),
        isTrue,
        reason:
            'the foreground listener is not restored at startup, so it '
            'works until the app is restarted and then silently stops',
      );
    },
  );

  test('the app declares its own channel, with sound', () {
    expect(
      service.contains('AndroidNotificationChannel'),
      isTrue,
      reason:
          'no channel is created, so FCM invents a fallback one with no '
          'sound and no vibration — the notification arrives silently, which '
          'is indistinguishable from not arriving',
    );
    expect(
      service.contains('Importance.high'),
      isTrue,
      reason: 'the channel is not important enough to make a sound',
    );
  });

  test('Android is told which icon and which channel to use', () {
    expect(
      manifest.contains('default_notification_icon'),
      isTrue,
      reason:
          'without this Android falls back to the LAUNCHER icon, which '
          'is full-colour and square and draws in the status bar as a white '
          'blob',
    );
    expect(
      manifest.contains('default_notification_channel_id'),
      isTrue,
      reason: 'FCM will invent a silent fallback channel instead',
    );
  });

  test('the notification icon exists and is white-only', () {
    final icon = File('android/app/src/main/res/drawable/ic_notification.xml');
    expect(
      icon.existsSync(),
      isTrue,
      reason:
          'the manifest names an icon that is not there — the build '
          'fails, or worse, resolves to something else',
    );
    final xml = icon.readAsStringSync();
    // ⚠ Android discards colour here and renders the alpha channel flat. A
    // gold icon arrives as a white blob.
    expect(
      RegExp(r'fillColor="#(FF)?FFFFFF"').hasMatch(xml),
      isTrue,
      reason: 'the icon is drawn in a colour Android will throw away',
    );
  });

  test('the plugin is initialised before the channel is made', () {
    // ⚠ The other way round, resolvePlatformSpecificImplementation has no
    // platform to resolve and returns null — the `?.` swallows the call, no
    // channel is created, and Android falls back to FCM's silent one. Nothing
    // throws and nothing is logged. The only symptom is a notification with no
    // sound, which reads as a phone setting rather than a bug.
    final init = service.indexOf('_local.initialize(');
    final make = service.indexOf('createNotificationChannel(');
    expect(init, greaterThan(-1), reason: 'the plugin is never initialised');
    expect(make, greaterThan(-1), reason: 'the channel is never created');
    expect(
      init,
      lessThan(make),
      reason:
          'the channel is created before the plugin is initialised, so '
          'it is silently never created at all',
    );
  });

  test('a failure to start watching is said out loud', () {
    // ⚠ It runs from `unawaited` at startup, where a thrown error goes
    // nowhere — and its only symptom is the very bug this code fixes.
    expect(
      service.contains('debugPrint'),
      isTrue,
      reason:
          'a failure to start the foreground listener is silent, so the '
          'bug it fixes comes back invisibly',
    );
  });

  test('the channel id in the code matches the one in the manifest', () {
    // ⚠ They are two separate strings in two separate files and nothing but
    // this compares them. Different ids mean a background notification lands
    // on a channel that was never created, with the fallback's silence.
    final inCode = RegExp(
      r"AndroidNotificationChannel\(\s*'([^']+)'",
    ).firstMatch(service)?.group(1);
    final inManifest = RegExp(
      r'default_notification_channel_id"\s*\n?\s*android:value="([^"]+)"',
    ).firstMatch(manifest)?.group(1);
    expect(inCode, isNotNull, reason: 'no channel id found in the service');
    expect(
      inManifest,
      isNotNull,
      reason: 'no channel id found in the manifest',
    );
    expect(
      inCode,
      equals(inManifest),
      reason:
          'the code creates channel "$inCode" and the manifest sends to '
          '"$inManifest" — background notifications land on a channel that '
          'does not exist',
    );
  });

  // ── and the same failure on the iPhone, found the same way ───────────────

  test('iOS is asked to present a notice while the app is on screen', () {
    // ⚠ **The Android bug, on the other platform.** With the app open on her
    // iPhone, FCM reported delivered=True, the phone accepted the message, and
    // nothing appeared — proven by sending one on 11 September 2026.
    //
    // iOS will present a notification in the foreground only when told to, and
    // this is the line that tells it.
    expect(
      service.contains('setForegroundNotificationPresentationOptions'),
      isTrue,
      reason: 'nothing arrives on screen while an iPhone has the app open',
    );
    expect(
      service.contains('alert: true'),
      isTrue,
      reason: 'presented with no alert is presented invisibly',
    );
  });

  test('an iPhone is not shown the same notice twice', () {
    // ⚠ The commonest bug in this corner of Flutter: iOS presents the real
    // notification AND the app draws a local copy of it, so the same words
    // appear in two banners. The listener must leave iOS alone.
    final listener = service.substring(
      service.indexOf('FirebaseMessaging.onMessage.listen'),
    );
    final body = listener.substring(0, listener.indexOf('_local.show'));
    expect(
      body.contains('_onAnIPhone'),
      isTrue,
      reason:
          'the foreground listener draws a local notification on iOS as '
          'well as the presented one',
    );
  });

  test('the platform is read from the build, not from the machine', () {
    // ⚠ `Platform.isIOS` answers for the computer a test is running on, which
    // is a Linux box — so a guard written with it would be permanently false
    // and permanently green.
    expect(
      service.contains('defaultTargetPlatform == TargetPlatform.iOS'),
      isTrue,
    );
    expect(
      RegExp(r'Platform\.isIOS').hasMatch(service),
      isFalse,
      reason: 'dart:io answers for the host, not for the phone',
    );
  });
}
