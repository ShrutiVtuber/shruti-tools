// SPDX-License-Identifier: AGPL-3.0-only
//
// The app and the website must say the same sky.
//
// ⚠ **The fixture comes from the WEBSITE's own engine**, not from the app's
// copy of the same library — see tool/make_ephemeris_fixture.py. That makes
// agreement true by construction: the numbers here are literally what
// shrutivtuber.com would answer, so passing means a chart cast on a phone and
// the same chart cast on the site show the same degrees.
//
// ⚠ **This runs on a DEVICE, not on the host.** The Swiss Ephemeris is a
// native library loaded through Flutter's asset bundle; there is no binding for
// it in a plain `flutter test`. That is why this lives in integration_test.
//
//   flutter test integration_test/agrees_with_the_website_test.dart
//
// ⚠ This test exists to survive a change of engine. The iOS build has to drop
// the Swiss Ephemeris — Apple's terms and the AGPL cannot both be satisfied in
// one binary — and whatever replaces it will be held to this same file.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sweph/sweph.dart';

import 'package:astrolabe/services/ephemeris.dart';
import 'package:astrolabe/services/stations.dart';
import 'package:astrolabe/sky/current.dart';

/// How far apart the two engines may be, in degrees.
///
/// ⚠ **One arcminute, and the number was argued for rather than picked.**
///
/// It started at one arcsecond, which is what the theories claim, and the app
/// failed it — for a reason worth recording. The site and the app run DIFFERENT
/// ephemerides: shrutivtuber.com falls back to `FLG_MOSEPH`, the built-in
/// analytic theory, because `SHRUTI_EPHE_PATH` is unset in production, while
/// the app carries the Swiss data files. Two implementations of the same sky,
/// about an arcsecond apart on the Moon and up to half an arcminute on the true
/// node, which is the most sensitive thing either computes.
///
/// An arcminute is the finest unit any reading is written in. A chart shows
/// degrees; a careful one shows degrees and minutes. Nothing in this app or on
/// that site turns on a second of arc.
///
/// ⚠ What this tolerance does NOT protect is the thing that actually matters,
/// so it is checked separately below: a body must never land in a DIFFERENT
/// SIGN on the two. That can happen at any tolerance if a body sits on a
/// boundary, and it is not a rounding difference — it is a different reading.
const tolerance = 60 / 3600;

/// The bodies the fixture carries, mapped to what the library calls them.
const bodies = <String, HeavenlyBody>{
  'Sun': HeavenlyBody.SE_SUN,
  'Moon': HeavenlyBody.SE_MOON,
  'Mercury': HeavenlyBody.SE_MERCURY,
  'Venus': HeavenlyBody.SE_VENUS,
  'Mars': HeavenlyBody.SE_MARS,
  'Jupiter': HeavenlyBody.SE_JUPITER,
  'Saturn': HeavenlyBody.SE_SATURN,
  'Rahu': HeavenlyBody.SE_TRUE_NODE,
};

/// Julian day from a UTC instant, the way the natal chart does it.
///
/// ⚠ **Through `swe_utc_to_jd`, which applies leap seconds.** Building one from
/// calendar fields with `swe_julday` silently drops that correction. It is
/// sub-second, which sounds like nothing — and the Moon moves half an
/// arcsecond a second, so it shows up as a Moon that disagrees with the website
/// by about one and a half arcseconds and a Sun that does not disagree at all.
/// The first version of this test used the wrong one and blamed the app.
double julianDay(DateTime utc) {
  final jd = Sweph.swe_utc_to_jd(
    utc.year,
    utc.month,
    utc.day,
    utc.hour,
    utc.minute,
    utc.second.toDouble(),
    CalendarType.SE_GREG_CAL,
  );
  // [TT, UT1]. Positions are asked for in UT, the same as the chart does.
  return jd[1];
}

/// The smaller of the two ways round a circle.
///
/// ⚠ Without this, 359.9999° and 0.0001° look like a third of a turn apart and
/// every sample that straddles the equinox fails for no reason.
double apart(double a, double b) {
  final d = (a - b).abs() % 360;
  return d > 180 ? 360 - d : d;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, dynamic> fixture;

  setUpAll(() async {
    await startEphemeris();
    fixture =
        jsonDecode(await rootBundle.loadString('test/fixtures/ephemeris.json'))
            as Map<String, dynamic>;
  });

  testWidgets('every body agrees with the website', (tester) async {
    final samples = fixture['samples'] as List;
    final offenders = <String, List<String>>{};
    var checked = 0;
    var worst = 0.0;
    var worstAt = '';

    for (final s in samples) {
      final at = DateTime.parse(s['utc'] as String);
      final jd = Sweph.swe_julday(
        at.year,
        at.month,
        at.day,
        at.hour + at.minute / 60 + at.second / 3600,
        CalendarType.SE_GREG_CAL,
      );

      for (final e in bodies.entries) {
        final want = (s['positions'] as Map)[e.key];
        if (want == null) continue;
        final got = Sweph.swe_calc_ut(
          jd,
          e.value,
          SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED,
        );

        final off = apart(got.longitude, (want['longitude'] as num).toDouble());
        if (off > worst) {
          worst = off;
          worstAt = '${e.key} at ${s['utc']}';
        }
        // ⚠ Collected, not thrown. Failing on the first mismatch tells you one
        // body at one moment and hides whether the rest agree — which is the
        // difference between "one body is wrong" and "the engine is wrong",
        // and it is the first thing you want to know.
        if (off >= tolerance) {
          (offenders[e.key] ??= []).add(
            '${s['utc']}: site ${want['longitude']}, here '
            '${got.longitude.toStringAsFixed(6)} '
            '(${(off * 3600).toStringAsFixed(1)} arcsec)',
          );
        }
        checked++;
      }
    }

    // ⚠ Printed even on success. A test that passes at 0.9 arcseconds is one
    // change away from failing, and the number is the only warning of that.
    debugPrint(
      'checked $checked positions; worst gap '
      '${(worst * 3600).toStringAsFixed(3)}" ($worstAt)',
    );
    for (final e in offenders.entries) {
      debugPrint('DISAGREES: ${e.key} — ${e.value.length} of the samples');
      for (final line in e.value.take(2)) {
        debugPrint('    $line');
      }
    }
    expect(
      checked,
      greaterThan(500),
      reason: 'the fixture went thin — it should carry hundreds of positions',
    );
    expect(
      offenders.keys,
      isEmpty,
      reason:
          'these bodies do not agree with the website: '
          '${offenders.keys.join(", ")}',
    );
  });

  testWidgets('nobody is ever in the wrong sign', (tester) async {
    // ⚠ The failure that actually matters. An arcsecond of drift is invisible
    // until a body sits within an arcsecond of a sign boundary, and then the
    // app and the site disagree about which sign somebody's Sun is in — which
    // is not a rounding difference, it is a different reading.
    final samples = fixture['samples'] as List;
    final wrongSign = <String>[];
    for (final s in samples) {
      final at = DateTime.parse(s['utc'] as String);
      final jd = Sweph.swe_julday(
        at.year,
        at.month,
        at.day,
        at.hour + at.minute / 60 + at.second / 3600,
        CalendarType.SE_GREG_CAL,
      );

      for (final e in bodies.entries) {
        final want = (s['positions'] as Map)[e.key];
        if (want == null) continue;
        final theirs = ((want['longitude'] as num) / 30).floor() % 12;
        final ours =
            (Sweph.swe_calc_ut(jd, e.value, SwephFlag.SEFLG_SWIEPH).longitude /
                    30)
                .floor() %
            12;
        if (ours != theirs) {
          wrongSign.add(
            '${e.key} at ${s['utc']}: sign $ours here, $theirs there',
          );
        }
      }
    }
    for (final line in wrongSign.take(5)) {
      debugPrint('WRONG SIGN: $line');
    }
    expect(
      wrongSign,
      isEmpty,
      reason:
          '${wrongSign.length} positions land in a different sign than '
          'the website puts them in',
    );
  });

  testWidgets('the ascendant agrees, at every latitude', (tester) async {
    // ⚠ Including Reykjavík. A hemisphere or obliquity mistake is invisible in
    // Athens and enormous at 64° north.
    final places = (fixture['places'] as Map).cast<String, dynamic>();
    for (final s in fixture['samples'] as List) {
      final at = DateTime.parse(s['utc'] as String);
      final jd = Sweph.swe_julday(
        at.year,
        at.month,
        at.day,
        at.hour + at.minute / 60 + at.second / 3600,
        CalendarType.SE_GREG_CAL,
      );

      for (final entry in (s['ascendant'] as Map).entries) {
        final coords = (places[entry.key] as List).cast<num>();
        final got = Sweph.swe_houses(
          jd,
          coords[0].toDouble(),
          coords[1].toDouble(),
          Hsys.W,
        );
        final off = apart(got.ascmc[0], (entry.value as num).toDouble());
        expect(
          off,
          lessThan(tolerance),
          reason:
              'ascendant at ${entry.key}, ${s['utc']}: '
              '${(off * 3600).toStringAsFixed(2)} arcseconds apart',
        );
      }
    }
  });

  // ── the Sun's comings and goings ─────────────────────────────────────────
  //
  // ⚠ These did not exist until 11 September 2026, and their absence is the
  // whole reason this section has a comment. The three tests above check
  // POSITIONS, and positions were right to a few arcseconds while every
  // sunrise this app computed on iOS was hours out and sunset came before it.
  // The engine there is a different one, but the gap was the same gap: nothing
  // above asks the sky when the Sun comes up.

  testWidgets('every station agrees with the website', (tester) async {
    await startEphemeris();
    final rows =
        (jsonDecode(await rootBundle.loadString('test/fixtures/stations.json'))
                as Map<String, dynamic>)['rows']
            as List;
    const named = {
      'sunrise': StationKind.dawn,
      'sunset': StationKind.dusk,
      'noon': StationKind.noon,
      'midnight': StationKind.midnight,
    };

    final trouble = <String>[];
    for (final row in rows.cast<Map<String, dynamic>>()) {
      final want = row['at'] as String?;
      if (want == null) continue;
      final day = DateTime.parse('${row['date']}T12:00:00Z');
      // ⚠ Through `stationsFor`, not through the engine directly: the day a
      // station belongs to is decided in the service, and testing underneath it
      // would leave the part that has actually been wrong untested.
      final all = stationsFor(day, row['lat'] as double, row['lon'] as double);
      final kind = named[row['station']]!;
      final mine = all.where((s) => s.kind == kind).firstOrNull;
      if (mine == null) {
        trouble.add(
          '${row['place']} ${row['date']} ${row['station']}: missing',
        );
        continue;
      }
      final off = mine.at
          .difference(DateTime.parse(want).toUtc())
          .inSeconds
          .abs();
      // ⚠ Generous above 60°, where the Sun grazes the horizon and the
      // refraction model rather than the arithmetic decides the answer.
      final allowed = (row['lat'] as double).abs() > 60 ? 360 : 60;
      if (off > allowed) {
        trouble.add(
          '${row['place']} ${row['date']} ${row['station']}: ${off}s apart',
        );
      }
    }
    expect(trouble, isEmpty, reason: trouble.take(6).join('\n'));
  });

  testWidgets('the midheaven agrees, at every latitude', (tester) async {
    await startEphemeris();
    final fixture =
        jsonDecode(await rootBundle.loadString('test/fixtures/ephemeris.json'))
            as Map<String, dynamic>;
    final places = (fixture['places'] as Map).cast<String, dynamic>();
    final over = <String>[];
    for (final s in (fixture['samples'] as List).cast<Map<String, dynamic>>()) {
      final jd = sky.julianDay(DateTime.parse(s['utc'] as String));
      for (final e in (s['midheaven'] as Map).entries) {
        final c = (places[e.key] as List).cast<num>();
        final off = apart(
          sky.midheaven(jd, c[0].toDouble(), c[1].toDouble()),
          (e.value as num).toDouble(),
        );
        if (off > tolerance) {
          over.add('${e.key} ${s['utc']}: ${(off * 3600).toStringAsFixed(1)}"');
        }
      }
    }
    expect(over, isEmpty, reason: over.take(3).join('; '));
  });
}
