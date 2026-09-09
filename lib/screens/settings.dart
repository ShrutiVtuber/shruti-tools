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
import '../services/site.dart';
import '../services/stations.dart';
import '../theme/tokens.dart';
import 'account.dart';
import '../widgets/eyebrow.dart';
import 'pick_place.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: Gap.xl),

        // First, because it is the only thing here that reaches off the phone
        // — and because somebody looking for "how do I sign in" looks in
        // settings before anywhere else.
        const Eyebrow('Your account'),
        const SizedBox(height: Gap.sm),
        Builder(
          builder: (context) {
            final account = AccountScope.of(context);
            return _Card(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const Scaffold(body: SafeArea(child: AccountScreen())),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.signedIn
                              ? (account.reader?.shownName ?? 'Signed in')
                              : 'Not signed in',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.signedIn
                              ? 'The same account as shrutivtuber.com'
                              : 'Sign in, or make one here',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Tone.faint),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: Gap.sm),
        _Note(
          'Nothing else in the app needs one. Every instrument computes on '
          'this phone and works signed out.',
        ),

        const SizedBox(height: Gap.xl),
        const Eyebrow('Where you are'),
        const SizedBox(height: Gap.sm),
        _Card(
          onTap: () => pickPlaceInto(context),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.place.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.placeChosen
                          ? settings.place.zone
                          : '${settings.place.zone} — not chosen yet',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Tone.faint),
            ],
          ),
        ),
        const SizedBox(height: Gap.sm),
        _Note(
          'The stations and the planetary hours are computed for here, and '
          'told in this timezone. Searching needs a connection; the '
          'instruments do not.',
        ),

        const SizedBox(height: Gap.xl),
        const Eyebrow('Where sunrise is'),
        const SizedBox(height: Gap.sm),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in RiseConvention.values)
                RadioListTile<RiseConvention>(
                  value: c,
                  // ignore: deprecated_member_use
                  groupValue: settings.convention,
                  // ignore: deprecated_member_use
                  onChanged: (v) =>
                      v == null ? null : settings.setConvention(v),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: Tone.accent,
                  title: Text(
                    c.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    c.detail,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Gap.sm),
        _Note(
          'The traditions disagree and the disagreement is real — about four '
          'and a half minutes, which is enough to move a planetary hour '
          'boundary, and so enough to change which planet rules the moment '
          'you are standing in.',
        ),

        const SizedBox(height: Gap.xl),
        const Eyebrow('Elsewhere'),
        const SizedBox(height: Gap.sm),
        _Link(label: 'The site', detail: 'shrutivtuber.com', url: siteOrigin),
        const SizedBox(height: Gap.sm),
        _Link(
          label: 'The Discord',
          detail: 'where a stream is announced first',
          url: 'https://discord.gg/Q8FW4AZNS6',
        ),
        const SizedBox(height: Gap.sm),
        _Link(
          label: 'Twitch',
          detail: 'where the streams happen',
          url: 'https://www.twitch.tv/shrutivtuber',
        ),

        const SizedBox(height: Gap.xl),
        const Eyebrow('About'),
        const SizedBox(height: Gap.sm),
        _Note(
          "Shruti's Tools computes on this phone. The ephemeris is bundled, "
          'so the stations, the hours, the chart and what the sky does next '
          'all work with no signal and send nothing anywhere. The site is '
          'asked only for what only she knows — whether she is streaming, and '
          'what she has posted.',
        ),
        const SizedBox(height: Gap.sm),
        _Link(
          label: 'Source, and the licence',
          detail: 'AGPL-3.0 — yours to read, change and run',
          url: 'https://github.com/ShrutiVtuber/shruti-tools',
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Tone.card,
    borderRadius: BorderRadius.circular(Corner.md),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Corner.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Corner.md),
          border: Border.all(color: Tone.line),
        ),
        child: child,
      ),
    ),
  );
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.detail, required this.url});

  final String label;
  final String detail;
  final String url;

  @override
  Widget build(BuildContext context) => _Card(
    onTap: () =>
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(detail, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const Icon(Icons.arrow_outward, size: 17, color: Tone.faint),
      ],
    ),
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
