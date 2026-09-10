// SPDX-License-Identifier: AGPL-3.0-only
//
// The wheels draw what they claim to draw.
//
// Not a golden test: nothing here asserts pixel equality, because a wheel that
// moves by a hair is not a failure and a test that says so is switched off
// within a week. What it asserts is that each thing is ON the canvas — every
// body in its own colour, the phase ring, the house numbers — measured by
// painting the figure and reading the pixels back.
//
// ⚠ The house-number checks are DIFFERENTIAL: the same wheel painted with the
// numbers on and off, asserting the first has more ink. No magic threshold to
// go stale, and nothing to tune when the geometry changes.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:astrolabe/models/place.dart';
import 'package:astrolabe/services/chart.dart';
import 'package:astrolabe/services/ephemeris.dart';
import 'package:astrolabe/services/events.dart';
import 'package:astrolabe/services/period_sky.dart';
import 'package:astrolabe/theme/theme.dart';
import 'package:astrolabe/theme/tokens.dart';
import 'package:astrolabe/widgets/period_events.dart';
import 'package:astrolabe/widgets/period_wheel.dart';
import 'package:astrolabe/widgets/wheel.dart';

Future<ui.Image> _paint(CustomPainter painter, double side) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(Rect.fromLTWH(0, 0, side, side), Paint()..color = Tone.page);
  painter.paint(canvas, Size(side, side));
  return recorder.endRecording().toImage(side.round(), side.round());
}

/// How many pixels two paintings disagree about.
///
/// ⚠ This is the honest way to test a flag. Counting total ink cannot see a
/// house number drawn on top of a filled disc — the pixel was already not the
/// ground, so the count does not move, and the chart wheel came back with the
/// two totals identical to the pixel. A difference is a difference wherever it
/// lands.
Future<int> _differing(ui.Image a, ui.Image b) async {
  final x = await a.toByteData(format: ui.ImageByteFormat.rawRgba);
  final y = await b.toByteData(format: ui.ImageByteFormat.rawRgba);
  var n = 0;
  for (var i = 0; i < x!.lengthInBytes; i += 4) {
    if (x.getUint32(i) != y!.getUint32(i)) n++;
  }
  return n;
}

/// How much of each body's own colour is on the canvas.
///
/// ⚠ This is the assertion that means something. Total ink says the wheel drew
/// SOMETHING; a body's hue says that body's track is there — and since every
/// body has a colour of its own, one silently missing track cannot hide inside
/// a total the way it can inside a pixel count.
Future<Map<String, int>> _byHue(ui.Image image) async {
  const hues = {
    'Saturn': [0x7C, 0x86, 0xA8],
    'Jupiter': [0x6E, 0x93, 0xC4],
    'Mercury': [0x86, 0xBF, 0xD6],
    'Venus': [0xB9, 0xA6, 0xD8],
    'Mars': [0xD9, 0x8C, 0x93],
    'Sun': [0xE0, 0xB9, 0x78],
    'Moon': [0x8A, 0x93, 0xB5],
  };
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final out = {for (final k in hues.keys) k: 0};
  for (var i = 0; i < bytes!.lengthInBytes; i += 4) {
    final r = bytes.getUint8(i);
    final g = bytes.getUint8(i + 1);
    final b = bytes.getUint8(i + 2);
    for (final e in hues.entries) {
      // Near enough: anti-aliasing pulls edge pixels toward the ground.
      if ((r - e.value[0]).abs() < 8 &&
          (g - e.value[1]).abs() < 8 &&
          (b - e.value[2]).abs() < 8) {
        out[e.key] = out[e.key]! + 1;
        break;
      }
    }
  }
  return out;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => startEphemeris());

  late List<SkyDay> february;
  late List<SkyEvent> events;
  setUpAll(() {
    february = skyAcross(DateTime.utc(2026, 2, 1), DateTime.utc(2026, 2, 28));
    events = eventsAcross(DateTime.utc(2026, 2, 1), DateTime.utc(2026, 2, 28));
  });

  testWidgets('every body walks the period in its own colour', (_) async {
    expect(february.length, 28);
    expect(events, isNotEmpty);

    final image = await _paint(
      PeriodWheelPainter(days: february, events: events, rising: 4),
      768,
    );
    final hues = await _byHue(image);
    for (final body in periodBodies) {
      // ⚠ Every one of the seven, not "most". A body whose track is missing is
      // a body a reader will conclude did nothing that month.
      expect(hues[body], greaterThan(100), reason: '$body has no colour on it');
    }
    // The Moon laps the zodiac, so its dashed track is far the longest.
    expect(hues['Moon'], greaterThan(hues['Saturn']!));
  });

  testWidgets('the period wheel numbers its houses', (_) async {
    final with_ = await _paint(
      PeriodWheelPainter(days: february, events: events, rising: 4),
      768,
    );
    final without = await _paint(
      PeriodWheelPainter(
        days: february,
        events: events,
        rising: 4,
        houseNumbers: false,
      ),
      768,
    );
    // Twelve numbers is a few hundred pixels; anything above a handful proves
    // they are drawn, and zero proves the flag does nothing.
    expect(await _differing(with_, without), greaterThan(200));
  });

  testWidgets('the chart wheel numbers its houses', (_) async {
    final chart = castChart(
      when: DateTime.utc(2026, 2, 1, 12),
      place: const Place(
        name: 'Athens',
        lat: 37.9838,
        lon: 23.7275,
        zone: 'Europe/Athens',
      ),
    );
    final rising = ((chart.ascendant ?? 0) ~/ 30) % 12;

    final with_ = await _paint(WheelPainter(chart: chart, rising: rising), 768);
    final without = await _paint(
      WheelPainter(chart: chart, rising: rising, houseNumbers: false),
      768,
    );
    expect(await _differing(with_, without), greaterThan(200));
  });

  testWidgets('the events list keeps the Moon out of the way', (tester) async {
    // The month has thirteen lunar crossings against a handful of planetary
    // events; the whole point of the widget is that the handful stays findable.
    expect(
      events
          .where((e) => e.body == 'Moon' && e.kind == EventKind.ingress)
          .length,
      greaterThan(9),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: shrutiTheme(),
        home: Scaffold(
          backgroundColor: Tone.page,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Gap.lg),
            child: PeriodEvents(events: events),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('THE PLANETS'), findsOneWidget);
    expect(find.text('THE MOON'), findsOneWidget);
    expect(find.text('and it crosses'), findsOneWidget);
    // A lunar crossing must NOT be a full row among the planets.
    expect(find.text('Moon enters Virgo'), findsNothing);
  });
}
