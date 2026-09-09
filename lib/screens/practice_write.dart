// SPDX-License-Identifier: AGPL-3.0-only
//
// Writing one, on the phone.
//
// ⚠ The draft is the SAME draft as the website's desk — one work per person per
// period, held by the account. Somebody can start a reading on the train and
// finish it at a desk, which was her whole point about one reading in three
// places.
//
// ⚠ Writing all twelve signs is one piece of work, not twelve. Switching sign
// here keeps you in the same draft; submitting sends whatever has words in it.
import 'package:flutter/material.dart';

import '../services/periods.dart';
import '../services/practice.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';
import 'account.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _text = TextEditingController();
  String _period = 'weekly';
  late String _covers = currentCovers(_period);
  String _sign = 'aries';

  int? _workId;
  String _said = '';
  String? _trouble;
  bool _loading = true;
  bool _sending = false;

  Practice get _room => Practice(AccountScope.of(context));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _fetch();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// What the account already holds for this sign of this period.
  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _trouble = null;
    });
    try {
      final body = await _room.draft(
        period: _period,
        covers: _covers,
        sign: _sign,
      );
      if (!mounted) return;
      _text.text = body;
      setState(() => _said = body.trim().isEmpty ? '' : 'kept');
    } on PracticeTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _keep() async {
    try {
      final id = await _room.keep(
        period: _period,
        covers: _covers,
        sign: _sign,
        bodyMd: _text.text,
        title: periodLabel(_period, _covers),
      );
      if (!mounted) return;
      final words = _text.text.trim().isEmpty
          ? 0
          : _text.text.trim().split(RegExp(r'\s+')).length;
      setState(() {
        _workId = id;
        _said = '$words word${words == 1 ? '' : 's'} · kept';
        _trouble = null;
      });
    } on PracticeTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    }
  }

  Future<void> _submit() async {
    // Keep first: whatever is in the box right now is part of what is sent.
    await _keep();
    final id = _workId;
    if (id == null) return;
    setState(() => _sending = true);
    try {
      await _room.submit(id);
      if (mounted) Navigator.of(context).pop(true);
    } on PracticeTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a reading')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.huge),
          children: [
            const Eyebrow('Which period'),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.sm,
              children: [
                for (final p in periods)
                  ChoiceChip(
                    label: Text(titled(p)),
                    selected: _period == p,
                    onSelected: (_) {
                      setState(() {
                        _period = p;
                        _covers = currentCovers(p);
                      });
                      _fetch();
                    },
                  ),
              ],
            ),
            const SizedBox(height: Gap.xs),
            Text(
              periodLabel(_period, _covers),
              style: const TextStyle(color: Tone.faint, fontSize: 13),
            ),

            const SizedBox(height: Gap.lg),
            const Eyebrow('Which sign'),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.xs,
              runSpacing: Gap.xs,
              children: [
                for (final s in zodiac)
                  ChoiceChip(
                    label: Text('${signGlyph[s]} ${titled(s)}'),
                    selected: _sign == s,
                    onSelected: (_) {
                      // ⚠ Keep what is on screen before moving: the box is
                      // about to be replaced with another sign's words.
                      _keep().then((_) {
                        setState(() => _sign = s);
                        _fetch();
                      });
                    },
                  ),
              ],
            ),

            const SizedBox(height: Gap.lg),
            if (_loading)
              const Text(
                'Fetching your draft…',
                style: TextStyle(color: Tone.faint),
              )
            else
              TextField(
                controller: _text,
                maxLines: null,
                minLines: 12,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() => _said = 'not kept yet'),
                decoration: const InputDecoration(
                  hintText: 'What does this sky ask of this sign?',
                  alignLabelWithHint: true,
                ),
              ),
            const SizedBox(height: Gap.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _said,
                    style: const TextStyle(color: Tone.faint, fontSize: 12),
                  ),
                ),
                TextButton(onPressed: _keep, child: const Text('Keep')),
              ],
            ),

            if (_trouble != null) ...[
              const SizedBox(height: Gap.sm),
              Text(
                _trouble!,
                style: const TextStyle(color: Tone.live, height: 1.45),
              ),
            ],

            const SizedBox(height: Gap.lg),
            FilledButton(
              onPressed: _sending ? null : _submit,
              child: Text(_sending ? 'Sending…' : 'Submit for others to read'),
            ),
            const SizedBox(height: Gap.sm),
            const Text(
              'Everything you have written for this period goes together, as one '
              'piece of work. Signs you left blank are not sent.',
              style: TextStyle(color: Tone.faint, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
