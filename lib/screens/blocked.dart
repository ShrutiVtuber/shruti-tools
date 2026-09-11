// SPDX-License-Identifier: AGPL-3.0-only
//
// Who you have blocked, and how to stop.
//
// ⚠ **A block nobody can find is a mistake somebody has to live with.** The
// button is pressed in a moment of irritation, from a feed, about a person
// whose name may not be remembered an hour later — so the undo cannot live
// next to the thing that is now invisible. It lives here, in the one place
// somebody thinks to look.
//
// ⚠ Blocking is not reporting. Nothing here went to Shruti, nobody was told,
// and no one else's feed changed. This screen says so, because a list headed
// only "Blocked" reads like a record of complaints made.
import 'package:flutter/material.dart';

import '../services/practice.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/parts.dart';
import 'account.dart';

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  late final Practice _room = Practice(AccountScope.of(context));
  late Future<List<({int id, String name})>> _people = _room.blocked();
  String? _trouble;

  Future<void> _unblock(({int id, String name}) who) async {
    try {
      await _room.unblockPerson(who.id);
      if (!mounted) return;
      setState(() => _people = _room.blocked());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${who.name} is unblocked.')));
    } on PracticeTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const Bar(title: 'Blocked', hour: false),
    body: SafeArea(
      child: FutureBuilder<List<({int id, String name})>>(
        future: _people,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(Gap.gutter),
              child: Skeleton(lines: 3, title: false),
            );
          }
          final people = snap.data ?? const [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Gap.gutter,
              Gap.lg,
              Gap.gutter,
              Gap.huge,
            ),
            children: [
              if (_trouble != null) ...[
                NoticeBar(tone: BannerTone.warning, text: _trouble!),
                const SizedBox(height: Gap.md),
              ],
              const Text(
                'Blocking is yours alone. Nobody was told, nothing went to '
                'Shruti, and no one else\'s feed changed. Unblocking brings '
                'their writing back and lets them answer yours again.',
                style: TextStyle(
                  fontFamily: Face.body,
                  fontFamilyFallback: [Face.glyph],
                  fontSize: Type.caption,
                  height: 1.5,
                  color: Tone.faint,
                ),
              ),
              const SizedBox(height: Gap.lg),
              if (people.isEmpty)
                const Text(
                  'You have not blocked anybody.',
                  style: TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: Type.body,
                    color: Tone.faint,
                  ),
                )
              else
                ListGroup(
                  children: [
                    for (final who in people)
                      ListRow(
                        label: who.name,
                        value: 'Unblock',
                        onTap: () => _unblock(who),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    ),
  );
}
