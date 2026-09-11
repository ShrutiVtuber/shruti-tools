// SPDX-License-Identifier: AGPL-3.0-only
//
// What this app is made of, and under what terms.
//
// ⚠ **This screen is a licence obligation, not a courtesy.**
//
// Swiss Ephemeris is dual-licensed: AGPL, or a paid professional edition. This
// app takes the AGPL option, which requires the whole project to be AGPL and
// the source to be available — both true — and requires that "the copyright
// notices and this notice be preserved on all copies". A compiled APK is a
// copy, so the notice has to be reachable from inside it and not only from the
// repository.
//
// The AGPL itself also requires that somebody running the software can get its
// source. For an app that means telling them where it is.
//
// ⚠ **Astrodienst's name and the authors' names appear ONLY in the notice
// below.** Their licence is explicit that the copyright notice is the only
// place they may legally appear, and that their names must not be used to
// promote anything. So: not in the store listing, not on a stream, not in a
// "powered by" line anywhere. Naming the SOFTWARE is fine; naming them is not.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/parts.dart';
import '../widgets/data.dart';
import '../widgets/content.dart';
import '../services/ephemeris.dart';
import '../sky/current.dart';
import '../widgets/eyebrow.dart';

const sourceUrl = 'https://github.com/ShrutiVtuber/astrolabe';

/// What the iOS build computes with.
///
/// ⚠ Credit rather than obligation. VSOP87 and the abridged lunar theory are
/// published analytic theories under no software licence, so nothing requires
/// this — which is precisely why it is here. Somebody reading this screen wants
/// to know what the arithmetic is, and "public domain" is an answer that tells
/// them nothing about whose work it was.
const _publicTheory = '''
VSOP87 — the planetary theory of P. Bretagnon and G. Francou, Bureau des
Longitudes, published in Astronomy & Astrophysics.

ELP-2000/82 — the lunar theory of M. Chapront-Touzé and J. Chapront, in the
abridged form that has been printed and reimplemented for decades.

Both are published science rather than software. No licence governs their use
and none is claimed over them here.''';

/// Preserved verbatim from `native/sweph/src/LICENSE`. Do not paraphrase it.
const _swissEphemeris = '''
Swiss Ephemeris

Copyright (C) 1997 - 2021 Astrodienst AG, Switzerland. All rights reserved.

This file is part of Swiss Ephemeris.

Swiss Ephemeris is distributed with NO WARRANTY OF ANY KIND. No author or
distributor accepts any responsibility for the consequences of using it, or
for whether it serves any particular purpose or works at all, unless he or
she says so in writing.

Swiss Ephemeris is made available by its authors under a dual licensing
system. The software developer, who uses any part of Swiss Ephemeris in his
or her software, must choose between one of the two license models, which
are:

  a) GNU Affero General Public License (AGPL)
  b) Swiss Ephemeris Professional License

This application is distributed under the AGPL option (a).

Authors of the Swiss Ephemeris: Dieter Koch and Alois Treindl

The authors of Swiss Ephemeris have no control or influence over any of the
derived works, i.e. over software or services created by other programmers
which use Swiss Ephemeris functions.

The names of the authors or of the copyright holder (Astrodienst) must not be
used for promoting any software, product or service which uses or contains
the Swiss Ephemeris. This copyright notice is the ONLY place where the names
of the authors can legally appear, except in cases where they have given
special permission in writing.
''';

class LicencesScreen extends StatelessWidget {
  const LicencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> open(String url) =>
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

    return Scaffold(
      appBar: const Bar(title: 'Licences', hour: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.huge),
          children: [
            const Prose(
              small: true,
              text:
                  'Astrolabe is free software under the GNU Affero General '
                  'Public License, version 3. You may use it, read it, change '
                  'it and pass it on, provided what you pass on carries the '
                  'same freedoms.',
            ),
            const SizedBox(height: Gap.md),
            Pressable(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Fact(
                    label: 'Astrolabe',
                    value: 'AGPL-3.0-only',
                    small: true,
                  ),
                  const Fact(
                    label: 'Swiss Ephemeris',
                    value: 'AGPL-3.0',
                    small: true,
                  ),
                  const Fact(
                    label: 'Flutter, Dart',
                    value: 'BSD-3-Clause',
                    small: true,
                  ),
                  const Fact(
                    label: 'EB Garamond',
                    value: 'OFL-1.1',
                    small: true,
                  ),
                  const Fact(
                    label: 'Commissioner',
                    value: 'OFL-1.1',
                    small: true,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Tone.line)),
                    ),
                    child: Column(
                      children: [
                        Fact(
                          label: 'This build',
                          value: appVersion,
                          small: true,
                          tone: Tone.faint,
                        ),
                        Fact(
                          label: 'Ephemeris',
                          value: engineVersion,
                          small: true,
                          tone: Tone.faint,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.md),
            ListGroup(
              children: [
                ListRow(
                  label: 'Source for this build',
                  description: 'ShrutiVtuber/astrolabe · $appVersion',
                  external: true,
                  onTap: () => open(sourceUrl),
                ),
              ],
            ),
            const SizedBox(height: Gap.sm),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Gap.xs),
              child: Text(
                'Every line of it, including the version this build was made '
                'from. ⚠ The AGPL requires that anybody running this can get '
                'the source — which is why the link is here rather than in a '
                'footer nobody reads.',
                style: TextStyle(
                  fontFamily: Face.body,
                  fontFamilyFallback: [Face.glyph],
                  fontSize: Type.caption,
                  height: 1.55,
                  color: Tone.faint,
                ),
              ),
            ),

            const SizedBox(height: Gap.xl),
            const Eyebrow('The ephemeris'),
            const SizedBox(height: Gap.sm),
            Text(
              sky.noticeRequired
                  ? 'The astronomy is computed on this phone, against '
                        '$engineVersion. Its notice is kept here in full, as '
                        'its licence requires.'
                  : 'The astronomy is computed on this phone, from published '
                        'theory. Nothing below is required of this app — it is '
                        'here because you should know whose work it is.',
              style: const TextStyle(color: Tone.soft, height: 1.5),
            ),
            const SizedBox(height: Gap.md),
            Container(
              padding: const EdgeInsets.all(Gap.md),
              decoration: BoxDecoration(
                color: Tone.inset,
                borderRadius: BorderRadius.circular(Corner.md),
                border: Border.all(color: Tone.line),
              ),
              child: Text(
                sky.noticeRequired ? _swissEphemeris : _publicTheory,
                style: TextStyle(
                  color: Tone.soft,
                  fontSize: 12,
                  height: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(height: Gap.xl),
            const Eyebrow('Everything else'),
            const SizedBox(height: Gap.sm),
            const Text(
              'Every package this app is built from, with its own licence.',
              style: TextStyle(color: Tone.soft, height: 1.5),
            ),
            const SizedBox(height: Gap.md),
            OutlinedButton(
              // Flutter collects the LICENSE file of every package in the
              // build, so this cannot fall behind the dependency list.
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'Astrolabe',
                applicationLegalese: 'AGPL-3.0-only',
              ),
              child: const Text('Package licences'),
            ),

            const SizedBox(height: Gap.xl),
            const Eyebrow('The language packs'),
            const SizedBox(height: Gap.sm),
            const Text(
              'The letter tables and word lists are downloaded from '
              'shrutivtuber.com and are not part of this app. They are hers, '
              'all rights reserved, and are not covered by the licence above.',
              style: TextStyle(color: Tone.faint, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
