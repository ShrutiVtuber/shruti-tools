// SPDX-License-Identifier: AGPL-3.0-only
import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A small uppercase label above a thing.
///
/// Uppercased here rather than in the string, so the words stay readable in
/// the widget tree and in a test — and so a language that has no capitals is
/// not mangled by a stylistic choice made for English.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.tone});

  final String text;
  final Color? tone;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    label: text,
    child: ExcludeSemantics(
      child: Text(
        text.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelSmall!.copyWith(color: tone ?? Tone.faint),
      ),
    ),
  );
}
