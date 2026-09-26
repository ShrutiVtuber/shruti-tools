// SPDX-License-Identifier: AGPL-3.0-only
//
// Before the first thing goes public: what happens to it if the account goes.
//
// Public work outlives the account that made it — kept, with the name taken
// off — because other people are reading and answering it. The site refuses
// to publish (428) until the person has agreed to that, and this asks, in the
// site's own words, at exactly that moment and at no other.
//
// ⚠ **The server refuses; this only asks.** Wrap a publish in [publishing]
// and it is sent as it is. Only a 428 opens the dialog; on agreement the
// decision is filed and the SAME call is made once more. Anything else comes
// back untouched, so a screen's own error handling is unchanged.
import 'package:flutter/material.dart';

import '../services/practice.dart';
import '../theme/tokens.dart';

Future<T> publishing<T>(
  BuildContext context,
  Practice room,
  Future<T> Function() send,
) async {
  try {
    return await send();
  } on NeedsPublishAgreement {
    final agreement = await room.publishAgreement();
    if (!context.mounted) rethrow;
    final agreed = await _ask(context, agreement);
    if (!agreed) rethrow;
    await room.agreeToPublish();
    return send();
  }
}

Future<bool> _ask(BuildContext context, PublishAgreement agreement) async {
  // Never ticked for them: every opening starts from no.
  var ticked = false;
  const prose = TextStyle(
    fontFamily: Face.body,
    fontFamilyFallback: [Face.glyph],
    fontSize: Type.caption,
    height: 1.5,
  );
  final go = await showDialog<bool>(
    context: context,
    builder: (ask) => StatefulBuilder(
      builder: (context, setDialog) => AlertDialog(
        backgroundColor: Tone.card,
        title: const Text('Before this goes public'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(agreement.explanation, style: prose),
              const SizedBox(height: Gap.md),
              CheckboxListTile(
                value: ticked,
                onChanged: (v) => setDialog(() => ticked = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(agreement.label),
                subtitle: Text('“${agreement.wording}”', style: prose),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ask).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: ticked ? () => Navigator.of(ask).pop(true) : null,
            child: const Text('Agree and post'),
          ),
        ],
      ),
    ),
  );
  return go == true;
}
