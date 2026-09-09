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
import '../widgets/eyebrow.dart';
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
      appBar: AppBar(title: const Text('A reading')),
      body: SafeArea(
        child: FutureBuilder<Work>(
          future: _work,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: Text('Fetching…', style: TextStyle(color: Tone.faint)),
              );
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(Gap.lg),
                child: Text(
                  '${snap.error}',
                  style: const TextStyle(color: Tone.live, height: 1.45),
                ),
              );
            }
            final w = snap.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                Gap.lg,
                Gap.lg,
                Gap.lg,
                Gap.huge,
              ),
              children: [
                Text(
                  w.shownTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${w.author} · ${periodLabel(w.period, w.covers)}',
                  style: const TextStyle(color: Tone.faint, fontSize: 13),
                ),
                const SizedBox(height: Gap.lg),

                for (final r in w.readings) ...[
                  Row(
                    children: [
                      Text(
                        signGlyph[r.sign] ?? '',
                        style: const TextStyle(
                          color: Tone.accent,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        r.signName,
                        style: const TextStyle(
                          color: Tone.faint,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.xs),
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.lg),
                    child: Text(
                      r.bodyMd,
                      style: const TextStyle(color: Tone.ink, height: 1.6),
                    ),
                  ),
                ],

                const Divider(color: Tone.line),
                const SizedBox(height: Gap.sm),
                Row(
                  children: [
                    // ⚠ Not shown to the author. Voting for your own work is
                    // not a vote, and the server says so too.
                    if (!w.mine)
                      OutlinedButton.icon(
                        onPressed: signedIn ? _vote : null,
                        icon: Icon(
                          w.voted ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: w.voted ? Tone.rose : null,
                        ),
                        label: Text(w.voted ? 'Voted' : 'Worth reading'),
                      ),
                    const SizedBox(width: Gap.md),
                    Text(
                      '${w.votes} vote${w.votes == 1 ? '' : 's'}',
                      style: const TextStyle(color: Tone.faint, fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: Gap.xl),
                const Eyebrow('What people said'),
                const SizedBox(height: Gap.sm),
                if (w.comments.isEmpty)
                  const Text(
                    'Nothing yet.',
                    style: TextStyle(color: Tone.faint, height: 1.45),
                  ),
                for (final c in w.comments)
                  Container(
                    margin: const EdgeInsets.only(bottom: Gap.sm),
                    padding: const EdgeInsets.all(Gap.md),
                    decoration: BoxDecoration(
                      color: Tone.inset,
                      borderRadius: BorderRadius.circular(Corner.md),
                      border: Border.all(color: Tone.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.author,
                          style: const TextStyle(
                            color: Tone.faint,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.bodyMd,
                          style: const TextStyle(color: Tone.soft, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: Gap.lg),
                if (signedIn) ...[
                  TextField(
                    controller: _remark,
                    maxLines: 4,
                    minLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Say what you think',
                      hintText:
                          'What worked, and what you would do differently.',
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  FilledButton(
                    onPressed: _busy ? null : _say,
                    child: Text(_busy ? 'Sending…' : 'Say it'),
                  ),
                ] else
                  const Text(
                    'Sign in to vote or say something. Reading needs no account.',
                    style: TextStyle(color: Tone.faint, height: 1.45),
                  ),

                if (_trouble != null) ...[
                  const SizedBox(height: Gap.md),
                  Text(
                    _trouble!,
                    style: const TextStyle(color: Tone.live, height: 1.45),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
