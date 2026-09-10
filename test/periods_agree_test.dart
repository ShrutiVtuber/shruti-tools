// SPDX-License-Identifier: AGPL-3.0-only
//
// The app and the site must agree about which week it is.
//
// The week id is what the database is keyed on. A reading filed under the wrong
// week is filed under somebody else's week, and both look perfectly plausible —
// nobody can tell by looking, which is exactly why this is a test and not a
// careful reading of the rule.
//
// ISO weeks are subtle: Monday starts the week, week one holds the first
// Thursday, and **Thursday decides the year**, so a week in early January can
// belong to the year before. The fixture is generated FROM THE SITE'S OWN CODE
// over fifteen years — every awkward new year in it — rather than from my
// understanding of the rule.
//
// ⚠ To regenerate: `node --experimental-strip-types
// frontend/site/scripts/gen-weeks.mjs`, then rebuild the fixture and copy it to
// BOTH repos. The site checks itself against the same file.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:astrolabe/services/periods.dart';

void main() {
  final fixture =
      jsonDecode(File('test/fixtures/iso_weeks.json').readAsStringSync())
          as Map<String, dynamic>;
  final weeks = (fixture['weeks'] as List).cast<Map<String, dynamic>>();

  test('the fixture covers enough years to be worth anything', () {
    expect(weeks.length, greaterThan(700));
    // The cases that break naive implementations: a week belonging to the
    // previous year, and a 53-week year.
    expect(weeks.any((w) => w['week'] == '2021-W52'), isTrue);
    expect(
      weeks.any((w) => (w['week'] as String).endsWith('-W53')),
      isTrue,
      reason: 'no 53-week year in the fixture — the hard case is missing',
    );
  });

  test('every day is put in the week the site puts it in', () {
    final wrong = <String>[];
    for (final w in weeks) {
      for (final day in [w['first'] as String, w['last'] as String]) {
        final got = isoWeek(DateTime.parse('${day}T00:00:00Z'));
        if (got != w['week']) wrong.add('$day: site ${w['week']}, app $got');
      }
    }
    expect(
      wrong,
      isEmpty,
      reason:
          '${wrong.length} days land in a different week:\n'
          '${wrong.take(8).join("\n")}',
    );
  });

  test('every week covers the days the site says it covers', () {
    final wrong = <String>[];
    for (final w in weeks) {
      final want = (w['days'] as List).cast<String>();
      final (start, end) = weekDays(w['week'] as String);
      if (start != want[0] || end != want[1]) {
        wrong.add('${w['week']}: site $want, app [$start, $end]');
      }
    }
    expect(
      wrong,
      isEmpty,
      reason:
          '${wrong.length} weeks span different days:\n'
          '${wrong.take(8).join("\n")}',
    );
  });

  test('a week id round-trips through its own days', () {
    for (final w in weeks) {
      final id = w['week'] as String;
      final (start, _) = weekDays(id);
      expect(
        isoWeek(DateTime.parse('${start}T00:00:00Z')),
        id,
        reason: '$id does not contain its own Monday',
      );
    }
  });

  test('the other periods are shaped the way the site keys them', () {
    final when = DateTime.utc(2026, 9, 10);
    expect(currentCovers('daily', when), '2026-09-10');
    expect(currentCovers('monthly', when), '2026-09');
    expect(currentCovers('yearly', when), '2026');
    expect(currentCovers('weekly', when), isoWeek(when));
  });

  test('a period reads as words, never as its database key', () {
    // ⚠ The ids are what the database is keyed on. A month of her readings
    // showing as "2026-08" on the home screen looked like a file name.
    expect(periodLabel('monthly', '2026-08'), 'August 2026');
    expect(periodLabel('daily', '2026-09-10'), '10 September 2026');
    expect(periodLabel('weekly', '2026-W37'), 'Week of 7 September');
    expect(periodLabel('yearly', '2026'), '2026');
    // Malformed is shown raw rather than crashing a heading.
    expect(periodLabel('monthly', 'nonsense'), 'nonsense');
  });
}
