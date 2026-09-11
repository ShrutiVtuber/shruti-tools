// SPDX-License-Identifier: AGPL-3.0-only
//
// What the app needs to know about the sky, and nothing else.
//
// ⚠ **This interface exists so one implementation can be swapped for another
// without touching a single screen.** The Android build asks the Swiss
// Ephemeris; the iOS build cannot, because Apple's App Store terms and the
// AGPL cannot both be satisfied in one binary and the Swiss Ephemeris is not
// hers to relicense. The iOS build therefore asks a public-domain engine
// instead, and everything above this line is unaware of which.
//
// ⚠ **This whole layer is temporary and is written to be deleted.** When the
// Swiss Ephemeris commercial licence is bought, iOS returns to the same engine
// as Android and the second implementation comes out — which should be a small
// change rather than an excavation. Nothing above here may depend on which
// engine answered.
//
// The surface is deliberately narrow: it is what the four services that touch
// the sky actually call, taken from their call sites rather than from what a
// library happens to offer.
library;

/// The bodies this app reads.
///
/// ⚠ **Seven wanderers and the two nodes. No outer planets.** Her practice is
/// Hellenistic, which reads the visible seven and the places where the Moon
/// crosses the ecliptic; Uranus, Neptune and Pluto were not known to it. That
/// is doctrine, and it happens also to be what the website returns.
enum Body {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,

  /// The north node — ⚠ the TRUE node, where the Moon's path actually crosses
  /// the ecliptic, not the smoothed mean. Her call, 11 September 2026: "we
  /// should use true for everything site and app." The two differ by up to
  /// 1.8° and can put Rahu in different signs.
  rahu;

  /// The name the website and the app's own screens use.
  String get label => switch (this) {
    Body.sun => 'Sun',
    Body.moon => 'Moon',
    Body.mercury => 'Mercury',
    Body.venus => 'Venus',
    Body.mars => 'Mars',
    Body.jupiter => 'Jupiter',
    Body.saturn => 'Saturn',
    Body.rahu => 'Rahu',
  };
}

/// Where a body is, and how fast it is going.
///
/// ⚠ Speed is not optional decoration: retrograde is `speed < 0`, and every
/// station, every ingress and half the events list is read off it.
class Placed {
  const Placed({required this.longitude, required this.speed});

  /// Ecliptic longitude of date, in degrees, folded into [0, 360).
  ///
  /// ⚠ Of DATE, measured from the equinox of the moment — which is what
  /// "tropical" means. No ayanamsa is applied anywhere in this app.
  final double longitude;

  /// Degrees per day. Negative when retrograde.
  final double speed;

  bool get retrograde => speed < 0;
}

/// Which of the day's turning points is wanted.
/// ⚠ Four, not three. The stations screen shows dawn, noon, dusk and midnight,
/// and midnight is the LOWER transit — the Sun crossing the meridian beneath
/// the horizon — rather than twelve hours after noon, which it is not.
enum Turn { rise, set, noon, midnight }

/// An engine that can say where the sky was.
///
/// ⚠ Every implementation must agree with shrutivtuber.com to within an
/// arcminute across 1800–2100, and must never put a body in a different sign
/// than the site does. That is not a style note: it is checked, on a device,
/// against a fixture generated from the site's own engine. See
/// `integration_test/agrees_with_the_website_test.dart`.
abstract interface class Sky {
  /// What this engine is, for the licences screen.
  ///
  /// ⚠ Asked rather than typed. The two builds do not use the same theory, and
  /// a hard-coded name would be wrong on one of them — on the screen whose
  /// entire purpose is to be accurate about what the app is made of.
  String get engine;

  /// Anything that must be loaded before the first question. Safe to call more
  /// than once.
  ///
  /// [into] is where an engine that needs data files should unpack them. An
  /// engine that needs none ignores it.
  Future<void> begin({String? into});

  /// Julian day (UT) from a UTC instant.
  ///
  /// ⚠ Leap seconds matter here. Building a Julian day from calendar fields by
  /// hand drops the correction silently — sub-second, which sounds like
  /// nothing until you remember the Moon moves half an arcsecond a second.
  double julianDay(DateTime utc);

  /// The UTC instant a Julian day names.
  DateTime instant(double jd);

  /// Where a body was.
  Placed at(double jd, Body body);

  /// The rising degree, for whole-sign houses.
  ///
  /// ⚠ Whole sign needs only this: the ascendant's SIGN is the first place and
  /// the rest follow round. No cusp arithmetic, no house system to choose.
  double ascendant(double jd, double lat, double lon);

  /// The degree culminating — the midheaven.
  ///
  /// ⚠ Not used by whole-sign houses, which need only the ascendant. It is
  /// shown on the chart screen as an angle in its own right, which is why it is
  /// here rather than derived where it is drawn.
  double midheaven(double jd, double lat, double lon);

  /// When the Sun rises, sets or culminates after [jd].
  ///
  /// ⚠ Null is a real answer, not a failure: above the Arctic circle the Sun
  /// does not always rise, and that is a fact about the latitude.
  ///
  /// ⚠ `refracted` is the difference between the two conventions this app
  /// offers. True is the visible disc — the upper limb, with the atmosphere
  /// bending the light, which is when somebody standing there would say the Sun
  /// rose. False is the centre of the disc with no refraction, which is what
  /// the Indian tradition computes with.
  double? turn(
    double jd,
    Turn which,
    double lat,
    double lon, {
    bool refracted = true,
  });
}
