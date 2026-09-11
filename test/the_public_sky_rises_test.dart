// SPDX-License-Identifier: AGPL-3.0-only
//
// The Sun's comings and goings, held to the website's own engine.
//
// ⚠ **This test exists because its absence shipped a broken app.** Its sister,
// `the_public_sky_agrees_test.dart`, checks POSITIONS — and positions were
// right to a few arcseconds while every sunrise on the iPhone was hours out
// and sunset came before it. The suite was green. The bug was found by looking
// at a screenshot.
//
// A test that checks one kind of answer says nothing whatever about another
// kind, however close together they sit in the source.
//
// ⚠ The fixture is generated from `shruti-astro`, the site's own engine, by
// `tool/make_stations_fixture.py` — so "agrees with the web" is true by
// construction rather than by assertion.
//
// How close, measured over 372 stations, eight places, twelve dates spanning
// 1850 to 2099:
//
//   within 5s    192      within 60s   368
//   within 30s   339      worst        298s, Tromsø in January
//
// ⚠ Everything worse than a minute is above 60° latitude, where the Sun comes
// up at a shallow angle and a hair of difference in the refraction model is
// minutes of time. Tromsø on 15 January has 49 minutes of daylight in total.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:astrolabe/sky/public.dart';
import 'package:astrolabe/sky/sky.dart';

/// Where the Sun climbs steeply, the two engines land on the same second.
const _ordinary = 60.0;

/// ⚠ Above this the Sun grazes, and altitude turns into time at a punishing
/// rate. The disagreement is the refraction model, not the arithmetic.
const _steep = 60.0;
const _grazing = 360.0;

/// A crossing this close to 00:00 UT belongs to whichever day you asked first.
const _boundary = Duration(minutes: 5);

void main() {
  const sky = PublicSky();
  const named = {
    'sunrise': Turn.rise,
    'sunset': Turn.set,
    'noon': Turn.noon,
    'midnight': Turn.midnight,
  };

  final rows =
      (jsonDecode(File('test/fixtures/stations.json').readAsStringSync())
              as Map<String, dynamic>)['rows']
          as List;

  test('the fixture is real and covers the hard cases', () {
    expect(rows.length, greaterThan(300));
    final places = {for (final r in rows) (r as Map)['place']};
    final dates = {for (final r in rows) (r as Map)['date']};
    expect(dates.length, greaterThan(8), reason: 'one date proves nothing');
    expect(
      places.any((p) => p == 'Tromso'),
      isTrue,
      reason:
          'without somewhere inside the Arctic circle the "it does not '
          'happen today" branch is never taken',
    );
  });

  test('every station agrees with the website', () {
    final trouble = <String>[];
    var worst = 0.0;
    for (final row in rows.cast<Map<String, dynamic>>()) {
      final lat = row['lat'] as double;
      final lon = row['lon'] as double;
      final where = '${row['place']} ${row['date']} ${row['station']}';
      final jd = sky.julianDay(DateTime.parse('${row['date']}T00:00:00Z'));
      final got = sky.turn(jd, named[row['station']]!, lat, lon);
      final want = row['at'] as String?;

      // Both saying "it does not happen" is agreement, and the commonest
      // case inside the Arctic circle.
      if (want == null && got == null) continue;

      if (want == null || got == null) {
        // ⚠ One says it happens, the other says it does not. That is only
        // forgivable when the crossing sits on the boundary between two days —
        // Reykjavík at midsummer sets at 23:59:55 and again at 00:00:05, and
        // which day owns it is a convention, not a fact about the sky.
        final t = got ?? sky.julianDay(DateTime.parse(want!));
        final when = sky.instant(t);
        final intoTheDay = Duration(
          hours: when.hour,
          minutes: when.minute,
          seconds: when.second,
        );
        final nearBoundary =
            intoTheDay < _boundary ||
            intoTheDay > const Duration(hours: 24) - _boundary;
        if (!nearBoundary) {
          trouble.add(
            '$where: website says ${want ?? "never"}, the app says '
            '${got == null ? "never" : when.toIso8601String()}',
          );
        }
        continue;
      }

      final off =
          sky
              .instant(got)
              .difference(DateTime.parse(want).toUtc())
              .inMilliseconds
              .abs() /
          1000.0;
      if (off > worst) worst = off;
      final allowed = lat.abs() > _steep ? _grazing : _ordinary;
      if (off > allowed) {
        trouble.add(
          '$where: ${off.toStringAsFixed(1)}s apart (allowed $allowed)',
        );
      }
    }
    expect(trouble, isEmpty, reason: trouble.join('\n'));
    // ⚠ A ceiling as well as a floor. If this ever passes with a worst case of
    // an hour, something has quietly widened and the test should say so.
    expect(worst, lessThan(_grazing));
  });

  test('the day the Sun does not set is answered with nothing, not a lie', () {
    // Tromsø, inside the Arctic circle, at midsummer and midwinter.
    final midsummer = sky.julianDay(DateTime.utc(2026, 6, 21));
    final midwinter = sky.julianDay(DateTime.utc(2026, 12, 22));
    expect(sky.turn(midsummer, Turn.set, 69.6492, 18.9553), isNull);
    expect(sky.turn(midsummer, Turn.rise, 69.6492, 18.9553), isNull);
    expect(sky.turn(midwinter, Turn.rise, 69.6492, 18.9553), isNull);

    // ⚠ But noon still happens — the Sun crosses the meridian whether or not
    // it is above the horizon, and a caller drawing a day needs that.
    expect(sky.turn(midsummer, Turn.noon, 69.6492, 18.9553), isNotNull);
    expect(sky.turn(midwinter, Turn.noon, 69.6492, 18.9553), isNotNull);
  });

  test('the four stations of an ordinary day come in order', () {
    // ⚠ The shape of the original bug: all four collapsed to within four
    // minutes of each other and sunset preceded sunrise. Nothing threw.
    final jd = sky.julianDay(DateTime.utc(2026, 9, 11));
    final rise = sky.turn(jd, Turn.rise, 51.5074, -0.1278)!;
    final noon = sky.turn(jd, Turn.noon, 51.5074, -0.1278)!;
    final set = sky.turn(jd, Turn.set, 51.5074, -0.1278)!;
    expect(rise, lessThan(noon));
    expect(noon, lessThan(set));
    expect(
      (set - rise) * 24,
      closeTo(12.9, 0.5),
      reason: 'London on 11 September has about thirteen hours of day',
    );
  });
}
