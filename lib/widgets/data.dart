// SPDX-License-Identifier: AGPL-3.0-only
//
// How the app states a fact.
//
// Two shapes and they are not interchangeable. A `Fact` is one label and one
// value, joined by an almanac's dotted leader — used wherever the app answers a
// question. A `Reference` is a table, and it is DENSE on purpose: a
// practitioner reading a month wants the month on one screen.
//
// ⚠ **The table fits.** A reference table that scrolls sideways is a table
// nobody can read at a glance, so the columns share the width and the figures
// get tighter instead. If a month will not fit, cut a column — never the
// density, and never sideways scrolling.
import 'package:flutter/material.dart';

import '../theme/glyph.dart';
import '../theme/tokens.dart';

/// A label, a leader, and a value.
class Fact extends StatelessWidget {
  const Fact({
    super.key,
    required this.label,
    required this.value,
    this.mark,
    this.tone = Tone.ink,
    this.small = false,
    this.leader = true,
  });

  final String label;
  final String value;

  /// An astronomical mark before the label, set in the glyph face.
  final String? mark;
  final Color tone;
  final bool small;
  final bool leader;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minHeight: small ? 24 : 30),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (mark != null) ...[
          Glyph(mark!, size: 13, color: Gilt.gilt),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: Face.body,
              fontFamilyFallback: [Face.glyph],
              fontSize: small ? Type.caption : Type.label,
              height: 1.4,
              color: Tone.faint,
            ),
          ),
        ),
        if (leader)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.sm),
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: const _LeaderPainter(),
              ),
            ),
          )
        else
          const SizedBox(width: Gap.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: Face.body,
              fontFamilyFallback: [Face.glyph],
              fontSize: small ? Type.caption : Type.data,
              height: 1.4,
              fontWeight: small ? FontWeight.w400 : FontWeight.w500,
              color: tone,
              fontFeatures: const [
                FontFeature.tabularFigures(),
                FontFeature.liningFigures(),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// The dotted rule between a label and its value — an almanac's leader, and the
/// reason a column of facts reads as a column rather than as a list.
class _LeaderPainter extends CustomPainter {
  const _LeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // ⚠ A loop bounded by a width that could be infinite is a hang, not a
    // drawing: an unbounded parent hands a painter `double.infinity`, the loop
    // never ends, the raster thread stops answering and Android kills the app.
    // Cheap to guard, invisible when it never happens, fatal when it does.
    if (!size.width.isFinite || size.width <= 0) return;
    final paint = Paint()
      ..color = Tone.line
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 5) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + 1, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LeaderPainter old) => false;
}

/// One column of a reference table.
///
/// ⚠ Named Heading rather than Column: `Column` is Flutter's layout widget,
/// and a table type that shadows it makes every file that wants both unwritable.
class Heading {
  const Heading({
    required this.label,
    this.mark,
    this.numeric = false,
    this.flex = 1,
  });

  final String label;
  final String? mark;
  final bool numeric;
  final int flex;
}

/// One cell.
class Cell {
  const Cell(
    this.value, {
    this.retrograde = false,
    this.muted = false,
    this.strong = false,
  });

  final String value;

  /// ⚠ Retrograde is ℞ AND rose. The mark is not optional decoration: it is
  /// the half of the signal that survives a monochrome screen, a printout, and
  /// the eight per cent of men who cannot separate the tint from the ink.
  final bool retrograde;
  final bool muted;
  final bool strong;
}

/// A row.
class Line {
  const Line(this.cells, {this.now = false});

  final List<Cell> cells;

  /// ⚠ Today is a wash AND the word "now". Again: never the colour alone.
  final bool now;
}

class Reference extends StatelessWidget {
  const Reference({
    super.key,
    required this.columns,
    required this.rows,
    this.caption,
    this.zebra = false,
    this.minWidth,
  });

  final List<Heading> columns;
  final List<Line> rows;
  final String? caption;
  final bool zebra;

  /// Below this the table scrolls sideways instead of squeezing, with the
  /// first column pinned.
  ///
  /// ⚠ The design system says a reference table must FIT and never scroll
  /// sideways, and it is right about the stations and the hours: four or five
  /// columns fit, and squeezing beats scrolling every time.
  ///
  /// An ephemeris is the exception, and it is a real one. Eleven columns of
  /// degrees cannot fit on a 360-point phone at a size anybody can read, and
  /// the alternative shipped: the table simply stopped after Mars, so Jupiter
  /// and Saturn were not missing from the screen — they were missing from the
  /// ephemeris, silently.
  ///
  /// ⚠ The first column is PINNED when this is set. A scrolled grid of degrees
  /// with the date gone is a grid of numbers about nothing.
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final wide = minWidth != null;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Tone.inset,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: Tone.line),
      ),
      child: wide
          ? LayoutBuilder(
              builder: (context, space) => space.maxWidth >= minWidth!
                  ? _table(context)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ⚠ The caption goes ABOVE both halves, not inside the
                        // pinned one. Left in the pinned column it wraps to
                        // four lines in 62 points and pushes every date down,
                        // so the days no longer line up with the degrees
                        // beside them — a table that is worse than no table.
                        if (caption != null) _caption(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Reference(
                              columns: [columns.first],
                              rows: [
                                for (final row in rows)
                                  Line([row.cells.first], now: row.now),
                              ],
                              zebra: zebra,
                            )._table(context, pinned: true),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: minWidth! - _pinnedWidth,
                                  child: Reference(
                                    columns: columns.sublist(1),
                                    rows: [
                                      for (final row in rows)
                                        Line(
                                          row.cells.sublist(1),
                                          now: row.now,
                                        ),
                                    ],
                                    zebra: zebra,
                                  )._table(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            )
          : _table(context),
    );
  }

  /// The width the pinned day column takes.
  static const _pinnedWidth = 62.0;

  /// Tall enough for a glyph above a label, whether or not there is one.
  static const _headerHeight = 42.0;

  Widget _caption() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
    child: Text(
      caption!,
      style: const TextStyle(
        fontFamily: Face.body,
        fontFamilyFallback: [Face.glyph],
        fontSize: Type.caption,
        height: 1.5,
        color: Tone.faint,
      ),
    ),
  );

  Widget _table(BuildContext context, {bool pinned = false}) => SizedBox(
    width: pinned ? _pinnedWidth : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (caption != null) _caption(),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Tone.lineStrong)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
          // ⚠ Fixed, because a header with a glyph above its label is two
          // lines tall and one without is one. Split across a pinned column
          // and a scroller, those two heights put every date half a row above
          // its own degrees — a table that lines up wrongly is worse than no
          // table, and it looks like a rendering glitch rather than a layout
          // bug.
          height: _headerHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < columns.length; i++)
                Expanded(
                  flex: columns[i].flex,
                  // ⚠ The same air the cells get. Without it a right-aligned
                  // "To" and a left-aligned "Ruler" meet in the middle and the
                  // header reads TORULER — which is what shipped.
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: i == 0 ? 0 : 6,
                      right: i == columns.length - 1 ? 0 : 2,
                    ),
                    child: Builder(
                      builder: (context) {
                        final c = columns[i];
                        return Column(
                          crossAxisAlignment: c.numeric
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (c.mark != null) ...[
                              Glyph(c.mark!, size: 13, color: Gilt.gilt),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              c.label.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: Face.body,
                                fontFamilyFallback: [Face.glyph],
                                fontSize: 9,
                                height: 1.15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.72,
                                color: Tone.faint,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (var i = 0; i < rows.length; i++)
          Container(
            decoration: BoxDecoration(
              color: rows[i].now
                  ? Tone.accentWash
                  : zebra && i.isOdd
                  ? Tone.ink.withValues(alpha: 0.015)
                  : null,
              border: const Border(bottom: BorderSide(color: Tone.line)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                for (var c = 0; c < columns.length; c++)
                  Expanded(
                    flex: columns[c].flex,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: c == 0 ? 0 : 6,
                        right: c == columns.length - 1 ? 0 : 2,
                      ),
                      child: _cell(rows[i], c),
                    ),
                  ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _cell(Line row, int index) {
    final cell = index < row.cells.length ? row.cells[index] : const Cell('');
    final column = columns[index];
    final bold = cell.strong || (row.now && index == 0);
    return Row(
      mainAxisAlignment: column.numeric
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            cell.value.isEmpty ? '—' : cell.value,
            overflow: TextOverflow.clip,
            softWrap: false,
            textAlign: column.numeric ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontFamily: Face.body,
              fontFamilyFallback: [Face.glyph],
              fontSize: Type.dataDense,
              height: 1.35,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: cell.value.isEmpty
                  ? Tone.faint
                  : cell.retrograde
                  ? Tone.rose
                  : cell.muted
                  ? Tone.faint
                  : Tone.ink,
              fontFeatures: const [
                FontFeature.tabularFigures(),
                FontFeature.liningFigures(),
              ],
            ),
          ),
        ),
        if (cell.retrograde) ...[
          const SizedBox(width: 3),
          const Glyph('℞', size: 12, color: Tone.rose),
        ],
        if (row.now && index == 0) ...[
          const SizedBox(width: 4),
          const Text(
            'NOW',
            style: TextStyle(
              fontFamily: Face.body,
              fontFamilyFallback: [Face.glyph],
              fontSize: 8,
              height: 1,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.48,
              color: Tone.accent,
            ),
          ),
        ],
      ],
    );
  }
}

/// A block of figures, set as a block — a reckoning, letter by letter.
class Figures extends StatelessWidget {
  const Figures({
    super.key,
    required this.text,
    this.label,
    this.right = false,
  });

  final String text;
  final String? label;

  /// Right-aligned, for a column of values that should line up on the units.
  final bool right;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(Gap.md),
    decoration: BoxDecoration(
      color: Tone.inset,
      borderRadius: BorderRadius.circular(Corner.md),
      border: Border.all(color: Tone.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: const TextStyle(
              fontFamily: Face.body,
              fontFamilyFallback: [Face.glyph],
              fontSize: Type.eyebrow,
              height: 1,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.54,
              color: Tone.faint,
            ),
          ),
          const SizedBox(height: Gap.sm),
        ],
        Text(
          text,
          textAlign: right ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontFamily: Face.body,
            fontFamilyFallback: [Face.glyph],
            fontSize: Type.dataDense,
            height: 1.65,
            color: Tone.ink,
            letterSpacing: 0.3,
            fontFeatures: [
              FontFeature.tabularFigures(),
              FontFeature.liningFigures(),
            ],
          ),
        ),
      ],
    ),
  );
}
