// SPDX-License-Identifier: AGPL-3.0-only
//
// Everything the app remembers, in the place a person goes looking for it.
//
// The place and the sunrise convention were reachable only from the cards that
// used them — the place from the top of the Stations card, the convention from
// halfway down Hours. Both are fine as shortcuts and neither is findable, and
// this is where notification choices will live, which is not a setting anybody
// will think to look for on a station table.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/settings.dart';
import '../services/ephemeris.dart';
import '../services/site.dart';
import '../services/stations.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/motifs.dart';
import '../widgets/forms.dart';
import '../widgets/data.dart';
import '../widgets/parts.dart';
import 'account.dart';
import 'blocked.dart';
import 'licences.dart';
import 'notifications.dart';
import '../widgets/eyebrow.dart';
import 'pick_place.dart';
import 'sunrise.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final account = AccountScope.of(context);
    final wanted = NoticeScope.of(context);

    return Scaffold(
      appBar: const Bar(title: 'Settings', hour: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Gap.gutter,
          Gap.gutter,
          Gap.gutter,
          Gap.huge,
        ),
        children: [
          ListGroup(
            children: [
              ListRow(
                label: 'Account',
                description: account.signedIn
                    ? (account.reader?.shownName ?? 'Signed in')
                    : 'Not signed in',
                value: account.signedIn ? 'Signed in' : null,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                ),
              ),
              ListRow(
                label: 'Notifications',
                value: wanted.on ? 'On' : 'Off',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NoticesScreen()),
                ),
              ),
              // ⚠ Only when signed in, because a block belongs to an account
              // and there is nothing to show without one. It sits here rather
              // than in the practice room on purpose: the undo must be
              // findable by somebody who has forgotten the name they blocked.
              if (account.signedIn)
                ListRow(
                  label: 'Blocked',
                  description: 'People whose writing you do not see',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BlockedScreen()),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.md),
          const _Note(
            'Nothing else in the app needs an account. Every instrument '
            'computes on this phone and works signed out.',
          ),

          const SizedBox(height: Gap.xl),
          const Eyebrow('The sky, where you are'),
          const SizedBox(height: Gap.sm),
          ListGroup(
            children: [
              ListRow(
                label: 'Place',
                description: 'Used for sunrise, sunset and the hours',
                value: settings.placeChosen
                    ? settings.place.shortName
                    : '${settings.place.shortName} · not chosen',
                onTap: () => pickPlaceInto(context),
              ),
              ListRow(
                label: 'Sunrise convention',
                description: 'Which moment starts the day',
                value: settings.convention == RiseConvention.visibleDisc
                    ? 'Upper limb'
                    : 'Centre of disc',
                onTap: () => showSunriseSheet(context),
              ),
              const ListRow(label: 'Zodiac', value: 'Tropical'),
              const ListRow(label: 'Houses', value: 'Whole sign'),
            ],
          ),
          const SizedBox(height: Gap.md),
          const _Note(
            'The stations and the planetary hours are computed for here and '
            'told in this timezone. Searching for a place needs a connection; '
            'the instruments never do.',
          ),

          const SizedBox(height: Gap.xl),
          const Eyebrow('On this phone'),
          const SizedBox(height: Gap.sm),
          Pressable(
            padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
            child: Column(
              children: [
                Switcher(
                  label: 'Reduce motion',
                  description:
                      'Follows your system setting. Nothing in the app is '
                      'only legible in motion.',
                  value: MediaQuery.disableAnimationsOf(context),
                  onChanged: null,
                  enabled: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: Gap.xl),
          const Eyebrow('Hers'),
          const SizedBox(height: Gap.sm),
          ListGroup(
            children: [
              // ⚠ **No links to anything that charges.** There were three —
              // support, the shop, classes — and Apple's guideline 3.1.1
              // forbids an app from pointing at a way to buy digital things
              // outside its own store. The Swara tiers unlock a members
              // channel, the schedule early and monthly notes, which is
              // digital content however modest it is.
              //
              // Taking that money through Apple instead would mean StoreKit
              // subscriptions, the paid-apps agreement, and 15-30% — and two
              // subscription systems for one tier, to be reconciled forever.
              // Her decision, made long before this: nothing takes money
              // inside the app.
              //
              // So the app points at the site and the site does the rest.
              // Linking to your own website is not the thing 3.1.1 prohibits;
              // a call to action to buy is.
              _Away(
                label: 'shrutivtuber.com',
                detail: 'Schedule, videos, horoscopes and everything else',
                url: siteOrigin,
              ),
              const _Away(
                label: 'The Discord',
                detail: 'Streams are announced here first',
                url: 'https://discord.gg/Q8FW4AZNS6',
              ),
              const _Away(
                label: 'Twitch',
                detail: 'Where the streams happen',
                url: 'https://www.twitch.tv/shrutivtuber',
              ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          // ⚠ Reworded when the support, shop and class links came out. It
          // used to say "nothing is bought inside Astrolabe … the address bar
          // says whose checkout it is", which described checkouts that no
          // longer have links here. A true sentence about a removed feature is
          // still a false one about the app.
          const _Note('These open your browser.'),

          const SizedBox(height: Gap.xl),
          const Eyebrow('About'),
          const SizedBox(height: Gap.sm),
          ListGroup(
            children: [
              // ⚠ **Guideline 5.1.1(i).** A privacy policy must be reachable
              // in App Store Connect AND "within the app in an easily
              // accessible manner". There was no link to it anywhere in the
              // app at all, which is its own rejection whatever else is right.
              //
              // The policy covers the app explicitly as of 11 September 2026 —
              // its own section says what stays on the phone, that charts are
              // computed on the device, and what turning notifications on
              // registers.
              _Away(
                label: 'Privacy',
                detail: 'What is kept, what is not, and what leaves the phone',
                url: '$siteOrigin/privacy',
              ),
              _Away(
                label: 'Terms',
                detail: 'What you are agreeing to by using it',
                url: '$siteOrigin/terms',
              ),
              ListRow(
                label: 'Licences',
                description:
                    'AGPL-3.0 · free software, and the ephemeris it computes '
                    'with',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LicencesScreen()),
                ),
              ),
              const _Away(
                label: 'Source',
                detail: 'ShrutiVtuber/astrolabe',
                url: 'https://github.com/ShrutiVtuber/astrolabe',
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Gap.xs),
            child: Column(
              children: [
                Fact(
                  label: 'Astrolabe',
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
          const SizedBox(height: Gap.lg),
          const Rule(),
        ],
      ),
    );
  }
}

/// A row that leaves the app.
///
/// ⚠ The mark is the leave-the-app one rather than a chevron, and that is not
/// decoration: everything that takes money leaves the app, and a reader is
/// owed the knowledge before the tap rather than after it.
class _Away extends StatelessWidget {
  const _Away({required this.label, required this.detail, required this.url});

  final String label;
  final String detail;
  final String url;

  @override
  Widget build(BuildContext context) => ListRow(
    label: label,
    description: detail,
    external: true,
    onTap: () =>
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}
