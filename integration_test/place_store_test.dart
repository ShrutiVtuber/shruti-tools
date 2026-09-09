// SPDX-License-Identifier: AGPL-3.0-only
//
// The chosen place has to survive being closed.
//
// It is the one setting the app has, and getting it wrong is not a lost
// preference — it is a table of times for the wrong city, which reads as
// perfectly normal.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shruti_tools/models/place.dart';
import 'package:shruti_tools/services/ephemeris.dart';
import 'package:shruti_tools/services/settings.dart';

const _athens = Place(
  name: 'Athens, Attica, Greece',
  lat: 37.98376,
  lon: 23.72784,
  zone: 'Europe/Athens',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await startEphemeris(); // loads the zone database
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'nothing chosen yet reads as null, so the app can offer to ask',
    () async {
      SharedPreferences.setMockInitialValues({});
      expect(await savedPlace(), isNull);
    },
  );

  test('a saved place comes back whole, zone included', () async {
    SharedPreferences.setMockInitialValues({});
    await savePlace(_athens);
    final back = await savedPlace();
    expect(back, isNotNull);
    expect(back!.name, _athens.name);
    expect(back.lat, closeTo(_athens.lat, 1e-9));
    expect(back.lon, closeTo(_athens.lon, 1e-9));
    // The field that makes the table right, and the one easiest to drop.
    expect(back.zone, 'Europe/Athens');
  });

  test(
    'a place whose zone no longer exists is refused, not thrown on',
    () async {
      // Zones are renamed and retired. A phone that saved one under its old name
      // should fall back to asking, not crash on the first frame.
      SharedPreferences.setMockInitialValues({
        'place':
            '{"name":"Nowhere","lat":0,"lon":0,"zone":"Mars/Olympus_Mons"}',
      });
      expect(await savedPlace(), isNull);
    },
  );

  test('a corrupt stored value is forgotten rather than fatal', () async {
    SharedPreferences.setMockInitialValues({'place': 'not json at all'});
    expect(await savedPlace(), isNull);
  });

  test('the short name is what a heading wants', () {
    expect(_athens.shortName, 'Athens');
  });
}
