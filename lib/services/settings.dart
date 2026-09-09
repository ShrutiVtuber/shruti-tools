// SPDX-License-Identifier: AGPL-3.0-only
//
// The few things the app remembers between openings.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/place.dart';
import 'stations.dart';

const _placeKey = 'place';
const _conventionKey = 'rise_convention';

/// The place stations are computed for, or null if she has never chosen one.
///
/// Null rather than a silent default, so the caller decides what to show. A
/// screen that cannot tell "never chosen" from "chose London" cannot offer to
/// ask, and asking once is the whole point.
Future<Place?> savedPlace() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_placeKey);
  if (raw == null) return null;
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? Place.fromJson(decoded) : null;
  } catch (_) {
    // A stored value this version cannot read is not worth a crash on the
    // first frame. Forgetting it and asking again is the graceful answer.
    return null;
  }
}

Future<void> savePlace(Place place) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_placeKey, jsonEncode(place.toJson()));
}

/// Which sunrise the stations and the hours are computed from.
///
/// Stored because it changes the answer — about four and a half minutes at
/// Athens, which is enough to move a planetary-hour boundary. Defaulting
/// silently to one of them is what the engine's own comment warns against.
Future<RiseConvention> savedConvention() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString(_conventionKey);
  return RiseConvention.values.firstWhere(
    (c) => c.name == name,
    orElse: () => RiseConvention.visibleDisc,
  );
}

Future<void> saveConvention(RiseConvention convention) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_conventionKey, convention.name);
}
