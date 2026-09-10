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

  /// Which sign of a set is on screen. Null until the work arrives, and then
  /// the first one — never a sign the work does not contain.
  String? _showing;

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

  /// Say a piece of work should not be there.
  ///
  /// ⚠ The reason is a short list, not a free-text box. A queue of a hundred
  /// paragraphs is a queue nobody reads; a queue of labelled reasons can be
  /// taken in at a glance, which is what makes it get looked at at all.
  Future<void> _askReport(Work work) async {
    var reason = reportReasons.first.$1;
    final detail = TextEditingController();

    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Tone.card,
      builder: (sheet) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Gap.lg,
              0,
              Gap.lg,
              Gap.lg + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: Gap.md),
                    child: Hem(),
                  ),
                  Text(
                    'Report this reading',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: Gap.sm),
                  const Text(
                    'It goes to Shruti. If a few people report the same thing '
                    'it comes off the feed until she has looked.',
                    style: TextStyle(
                      fontFamily: Face.body,
                      fontFamilyFallback: [Face.glyph],
                      fontSize: Type.caption,
                      height: 1.5,
                      color: Tone.faint,
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  for (final (value, label) in reportReasons)
                    ChoiceRow(
                      label: label,
                      checked: reason == value,
                      onChanged: (_) => setSheet(() => reason = value),
                    ),
                  const SizedBox(height: Gap.md),
                  Field(
                    label: 'Anything else she should know',
                    controller: detail,
                    multiline: true,
                    rows: 2,
                    maxLength: 1000,
                  ),
                  const SizedBox(height: Gap.lg),
                  Push(
                    label: 'Send the report',
                    full: true,
                    onTap: () => Navigator.of(sheet).pop(true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (sent == true && mounted) {
      try {
        await _room.report(work.id, reason: reason, detail: detail.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thank you — it has gone to Shruti.')),
          );
        }
      } on PracticeTrouble catch (e) {
        if (mounted) setState(() => _trouble = e.message);
      }
    }

    detail.dispose();
  }

  /// An author taking their own work back.
  Future<void> _askWithdraw(Work work) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Take this down?'),
        content: const Text(
          'Nobody but you will see it. Nothing is deleted, and the comments '
          'stay with it — you can ask Shruti to put it back.',
        ),
        actions: [
          Push(
            label: 'Leave it up',
            weight: Weight.text,
            onTap: () => Navigator.of(dialog).pop(false),
          ),
          Push(
            label: 'Take it down',
            weight: Weight.outlined,
            destructive: true,
            onTap: () => Navigator.of(dialog).pop(true),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    try {
      await _room.withdraw(work.id);
      if (mounted) setState(() => _work = _room.read(work.id));
    } on PracticeTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = AccountScope.of(context).signedIn;
    return Scaffold(
      appBar: Bar(
        title: 'A reading',
        hour: false,
        actions: [
          FutureBuilder<Work>(
            future: _work,
            builder: (context, snap) {
              final w = snap.data;
              if (w == null) return const SizedBox.shrink();
              return Tap(
                icon: Icons.more_vert,
                label: w.mine ? 'What to do with this' : 'Report this',
                onTap: () => w.mine ? _askWithdraw(w) : _askReport(w),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Work>(
          future: _work,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(Gap.gutter),
                child: Column(
                  children: [
                    Skeleton(lines: 1),
                    SizedBox(height: Gap.xl),
                    Skeleton(lines: 6, title: false),
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
            // ⚠ Settle the chosen sign the moment the work arrives. Left
            // null, the guard below renders EVERY sign at once — which is
            // exactly what the tabs exist to prevent, and it would only show
            // up on a set.
            if (w.series && _showing == null && w.readings.isNotEmpty) {
              _showing = w.readings.first.sign;
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                Gap.gutter,
                Gap.gutter,
                Gap.gutter,
                Gap.huge,
              ),
              children: [
                // ⚠ The author is told what happened to their writing, and
                // why. Somebody whose reading vanished with no explanation
                // concludes the room ate it; "three people reported this and
                // she has not looked yet" is a different sentence, and it is
                // the true one.
                if (w.hidden) ...[
                  NoticeBar(
                    tone: w.hiddenBy == 'author'
                        ? BannerTone.note
                        : BannerTone.caution,
                    title: switch (w.hiddenBy) {
                      'reports' => 'Off the feed while she looks',
                      'author' => 'You took this down',
                      _ => 'Shruti took this down',
                    },
                    text: switch (w.hiddenBy) {
                      'reports' =>
                        'Enough people reported it that it was hidden '
                            'automatically. Shruti reads every report and '
                            'either agrees or puts it straight back. Nothing '
                            'has been deleted.',
                      'author' =>
                        'Only you can see it. Ask Shruti if you want it back '
                            'up.',
                      _ => 'Ask her why if you would like to know.',
                    },
                  ),
                  const SizedBox(height: Gap.lg),
                ],
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
                // ⚠ A set is ONE piece of work — her words, "submitted, read
                // and voted on as one" — so the signs are tabs rather than a
                // scroll through twelve. Moving between them keeps your place.
                //
                // ⚠ Wraps rather than scrolls sideways: twelve chips on a
                // phone is two rows, and a row that scrolls hides its own last
                // sign.
                if (w.series) ...[
                  TagRow(
                    children: [
                      for (final r in w.readings)
                        Tag(
                          label: r.signName,
                          selected: _showing == r.sign,
                          leading: Glyph(
                            signGlyph[r.sign] ?? '',
                            size: 13,
                            color: _showing == r.sign ? Tone.accent : Gilt.gilt,
                          ),
                          onTap: () => setState(() => _showing = r.sign),
                        ),
                    ],
                  ),
                  const SizedBox(height: Gap.lg),
                ],
                for (final r in w.readings)
                  if (!w.series || _showing == r.sign) ...[
                    if (!w.series)
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
                    if (!w.series) const SizedBox(height: Gap.sm),
                    Padding(
                      padding: const EdgeInsets.only(bottom: Gap.xl),
                      child: Prose(
                        text: r.bodyMd,
                        drop: w.readings.length == 1,
                      ),
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
