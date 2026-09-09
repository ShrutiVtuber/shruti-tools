// SPDX-License-Identifier: AGPL-3.0-only
//
// Sigil geometry, on the phone.
//
// This is a port of the engine at frontend/site/src/lib/sigil.js on
// shrutivtuber.com, and it is a port on purpose: a sigil drawn on the phone and
// the same statement typed into the website must give the SAME FIGURE. If the
// two ever disagree, one of them is lying about a thing the practitioner is
// meant to be able to reproduce by hand. `sigil_agrees_test.dart` holds the two
// against each other.
//
// ⚠ **The statement never leaves the device.** Not in a request, not in a log,
// not in the exported file's metadata. This is not a privacy nicety bolted on
// afterwards — many hold that a statement of intent is spent once drawn, and
// transmitting it is not nothing. So: no analytics call on this screen, no
// autosave to the account, and the SVG carries the letters and nothing else.
import 'dart:math' as math;

const _vowels = {'A', 'E', 'I', 'O', 'U'};

/// The reduction, stage by stage.
///
/// Every stage is kept, not just the result, because a sigil you cannot
/// reconstruct is one you have to take somebody's word for. The screen shows
/// all of them.
class Reduction {
  const Reduction({
    required this.statement,
    required this.upper,
    required this.lettersOnly,
    required this.afterVowels,
    required this.unique,
  });

  final String statement;
  final String upper;
  final List<String> lettersOnly;
  final List<String> afterVowels;
  final List<String> unique;

  /// The reduction can eat the sentence whole — every letter a vowel, or every
  /// letter a repeat. A designed outcome with something to say, not an error.
  bool get exhausted => unique.isEmpty;

  /// One point is not a line. Also designed, also not an error.
  bool get tooShort => unique.length == 1;
}

/// Strike the vowels, then the repeats. Spare's method.
Reduction reduce(String statement, {bool keepVowels = false}) {
  final upper = statement.toUpperCase();
  final letters = <String>[];
  for (final c in upper.split('')) {
    final u = c.codeUnitAt(0);
    if (u >= 65 && u <= 90) letters.add(c); // A–Z
  }
  final after = keepVowels
      ? letters
      : letters.where((c) => !_vowels.contains(c)).toList();

  final seen = <String>{};
  final unique = <String>[];
  for (final c in after) {
    if (seen.add(c)) unique.add(c);
  }

  return Reduction(
    statement: statement,
    upper: upper,
    lettersOnly: letters,
    afterVowels: after,
    unique: unique,
  );
}

/// Where each letter sits: 26 points around a circle, A at the top, fixed for
/// all time. Change this and every sigil ever drawn by the site stops matching.
math.Point<double> letterPoint(
  String letter,
  double radius,
  double cx,
  double cy,
) {
  final index = letter.codeUnitAt(0) - 65; // A = 0
  final angle = (index / 26) * math.pi * 2 - math.pi / 2;
  return math.Point(
    cx + radius * math.cos(angle),
    cy + radius * math.sin(angle),
  );
}

/// The stroke widths, by name. Same numbers as the site.
const strokeWeights = {'hairline': 1.0, 'broad-pen': 3.5, 'engraved': 2.0};

const weightOptions = [
  ('hairline', 'Hairline'),
  ('broad-pen', 'Broad pen'),
  ('engraved', 'Engraved'),
];
const enclosureOptions = [
  ('none', 'None'),
  ('circle', 'Circle'),
  ('vesica', 'Vesica'),
];

/// The figure: a pure function of (letters, options).
///
/// No randomness, no clock, no machine state — which is what lets the same
/// statement give the same figure on the phone, on the website, and on paper.
class Figure {
  const Figure({
    required this.points,
    required this.stroke,
    required this.enclosure,
    required this.size,
  });

  final List<math.Point<double>> points;
  final double stroke;
  final String enclosure;
  final double size;

  double get cx => size / 2;
  double get cy => size / 2;
  double get radius => size * 0.34;
}

Figure? cast(
  List<String> letters, {
  String weight = 'hairline',
  String enclosure = 'none',
  double size = 512,
}) {
  if (letters.isEmpty) return null;
  final cx = size / 2, cy = size / 2, radius = size * 0.34;
  return Figure(
    points: [for (final l in letters) letterPoint(l, radius, cx, cy)],
    stroke: strokeWeights[weight] ?? 1.0,
    enclosure: enclosure,
    size: size,
  );
}

/// The figure as SVG, byte-identical in shape to what the website exports.
///
/// ⚠ No `<title>`, no `<desc>`, no metadata. The statement must not travel with
/// the file — someone will send this to a friend.
String toSvg(Figure f) {
  String n(double v) => v.toStringAsFixed(3);
  final path = [
    for (var i = 0; i < f.points.length; i++)
      '${i == 0 ? 'M' : 'L'}${n(f.points[i].x)} ${n(f.points[i].y)}',
  ].join(' ');

  var ring = '';
  if (f.enclosure == 'circle') {
    ring =
        '<circle cx="${n(f.cx)}" cy="${n(f.cy)}" '
        'r="${n(f.radius * 1.28)}" fill="none" stroke="currentColor" '
        'stroke-width="${f.stroke}"/>';
  } else if (f.enclosure == 'vesica') {
    final r = f.radius * 1.15, dx = f.radius * 1.15 * 0.5;
    ring =
        '<circle cx="${n(f.cx - dx)}" cy="${n(f.cy)}" r="${n(r)}" '
        'fill="none" stroke="currentColor" stroke-width="${f.stroke}"/>'
        '<circle cx="${n(f.cx + dx)}" cy="${n(f.cy)}" r="${n(r)}" '
        'fill="none" stroke="currentColor" stroke-width="${f.stroke}"/>';
  }

  final start = f.points.first, end = f.points.last;
  final s3 = f.stroke * 3;
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${f.size.toInt()} '
      '${f.size.toInt()}" width="${f.size.toInt()}" height="${f.size.toInt()}" '
      'role="img" aria-label="Sigil">\n'
      '  <g stroke="currentColor" fill="none" stroke-linecap="round" '
      'stroke-linejoin="round">\n'
      '    $ring\n'
      '    <path d="$path" stroke-width="${f.stroke}"/>\n'
      '    <circle cx="${n(start.x)}" cy="${n(start.y)}" '
      'r="${n(f.stroke * 2.2)}" fill="currentColor" stroke="none"/>\n'
      '    <path d="M${n(end.x - s3)} ${n(end.y - s3)} L${n(end.x + s3)} '
      '${n(end.y + s3)} M${n(end.x + s3)} ${n(end.y - s3)} L${n(end.x - s3)} '
      '${n(end.y + s3)}" stroke-width="${f.stroke}"/>\n'
      '  </g>\n'
      '</svg>';
}
