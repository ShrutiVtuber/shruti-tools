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
  static const liveWash = Color(0xFF33202B);

  /// Pressed fill, sheet scrim base.
  static const veil = Color(0xFF232C48);

  /// On the accent — text and icons that sit on a filled blue.
  static const onAccent = Color(0xFF10182B);
}

/// The brand layer, sampled from her own artwork: the cloak's gold trim and
/// its scattered stars.
///
/// ⚠ **Gold is ornament and never interactive.** Blue keeps that job. A gilt
/// hem marks a selected tab, a gilt rule closes a section, a gilt star sits on
/// a brand surface — but nothing gold is ever the thing you tap, because then
/// the app has two colours meaning "touch this" and neither means it reliably.
abstract final class Gilt {
  /// 7.8:1 on the page, so it may carry text.
  static const gilt = Color(0xFFC9A15B);

  /// Star fill, and the lit limb of a phase disc.
  static const bright = Color(0xFFE0BE7E);

  /// ⚠ Hairlines only. It does NOT pass contrast for text.
  static const dim = Color(0xFF7A6238);
  static const wash = Color(0xFF241E13);

  /// The cloak's two flats, for large brand fields.
  static const cloth = Color(0xFF3E4A6B);
  static const clothDeep = Color(0xFF2B3450);

  /// Card stock — share images and print only, never a screen surface.
  static const parchment = Color(0xFFEDE4CE);
}

/// Which planet rules the hour, computed on the device from the place and the
/// clock — so it is right offline, which is when the app is mostly opened.
enum HourRuler { sun, moon, mars, mercury, jupiter, venus, saturn }

/// ⚠ These tint EXACTLY two things: the hem under the app bar, and the hour
/// chip. Never a table, never a `ColorScheme` slot, never body text. Somebody
/// reading a table of stations must not watch it change colour every sixty-odd
/// minutes.
const hourTint = <HourRuler, Color>{
  HourRuler.sun: Color(0xFFC9A15B),
  HourRuler.moon: Color(0xFFB9C2DA),
  HourRuler.mars: Color(0xFFD08A7C),
  HourRuler.mercury: Color(0xFF8FBEE8),
  HourRuler.jupiter: Color(0xFF9FC2A8),
  HourRuler.venus: Color(0xFFE0A4BC),
  HourRuler.saturn: Color(0xFF8B93AF),
};

abstract final class Face {
  /// Headings and numbers that want to feel set rather than typed.
  static const display = 'EBGaramond';

  /// Everything read at length.
  static const body = 'Commissioner';

  /// The bundled cut of twenty-nine astronomical marks. ⚠ Never named
  /// directly — go through `glyph.dart`, which also emits U+FE0E. Half the
  /// rule applied is a glyph that still arrives as emoji.
  static const glyph = 'AstroSymbols';
}

/// A four-point spacing scale. Anything between these is a decision to argue
/// for, not a nudge.
abstract final class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const ml = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 48.0;
  static const vast = 56.0;

  /// The page margin. Reading screens get [gutter]; the instruments — Sky,
  /// Chart, the ephemeris — get [gutterDense], because density is the point
  /// there and a wide margin buys nothing but a narrower table.
  static const gutter = 16.0;
  static const gutterDense = 12.0;
}

/// ⚠ Rounder than the website's 4 / 10 / 16, deliberately: this is a phone, it
/// is Material 3, and her line is soft. Anything SHARED with the site — an
/// email, a share image — keeps the site's radii, not these.
/// The type scale, named as the design system names it.
///
/// ⚠ Sizes, not styles. A style pairs a size with a family, a weight and a
/// colour, and those live in `theme.dart` — this is here so a widget that
/// genuinely needs a bare number reaches for the same number as the widget
/// beside it.
abstract final class Type {
  static const masthead = 34.0;
  static const display = 28.0;
  static const title = 22.0;
  static const heading = 17.0;
  static const prose = 17.0;
  static const body = 16.0;
  static const label = 14.0;
  static const caption = 13.0;

  /// Times, degrees, counts.
  static const data = 15.0;

  /// The stations table and the ephemeris. ⚠ Dense on purpose.
  static const dataDense = 13.0;

  /// Uppercase only.
  static const eyebrow = 11.0;
}

abstract final class Corner {
  /// Chips, buttons, inputs.
  static const sm = 8.0;

  /// Cards and list groups.
  static const md = 14.0;

  /// The Home plate, dialogs.
  static const lg = 20.0;

  /// Bottom sheets.
  static const xl = 28.0;
}

/// What a finger can reliably hit.
abstract final class Target {
  static const min = 48.0;
  static const row = 56.0;
  static const appBar = 56.0;
  static const tabBar = 64.0;
}
