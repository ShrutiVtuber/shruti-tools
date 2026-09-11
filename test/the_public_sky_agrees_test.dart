// SPDX-License-Identifier: AGPL-3.0-only
//
// The public-domain engine, held to the website's own numbers.
//
// ⚠ **This runs on the HOST**, which is the quiet advantage of leaving the
// Swiss Ephemeris behind: the replacement is pure Dart, so three centuries of
// sky are checked in a second rather than in a minute on a phone. The fixture
// is the same one the device test uses, generated from shrutivtuber.com's own
// engine by tool/make_ephemeris_fixture.py.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:astrolabe/sky/public.dart';
import 'package:astrolabe/sky/sky.dart';

/// The agreement the app is held to: one arcminute.
///
/// The finest unit any reading is written in. Argued for in
/// integration_test/agrees_with_the_website_test.dart, where the same number
/// governs the Swiss implementation.
const tolerance = 60 / 3600;

/// ⚠ **After 2050 the two engines disagree about ΔT, and neither is wrong.**
///
/// ΔT is the gap between atomic time and the Earth's actual rotation. It is
/// MEASURED, not derived — the planet's spin is not predictable from theory —
/// so every model's future is an extrapolation, and this one and the Swiss
/// Ephemeris's extrapolate differently. By 2100 they differ by a couple of
/// minutes of time, and the Moon moves half an arcsecond a second.
///
/// It affects the Moon and nothing else appreciably, and it affects no date
/// anybody has been born on. Widening here is the honest response: pretending
/// to agree about an unknowable would mean fitting to the other engine's guess
/// and re-fitting every time they revise it.
const beyondDeltaT = 3 * 60 / 3600;

double apart(double a, double b) {
  final d = (a - b).abs() % 360;
  return d > 180 ? 360 - d : d;
}

void main() {
  const sky = PublicSky();
  final fixture =
      jsonDecode(File('test/fixtures/ephemeris.json').readAsStringSync())
          as Map<String, dynamic>;
  final samples = fixture['samples'] as List;

  double allowed(DateTime at) => at.year >= 2050 ? beyondDeltaT : tolerance;

  for (final body in Body.values) {
    test('${body.label} agrees with the website', () {
      var worst = 0.0;
      var worstAt = '';
      final over = <String>[];

      for (final s in samples) {
        final want = (s['positions'] as Map)[body.label];
        if (want == null) continue;
        final at = DateTime.parse(s['utc'] as String);
        final off = apart(
          sky.at(sky.julianDay(at), body).longitude,
          (want['longitude'] as num).toDouble(),
        );
        if (off > worst) {
          worst = off;
          worstAt = s['utc'] as String;
        }
        if (off > allowed(at)) {
          over.add('${s['utc']}: ${(off * 3600).toStringAsFixed(1)} arcsec');
        }
      }

      printOnFailure(
        '${body.label}: worst ${(worst * 3600).toStringAsFixed(1)} '
        'arcsec at $worstAt',
      );
      expect(
        over,
        isEmpty,
        reason:
            '${body.label} is outside tolerance on ${over.length} of '
            '${samples.length} samples: ${over.take(3).join("; ")}',
      );
    });
  }

  test('nobody is ever in the wrong sign', () {
    // ⚠ The failure that is not a rounding difference. A body an arcsecond
    // from a boundary can land either side of it, and then the app and the site
    // disagree about which sign somebody's Sun is in — which is a different
    // reading, not a small error.
    final wrong = <String>[];
    for (final s in samples) {
      final at = DateTime.parse(s['utc'] as String);
      final jd = sky.julianDay(at);
      for (final body in Body.values) {
        final want = (s['positions'] as Map)[body.label];
        if (want == null) continue;
        final theirs = ((want['longitude'] as num) / 30).floor() % 12;
        final ours = (sky.at(jd, body).longitude / 30).floor() % 12;
        if (ours != theirs) {
          wrong.add('${body.label} at ${s['utc']}: $ours here, $theirs there');
        }
      }
    }
    expect(wrong, isEmpty, reason: wrong.take(4).join('; '));
  });

  test('retrograde is agreed', () {
    // Every station and half the events list is read off the sign of the speed.
    final wrong = <String>[];
    for (final s in samples) {
      final jd = sky.julianDay(DateTime.parse(s['utc'] as String));
      for (final body in Body.values) {
        final want = (s['positions'] as Map)[body.label];
        if (want == null) continue;
        // ⚠ The node is always retrograde and the Moon never is; neither is
        // interesting, and the node's tiny wobble can cross zero.
        if (body == Body.rahu || body == Body.moon) continue;
        if (sky.at(jd, body).retrograde != (want['retrograde'] as bool)) {
          wrong.add('${body.label} at ${s['utc']}');
        }
      }
    }
    expect(wrong, isEmpty, reason: wrong.take(4).join('; '));
  });

  test('the ascendant agrees, at every latitude', () {
    final places = (fixture['places'] as Map).cast<String, dynamic>();
    var worst = 0.0;
    final over = <String>[];
    for (final s in samples) {
      final jd = sky.julianDay(DateTime.parse(s['utc'] as String));
      for (final e in (s['ascendant'] as Map).entries) {
        final c = (places[e.key] as List).cast<num>();
        final off = apart(
          sky.ascendant(jd, c[0].toDouble(), c[1].toDouble()),
          (e.value as num).toDouble(),
        );
        if (off > worst) worst = off;
        if (off > tolerance) {
          over.add('${e.key} ${s['utc']}: ${(off * 3600).toStringAsFixed(1)}"');
        }
      }
    }
    printOnFailure(
      'ascendant worst ${(worst * 3600).toStringAsFixed(1)} arcsec',
    );
    expect(over, isEmpty, reason: over.take(3).join('; '));
  });
}
