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

/// ⚠ Kept in step with pubspec.yaml by hand, and named here so the one place
/// that shows it is not six places that disagree.
const appVersion = '1.0.0 (1)';

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
