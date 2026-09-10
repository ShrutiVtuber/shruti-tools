// SPDX-License-Identifier: AGPL-3.0-only
//
// What state the whole app is in: which planet rules the hour, and whether she
// is live.
//
// Two facts, held once, because the shell's ornament colour is derived from
// both and every screen inherits it. Without a single holder each screen would
// ask separately, they would disagree at the boundary of an hour, and the hem
// under the app bar would be a different colour from the hem over the tabs.
//
// ⚠ **The ruling hour is computed on the device.** It needs a place and a
// clock and nothing else, so it is right on a train, in a tunnel, and on a
// phone that has never had a network. Liveness is the opposite — it can only
// be asked, so it has three states and `unknown` is never rendered as
// `offline`.
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../theme/tokens.dart';
import 'hours.dart';

/// ⚠ Three states, and the third is not the second. "We could not reach
/// Twitch" and "she is not streaming" are different sentences, and showing the
/// first as the second is the app telling a small lie every time the network
/// hiccups.
enum Liveness { live, off, unknown }

class ShellState extends ChangeNotifier {
  ShellState({required Place where}) : _place = where {
    _readTheHour();
  }

  Place _place;
  HourRuler? _ruler;
  Liveness _live = Liveness.unknown;
  Timer? _tick;

  HourRuler? get ruler => _ruler;
  Liveness get live => _live;
  Place get place => _place;

  /// What the ornament should be: rose all the while she is live, otherwise
  /// the hour's own tint, otherwise gilt.
  ///
  /// ⚠ Live WINS. It is the one thing a viewer opened the app to find out, and
  /// a shell that keeps its ordinary colour while she is streaming has buried
  /// the answer under decoration.
  Color get ornament => switch (_live) {
    Liveness.live => Tone.live,
    _ => _ruler == null ? Gilt.gilt : hourTint[_ruler]!,
  };

  set place(Place value) {
    if (value.lat == _place.lat && value.lon == _place.lon) return;
    _place = value;
    _readTheHour();
  }

  void told(Liveness state) {
    if (state == _live) return;
    _live = state;
    notifyListeners();
  }

  /// The ruler of the hour standing now, and a timer set for the next one.
  ///
  /// ⚠ Scheduled to the hour's own end rather than polled every minute: a
  /// planetary hour is a twelfth of the daylight, so it is 45 minutes in
  /// December and 75 in June, and any fixed poll is either wasteful or late.
  void _readTheHour() {
    _tick?.cancel();
    final now = DateTime.now().toUtc();
    final hours = hoursFor(now, _place.lat, _place.lon);
    final standing = hourNow(hours, now);
    _ruler = standing == null ? null : _rulerOf(standing.ruler);
    notifyListeners();

    if (standing == null) return;
    final until = standing.to.difference(now) + const Duration(seconds: 2);
    if (until.isNegative) return;
    _tick = Timer(until, _readTheHour);
  }

  static HourRuler? _rulerOf(String name) => switch (name) {
    'Sun' => HourRuler.sun,
    'Moon' => HourRuler.moon,
    'Mars' => HourRuler.mars,
    'Mercury' => HourRuler.mercury,
    'Jupiter' => HourRuler.jupiter,
    'Venus' => HourRuler.venus,
    'Saturn' => HourRuler.saturn,
    _ => null,
  };

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }
}

/// The shell's state, reachable from any screen.
class ShellScope extends InheritedNotifier<ShellState> {
  const ShellScope({super.key, required ShellState state, required super.child})
    : super(notifier: state);

  static ShellState? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellScope>()?.notifier;
}
