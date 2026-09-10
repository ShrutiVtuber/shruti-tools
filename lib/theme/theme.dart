// SPDX-License-Identifier: AGPL-3.0-only
//
// One ThemeData, built from tokens.dart. Nothing in the app should reach for a
// raw Color or a bare TextStyle — if a screen needs something this does not
// offer, it belongs here so the next screen gets it too.
//
// The scale and the roles come from the Astrolabe design system
// (`guidelines/theme-flutter.md`): two families and one glyph cut, EB Garamond
// for her voice and Commissioner for the chrome, with data set in Commissioner
// at tabular figures rather than in a third face nobody would notice.
//
// ⚠ Dark only, and that is a decision rather than an omission. The site
// carries the light hour of the same palette; the app carries the dark one, so
// the pair reads as one sky at two junctures. A dawn theme on a phone opened
// mostly at night would double what has to be tested for an audience that does
// not have the case.
import 'package:flutter/material.dart';

import 'motion.dart';
import 'tokens.dart';

ThemeData shrutiTheme() {
  const scheme = ColorScheme.dark(
    // ⚠ The only colour that means "you can touch this". Gilt is ornament and
    // never lands in this object.
    primary: Tone.accent,
    onPrimary: Tone.onAccent,
    primaryContainer: Tone.accentWash,
    onPrimaryContainer: Tone.accent,
    secondary: Gilt.gilt,
    onSecondary: Gilt.wash,
    tertiary: Tone.rose,
    onTertiary: Color(0xFF2C2338),
    error: Tone.live,
    onError: Color(0xFF2A0F16),
    errorContainer: Tone.liveWash,
    onErrorContainer: Tone.live,
    surface: Tone.page,
    onSurface: Tone.ink,
    surfaceContainerLowest: Tone.inset,
    surfaceContainerLow: Tone.card,
    surfaceContainerHigh: Tone.veil,
    onSurfaceVariant: Tone.soft,
    outline: Tone.line,
    outlineVariant: Tone.lineStrong,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,

    // ⚠ Push and pop slide 240 ms from the right, on the emphasised curve —
    // not Material's default, which differs per platform and fades on Android.
    // A pushed screen that arrives from the side is a pushed screen; one that
    // fades in has no direction to go back in.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _SlideIn(),
        TargetPlatform.iOS: _SlideIn(),
      },
    ),
    scaffoldBackgroundColor: Tone.page,
    fontFamily: Face.body,
    fontFamilyFallback: [Face.glyph],
    splashFactory: InkSparkle.splashFactory,

    textTheme: const TextTheme(
      // EB Garamond has a great deal of character at size and very little at
      // 13pt, which is exactly the division of labour here.
      displayLarge: TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w500,
        fontSize: 34,
        height: 1.12,
        letterSpacing: -0.41,
        color: Tone.ink,
      ),
      displayMedium: TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w500,
        fontSize: 28,
        height: 1.12,
        letterSpacing: -0.34,
        color: Tone.ink,
      ),
      // Kept: screens written before the system used this for their title.
      displaySmall: TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w600,
        fontSize: 28,
        height: 1.15,
        color: Tone.ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w600,
        fontSize: 26,
        height: 1.2,
        color: Tone.ink,
      ),
      headlineSmall: TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w500,
        fontSize: 21,
        height: 1.25,
        color: Tone.ink,
      ),
      titleLarge: TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.24,
        color: Tone.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w500,
        fontSize: 19,
        height: 1.3,
        color: Tone.ink,
      ),
      titleSmall: TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w600,
        fontSize: 17,
        height: 1.32,
        color: Tone.ink,
      ),
      // ⚠ Prose only. A reading set in Garamond reads as her writing; a list
      // row set in it reads as a mistake.
      bodyLarge: TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontSize: 17,
        height: 1.65,
        color: Tone.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontSize: 16,
        height: 1.5,
        color: Tone.soft,
      ),
      bodySmall: TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontSize: 13,
        height: 1.4,
        color: Tone.soft,
      ),
      labelLarge: TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.4,
        color: Tone.ink,
      ),
      // Eyebrows and column headings. Uppercased at the call site, not here,
      // so the string stays readable in the widget tree and in a test — and so
      // a screen reader is given the sentence rather than the shout.
      labelSmall: TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1.4,
        letterSpacing: 1.54,
        color: Tone.faint,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Tone.page,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: Target.appBar,
      titleTextStyle: TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w600,
        fontSize: 21,
        color: Tone.ink,
      ),
      iconTheme: IconThemeData(color: Tone.soft),
    ),

    cardTheme: CardThemeData(
      color: Tone.card,
      surfaceTintColor: Colors.transparent,
      // On a #121829 page a Material shadow barely reads, so the hairline does
      // the structural work and shadow is kept for things that truly float.
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
      // ⚠ No pill. The gilt hem above the bar marks the selected tab, together
      // with a filled icon and a full-ink label — three signals, because
      // colour is never allowed to be the only one.
      indicatorColor: Colors.transparent,
      overlayColor: WidgetStatePropertyAll(Tone.veil),
      height: Target.tabBar,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: Face.body,
          fontFamilyFallback: [Face.glyph],
          fontSize: 11.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected) ? Tone.ink : Tone.faint,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected) ? Tone.ink : Tone.faint,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Tone.accent,
        foregroundColor: Tone.onAccent,
        disabledBackgroundColor: Tone.accent.withValues(alpha: 0.38),
        disabledForegroundColor: Tone.onAccent.withValues(alpha: 0.6),
        minimumSize: const Size(0, Target.min),
        textStyle: const TextStyle(
          fontFamily: Face.body,
          fontFamilyFallback: [Face.glyph],
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
        minimumSize: const Size(0, Target.min),
        textStyle: const TextStyle(
          fontFamily: Face.body,
          fontFamilyFallback: [Face.glyph],
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corner.sm),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Tone.accent,
        minimumSize: const Size(0, Target.min),
        textStyle: const TextStyle(
          fontFamily: Face.body,
          fontFamilyFallback: [Face.glyph],
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Tone.inset,
      hintStyle: const TextStyle(color: Tone.faint),
      labelStyle: const TextStyle(color: Tone.soft),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Gap.md,
        vertical: Gap.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Corner.sm),
        borderSide: const BorderSide(color: Tone.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Corner.sm),
        borderSide: const BorderSide(color: Tone.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Corner.sm),
        borderSide: const BorderSide(color: Tone.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Corner.sm),
        borderSide: const BorderSide(color: Tone.live),
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Tone.card,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: Tone.lineStrong,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Corner.xl)),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Tone.card,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.lg),
        side: const BorderSide(color: Tone.line),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: Face.display,
        fontFamilyFallback: [Face.glyph],
        fontWeight: FontWeight.w600,
        fontSize: 22,
        color: Tone.ink,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontSize: 16,
        height: 1.5,
        color: Tone.soft,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: Tone.veil,
      contentTextStyle: const TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontSize: 14.5,
        color: Tone.ink,
      ),
      actionTextColor: Tone.accent,
      behavior: SnackBarBehavior.floating,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.sm),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: Tone.card,
      selectedColor: Tone.accentWash,
      disabledColor: Tone.card,
      side: const BorderSide(color: Tone.line),
      labelStyle: const TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontSize: 14,
        color: Tone.soft,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontSize: 14,
        color: Tone.accent,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corner.sm),
      ),
      showCheckmark: false,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Tone.onAccent : Tone.soft,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Tone.accent : Tone.inset,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Tone.lineStrong),
    ),

    listTileTheme: const ListTileThemeData(
      minVerticalPadding: Gap.md,
      iconColor: Tone.faint,
      textColor: Tone.ink,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Gilt.gilt,
      linearTrackColor: Tone.inset,
      circularTrackColor: Tone.inset,
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Tone.veil,
        borderRadius: BorderRadius.circular(Corner.sm),
        border: Border.all(color: Tone.line),
      ),
      textStyle: const TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontSize: 13,
        color: Tone.ink,
      ),
    ),
  );
}

/// The push: 240 ms from the right, and nothing else moves.
///
/// ⚠ Under reduced motion the whole thing collapses to a millisecond and the
/// screen simply is there. Nothing in this app is only legible in motion.
class _SlideIn extends PageTransitionsBuilder {
  const _SlideIn();

  @override
  Duration get transitionDuration => Motion.normal;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (Motion.stilled(context)) return child;
    final curve = CurvedAnimation(parent: animation, curve: Motion.enter);
    return SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(curve),
      child: FadeTransition(opacity: curve, child: child),
    );
  }
}
