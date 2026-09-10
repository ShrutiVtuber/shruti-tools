// SPDX-License-Identifier: AGPL-3.0-only
//
// Where sunrise is — a sheet, because it is a choice made while looking at the
// thing it changes.
//
// ⚠ **Neither option is marked correct, and the copy says so.** Where two
// traditions disagree the app puts the choice on the instrument and gives each
// its one-line rule; picking a default and calling it right would be this app
// taking a side it has no standing to take. The difference is about four and a
// half minutes at Athens — enough to move a planetary hour boundary, and so
// enough to change which planet rules the moment somebody is standing in.
import 'package:flutter/material.dart';

import '../services/settings.dart';
import '../services/stations.dart';
import '../theme/tokens.dart';
import '../widgets/forms.dart';

Future<void> showSunriseSheet(BuildContext context) {
  final settings = SettingsScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Tone.card,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where sunrise is',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Gap.sm),
            const Text(
              'Neither is the correct one. Pick the one your tradition uses.',
              style: TextStyle(
                fontFamily: Face.body,
                fontSize: Type.caption,
                height: 1.5,
                color: Tone.faint,
              ),
            ),
            const SizedBox(height: Gap.sm),
            ListenableBuilder(
              listenable: settings,
              builder: (context, _) => Column(
                children: [
                  for (final c in RiseConvention.values)
                    ChoiceRow(
                      label: c.label,
                      rule: c.detail,
                      checked: settings.convention == c,
                      onChanged: (_) {
                        settings.setConvention(c);
                        Navigator.of(sheet).pop();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
