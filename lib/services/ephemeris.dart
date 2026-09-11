// SPDX-License-Identifier: AGPL-3.0-only
//
// Getting the sky ready, once, before anything asks it a question.
//
// ⚠ **This file no longer knows which engine answers.** It used to start the
// Swiss Ephemeris directly, which meant nineteen files imported a library only
// one of them needed — and the iOS build cannot contain that library at all.
// Everything engine-specific now lives behind `Sky.begin`, and what is left
// here is what every build needs whichever engine it carries.
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../sky/current.dart';

bool _ready = false;

/// What the arithmetic was done by, named once.
///
/// ⚠ This string appears on every instrument screen, and a licence notice must
/// be preserved on all copies — so it is asked of the engine rather than typed,
/// because the two builds do not use the same one and a hard-coded name would
/// be a lie on one of them.
String get engineVersion => sky.engine;

/// What the app calls itself, on the settings and licences screens.
///
/// ⚠ **No build number, deliberately.** It used to read `1.0.0 (1)`, kept in
/// step with pubspec.yaml by hand — which cannot work, because nothing here
/// has the last word on it. `manageAppVersionAndBuildNumber` defaults to true
/// for `xcodebuild -exportArchive`, so Xcode takes the next free number on the
/// way to TestFlight: pubspec has said `+1` throughout and Apple holds builds
/// 1 to 4. The app was telling everybody it was build 1 whichever build it was.
///
/// A wrong build number is worse than none — somebody reporting a bug reads it
/// out and it points at the wrong binary. If the real one is wanted later,
/// `package_info_plus` reports it at runtime; that is a dependency rather than
/// a constant, which is why it is not here today.
const appVersion = '1.0.0';

/// Make the sky answerable.
///
/// ⚠ The timezone rules are loaded here rather than inside an engine, because
/// they are not an engine's business: a station computed for a place is told in
/// that place's time whichever theory found it.
Future<void> startEphemeris({String? into}) async {
  if (_ready) return;
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));
  await sky.begin(into: into);
  _ready = true;
}
