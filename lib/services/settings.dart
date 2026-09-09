// SPDX-License-Identifier: AGPL-3.0-only
//
// The few things the app remembers, held in ONE place.
//
// Every screen used to read the saved place for itself in initState. That is
// fine until two screens are alive at once — which they always are, because
// the tabs are an IndexedStack and keep their state so a cast chart survives
// a visit to another tab. Change the place on Stations and Hours went on
// answering for the old one, with its name still printed at the top of the
// card. A station table for the wrong city is indistinguishable from a right
// one, and this is the version of that where the app itself disagrees with
// itself.
//
// So: loaded once, before the first frame, and changed through here. A screen
// that wants the place listens rather than remembers.
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/place.dart';
import 'stations.dart';

const _placeKey = 'place';
const _conventionKey = 'rise_convention';

class Settings extends ChangeNotifier {
  Settings._(this._place, this._convention, this._chosen);

  Place _place;
  RiseConvention _convention;
  bool _chosen;

  /// Where the instruments compute for.
  Place get place => _place;

  /// Which sunrise. It moves an hour boundary, so it is carried, not assumed.
  RiseConvention get convention => _convention;

  /// Whether a place was ever actually chosen, as opposed to defaulted.
  ///
  /// A screen that cannot tell "never chosen" from "chose London" cannot offer
  /// to ask, and asking once is the point.
  bool get placeChosen => _chosen;

  static Future<Settings> load() async {
    final prefs = await SharedPreferences.getInstance();

    Place? saved;
    final raw = prefs.getString(_placeKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        saved = decoded is Map<String, dynamic>
            ? Place.fromJson(decoded)
            : null;
      } catch (_) {
        // A stored value this version cannot read is not worth a crash on the
        // first frame. Forgetting it and asking again is the graceful answer.
        saved = null;
      }
    }

    final name = prefs.getString(_conventionKey);
    final convention = RiseConvention.values.firstWhere(
      (c) => c.name == name,
      orElse: () => RiseConvention.visibleDisc,
    );

    return Settings._(saved ?? Place.london, convention, saved != null);
  }

  Future<void> setPlace(Place place) async {
    if (place.name == _place.name && place.zone == _place.zone) return;
    _place = place;
    _chosen = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_placeKey, jsonEncode(place.toJson()));
  }

  Future<void> setConvention(RiseConvention convention) async {
    if (convention == _convention) return;
    _convention = convention;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_conventionKey, convention.name);
  }
}

/// Reach the settings from any screen.
class SettingsScope extends InheritedNotifier<Settings> {
  const SettingsScope({
    super.key,
    required Settings super.notifier,
    required super.child,
  });

  static Settings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope?.notifier != null, 'no SettingsScope above this widget');
    return scope!.notifier!;
  }
}
