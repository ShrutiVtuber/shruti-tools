// SPDX-License-Identifier: AGPL-3.0-only
//
// One piece of work, and what people made of it.
//
// ⚠ A series is read here as one thing — every sign in it, one after another —
// because that is what was submitted. Splitting it into twelve cards would make
// a week's work look like twelve people's.
import 'package:flutter/material.dart';

import '../services/periods.dart';
import '../services/practice.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/parts.dart';
import '../widgets/motifs.dart';
import '../widgets/forms.dart';
import '../widgets/content.dart';
import '../theme/glyph.dart';
import 'account.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key, required this.id});
  final int id;

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  final _remark = TextEditingController();
  Future<Work>? _work;
  bool _busy = false;
  String? _trouble;

  Practice get _room => Practice(AccountScope.of(context));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _work ??= _room.read(widget.id);
  }

  @override
  void dispose() {
    _remark.dispose();
    super.dispose();
  }

  Future<void> _vote() async {
    setState(() => _trouble = null);
    try {
      await _room.vote(widget.id);
      setState(() => _work = _room.read(widget.id));
    } on PracticeTrouble catch (e) {
      setState(() => _trouble = e.message);
    }
  }

  Future<void> _say() async {
    final what = _remark.text.trim();
    if (what.isEmpty) return;
    setState(() {
      _busy = true;
      _trouble = null;
    });
    try {
      await _room.say(widget.id, what);
      _remark.clear();
      setState(() => _work = _room.read(widget.id));
    } on PracticeTrouble catch (e) {
      setState(() => _trouble = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = AccountScope.of(context).signedIn;
    return Scaffold(
      appBar: const Bar(title: 'A reading', hour: false),
      body: SafeArea(
        child: FutureBuilder<Work>(
          future: _work,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(Gap.gutter),
                child: Column(
                  children: [
                    Skeleton(height: 90),
                    SizedBox(height: Gap.md),
                    Skeleton(height: 220),
                  ],
                ),
              );
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(Gap.gutter),
                child: NoticeBar(
                  tone: BannerTone.warning,
                  title: 'That reading did not load',
                  text: '${snap.error}',
                ),
              );
            }
            final w = snap.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                Gap.gutter,
                Gap.gutter,
                Gap.gutter,
                Gap.huge,
              ),
              children: [
                Text(
                  'PRACTICE · ${w.series ? "${w.signs.length} SIGNS" : (w.signs.isEmpty ? periodLabel(w.period, w.covers).toUpperCase() : titled(w.signs.first).toUpperCase())}',
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
                const SizedBox(height: 10),
                Text(
                  w.shownTitle,
                  style: const TextStyle(
                    fontFamily: Face.display,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: 26,
                    height: 1.22,
                    fontWeight: FontWeight.w500,
                    color: Tone.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Tone.veil,
                        shape: BoxShape.circle,
                        border: Border.all(color: Tone.line),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      w.author,
                      style: const TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: Type.caption,
                        color: Tone.soft,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      periodLabel(w.period, w.covers),
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

                const SizedBox(height: Gap.lg),
                // The vote bar: the control, what it means, and the way to
                // add to it — one row, above the reading, where somebody who
                // has just decided can act on it.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: Gap.md,
                  ),
                  decoration: BoxDecoration(
                    color: Tone.inset,
                    borderRadius: BorderRadius.circular(Corner.md),
                    border: Border.all(color: Tone.line),
                  ),
                  child: Row(
                    children: [
                      VoteControl(
                        value: w.votes,
                        mine: w.voted ? 1 : 0,
                        // ⚠ Not shown to the author. Voting for your own work
                        // is not a vote, and the server says so too.
                        onVote: signedIn && !w.mine ? (_) => _vote() : null,
                      ),
                      const SizedBox(width: Gap.lg),
                      Expanded(
                        child: Text(
                          w.mine
                              ? 'Your own work. The room votes; you do not.'
                              : signedIn
                              ? 'Your vote is counted and can be changed.'
                              : 'Sign in to vote or comment.',
                          style: const TextStyle(
                            fontFamily: Face.body,
                            fontFamilyFallback: [Face.glyph],
                            fontSize: Type.caption,
                            height: 1.5,
                            color: Tone.soft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Gap.lg),
                for (final r in w.readings) ...[
                  Row(
                    children: [
                      Glyph(
                        signGlyph[r.sign] ?? '',
                        size: 15,
                        color: Gilt.gilt,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        r.signName.toUpperCase(),
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
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.xl),
                    child: Prose(text: r.bodyMd, drop: w.readings.length == 1),
                  ),
                ],

                const Rule(mark: '♄'),
                const SizedBox(height: Gap.lg),
                SectionHeader(
                  eyebrow: w.comments.isEmpty
                      ? 'No comments yet'
                      : '${w.comments.length} '
                            'comment${w.comments.length == 1 ? "" : "s"}',
                  title: 'The room',
                ),
                const SizedBox(height: Gap.md),
                if (w.comments.isEmpty)
                  const EmptyState(
                    compact: true,
                    mark: '☿',
                    title: 'Nobody has answered yet',
                    body:
                        'A reading with no reply is a reading nobody argued '
                        'with. Be the first to.',
                  ),
                for (final c in w.comments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const VoteControl(value: 0, compact: true),
                        const SizedBox(width: Gap.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.author,
                                style: const TextStyle(
                                  fontFamily: Face.body,
                                  fontFamilyFallback: [Face.glyph],
                                  fontSize: Type.caption,
                                  color: Tone.soft,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                c.bodyMd,
                                style: const TextStyle(
                                  fontFamily: Face.body,
                                  fontFamilyFallback: [Face.glyph],
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Tone.soft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: Gap.lg),
                if (signedIn) ...[
                  Field(
                    label: 'Add a comment',
                    controller: _remark,
                    multiline: true,
                    rows: 3,
                    hint: 'Argue with it.',
                  ),
                  const SizedBox(height: Gap.md),
                  Push(
                    label: _busy ? 'Sending…' : 'Say it',
                    loading: _busy,
                    onTap: _busy ? null : _say,
                  ),
                ] else
                  const Pressable(
                    tone: Surface.inset,
                    child: Text(
                      'Sign in to reply. Reading needs no account — the room '
                      'keeps its own guidelines, they are two paragraphs long '
                      'and worth reading.',
                      style: TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: Type.caption,
                        height: 1.6,
                        color: Tone.faint,
                      ),
                    ),
                  ),

                if (_trouble != null) ...[
                  const SizedBox(height: Gap.md),
                  NoticeBar(tone: BannerTone.warning, text: _trouble!),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
