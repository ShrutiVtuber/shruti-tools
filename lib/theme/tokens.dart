// SPDX-License-Identifier: AGPL-3.0-only
//
// The site's palette and type, so the app is recognisably the same thing.
//
// These values are lifted from shrutivtuber.com's stylesheet rather than
// re-picked by eye. A colour that is nearly the accent is worse than one that
// is obviously different: it reads as a mistake instead of a choice.
//
// The site carries two palettes, dawn and dusk. The app is dusk only, for the
// same reason the share cards are: it is a night sky, and one look tested well
// beats two looks tested half each.
import 'package:flutter/material.dart';

abstract final class Tone {
  /// The page behind everything.
  static const page = Color(0xFF121829);

  /// A card lifted off the page.
  static const card = Color(0xFF1A2138);

  /// Recessed — a well, a chart ground, a code block.
  static const inset = Color(0xFF0D1220);

  /// Body text.
  static const ink = Color(0xFFE9E6F0);

  /// Secondary text: captions, notes, the second line of a card.
  static const soft = Color(0xFFB3B9D2);

  /// Labels and eyebrows. Not for anything a reader must read.
  static const faint = Color(0xFF8B93AF);

  /// Hairlines.
  static const line = Color(0xFF2E3752);
  static const lineStrong = Color(0xFF485272);

  /// The one accent. Spend it sparingly — a link, the live dot, the current
  /// station. If everything is accented, nothing is.
  static const accent = Color(0xFF8FBEE8);
  static const accentWash = Color(0xFF1D2A45);

  /// Warm counterweight, used for support and for the rose in the mark.
  static const rose = Color(0xFFE0A4BC);

  /// She is streaming. This is the only red on the palette and it means one
  /// thing.
  static const live = Color(0xFFF07A8C);
}

abstract final class Face {
  /// Headings and numbers that want to feel set rather than typed.
  static const display = 'EBGaramond';

  /// Everything read at length.
  static const body = 'Commissioner';
}

/// A four-point spacing scale. Anything between these is a decision to argue
/// for, not a nudge.
abstract final class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 48.0;
}

abstract final class Corner {
  static const sm = 6.0;
  static const md = 12.0;
  static const lg = 20.0;
}
