// SPDX-License-Identifier: AGPL-3.0-only
//
// Which period a reading is for.
//
// ⚠ This must agree with the site's `lib/periods.ts` exactly. The id is what
// the database is keyed on: a reading filed under the wrong week is filed under
// somebody else's week, and both look perfectly plausible.
//
// ISO weeks are the subtle part. Monday starts the week, week one holds the
// first Thursday, and **Thursday decides the year** — which is why a week in
// early January can belong to the year before. `periods_agree_test.dart` holds
// this against the site's own answer rather than against my reading of the
// rule.
const periods = ['daily', 'weekly', 'monthly', 'yearly'];

String _pad(int n) => n.toString().padLeft(2, '0');

/// The ISO week id for a day: "2026-W37".
String isoWeek(DateTime day) {
  final d = DateTime.utc(day.year, day.month, day.day);
  // Move to the Thursday of this week; its year is the week's year.
  final thursday = d.add(Duration(days: 4 - (d.weekday == 0 ? 7 : d.weekday)));
  final jan1 = DateTime.utc(thursday.year, 1, 1);
  final week = ((thursday.difference(jan1).inDays) / 7).floor() + 1;
  return '${thursday.year}-W${_pad(week)}';
}

/// The Monday and Sunday of an ISO week id.
(String, String) weekDays(String id) {
  final parts = id.split('-W');
  final year = int.parse(parts[0]);
  final week = int.parse(parts[1]);
  final jan4 = DateTime.utc(year, 1, 4);
  final monday = jan4.add(Duration(days: -(jan4.weekday - 1) + (week - 1) * 7));
  final sunday = monday.add(const Duration(days: 6));
  String iso(DateTime d) => d.toIso8601String().substring(0, 10);
  return (iso(monday), iso(sunday));
}

/// The id of the period containing [at] — "this week", "this month".
String currentCovers(String period, [DateTime? at]) {
  final now = (at ?? DateTime.now().toUtc());
  switch (period) {
    case 'daily':
      return now.toIso8601String().substring(0, 10);
    case 'weekly':
      return isoWeek(now);
    case 'yearly':
      return '${now.year}';
    default:
      return '${now.year}-${_pad(now.month)}';
  }
}

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// What to call a period out loud.
///
/// ⚠ Never the raw id. "2026-08" and "2026-W37" are what the DATABASE is keyed
/// on; a person reads "August 2026" and "Week of 7 September". Showing the id
/// on the home screen made a month of her readings look like a file name.
String periodLabel(String period, String covers) {
  try {
    switch (period) {
      case 'daily':
        final d = DateTime.parse(covers);
        return '${d.day} ${_months[d.month - 1]} ${d.year}';
      case 'weekly':
        final (start, _) = weekDays(covers);
        final d = DateTime.parse(start);
        return 'Week of ${d.day} ${_months[d.month - 1]}';
      case 'monthly':
        final parts = covers.split('-');
        return '${_months[int.parse(parts[1]) - 1]} ${parts[0]}';
      default:
        return covers;
    }
  } catch (_) {
    // A malformed id is somebody else's problem to fix; showing it raw is
    // better than showing nothing where a heading should be.
    return covers;
  }
}

const zodiac = [
  'aries',
  'taurus',
  'gemini',
  'cancer',
  'leo',
  'virgo',
  'libra',
  'scorpio',
  'sagittarius',
  'capricorn',
  'aquarius',
  'pisces',
];

/// The glyph for a sign, asked to render as text rather than as a picture.
const signGlyph = {
  'aries': '♈︎',
  'taurus': '♉︎',
  'gemini': '♊︎',
  'cancer': '♋︎',
  'leo': '♌︎',
  'virgo': '♍︎',
  'libra': '♎︎',
  'scorpio': '♏︎',
  'sagittarius': '♐︎',
  'capricorn': '♑︎',
  'aquarius': '♒︎',
  'pisces': '♓︎',
};

String titled(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
