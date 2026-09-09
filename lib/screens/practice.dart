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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 0),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('Read'),
                icon: Icon(Icons.menu_book_outlined, size: 18),
              ),
              ButtonSegment(
                value: 1,
                label: Text('Mine'),
                icon: Icon(Icons.edit_outlined, size: 18),
              ),
            ],
            selected: {_tab},
            showSelectedIcon: false,
            onSelectionChanged: (s) {
              setState(() => _tab = s.first);
              if (_tab == 1 && _mine == null && account.signedIn) {
                setState(() => _mine = _room(context).mine());
              }
            },
          ),
        ),
        Expanded(child: _tab == 0 ? _read(account) : _own(account)),
      ],
    );
  }

  Widget _read(Account account) => RefreshIndicator(
    onRefresh: () async => _again(),
    child: FutureBuilder<List<Work>>(
      future: _feed,
      builder: (context, snap) => ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.huge),
        children: [
          Text('Practice', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: Gap.xs),
          const Text(
            'Readings people wrote for practice. Say what you think, and '
            'vote for the ones worth reading — she picks from the top of '
            'this list for the stream.',
            style: TextStyle(color: Tone.soft, height: 1.45),
          ),
          const SizedBox(height: Gap.lg),
          Wrap(
            spacing: Gap.sm,
            children: [
              for (final (value, label) in const [
                ('recent', 'Newest'),
                ('top', 'Most voted'),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: _sort == value,
                  onSelected: (_) {
                    setState(() {
                      _sort = value;
                      _feed = _room(context).feed(sort: value);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          ..._body(snap, empty: 'Nothing submitted yet. Be first.'),
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
              empty:
                  'Nothing yet. A draft here is the same draft as the one '
                  'on the website.',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(AsyncSnapshot<List<Work>> snap, {required String empty}) {
    if (snap.connectionState != ConnectionState.done) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: Gap.xl),
          child: Text('Fetching…', style: TextStyle(color: Tone.faint)),
        ),
      ];
    }
    if (snap.hasError) {
      return [
        Text(
          '${snap.error}',
          style: const TextStyle(color: Tone.live, height: 1.45),
        ),
      ];
    }
    final works = snap.data ?? const <Work>[];
    if (works.isEmpty) {
      return [
        Text(empty, style: const TextStyle(color: Tone.faint, height: 1.45)),
      ];
    }
    return [
      for (final w in works)
        _WorkCard(
          work: w,
          onOpen: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => WorkScreen(id: w.id)))
              .then((_) => _again()),
        ),
    ];
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.work, required this.onOpen});

  final Work work;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onOpen,
    borderRadius: BorderRadius.circular(Corner.md),
    child: Container(
      margin: const EdgeInsets.only(bottom: Gap.sm),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: Tone.card,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: Tone.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  work.shownTitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (work.isDraft)
                const Text(
                  'draft',
                  style: TextStyle(color: Tone.rose, fontSize: 11),
                )
              else
                Row(
                  children: [
                    Icon(
                      work.voted ? Icons.favorite : Icons.favorite_border,
                      size: 14,
                      color: work.voted ? Tone.rose : Tone.faint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${work.votes}',
                      style: const TextStyle(color: Tone.faint, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            [
              work.author,
              // A series says so; a single reading names its sign.
              if (work.series)
                '${work.signs.length} signs'
              else if (work.signs.isNotEmpty)
                titled(work.signs.first),
            ].join(' · '),
            style: const TextStyle(color: Tone.faint, fontSize: 12),
          ),
          if (work.opening.trim().isNotEmpty) ...[
            const SizedBox(height: Gap.sm),
            Text(
              work.opening.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Tone.soft, height: 1.45),
            ),
          ],
        ],
      ),
    ),
  );
}
