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
    // ⚠ **15.0, and the number was learned the expensive way.** The first
    // TestFlight run failed on exactly this, and the message named the package
    // rather than the setting:
    //
    //   error: The package product 'firebase-core' requires minimum platform
    //   version 15.0 for the iOS platform, but this target supports 13.0
    //
    // Firebase raised its floor. Flutter's template still writes 13.0.
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final targets = RegExp(
      r'IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+)',
    ).allMatches(pbx).map((m) => double.parse(m.group(1)!)).toList();
    expect(targets, isNotEmpty, reason: 'no deployment target is set at all');
    expect(
      targets.every((t) => t >= 15.0),
      isTrue,
      reason:
          'firebase_core needs iOS 15 or later; a lower target fails the '
          'archive with an error that names the package, not the setting',
    );
  });

  test('export compliance is declared, so TestFlight does not stall', () {
    // ⚠ Learned by rebetichord and practiseapp before this app existed.
    // Without this key EVERY upload sits in "Missing Compliance" until
    // somebody answers the same questionnaire by hand, and the build cannot be
    // installed until they do. `false` is the true answer: ordinary HTTPS and
    // Apple's own push transport are both the exempt category.
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(
      plist.contains('ITSAppUsesNonExemptEncryption'),
      isTrue,
      reason:
          'every TestFlight build will stall on the encryption '
          'questionnaire until somebody answers it by hand',
    );
  });

  test('the app icon is hers, and has no alpha channel', () {
    // ⚠ Two separate traps in one file.
    //
    // Flutter's template ships its own blue logo, and a build that reaches
    // TestFlight wearing it looks like an unfinished sample — which is what
    // this app was about to do.
    //
    // And an iOS icon with an alpha channel is REJECTED AT UPLOAD, after the
    // whole archive has been built and signed, with a message about
    // transparency rather than about which file.
    final icon = File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    );
    expect(icon.existsSync(), isTrue, reason: 'no 1024 icon at all');

    final bytes = icon.readAsBytesSync();
    // PNG header: colour type is the 26th byte. 2 = RGB, 6 = RGB+alpha.
    final colourType = bytes[25];
    expect(
      colourType,
      equals(2),
      reason:
          'the icon has an alpha channel (colour type $colourType); '
          'Apple rejects that at upload, after the build has been made',
    );

    // ⚠ Whether the drawing is HERS cannot be checked from bytes without
    // decoding the image, and a test that pretends to is worse than none —
    // the first version of this line was `expect(x || true, isTrue)`, which
    // cannot fail. The mechanical half is the alpha channel, above. The
    // "is it still Flutter's blue logo" half is a human looking at it, and it
    // was looked at: it is the crescent-and-star placeholder from
    // assets/art/icon-1024.png, per the artwork spec.
    expect(
      bytes.length,
      greaterThan(1000),
      reason: 'the icon file is too small to be a real 1024 image',
    );
  });

  test('the Podfile and the project agree on the floor', () {
    // ⚠ Three places have to say the same number: the project setting governs
    // the app, the Podfile's platform line governs the pods, and the
    // post_install hook governs each pod that declares its own. CocoaPods
    // lets a pod keep an older target unless told otherwise —
    // flutter_local_notifications arrived asking for 11.0, which Xcode 26 no
    // longer supports, and only warned. A warning today is an error next
    // release.
    final podfile = File('ios/Podfile');
    expect(
      podfile.existsSync(),
      isTrue,
      reason: 'no Podfile, so the pods take whatever floor they like',
    );

    final pods = podfile.readAsStringSync();
    final platform = RegExp(
      r"platform :ios, '([\d.]+)'",
    ).firstMatch(pods)?.group(1);
    expect(
      platform,
      equals('15.0'),
      reason: 'the Podfile platform is $platform, not 15.0',
    );

    expect(
      pods.contains(
        "config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'",
      ),
      isTrue,
      reason: 'no post_install hook forcing every pod to the same floor',
    );
  });

  // ── Push, which has four separate ways of being absent ──────────────────

  test('the iPhone is given a Firebase configuration to read', () {
    // ⚠ The plist is written from a secret at build time, never committed —
    // this repository is public. So the check is that the WORKFLOW writes it
    // and that the Xcode project would carry it, not that the file is here.
    final flow = File(
      '.github/workflows/ios-testflight.yml',
    ).readAsStringSync();
    expect(
      flow.contains('GOOGLE_SERVICE_INFO_PLIST'),
      isTrue,
      reason: 'nothing writes GoogleService-Info.plist on the Mac',
    );
    expect(
      File(
        '.gitignore',
      ).readAsStringSync().contains('ios/Runner/GoogleService-Info.plist'),
      isTrue,
      reason: 'the iOS Firebase config is not ignored, so it can be committed',
    );
  });

  test('the configuration is actually put INSIDE the app', () {
    // ⚠ The distinction that costs an afternoon: a file sitting in ios/Runner
    // is not in the bundle. Only membership of the Resources build phase puts
    // it there, and a build with the file present but unreferenced starts,
    // runs, and has no notifications — exactly like a build with no file.
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    // ⚠ ' = {', because the same identifier appears twice: once in the
    // target's list of build phases, and once as the phase itself. Anchoring
    // on the bare id finds the list, whose block ends long before the files do.
    final phase = pbx.substring(
      pbx.indexOf('97C146EC1CF9000F007C117D /* Resources */ = {'),
    );
    expect(
      phase.substring(0, phase.indexOf('};')).contains('GoogleService-Info'),
      isTrue,
      reason: 'the plist is not in the Runner Resources build phase',
    );
  });

  test('the push entitlement matches the profile it is signed with', () {
    // ⚠ Not a warning — codesign refuses the build outright when these differ.
    // The App Store profile declares production, and this app is never signed
    // with anything else, so "development" here would fail every build.
    final ent = File('ios/Runner/Runner.entitlements').readAsStringSync();
    expect(ent.contains('aps-environment'), isTrue);
    expect(
      ent.contains('<string>production</string>'),
      isTrue,
      reason: 'the entitlement is not production, but the profile is',
    );
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    expect(
      pbx.contains('CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;'),
      isTrue,
      reason: 'the entitlements file exists but no configuration uses it',
    );
  });

  test('iOS is allowed to wake for a notification', () {
    final info = File('ios/Runner/Info.plist').readAsStringSync();
    expect(
      info.contains('UIBackgroundModes') &&
          info.contains('<string>remote-notification</string>'),
      isTrue,
      reason: 'without this iOS delivers a push only while the app is open',
    );
  });

  test('the drawing code knows about iOS as well as Android', () {
    final source = File('lib/services/notifications.dart').readAsStringSync();
    expect(
      source.contains('DarwinInitializationSettings'),
      isTrue,
      reason: 'the local notification plugin is not initialised for iOS',
    );
    expect(
      source.contains('DarwinNotificationDetails'),
      isTrue,
      reason: 'a foreground notification would be drawn silently on iOS',
    );
    // ⚠ The regression this replaces: resolving the Android plugin returns
    // null on iOS, and the code returned early on that — so the listener that
    // draws foreground notifications was never registered on the one platform
    // that reaches this line.
    expect(
      source.contains("debugPrint('notifications: no Android plugin"),
      isFalse,
      reason: 'a null Android plugin must not stop the listener being set up',
    );
  });
}
