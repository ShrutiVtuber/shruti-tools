// SPDX-License-Identifier: AGPL-3.0-only
//
// Astronomical marks, set as type.
//
// ⚠ **A mark is type, never emoji.** Left to itself a platform hands ♀ ♃ ☾ to
// a colour-emoji font, which ignores `color` outright — the glyph arrives as a
// picture in somebody else's palette, at somebody else's weight, and the whole
// figure it sits in stops matching. U+FE0E is the request for the text
// presentation, and the family pins which face answers.
//
// Both halves are needed and both are easy to forget, which is exactly why
// they live in one function rather than in a habit.
import 'package:flutter/material.dart';

import 'tokens.dart';

/// The variation selector that asks for text rather than emoji.
const textPresentation = '︎';

/// One mark, as a span, so it can sit mid-sentence.
TextSpan glyphSpan(String mark, {Color? color, double size = 16}) => TextSpan(
  text: '$mark$textPresentation',
  style: TextStyle(
    fontFamily: Face.glyph,
    fontSize: size,
    color: color,
    height: 1,
  ),
);

/// One mark, on its own.
class Glyph extends StatelessWidget {
  const Glyph(this.mark, {super.key, this.size = 16, this.color});

  final String mark;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    '$mark$textPresentation',
    style: TextStyle(
      fontFamily: Face.glyph,
      fontSize: size,
      color: color ?? Tone.soft,
      height: 1,
    ),
  );
}
