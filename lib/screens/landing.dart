// SPDX-License-Identifier: AGPL-3.0-only
//
// Home: her, first.
//
// The instruments are why the app works offline; THIS is why somebody opens it
// when they are not looking anything up. Whether she is streaming right now,
// what she has published, what she has written — and a way to the site to
// support her.
//
// ⚠ The live card used to live on the stations page, wedged between an
// astronomical table and a place picker. It is the only urgent thing in the
// app and it was somewhere nobody would look for it.
//
// ⚠ Everything here fails soft. A phone with no signal opens on the same
// screen with the sections it could not reach simply absent — never an error,
// because none of this is what the app is FOR.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/periods.dart';
import '../services/site.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';
import 'account.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LiveStatus _live = LiveStatus.offline;
  List<Reading> _readings = const [];
  List<Article> _articles = const [];
  List<Offer> _offers = const [];
  bool _looked = false;

  bool _asked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⚠ NOT initState. This reads AccountScope — which offers depend on — and
    // an inherited widget cannot be looked up before initState has finished.
    // Flutter asserts on it, so the whole screen throws rather than degrading.
    if (!_asked) {
      _asked = true;
      _fetch();
    }
  }

  Future<void> _fetch() async {
    // Together, not in sequence: three round trips one after another is three
    // seconds of an empty screen on a phone connection.
    // ⚠ The offers call carries the account's token: which offers exist at all
    // depends on whether this person is a member.
    final headers = AccountScope.of(context).headers;
    final results = await Future.wait([
      liveStatus(),
      publishedReadings(limit: 6),
      articles(limit: 4),
      offers(headers: headers),
    ]);
    if (!mounted) return;
    setState(() {
      _live = results[0] as LiveStatus;
      _readings = results[1] as List<Reading>;
      _articles = results[2] as List<Article>;
      _offers = results[3] as List<Offer>;
      _looked = true;
    });
  }

  Future<void> _open(String path) async {
    final url = path.startsWith('http') ? path : '$siteOrigin$path';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Tone.accent,
      backgroundColor: Tone.card,
      onRefresh: _fetch,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
        children: [
          Text('Shruti', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: Gap.xs),
          Text(
            'Instruments for magick, built live from Athens',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: Gap.xl),

          _Live(live: _live, onTap: _open),

          if (_readings.isNotEmpty) ...[
            const SizedBox(height: Gap.xl),
            const Eyebrow('The readings'),
            const SizedBox(height: Gap.sm),
            for (final r in _grouped(_readings))
              _ReadingRow(reading: r, onTap: () => _open(r.path)),
            const SizedBox(height: Gap.sm),
            _More(label: 'All the readings', onTap: () => _open('/horoscopes')),
          ],

          if (_articles.isNotEmpty) ...[
            const SizedBox(height: Gap.xl),
            const Eyebrow('Lately'),
            const SizedBox(height: Gap.sm),
            for (final a in _articles)
              _ArticleRow(article: a, onTap: () => _open(a.url)),
            const SizedBox(height: Gap.sm),
            _More(label: 'The journal', onTap: () => _open('/journal')),
          ],

          if (_offers.isNotEmpty) ...[
            const SizedBox(height: Gap.xl),
            const Eyebrow('Worth having'),
            const SizedBox(height: Gap.sm),
            for (final o in _offers) _OfferCard(offer: o, onOpen: _open),
          ],

          const SizedBox(height: Gap.xl),
          const Eyebrow('The site'),
          const SizedBox(height: Gap.sm),
          _SiteLinks(onTap: _open),

          if (_looked && _readings.isEmpty && _articles.isEmpty) ...[
            const SizedBox(height: Gap.xl),
            const Text(
              'Nothing from the site right now — you may be offline. Every '
              'instrument still works; they are computed on this phone.',
              style: TextStyle(color: Tone.faint, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  /// One row per period, newest first.
  ///
  /// ⚠ Twelve signs publish at once, so an ungrouped list is twelve rows
  /// saying the same date — the whole home screen, for one week's readings.
  List<Reading> _grouped(List<Reading> all) {
    final seen = <String>{};
    final out = <Reading>[];
    for (final r in all) {
      final key = '${r.period}:${r.covers}';
      if (seen.add(key)) out.add(r);
    }
    return out.take(3).toList();
  }
}

class _Live extends StatelessWidget {
  const _Live({required this.live, required this.onTap});

  final LiveStatus live;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: live.isLive && live.url.isNotEmpty ? () => onTap(live.url) : null,
    borderRadius: BorderRadius.circular(Corner.md),
    child: Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: live.isLive ? Tone.accentWash : Tone.card,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: live.isLive ? Tone.live : Tone.line),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: live.isLive ? Tone.live : Tone.faint,
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live.isLive ? 'Live now' : 'Not streaming',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  live.isLive && live.title.isNotEmpty
                      ? live.title
                      : 'The schedule is on the site.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Tone.faint, fontSize: 13),
                ),
              ],
            ),
          ),
          if (live.isLive)
            const Icon(Icons.play_arrow, color: Tone.live, size: 22),
        ],
      ),
    ),
  );
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({required this.reading, required this.onTap});

  final Reading reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Row(
    onTap: onTap,
    title: periodLabel(reading.period, reading.covers),
    under: 'All twelve signs · ${titled(reading.period)}',
  );
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      _Row(onTap: onTap, title: article.title, under: article.opening);
}

class _Row extends StatelessWidget {
  const _Row({required this.onTap, required this.title, required this.under});

  final VoidCallback onTap;
  final String title;
  final String under;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(Corner.md),
    child: Container(
      margin: const EdgeInsets.only(bottom: Gap.sm),
      padding: const EdgeInsets.all(Gap.md),
      decoration: BoxDecoration(
        color: Tone.card,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: Tone.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                if (under.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    under,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Tone.faint,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.north_east, size: 15, color: Tone.faint),
        ],
      ),
    ),
  );
}

class _More extends StatelessWidget {
  const _More({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton(onPressed: onTap, child: Text('$label →')),
  );
}

/// Ways to the site.
///
/// ⚠ Opened in a browser, not a webview. Anything that takes money goes
/// through her own checkout on her own domain, where the address bar says whose
/// it is — a payment form inside somebody's app is the shape of a scam, and
/// the app stores take a view on it too.
class _SiteLinks extends StatelessWidget {
  const _SiteLinks({required this.onTap});

  final void Function(String) onTap;

  static const _links = [
    ('/support', 'Support the work', 'One-off, or monthly'),
    ('/shop', 'The shop', 'Prints, and other made things'),
    ('/classes', 'Classes and workshops', 'When they are open'),
    ('/schedule', 'The schedule', 'What is on, and when'),
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final (path, label, under) in _links)
        _Row(onTap: () => onTap(path), title: label, under: under),
    ],
  );
}

/// A sponsor's deal, or money off something of hers.
///
/// ⚠ The code is copied to the clipboard rather than expecting somebody to
/// retype it from a phone screen into a checkout on the same phone. That
/// retyping is where an offer quietly stops being used.
class _OfferCard extends StatefulWidget {
  const _OfferCard({required this.offer, required this.onOpen});

  final Offer offer;
  final void Function(String) onOpen;

  @override
  State<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<_OfferCard> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.offer;
    return Container(
      margin: const EdgeInsets.only(bottom: Gap.sm),
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: Tone.card,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: Tone.accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (o.from.isNotEmpty)
            Text(
              o.from.toUpperCase(),
              style: const TextStyle(
                color: Tone.faint,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
          Text(o.title, style: Theme.of(context).textTheme.bodyLarge),
          if (o.blurb.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              o.blurb,
              style: const TextStyle(color: Tone.soft, height: 1.45),
            ),
          ],
          const SizedBox(height: Gap.md),
          Row(
            children: [
              if (o.code.isNotEmpty)
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: o.code));
                      if (mounted) setState(() => _copied = true);
                    },
                    borderRadius: BorderRadius.circular(Corner.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Gap.md,
                        vertical: Gap.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Tone.inset,
                        borderRadius: BorderRadius.circular(Corner.sm),
                        border: Border.all(color: Tone.line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              o.code,
                              style: const TextStyle(
                                color: Tone.ink,
                                fontFamily: 'monospace',
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Icon(
                            _copied ? Icons.check : Icons.copy_outlined,
                            size: 15,
                            color: _copied ? Tone.accent : Tone.faint,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (o.code.isNotEmpty && o.url.isNotEmpty)
                const SizedBox(width: Gap.sm),
              if (o.url.isNotEmpty)
                FilledButton(
                  onPressed: () => widget.onOpen(o.url),
                  child: const Text('Go'),
                ),
            ],
          ),
          if (o.endsAt != null) ...[
            const SizedBox(height: Gap.xs),
            Text(
              'Until ${o.endsAt!.substring(0, 10)}',
              style: const TextStyle(color: Tone.faint, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
