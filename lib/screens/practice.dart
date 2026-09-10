// SPDX-License-Identifier: AGPL-3.0-only
//
// The practice room.
//
// Somewhere to put a reading in front of other people and be told what they
// think — her purpose, in her words, so people "can get feedback on their
// interpretations, learn and grow as horoscope writers", and so she can pick
// the highest-voted ones to read on stream.
//
// ⚠ **A WORK is the unit.** Twelve signs for a week is one piece of work and is
// read and voted on as one; a single reading is a work holding one. Nothing
// here has a separate mode for a series.
//
// ⚠ **Reading needs no account, posting does.** Every screen that writes says
// so up front rather than letting somebody type a paragraph and then be told.
import 'package:flutter/material.dart';

import '../services/account.dart';
import '../services/periods.dart';
import '../services/practice.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/content.dart';
import '../widgets/forms.dart';
import '../widgets/parts.dart';
import 'account.dart';
import 'practice_work.dart';
import 'practice_write.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _tab = 0; // 0 read, 1 mine
  String _sort = 'recent';
  Future<List<Work>>? _feed;
  Future<List<Work>>? _mine;

  Practice _room(BuildContext context) => Practice(AccountScope.of(context));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _feed ??= _room(context).feed(sort: _sort);
  }

  void _again() {
    setState(() {
      _feed = _room(context).feed(sort: _sort);
      _mine = AccountScope.of(context).signedIn ? _room(context).mine() : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = AccountScope.of(context);
    return Scaffold(
      appBar: const Bar(title: 'Practice'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.sm),
            child: Segmented<int>(
              options: const [(0, 'Read'), (1, 'Mine')],
              chosen: _tab,
              onChosen: (i) {
                setState(() => _tab = i);
                if (_tab == 1 && _mine == null && account.signedIn) {
                  setState(() => _mine = _room(context).mine());
                }
              },
            ),
          ),
          Expanded(child: _tab == 0 ? _read(account) : _own(account)),
        ],
      ),
    );
  }

  Widget _read(Account account) => RefreshIndicator(
    onRefresh: () async => _again(),
    child: FutureBuilder<List<Work>>(
      future: _feed,
      builder: (context, snap) => ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.huge),
        children: [
          const Text(
            'Readings people wrote for practice. Say what you think, and '
            'vote for the ones worth reading — she picks from the top of '
            'this list for the stream.',
            style: TextStyle(color: Tone.soft, height: 1.45),
          ),
          const SizedBox(height: Gap.lg),
          TagRow(
            children: [
              for (final (value, label) in const [
                ('recent', 'Newest'),
                ('top', 'Most voted'),
              ])
                Tag(
                  label: label,
                  kind: ChipKind.filter,
                  selected: _sort == value,
                  onTap: () => setState(() {
                    _sort = value;
                    _feed = _room(context).feed(sort: value);
                  }),
                ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          ..._body(
            snap,
            emptyTitle: 'The room is quiet',
            empty:
                'Nobody has posted a reading this week. Yours would be '
                'the first.',
          ),
        ],
      ),
    ),
  );

  Widget _own(Account account) {
    if (!account.signedIn) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
        children: [
          Text('Your writing', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: Gap.sm),
          const Text(
            'An account keeps what you write, on this phone and on the website '
            'both — and it is what puts a name on a reading when you submit '
            'one.',
            style: TextStyle(color: Tone.soft, height: 1.45),
          ),
          const SizedBox(height: Gap.lg),
          FilledButton(
            onPressed: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const Scaffold(body: SafeArea(child: AccountScreen())),
                  ),
                )
                .then((_) => _again()),
            child: const Text('Sign in, or make an account'),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _again(),
      child: FutureBuilder<List<Work>>(
        future: _mine ??= _room(context).mine(),
        builder: (context, snap) => ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.huge),
          children: [
            Text(
              'Your writing',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: Gap.md),
            FilledButton.icon(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const WriteScreen()))
                  .then((_) => _again()),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Write one'),
            ),
            const SizedBox(height: Gap.lg),
            ..._body(
              snap,
              emptyTitle: 'Nothing written yet',
              empty:
                  'A draft kept here is the same draft as the one on the '
                  'website — start on a phone, finish at a desk.',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(
    AsyncSnapshot<List<Work>> snap, {
    required String emptyTitle,
    required String empty,
    Widget? emptyAction,
  }) {
    if (snap.connectionState != ConnectionState.done) {
      // ⚠ Three skeleton cards rather than a spinner. A spinner says "wait";
      // a skeleton says what is coming and how much of it, and the screen does
      // not jump when the answer lands.
      return const [
        Skeleton(height: 96),
        SizedBox(height: Gap.sm),
        Skeleton(height: 96),
        SizedBox(height: Gap.sm),
        Skeleton(height: 96),
      ];
    }
    if (snap.hasError) {
      return [Notice(tone: BannerTone.warning, text: '${snap.error}')];
    }
    final works = snap.data ?? const <Work>[];
    if (works.isEmpty) {
      return [
        EmptyState(
          mark: '♄',
          title: emptyTitle,
          body: empty,
          action: emptyAction,
        ),
      ];
    }
    return [
      for (final w in works)
        _WorkCard(
          work: w,
          onOpen: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => WorkScreen(id: w.id)))
              .then((_) => _again()),
          // ⚠ Signed out the arrows are dimmed rather than hidden: somebody
          // who can see that voting exists knows what an account is FOR,
          // which a missing control never says.
          onVote: AccountScope.of(context).signedIn && !w.isDraft
              ? (_) async {
                  await _room(context).vote(w.id);
                  _again();
                }
              : null,
        ),
    ];
  }
}

/// One work in the room, in the shared card.
///
/// ⚠ The vote lives on the card and lands where it is: a vote that pushes to a
/// detail screen is a vote nobody casts while scrolling, which is when people
/// actually read a feed.
class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.work, required this.onOpen, this.onVote});

  final Work work;
  final VoidCallback onOpen;
  final ValueChanged<int>? onVote;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: WorkCard(
      title: work.shownTitle,
      author: work.author,
      mine: work.mine,
      date: _when(work.submittedAt),
      excerpt: work.opening.trim().isEmpty ? null : work.opening.trim(),
      votes: work.votes,
      myVote: work.voted ? 1 : 0,
      comments: work.comments.length,
      status: work.isDraft ? 'draft' : (work.mine ? 'posted' : null),
      sign: work.series
          ? '${work.signs.length} signs'
          : (work.signs.isEmpty ? null : titled(work.signs.first)),
      onOpen: onOpen,
      onVote: onVote,
    ),
  );

  static String _when(String? at) {
    if (at == null) return 'draft';
    final t = DateTime.tryParse(at)?.toLocal();
    if (t == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${t.day} ${months[t.month - 1]}';
  }
}
