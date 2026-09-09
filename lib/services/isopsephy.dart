// SPDX-License-Identifier: AGPL-3.0-only
//
// Letter-reckoning, against the tables the packs carry.
//
// Nothing about the arithmetic is invented here. Each system brings its own
// letter table, its own accent folding and its own methods, and this walks
// them — a second copy of the Greek Milesian values in Dart would be a second
// place for them to be wrong.
//
// ⚠ **No conversion between systems.** A Greek 598 and a Hebrew 598 are not a
// correspondence; they are two different questions that happen to have the
// same answer. Matches are only ever sought inside one system, which is why
// `matches` takes the system it was reckoned in and refuses to look outside
// it.
import 'packs.dart';

/// One letter-value system — Greek isopsephy, Hebrew gematria, the abjad.
class NumberSystem {
  const NumberSystem({
    required this.id,
    required this.name,
    required this.script,
    required this.table,
    required this.fold,
    required this.rightToLeft,
  });

  final String id;
  final String name;
  final String script;

  /// Letter → value.
  final Map<String, int> table;

  /// Accented or final forms → the letter they count as.
  final Map<String, String> fold;

  final bool rightToLeft;

  /// The value of a word, and which characters were counted.
  ///
  /// A character with no value is skipped rather than treated as zero, and
  /// reported, because "ΑΒΓ 5" and "ΑΒΓ! 5" are the same number for different
  /// reasons and only one of them is what somebody meant.
  Reckoning reckon(String text) {
    var total = 0;
    final counted = <String>[];
    final ignored = <String>[];
    for (final ch in text.characters()) {
      final folded = fold[ch] ?? ch;
      final value = table[folded];
      if (value == null) {
        if (ch.trim().isNotEmpty) ignored.add(ch);
        continue;
      }
      total += value;
      counted.add(folded);
    }
    return Reckoning(total: total, counted: counted, ignored: ignored);
  }
}

class Reckoning {
  const Reckoning({
    required this.total,
    required this.counted,
    required this.ignored,
  });

  final int total;
  final List<String> counted;

  /// Characters that carry no value in this system. Shown rather than
  /// swallowed: a Latin letter typed into a Greek reckoning is a mistake worth
  /// seeing, and it is invisible in the total.
  final List<String> ignored;
}

extension on String {
  /// Characters, not code units — Greek and Hebrew are outside the BMP in
  /// places and `split('')` would cut a character in half.
  Iterable<String> characters() sync* {
    for (final rune in runes) {
      yield String.fromCharCode(rune);
    }
  }
}

/// A word found at some number.
class Match {
  const Match({
    required this.word,
    required this.gloss,
    required this.value,
    required this.corpus,
  });

  final String word;
  final String gloss;
  final int value;

  /// Which corpus it came from, because a reader deserves to know whether a
  /// match is from the Hebrew Bible or from a 1912 index of Crowley's.
  final String corpus;
}

/// Every letter system installed on this phone.
Future<List<NumberSystem>> installedSystems() async {
  final items = await loadItems('gematria-systems');
  final out = <NumberSystem>[];
  for (final item in items) {
    final tables = item['tables'];
    final table = tables is Map ? tables['default'] : null;
    if (table is! Map) continue;

    final normalising = item['normalising'];
    final foldRaw = normalising is Map
        ? (normalising['default'] is Map
              ? (normalising['default'] as Map)['fold']
              : null)
        : null;

    out.add(
      NumberSystem(
        id: (item['id'] ?? '') as String,
        name: (item['name'] ?? '') as String,
        script: (item['script'] ?? '') as String,
        table: {
          for (final e in table.entries)
            e.key as String: (e.value as num).toInt(),
        },
        // The fold is keyed by CODEPOINT as a string — "7936" for ἀ — because
        // JSON object keys are strings and a codepoint is the stable way to name
        // a character that may not survive being pasted around.
        fold: {
          if (foldRaw is Map)
            for (final e in foldRaw.entries)
              String.fromCharCode(int.tryParse(e.key as String) ?? 0):
                  e.value as String,
        },
        rightToLeft: item['rightToLeft'] == true,
      ),
    );
  }
  return out;
}

/// Words in the installed corpora that reckon to [value], in one system only.
///
/// Named `wordsAt` rather than `matches` because `matcher` exports a `matches`
/// of its own, and a test importing both fails to compile with a message about
/// ambiguity rather than about anything real.
///
/// Loaded from disk on each search rather than held in memory: the Greek
/// corpus is four megabytes of entries, and an app that keeps it resident to
/// answer an occasional question is an app that gets killed in the background.
Future<List<Match>> wordsAt(
  String systemId,
  int value, {
  int limit = 60,
}) async {
  final corpora = await loadItems('gematria-word-lists');
  final out = <Match>[];
  for (final corpus in corpora) {
    if (corpus['system'] != systemId) continue; // never across systems
    final name = (corpus['name'] ?? '') as String;
    for (final row in entriesFor(corpus)) {
      // [word, transliteration, gloss, convention, value]
      if (row.length < 5) continue;
      final v = row[4];
      if (v is! num || v.toInt() != value) continue;
      out.add(
        Match(
          word: '${row[0]}',
          gloss: '${row[2]}',
          value: value,
          corpus: name,
        ),
      );
      if (out.length >= limit) return out;
    }
  }
  return out;
}
