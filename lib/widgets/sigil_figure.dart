// SPDX-License-Identifier: AGPL-3.0-only
//
// Drawing a sigil: on screen, and to a file.
//
// Kept out of the screen so the export can be tested. Handing a picture to the
// share sheet cannot be driven from a test — the sheet belongs to the OS — but
// the bytes that would be handed over can be, and that is where an export
// breaks: an empty image, the wrong size, a figure that never got painted.
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../services/sigil.dart' as sigil;
import '../theme/tokens.dart';

/// The size the website exports at. Kept the same so a sigil saved from the
/// phone and one saved from the site are the same picture.
const sigilExportSide = 2048.0;

/// The figure as PNG bytes, or null if the engine could not encode it.
///
/// ⚠ Transparent ground on purpose. These get printed, inked over, and laid on
/// top of other things; a white square would have to be cut off every time.
Future<Uint8List?> pngOf(
  sigil.Figure figure, {
  double side = sigilExportSide,
}) async {
  final recorder = ui.PictureRecorder();
  SigilPainter(figure).paint(Canvas(recorder), Size(side, side));
  final image = await recorder.endRecording().toImage(
    side.toInt(),
    side.toInt(),
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data?.buffer.asUint8List();
}

/// The same geometry as the website, scaled to whatever box it is given.
class SigilPainter extends CustomPainter {
  const SigilPainter(this.f);
  final sigil.Figure f;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / f.size; // the figure is cast at 512; fit the box
    final line = Paint()
      ..color = Tone.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = f.stroke * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final solid = Paint()..color = Tone.ink;

    Offset at(math.Point<double> p) => Offset(p.x * k, p.y * k);
    final centre = Offset(f.cx * k, f.cy * k);

    if (f.enclosure == 'circle') {
      canvas.drawCircle(centre, f.radius * 1.28 * k, line);
    } else if (f.enclosure == 'vesica') {
      final r = f.radius * 1.15 * k, dx = r * 0.5;
      canvas.drawCircle(centre.translate(-dx, 0), r, line);
      canvas.drawCircle(centre.translate(dx, 0), r, line);
    }

    final path = Path();
    for (var i = 0; i < f.points.length; i++) {
      final o = at(f.points[i]);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(path, line);

    // A dot where the line starts, a cross where it ends — so the figure can
    // be walked in the right direction a year from now.
    canvas.drawCircle(at(f.points.first), f.stroke * 2.2 * k, solid);
    final end = at(f.points.last), s3 = f.stroke * 3 * k;
    canvas.drawLine(end.translate(-s3, -s3), end.translate(s3, s3), line);
    canvas.drawLine(end.translate(s3, -s3), end.translate(-s3, s3), line);
  }

  @override
  bool shouldRepaint(SigilPainter old) => old.f != f;
}
