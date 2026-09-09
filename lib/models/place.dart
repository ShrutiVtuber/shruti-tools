// SPDX-License-Identifier: AGPL-3.0-only
//
// Where the stations are being computed for.
//
// A place is three things and it needs all three. Coordinates decide WHEN the
// sun rises; the zone decides what that instant is CALLED. Carrying the first
// two without the third is the bug this type exists to prevent: the app
// computed London's dawn correctly and then printed it in the phone's own
// timezone, so a screen headed LONDON showed 07:24 for a sunrise that London
// calls 06:24. Both numbers are the same instant. Only one of them is an
// answer to the question on the screen.
import 'package:timezone/timezone.dart' as tz;

class Place {
  const Place({
    required this.name,
    required this.lat,
    required this.lon,
    required this.zone,
  });

  final String name;

  /// North-positive.
  final double lat;

  /// **East-positive.** The convention Swiss Ephemeris uses and the one the
  /// site's places lookup returns. Entering a west longitude as positive puts
  /// a London dawn in the Pacific, and the table still looks like a normal day.
  final double lon;

  /// An IANA name — "Europe/London". Not an offset: an offset cannot know
  /// about summer time, and a table built from one is right for half the year.
  final String zone;

  /// Until the app asks the phone where it is, or she picks somewhere.
  static const london = Place(
    name: 'London',
    lat: 51.4779,
    lon: 0.0,
    zone: 'Europe/London',
  );

  tz.Location get location => tz.getLocation(zone);

  /// Just the town, for a heading where the country is noise.
  String get shortName => name.split(',').first.trim();

  Map<String, dynamic> toJson() => {
    'name': name,
    'lat': lat,
    'lon': lon,
    'zone': zone,
  };

  /// Rejects a stored place whose zone the database no longer knows, rather
  /// than throwing on the first frame. Zones are renamed and retired — a phone
  /// that saved "Europe/Kiev" should fall back, not crash.
  static Place? fromJson(Map<String, dynamic> j) {
    final zone = j['zone'];
    final lat = j['lat'];
    final lon = j['lon'];
    if (zone is! String || lat is! num || lon is! num) return null;
    try {
      tz.getLocation(zone);
    } catch (_) {
      return null;
    }
    return Place(
      name: (j['name'] ?? '') as String,
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      zone: zone,
    );
  }

  /// An instant, told in this place's own time.
  tz.TZDateTime tell(DateTime instant) =>
      tz.TZDateTime.from(instant.toUtc(), location);
}
