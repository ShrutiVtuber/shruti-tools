// SPDX-License-Identifier: AGPL-3.0-only
//
// How long things take, and how they get there.
//
// Fades and small translates only. No bounce, no parallax, no spring, and
// nothing that scales — a control that shrinks under a thumb reads as a toy.
//
// ⚠ **Nothing in this app is only legible in motion.** Under reduced motion
// every duration below collapses to a millisecond, the live dot stops pulsing,
// and the word "Live" carries the meaning on its own.
import 'package:flutter/material.dart';

abstract final class Motion {
  /// A state change: a press, a tint, a chip.
  static const quick = Duration(milliseconds: 120);

  /// An enter or an exit: a segment sliding, a card arriving, a vote landing.
  static const normal = Duration(milliseconds: 240);

  /// Atmosphere: the hour tint crossing over, live arriving.
  static const slow = Duration(milliseconds: 600);

  static const ease = Cubic(0.2, 0.7, 0.3, 1);
  static const enter = Cubic(0.32, 0.72, 0, 1);
  static const inOut = Cubic(0.45, 0, 0.25, 1);

  /// The duration to actually use, given what the reader has asked their
  /// phone for.
  static Duration of(BuildContext context, Duration wanted) =>
      MediaQuery.disableAnimationsOf(context)
      ? const Duration(milliseconds: 1)
      : wanted;

  /// True when the reader has asked for less movement. Anything that conveys
  /// meaning by moving must also convey it standing still.
  static bool stilled(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}
