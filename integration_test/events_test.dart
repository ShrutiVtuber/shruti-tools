// SPDX-License-Identifier: AGPL-3.0-only
//
// Sky events must land on the same minute her engine does.
//
// Reference values from shruti-astro. These are the entries an ephemeris is
// opened for, and an ingress found a day late is not a small error — it is the
// wrong sign for a whole day.
//
// A minute of tolerance: the root-finder is exact to well under a second, so
// anything bigger than a minute is a real disagreement rather than rounding.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:astrolabe/services/chart.dart';
import 'package:astrolabe/services/ephemeris.dart';
import 'package:astrolabe/services/events.dart';

DateTime _utc(String iso) => DateTime.parse('${iso}Z').toUtc();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => startEphemeris());

  late List<SkyEvent> september;
  setUpAll(() {
    september = eventsBetween(
      DateTime.utc(2026, 9, 1),
      DateTime.utc(2026, 10, 1),
    );
  });

  SkyEvent? find(EventKind kind, {String? body, int? sign}) {
    for (final e in september) {
      if (e.kind != kind) continue;
      if (body != null && e.body != body) continue;
      if (sign != null && e.sign != sign) continue;
      return e;
    }
    return null;
  }

  void within(DateTime? got, String want, {String? because}) {
    expect(got, isNotNull, reason: because);
    expect(
      got!.difference(_utc(want)).inMinutes.abs(),
      lessThanOrEqualTo(1),
      reason: '$because — got $got, engine says $want',
    );
  }

  group('ingresses', () {
    test('the Moon enters Taurus on the 1st at 08:01', () {
      within(
        find(EventKind.ingress, body: 'Moon', sign: 1)?.at,
        '2026-09-01T08:01:18',
        because: 'Moon into Taurus',
      );
    });

    test('Venus enters Scorpio on the 10th at 08:06', () {
      within(
        find(EventKind.ingress, body: 'Venus', sign: 7)?.at,
        '2026-09-10T08:06:48',
        because: 'Venus into Scorpio',
      );
    });

    test('Mercury enters Libra on the 10th at 16:20', () {
      within(
        find(EventKind.ingress, body: 'Mercury', sign: 6)?.at,
        '2026-09-10T16:20:38',
        because: 'Mercury into Libra',
      );
    });

    test('a RETROGRADE ingress lands on the right minute', () {
      // Venus backs out of Scorpio into Libra on 25 October. Going backwards
      // the body crosses the start of the sign it is LEAVING, not the one it
      // is entering — and bisecting on the wrong boundary searches an interval
      // the body never touched. The Moon never goes retrograde, so a scan
      // dominated by the Moon looks perfect with this wrong.
      final autumn = eventsBetween(
        DateTime.utc(2026, 10, 20),
        DateTime.utc(2026, 11, 20),
      );
      final e = autumn.firstWhere(
        (x) => x.kind == EventKind.ingress && x.body == 'Venus',
      );
      expect(signNames[e.sign!], 'Libra');
      within(
        e.at,
        '2026-10-25T09:09:48',
        because: 'Venus retrograde into Libra',
      );
    });

    test('the Moon is found in every sign it enters — fourteen of them', () {
      // Counted from her engine, not reasoned from the sidereal period. My
      // arithmetic said eleven to thirteen and the engine says fourteen: the
      // month happens to open just after one boundary and close just after
      // another, which no average catches. A missed ingress looks exactly like
      // there not being one, so this is pinned to the real number.
      final moon = september
          .where((e) => e.kind == EventKind.ingress && e.body == 'Moon')
          .length;
      expect(moon, 14);
    });
  });

  group('lunations', () {
    test('new moon on the 11th at 03:27, in Virgo', () {
      final e = find(EventKind.newMoon);
      within(e?.at, '2026-09-11T03:27:01', because: 'new moon');
      expect(signNames[e!.sign!], 'Virgo');
    });

    test('full moon on the 26th at 16:49, in Aries', () {
      final e = find(EventKind.fullMoon);
      within(e?.at, '2026-09-26T16:49:01', because: 'full moon');
      expect(signNames[e!.sign!], 'Aries');
    });

    test('one of each in a month, not two and not none', () {
      // The fold from +180 to -180 is a jump, not a crossing. Counting it as
      // one gives a phantom lunation every month, and it is the exact mistake
      // this shape of scan invites.
      expect(september.where((e) => e.kind == EventKind.newMoon).length, 1);
      expect(september.where((e) => e.kind == EventKind.fullMoon).length, 1);
    });
  });

  group('stations', () {
    late List<SkyEvent> autumn;
    setUpAll(() {
      autumn = eventsBetween(
        DateTime.utc(2026, 10, 1),
        DateTime.utc(2026, 12, 1),
      );
    });

    test('Venus turns retrograde on 3 October at 07:15', () {
      final e = autumn.firstWhere(
        (x) => x.kind == EventKind.retrograde && x.body == 'Venus',
      );
      within(e.at, '2026-10-03T07:15:51', because: 'Venus stations retrograde');
      expect(signNames[e.sign!], 'Scorpio');
    });

    test('Mercury turns retrograde on 24 October at 07:12', () {
      final e = autumn.firstWhere(
        (x) => x.kind == EventKind.retrograde && x.body == 'Mercury',
      );
      within(
        e.at,
        '2026-10-24T07:12:48',
        because: 'Mercury stations retrograde',
      );
    });

    test('and direct again on 13 November at 15:53', () {
      final e = autumn.firstWhere(
        (x) => x.kind == EventKind.direct && x.body == 'Mercury',
      );
      within(e.at, '2026-11-13T15:53:57', because: 'Mercury stations direct');
    });

    test('the Sun and Moon never station', () {
      expect(
        autumn.any(
          (e) =>
              (e.kind == EventKind.retrograde || e.kind == EventKind.direct) &&
              (e.body == 'Sun' || e.body == 'Moon'),
        ),
        isFalse,
      );
    });
  });

  test('everything comes back in time order', () {
    for (var i = 1; i < september.length; i++) {
      expect(september[i].at.isBefore(september[i - 1].at), isFalse);
    }
  });
}
