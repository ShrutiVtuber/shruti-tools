// SPDX-License-Identifier: AGPL-3.0-only
//
// The release build must be able to reach the network.
//
// Flutter declares `android.permission.INTERNET` in the DEBUG and PROFILE
// manifests only. A release build without it in `main` has no network at all,
// and says nothing about it: the place search answered "nothing found" and the
// live card said "Offline", both of which are perfectly ordinary things for
// them to say. Every test passed, the app installed, and the screen looked
// right. One missing line.
//
// A file check rather than a runtime one, because by the time the app is
// running it is too late to tell the difference between "no permission" and
// "no signal" — which is exactly what made it hard to see.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the main manifest declares INTERNET, not just the debug one', () {
    final main = File('android/app/src/main/AndroidManifest.xml');
    expect(main.existsSync(), isTrue, reason: 'manifest missing');
    expect(
      main.readAsStringSync(),
      contains('android.permission.INTERNET'),
      reason: 'a release build without this is silently offline',
    );
  });

  test('the app declares no permission it does not use', () {
    // Every permission is a question the Play Store asks and a reason for
    // somebody to decline. The app computes on the device; it needs the
    // network for her site and nothing else.
    final text = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final asked = RegExp(
      r'android:name="android\.permission\.(\w+)"',
    ).allMatches(text).map((m) => m.group(1)).toSet();
    expect(asked, {'INTERNET'});
  });
}
