// SPDX-License-Identifier: AGPL-3.0-only
//
// Her things, and other people's: readings, articles, work in the practice
// room, and offers.
//
// ⚠ **Missing content is designed here, not patched over.** A reading with no
// title falls back to its sign and date; a work with no opening line simply
// sits shorter. Nothing in this file ever renders "Untitled", because
// "Untitled" is a sentence about the database rather than about the reading.
import 'package:flutter/material.dart';

import '../theme/glyph.dart';
import '../theme/tokens.dart';
import 'motifs.dart';
import 'parts.dart';

/// One of her things: a reading or an article. Same card, two kinds.
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.kind,
    required this.date,
    this.title,
    this.sign,
    this.mark,
    this.excerpt,
    this.readingTime,
    this.unread = false,
    this.onOpen,
  });

  /// 'reading' or 'article'.
  final String kind;
  final String date;
  final String? title;
  final String? sign;
  final String? mark;
  final String? excerpt;
  final String? readingTime;
  final bool unread;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final heading = title ?? (sign == null ? date : '$sign · $date');
    return Pressable(
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (mark != null) ...[
                Glyph(mark!, size: 12, color: Gilt.gilt),
                const SizedBox(width: 7),
              ],
              Text(
                (kind == 'reading'
                        ? (sign == null ? 'Reading' : '$sign · reading')
                        : 'Article')
                    .toUpperCase(),
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
              if (unread) ...[
                const SizedBox(width: 7),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Tone.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            heading,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: Face.display,
              fontFamilyFallback: [Face.glyph],
              fontSize: 19,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: Tone.ink,
            ),
          ),
          if (excerpt != null && excerpt!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              excerpt!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.caption,
                height: 1.55,
                color: Tone.faint,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: Face.body,
                  fontFamilyFallback: [Face.glyph],
                  fontSize: Type.caption,
                  height: 1.4,
                  color: Tone.faint,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              if (readingTime != null) ...[
                const SizedBox(width: Gap.sm),
                const Text(
                  '·',
                  style: TextStyle(color: Tone.faint, fontSize: Type.caption),
                ),
                const SizedBox(width: Gap.sm),
                Text(
                  readingTime!,
                  style: const TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: Type.caption,
                    color: Tone.faint,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A reading in the practice room — somebody else's, or your own.
class WorkCard extends StatelessWidget {
  const WorkCard({
    super.key,
    required this.title,
    required this.date,
    this.author,
    this.excerpt,
    this.votes = 0,
    this.myVote = 0,
    this.comments = 0,
    this.status,
    this.mine = false,
    this.sign,
    this.onOpen,
    this.onVote,
  });

  final String title;
  final String date;
  final String? author;
  final String? excerpt;
  final int votes;
  final int myVote;
  final int comments;

  /// 'draft', 'posted' or 'corrected'.
  final String? status;
  final bool mine;
  final String? sign;
  final VoidCallback? onOpen;
  final ValueChanged<int>? onVote;

  @override
  Widget build(BuildContext context) {
    final (statusWord, statusTone) = switch (status) {
      'draft' => ('Draft', Tone.faint),
      'posted' => ('Posted', Tone.accent),
      'corrected' => ('Corrected', Gilt.gilt),
      _ => ('', Tone.faint),
    };
    return Pressable(
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VoteControl(value: votes, mine: myVote, onVote: onVote),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Tone.veil,
                        shape: BoxShape.circle,
                        border: Border.all(color: Tone.line),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        mine ? 'You' : (author ?? 'somebody'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: Type.caption,
                          color: Tone.soft,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      date,
                      style: const TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: Type.caption,
                        color: Tone.faint,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (statusWord.isNotEmpty) ...[
                      const SizedBox(width: 7),
                      Text(
                        statusWord.toUpperCase(),
                        style: TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: 10,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: statusTone,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: Face.display,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: 18,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Tone.ink,
                  ),
                ),
                if (excerpt != null && excerpt!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    excerpt!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: Face.body,
                      fontFamilyFallback: [Face.glyph],
                      fontSize: Type.caption,
                      height: 1.55,
                      color: Tone.faint,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (sign != null) ...[
                      Text(
                        sign!,
                        style: const TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: Type.caption,
                          color: Tone.faint,
                        ),
                      ),
                      const SizedBox(width: Gap.lg),
                    ],
                    const Icon(
                      Icons.mode_comment_outlined,
                      size: 15,
                      color: Tone.faint,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$comments',
                      style: const TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: Type.caption,
                        color: Tone.faint,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Up, down, or neither, with the running total between.
///
/// ⚠ State is fill AND colour AND the semantic flag — never colour alone. A
/// vote lands by the arrow filling; there is no toast, because a toast for
/// every vote is a room nobody can read in.
class VoteControl extends StatelessWidget {
  const VoteControl({
    super.key,
    required this.value,
    this.mine = 0,
    this.onVote,
    this.compact = false,
  });

  final int value;

  /// 1, -1 or 0.
  final int mine;
  final ValueChanged<int>? onVote;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    Widget arrow(int direction) {
      final on = mine == direction;
      return Semantics(
        button: true,
        selected: on,
        label: direction > 0 ? 'Vote up' : 'Vote down',
        child: InkResponse(
          onTap: onVote == null ? null : () => onVote!(on ? 0 : direction),
          radius: 18,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              direction > 0
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: compact ? 20 : 24,
              color: on
                  ? (direction > 0 ? Tone.accent : Tone.rose)
                  : Tone.faint,
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: onVote == null ? 0.38 : 1,
      child: SizedBox(
        width: 34,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            arrow(1),
            Text(
              '$value',
              style: TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.caption,
                height: 1,
                fontWeight: mine != 0 ? FontWeight.w600 : FontWeight.w500,
                color: mine > 0
                    ? Tone.accent
                    : mine < 0
                    ? Tone.rose
                    : Tone.soft,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            arrow(-1),
          ],
        ),
      ),
    );
  }
}

/// A class, a reading slot, the shop, support.
///
/// ⚠ **Nothing takes money inside the app.** Every offer leaves for her own
/// checkout in a browser, and the card says so on its face — the mark and the
/// words "opens in your browser" are the promise that the address bar will say
/// whose checkout it is. They are not decoration and they do not move to the
/// far side of a tap.
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.title,
    this.body,
    this.price,
    this.cadence,
    this.mark = '☉',
    this.membersOnly = false,
    this.locked = false,
    this.soldOut = false,
    this.footnote,
    this.onOpen,
    this.trailing,
  });

  final String title;
  final String? body;
  final String? price;
  final String? cadence;
  final String mark;
  final bool membersOnly;
  final bool locked;
  final bool soldOut;
  final String? footnote;
  final VoidCallback? onOpen;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: soldOut ? 0.6 : 1,
    child: GestureDetector(
      onTap: locked ? null : onOpen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Corner.md),
        child: Container(
          decoration: BoxDecoration(
            // The gilt wash falling away into the card — the one place the
            // brand ornament is allowed to sell something.
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Gilt.wash, Tone.card],
              stops: [0, 0.58],
            ),
            borderRadius: BorderRadius.circular(Corner.md),
            border: Border.all(color: Gilt.gilt.withValues(alpha: 0.38)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Hem(colour: Gilt.gilt),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Glyph(mark, size: 14, color: Gilt.gilt),
                        const SizedBox(width: Gap.sm),
                        Text(
                          (membersOnly ? 'Members' : 'Offer').toUpperCase(),
                          style: const TextStyle(
                            fontFamily: Face.body,
                            fontFamilyFallback: [Face.glyph],
                            fontSize: Type.eyebrow,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.54,
                            color: Gilt.gilt,
                          ),
                        ),
                        if (locked) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.lock_outlined,
                            size: 14,
                            color: Gilt.gilt,
                          ),
                        ],
                        if (soldOut) ...[
                          const SizedBox(width: 6),
                          const Text(
                            '· FULL',
                            style: TextStyle(
                              fontFamily: Face.body,
                              fontFamilyFallback: [Face.glyph],
                              fontSize: Type.eyebrow,
                              letterSpacing: 1.54,
                              fontWeight: FontWeight.w600,
                              color: Tone.faint,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: Face.display,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: 19,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: Tone.ink,
                      ),
                    ),
                    if (body != null && body!.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        body!,
                        style: const TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: Type.caption,
                          height: 1.55,
                          color: Tone.soft,
                        ),
                      ),
                    ],
                    if (trailing != null) ...[
                      const SizedBox(height: Gap.md),
                      trailing!,
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Gilt.gilt.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (price != null)
                            Text.rich(
                              TextSpan(
                                text: price,
                                style: const TextStyle(
                                  fontFamily: Face.body,
                                  fontFamilyFallback: [Face.glyph],
                                  fontSize: Type.data,
                                  height: 1,
                                  fontWeight: FontWeight.w600,
                                  color: Gilt.gilt,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                                children: [
                                  if (cadence != null)
                                    TextSpan(
                                      text: ' $cadence',
                                      style: const TextStyle(
                                        fontSize: Type.caption,
                                        fontWeight: FontWeight.w400,
                                        color: Tone.faint,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          Text(
                            locked
                                ? 'Members only'
                                : (footnote ?? 'opens in your browser'),
                            style: const TextStyle(
                              fontFamily: Face.body,
                              fontFamilyFallback: [Face.glyph],
                              fontSize: Type.caption,
                              height: 1,
                              color: Tone.faint,
                            ),
                          ),
                          if (!locked) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.open_in_new_outlined,
                              size: 14,
                              color: Tone.faint,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Long-form: a reading, an article, a licence.
///
/// EB Garamond at 17/1.65, because these are read on a phone in bed.
class Prose extends StatelessWidget {
  const Prose({
    super.key,
    required this.text,
    this.drop = false,
    this.small = false,
  });

  /// Plain paragraphs, blank-line separated. `> ` opens a quotation and `## `
  /// a heading — the little of Markdown a reading actually uses.
  final String text;

  /// A gilt drop capital on the first paragraph.
  final bool drop;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final blocks = text
        .split(RegExp(r'\n\s*\n'))
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();
    final base = TextStyle(
      fontFamily: Face.display,
      fontFamilyFallback: [Face.glyph],
      fontSize: small ? 15 : Type.prose,
      height: 1.65,
      color: Tone.ink,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == blocks.length - 1 ? 0 : 16),
            child: _block(blocks[i], base, first: i == 0),
          ),
      ],
    );
  }

  Widget _block(String block, TextStyle base, {required bool first}) {
    if (block.startsWith('## ')) {
      return Text(
        block.substring(3),
        style: const TextStyle(
          fontFamily: Face.display,
          fontFamilyFallback: [Face.glyph],
          fontSize: 22,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: Tone.ink,
        ),
      );
    }
    if (block.startsWith('> ')) {
      // A gilt hairline, not a box: a quotation inside a reading is a change of
      // voice, not a change of surface.
      return Container(
        padding: const EdgeInsets.only(left: Gap.lg),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Gilt.gilt.withValues(alpha: 0.45)),
          ),
        ),
        child: Text(
          block.substring(2),
          style: base.copyWith(fontStyle: FontStyle.italic, color: Tone.soft),
        ),
      );
    }
    if (!drop || !first) return Text(block, style: base);

    // The drop capital, made by floating the first letter beside the rest.
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: block.characters.first,
            style: base.copyWith(
              fontSize: base.fontSize! * 2.6,
              height: 1,
              color: Gilt.gilt,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: block.characters.skip(1).toString()),
        ],
      ),
      style: base,
    );
  }
}
