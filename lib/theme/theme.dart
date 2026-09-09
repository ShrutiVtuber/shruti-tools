// SPDX-License-Identifier: AGPL-3.0-only
//
// One ThemeData, built from tokens.dart. Nothing in the app should reach for a
// raw Color or a bare TextStyle — if a screen needs something this does not
// offer, it belongs here so the next screen gets it too.
import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData shrutiTheme() {
  const scheme = ColorScheme.dark(
    primary: Tone.accent,
    onPrimary: Tone.page,
    secondary: Tone.rose,
    onSecondary: Tone.page,
    surface: Tone.card,
    onSurface: Tone.ink,
    error: Tone.live,
    onError: Tone.page,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Tone.page,
    fontFamily: Face.body,
    splashFactory: InkSparkle.splashFactory,

    textTheme: const TextTheme(
      // Display sizes are EB Garamond. It is a text face with a lot of
      // character at size and very little at 13pt, which is exactly the
      // division of labour here.
      displaySmall: TextStyle(
        fontFamily: Face.display,
        fontWeight: FontWeight.w600,
        fontSize: 34,
        height: 1.15,
        color: Tone.ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: Face.display,
        fontWeight: FontWeight.w600,
        fontSize: 26,
        height: 1.2,
        color: Tone.ink,
      ),
      headlineSmall: TextStyle(
        fontFamily: Face.display,
        fontWeight: FontWeight.w500,
        fontSize: 21,
        height: 1.25,
        color: Tone.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: Face.body,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.35,
        color: Tone.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: Face.body,
        fontSize: 16,
        height: 1.55,
        color: Tone.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: Face.body,
        fontSize: 14.5,
        height: 1.55,
        color: Tone.soft,
      ),
      bodySmall: TextStyle(
        fontFamily: Face.body,
        fontSize: 13,
        height: 1.5,
        color: Tone.soft,
      ),
      // Eyebrows and column headings. Uppercased at the call site, not here,
      // so the string stays readable in the widget tree and in a test.
      labelSmall: TextStyle(
        fontFamily: Face.body,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
        letterSpacing: 0.9,
        color: Tone.faint,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Tone.page,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: Face.display,
        fontWeight: FontWeight.w600,
        fontSize: 21,
        color: Tone.ink,
      ),
      iconTheme: IconThemeData(color: Tone.soft),
    ),

    cardTheme: CardThemeData(
      color: Tone.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.md),
        side: const BorderSide(color: Tone.line),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Tone.line,
      thickness: 1,
      space: 1,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Tone.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Tone.accentWash,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: Face.body,
          fontSize: 11.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected)
              ? Tone.accent
              : Tone.faint,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected)
              ? Tone.accent
              : Tone.faint,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Tone.accent,
        foregroundColor: Tone.page,
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(
          fontFamily: Face.body,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corner.sm),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Tone.ink,
        side: const BorderSide(color: Tone.lineStrong),
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(
          fontFamily: Face.body,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corner.sm),
        ),
      ),
    ),
  );
}
