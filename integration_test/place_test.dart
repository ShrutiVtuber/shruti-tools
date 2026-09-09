// SPDX-License-Identifier: AGPL-3.0-only
//
// A station is an instant. What it is CALLED depends on where you are asking.
//
// The screen printed London's sunrise in the phone's timezone: a card headed
// LONDON showing 07:24 for a sunrise London calls 06:24. Both are the same
// moment. Only one answers the question on the screen, and the wrong one looks
// entirely normal — which is why it survived a build, an install and a look.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shruti_tools/models/place.dart';
import 'package:shruti_tools/services/ephemeris.dart';
import 'package:shruti_tools/services/stations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // No path override: on a real target path_provider answers, and the app's
  // own support directory is the one place guaranteed writable. `/tmp` is not
  // — Android refuses it outright.
  setUpAll(() async => startEphemeris());

  test(
    'London sunrise is told in London time, whatever the phone is set to',
    () {
      // 2026-09-09: British Summer Time, so London is UTC+1.
      final day = stationsFor(
        DateTime.utc(2026, 9, 9, 12),
        Place.london.lat,
        Place.london.lon,
      );
      final dawn = day.firstWhere((s) => s.kind == StationKind.dawn);

      // The instant, in UT.
      expect(dawn.at.hour, 5);
      expect(dawn.at.minute, closeTo(24, 2));

      // The same instant, as London tells it: an hour later, because BST.
      final there = Place.london.tell(dawn.at);
      expect(there.hour, 6);
      expect(there.minute, closeTo(24, 2));
    },
  );

  test('summer time is applied, not a fixed offset', () {
    // The reason the zone is an IANA name and not a number. A table built from
    // a fixed +1 is right for half the year and an hour out for the other half.
    final winter = Place.london.tell(DateTime.utc(2026, 1, 15, 12));
    final summer = Place.london.tell(DateTime.utc(2026, 7, 15, 12));
    expect(winter.hour, 12, reason: 'GMT in January');
    expect(summer.hour, 13, reason: 'BST in July');
  });
}
