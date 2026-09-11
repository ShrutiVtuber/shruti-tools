// SPDX-License-Identifier: AGPL-3.0-only
//
// The iOS build's configuration, checked from a machine that cannot build it.
//
// ⚠ **There is no Mac here.** Everything about the iOS side was written
// against documentation, and the first real feedback will be a CI log. These
// are the facts that can be checked without Xcode — mostly that two identifiers
// which live in four different places still agree — and they are worth checking
// precisely because getting one wrong produces an error that names something
// else entirely.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const bundleId = 'com.shrutivtuber.astrolabe';

void main() {
  test('iOS and Android carry the same identifier', () {
    // ⚠ Firebase matches on this string exactly, and one project holds both
    // apps. A mismatch registers an app nothing sends to, and nothing errors.
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(pbx.contains('PRODUCT_BUNDLE_IDENTIFIER = $bundleId;'), isTrue,
        reason: 'the iOS bundle id is not $bundleId');
    expect(pbx.contains('shrutiTools'), isFalse,
        reason: 'the old shrutiTools identifier survives somewhere in the '
            'Xcode project — Firebase and the provisioning profile both match '
            'on this string exactly');
    expect(gradle.contains('applicationId = "$bundleId"'), isTrue,
        reason: 'the Android id no longer matches the iOS one');
  });

  test('the workflow signs the identifier it builds', () {
    // ⚠ The export options name the bundle id as a key. If it drifts from the
    // project's, the build succeeds and the export fails with "no profile
    // matching", which sends you looking at the profile.
    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();
    expect(wf.contains('<key>$bundleId</key>'), isTrue,
        reason: 'the export options sign a different bundle id than the app '
            'is built with');
  });

  test('the workflow does not burn macOS minutes on every push', () {
    // ⚠ A macOS runner costs about ten times a Linux one.
    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();
    expect(RegExp(r'push:\s*\n\s*branches').hasMatch(wf), isFalse,
        reason: 'it builds on every push to a branch, which will eat the '
            'free allowance');
    expect(wf.contains("tags: ['v*']"), isTrue,
        reason: 'no tag trigger, so a release cannot be cut by tagging');
    expect(wf.contains('workflow_dispatch'), isTrue,
        reason: 'no manual trigger, so it cannot be tested without tagging a '
            'release');
  });

  test('the Flutter version is pinned', () {
    // A Flutter release lands mid-week and changes the CocoaPods contract; a
    // pinned version means a broken build is something you changed.
    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();
    expect(RegExp(r"flutter-version: '\d+\.\d+\.\d+'").hasMatch(wf), isTrue,
        reason: 'the workflow tracks a moving channel, so a build can break '
            'with no change of yours');
  });

  test('the deployment target is new enough for Firebase', () {
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final targets = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+)')
        .allMatches(pbx)
        .map((m) => double.parse(m.group(1)!))
        .toList();
    expect(targets, isNotEmpty, reason: 'no deployment target is set at all');
    expect(targets.every((t) => t >= 13.0), isTrue,
        reason: 'firebase_core needs iOS 13 or later; a lower target fails in '
            'CocoaPods with a dependency error that names the pod, not the '
            'setting');
  });
}
