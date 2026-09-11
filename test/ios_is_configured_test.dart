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

    expect(
      pbx.contains('PRODUCT_BUNDLE_IDENTIFIER = $bundleId;'),
      isTrue,
      reason: 'the iOS bundle id is not $bundleId',
    );
    expect(
      pbx.contains('shrutiTools'),
      isFalse,
      reason:
          'the old shrutiTools identifier survives somewhere in the '
          'Xcode project — Firebase and the provisioning profile both match '
          'on this string exactly',
    );
    expect(
      gradle.contains('applicationId = "$bundleId"'),
      isTrue,
      reason: 'the Android id no longer matches the iOS one',
    );
  });

  test('the workflow signs the identifier the app is built with', () {
    // ⚠ The export options name the bundle id as a key. If it drifts from the
    // project's, the build succeeds and the export fails with "no profile
    // matching", which sends you looking at the profile.
    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();
    expect(
      wf.contains('BUNDLE_ID: $bundleId'),
      isTrue,
      reason: 'the workflow builds a different bundle id than the app has',
    );
  });

  test('the profile name matches in both places it is written', () {
    // ⚠ The trap that costs an afternoon. The name lives in the Xcode project
    // as PROVISIONING_PROFILE_SPECIFIER and in the workflow's ExportOptions,
    // and a mismatch fails at export with an error that never mentions the
    // profile. Nothing but this compares them.
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();

    final inXcode = RegExp(
      r'PROVISIONING_PROFILE_SPECIFIER = "?([^";]+)"?;',
    ).firstMatch(pbx)?.group(1)?.trim();
    final inWorkflow = RegExp(
      r'PROFILE_NAME:\s*(\S+)',
    ).firstMatch(wf)?.group(1)?.trim();

    expect(inXcode, isNotNull, reason: 'the Xcode project names no profile');
    expect(inWorkflow, isNotNull, reason: 'the workflow names no profile');
    expect(
      inXcode,
      equals(inWorkflow),
      reason:
          'Xcode signs with "$inXcode" and the workflow exports with '
          '"$inWorkflow" — the export will fail without naming the profile',
    );
  });

  test('signing is manual, and only on the Runner Release configuration', () {
    // ⚠ Signing set on the project, or passed on the xcodebuild command line,
    // hits EVERY target — and plugin pods cannot take a provisioning profile.
    // That is what practiseapp's attempt 5 failed on.
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    expect(
      'CODE_SIGN_STYLE = Manual;'.allMatches(pbx).length,
      equals(1),
      reason:
          'manual signing is set on more than one configuration, which '
          'reaches targets that cannot be signed that way',
    );
    expect(
      pbx.contains('DEVELOPMENT_TEAM = L25T4F2NJ2;'),
      isTrue,
      reason: 'her Apple team is not set on the Release configuration',
    );

    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();
    final archive = wf.substring(wf.indexOf('xcodebuild -workspace'));
    expect(
      archive.substring(0, 300).contains('CODE_SIGN'),
      isFalse,
      reason:
          'the archive command passes signing flags, which override '
          'every target including the pods',
    );
  });

  test('the Mac never runs before Linux has agreed', () {
    // Her reasoning, to another project: "I don't want to pay for mac os
    // runners if things fail already in android."
    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();
    expect(
      wf.contains('needs: gate'),
      isTrue,
      reason:
          'the macOS job can start before the Linux gate has passed, at '
          'ten times the price of finding out on Linux',
    );
  });

  test('the workflow does not burn macOS minutes on every push', () {
    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();
    expect(
      RegExp(r'push:\s*\n\s*branches').hasMatch(wf),
      isFalse,
      reason:
          'it builds on every push to a branch, which will eat the '
          'free allowance',
    );
    expect(
      wf.contains('tags: ["ios-v*"]'),
      isTrue,
      reason: 'no tag trigger, so a release cannot be cut by tagging',
    );
    expect(
      wf.contains('workflow_dispatch'),
      isTrue,
      reason:
          'no manual trigger, so it cannot be tested without tagging a '
          'release',
    );
  });

  test('the Flutter version is pinned', () {
    // A Flutter release lands mid-week and changes the CocoaPods contract; a
    // pinned version means a broken build is something you changed.
    final wf = File('.github/workflows/ios-testflight.yml').readAsStringSync();
    expect(
      RegExp(r'FLUTTER_VERSION: "\d+\.\d+\.\d+"').hasMatch(wf),
      isTrue,
      reason:
          'the workflow tracks a moving channel, so a build can break '
          'with no change of yours',
    );
  });

  test('the deployment target is new enough for Firebase', () {
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final targets = RegExp(
      r'IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+)',
    ).allMatches(pbx).map((m) => double.parse(m.group(1)!)).toList();
    expect(targets, isNotEmpty, reason: 'no deployment target is set at all');
    expect(
      targets.every((t) => t >= 13.0),
      isTrue,
      reason:
          'firebase_core needs iOS 13 or later; a lower target fails in '
          'CocoaPods with a dependency error that names the pod, not the '
          'setting',
    );
  });
}
