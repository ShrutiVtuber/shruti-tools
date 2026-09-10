// SPDX-License-Identifier: AGPL-3.0-only
//
// The picture somebody actually keeps.
//
// Handing a file to the share sheet cannot be driven from a test — the sheet
// belongs to the OS — but the bytes handed over can be, and that is where an
// export breaks: an empty image, the wrong size, or a frame with nothing
// painted in it. "It opened the share sheet" is not the same claim as "the
// figure was in the file", and this project has shipped that mistake before.
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrolabe/services/sigil.dart';
import 'package:astrolabe/widgets/sigil_figure.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Figure figured([String statement = 'My will is to finish the work']) =>
      cast(reduce(statement).unique, weight: 'engraved', enclosure: 'circle')!;

  /// PNG header, then width and height as big-endian 32-bit ints in the IHDR
  /// chunk. Read straight out of the bytes rather than trusting the encoder.
  ({int width, int height}) pngSize(Uint8List b) {
    expect(b.sublist(0, 8), [
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
    ], reason: 'not a PNG at all');
    final d = ByteData.sublistView(b);
    return (width: d.getUint32(16), height: d.getUint32(20));
  }

  test('the exported picture is the size the website exports', () async {
    final bytes = await pngOf(figured());
    expect(bytes, isNotNull);
    final size = pngSize(bytes!);
    expect(size.width, 2048);
    expect(size.height, 2048);
    expect(
      sigilExportSide,
      2048.0,
      reason: 'the site exports 2048; the two must stay the same picture',
    );
  });

  /// How many pixels actually got ink, out of the raw RGBA.
  ///
  /// ⚠ The first version of this test compared PNG byte lengths instead, and
  /// it PASSED with `canvas.drawPath` commented out — the size difference it
  /// was reading came from the enclosure ring, not from the strokes. A test
  /// that cannot fail is worse than no test, so this counts the ink.
  Future<int> ink(Figure f, {double side = 512}) async {
    final recorder = ui.PictureRecorder();
    SigilPainter(f).paint(Canvas(recorder), Size(side, side));
    final image = await recorder.endRecording().toImage(
      side.toInt(),
      side.toInt(),
    );
    final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    var lit = 0;
    for (var i = 3; i < raw!.lengthInBytes; i += 4) {
      if (raw.getUint8(i) > 0) lit++;
    }
    return lit;
  }

  test('the strokes are actually painted', () async {
    // Same options, same everything — only the number of points differs. One
    // point draws no line at all (a moveTo and nothing else), so all its ink is
    // the start dot and the end cross. Eleven points must draw a great deal
    // more, and if the polyline stops being painted this is what notices.
    final line = await ink(
      cast(
        reduce('My will is to finish the work').unique,
        weight: 'hairline',
        enclosure: 'none',
      )!,
    );
    final endsOnly = await ink(
      cast(reduce('Zz').unique, weight: 'hairline', enclosure: 'none')!,
    );

    expect(endsOnly, greaterThan(0), reason: 'nothing was painted at all');
    expect(
      line,
      greaterThan(endsOnly * 3),
      reason:
          'the eleven-letter figure has barely more ink than a single '
          'point, so the strokes between the letters are not being drawn',
    );
  });

  test('the line says where it starts and where it ends', () async {
    // A dot on the first letter, a cross on the last, so the figure can be
    // walked in the right direction a year from now. Both are drawn on top of
    // the polyline, so each carries visibly more ink than a plain corner does —
    // measured, not guessed: on this figure the start reads 301, the end 410,
    // and the heaviest middle corner 195.
    const side = 1024.0;
    final f = cast(
      reduce('My will is to finish the work').unique,
      weight: 'engraved',
      enclosure: 'none',
    )!;
    final recorder = ui.PictureRecorder();
    SigilPainter(f).paint(Canvas(recorder), const Size(side, side));
    final image = await recorder.endRecording().toImage(1024, 1024);
    final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final k = side / f.size;

    int around(math.Point<double> p) {
      var lit = 0;
      for (var y = (p.y * k - 14).round(); y <= (p.y * k + 14).round(); y++) {
        for (var x = (p.x * k - 14).round(); x <= (p.x * k + 14).round(); x++) {
          if (x < 0 || y < 0 || x >= side || y >= side) continue;
          if (raw!.getUint8(((y * 1024 + x) * 4) + 3) > 0) lit++;
        }
      }
      return lit;
    }

    final corners = [
      for (var i = 1; i < f.points.length - 1; i++) around(f.points[i]),
    ];
    final heaviestCorner = corners.reduce((a, b) => a > b ? a : b);

    expect(
      around(f.points.first),
      greaterThan(heaviestCorner * 1.35),
      reason: 'no dot marking where the line starts',
    );
    expect(
      around(f.points.last),
      greaterThan(heaviestCorner * 1.35),
      reason: 'no cross marking where the line ends',
    );
  });

  test('two different statements make two different pictures', () async {
    final a = await pngOf(figured('My will is to finish the work'), side: 512);
    final b = await pngOf(figured('My will is to open the door'), side: 512);
    expect(a, isNotNull);
    expect(b, isNotNull);
    expect(a, isNot(equals(b)));
  });

  test('the same statement makes the same picture, every time', () async {
    // The claim the whole tool rests on. If the export drifted between runs —
    // an antialiasing seed, a clock, a machine detail — a sigil could not be
    // reproduced, and reproducing it is the point.
    final once = await pngOf(figured(), side: 512);
    final twice = await pngOf(figured(), side: 512);
    expect(once, equals(twice));
  });
}
