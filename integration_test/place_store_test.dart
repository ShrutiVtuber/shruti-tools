// SPDX-License-Identifier: AGPL-3.0-only
//
// The settings are ONE object, and every screen reads it.
//
// Each screen used to load the saved place for itself in initState. That is
// fine until two are alive at once — which they always are, because the tabs
// are an IndexedStack and keep their state so a cast chart survives a visit
// elsewhere. Change the place on Stations and Hours went on answering for the
// old one, with its name still printed at the top of its card. A station table
// for the wrong city is indistinguishable from a right one; this was the
// version where the app disagreed with itself.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrolabe/models/place.dart';
import 'package:astrolabe/services/ephemeris.dart';
import 'package:astrolabe/services/settings.dart';
import 'package:astrolabe/services/stations.dart';

const _athens = Place(
  name: 'Athens, Attica, Greece',
  lat: 37.98376,
  lon: 23.72784,
  zone: 'Europe/Athens',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => startEphemeris()); // loads the zone database

  test('nothing chosen yet says so, so a screen can offer to ask', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await Settings.load();
    expect(s.placeChosen, isFalse);
    expect(s.place.name, Place.london.name);
  });

  test('a chosen place comes back whole, zone included', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await Settings.load();
    await s.setPlace(_athens);

    final reopened = await Settings.load();
    expect(reopened.placeChosen, isTrue);
    expect(reopened.place.name, _athens.name);
    expect(reopened.place.lat, closeTo(_athens.lat, 1e-9));
    // The field that makes a table right, and the one easiest to drop.
    expect(reopened.place.zone, 'Europe/Athens');
  });

  test('changing it tells everyone listening', () async {
    // The whole point. Four screens are alive at once and none of them may
    // hold their own answer.
    SharedPreferences.setMockInitialValues({});
    final s = await Settings.load();
    var told = 0;
    s.addListener(() => told++);
    await s.setPlace(_athens);
    expect(told, 1);
    expect(s.place.zone, 'Europe/Athens');
  });

  test('setting the same place again says nothing', () async {
    // A notification per rebuild is a rebuild loop.
    SharedPreferences.setMockInitialValues({});
    final s = await Settings.load();
    await s.setPlace(_athens);
    var told = 0;
    s.addListener(() => told++);
    await s.setPlace(_athens);
    expect(told, 0);
  });

  test('the sunrise convention is remembered and announced', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await Settings.load();
    expect(s.convention, RiseConvention.visibleDisc);
    var told = 0;
    s.addListener(() => told++);
    await s.setConvention(RiseConvention.hindu);
    expect(told, 1);
    expect((await Settings.load()).convention, RiseConvention.hindu);
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
      final s = await Settings.load();
      expect(s.placeChosen, isFalse);
    },
  );

  test('a corrupt stored value is forgotten rather than fatal', () async {
    SharedPreferences.setMockInitialValues({'place': 'not json at all'});
    final s = await Settings.load();
    expect(s.placeChosen, isFalse);
  });
}
