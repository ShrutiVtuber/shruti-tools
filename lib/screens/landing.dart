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
// ⚠ Everything here fails soft, and the copy carries the distinction between
// OFFLINE and BROKEN: her half is out of reach, the instruments are not,
// because they are arithmetic done on this phone.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/art.dart';
import '../services/chart.dart' show signNames;
import '../services/period_sky.dart';
import '../services/periods.dart';
import '../services/shell_state.dart';
import '../services/site.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/content.dart';
import '../widgets/forms.dart';
import '../widgets/moon_disc.dart';
import '../widgets/parts.dart';
import 'account.dart';
import 'horoscopes.dart';
import 'notifications.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  /// ⚠ Null until the site answers, and null again if it cannot be reached —
  /// which the banner renders as "status unavailable", never as "not live".
  LiveStatus? _live;
  List<Reading> _readings = const [];
  List<Article> _articles = const [];
  List<Offer> _offers = const [];
  bool _looked = false;
  bool _reached = true;
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
    // Together, not in sequence: four round trips one after another is four
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
      _live = results[0] as LiveStatus?;
      _readings = results[1] as List<Reading>;
      _articles = results[2] as List<Article>;
      _offers = results[3] as List<Offer>;
      _looked = true;
      // Her half is unreachable when nothing at all came back — one empty
      // list is a quiet week, four is a network.
      _reached = _live != null || _readings.isNotEmpty || _articles.isNotEmpty;
    });
  }

  /// Her readings, in the app when they are current and on the site when not.
  ///
  /// ⚠ The whole of the boundary she asked for, in one place. `covers` is
  /// compared against what the period is NOW: a reading for this month opens
  /// here, and last month's opens the site. Passing no covers means "whatever
  /// is current", which is what the "All twelve" action wants.
  Future<void> _readHerReadings({
    String period = 'monthly',
    String? covers,
    String? sign,
  }) async {
    if (covers != null && covers != currentCovers(period)) {
      await _open('/horoscopes/$sign/$period/$covers');
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => HoroscopesScreen(period: period, sign: sign),
    ));
  }

  Future<void> _open(String path) async {
    final url = path.startsWith('http') ? path : '$siteOrigin$path';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Liveness get _liveness => switch (_live) {
    null => Liveness.unknown,
    final l => l.isLive ? Liveness.live : Liveness.off,
  };

  /// The hour of the day, in her voice rather than the clock's.
  String _greeting() {
    if (_liveness == Liveness.live) return 'She is live';
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Still up';
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  /// Today's moon, computed here rather than fetched — so the masthead has
  /// something true to say on a phone with no signal, which is the whole
  /// argument of the app.
  (double lit, bool waxing, String sign) _moon() {
    final now = DateTime.now().toUtc();
    final today = skyAcross(now, now);
    if (today.isEmpty) return (0, true, '');
    final before = skyAcross(
      now.subtract(const Duration(days: 1)),
      now.subtract(const Duration(days: 1)),
    );
    final lit = today.first.lit;
    final waxing = before.isEmpty || lit >= before.first.lit;
    final moon = today.first.longitudes['Moon'] ?? 0;
    return (lit, waxing, signNames[(moon ~/ 30) % 12]);
  }

  static String phaseName(double lit, bool waxing) => switch (lit) {
    < 0.03 => 'New moon',
    < 0.47 => waxing ? 'Waxing crescent' : 'Waning crescent',
    < 0.53 => waxing ? 'First quarter' : 'Last quarter',
    < 0.97 => waxing ? 'Waxing gibbous' : 'Waning gibbous',
    _ => 'Full moon',
  };

  @override
  Widget build(BuildContext context) {
    final shell = ShellScope.of(context);
    final (lit, waxing, sign) = _moon();

    // The shell's ornament follows the stream, so Home telling it what it
    // found keeps the tab hem and the app bar hem honest.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_looked) shell?.told(_liveness);
    });

    return Scaffold(
      appBar: Bar(
        title: 'Astrolabe',
        actions: [
          Tap(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NoticesScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        // Gilt, per the system: the refresh arc is ornament, not an action.
        color: Gilt.gilt,
        backgroundColor: Tone.card,
        onRefresh: _fetch,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Gap.gutter,
            Gap.gutter,
            Gap.gutter,
            Gap.huge,
          ),
          children: [
            if (_looked && !_reached) ...[
              const NoticeBar(
                tone: BannerTone.offline,
                title: 'Her half is out of reach',
                text:
                    'The instruments all still work — they compute on your '
                    'phone. Readings, offers and the practice room will come '
                    'back when you do.',
              ),
              const SizedBox(height: Gap.lg),
            ],

            // ⚠ The one brand surface in the app. Sky, Chart, Letters,
            // Practice and Settings are page-coloured — put a second plate
            // anywhere and neither is special.
            Masthead(
              // ⚠ Null until she has drawn it, and the art-absent state is
              // designed rather than empty — see services/art.dart.
              portrait: Drawings.of(
                _liveness == Liveness.live
                    ? Art.portraitLive
                    : Art.portraitOffline,
              ),
              greeting: _greeting(),
              line: _liveness == Liveness.live
                  ? (_live?.title.isNotEmpty ?? false
                        ? _live!.title
                        : 'Streaming now.')
                  : '${phaseName(lit, waxing)}, in $sign.',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (shell?.ruler != null) HourChip(ruler: shell!.ruler!),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MoonDisc(lit: lit, waxing: waxing, size: 22),
                    const SizedBox(width: 7),
                    Text(
                      phaseName(lit, waxing),
                      style: const TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: Type.caption,
                        color: Tone.soft,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: Gap.lg),
            LiveBanner(
              status: _liveness,
              title: _live?.title.isNotEmpty ?? false ? _live!.title : null,
              onOpen: () =>
                  _open(_live?.url ?? 'https://twitch.tv/shrutivtuber'),
            ),

            const SizedBox(height: Gap.xl),
            SectionHeader(
              eyebrow: 'From Shruti',
              title: 'Latest readings',
              action: 'All twelve',
              // ⚠ Opens IN THE APP now. It used to launch the website, which
              // sent somebody out of the app to read the thing the app exists
              // to carry. Her decision: the current period is read here, and
              // only the archive is on the site.
              onAction: _readHerReadings,
            ),
            const SizedBox(height: Gap.md),
            if (!_looked)
              const Column(
                children: [
                  Pressable(
                    padding: EdgeInsets.all(14),
                    child: Skeleton(lines: 2),
                  ),
                  SizedBox(height: 10),
                  Pressable(
                    padding: EdgeInsets.all(14),
                    child: Skeleton(lines: 2),
                  ),
                ],
              )
            else if (_readings.isEmpty)
              Pressable(
                padding: EdgeInsets.zero,
                child: EmptyState(
                  compact: true,
                  mark: '☾',
                  title: _reached
                      ? 'Nothing written yet this week'
                      : 'Kept from last time',
                  body: _reached
                      ? 'She writes the twelve on Sunday night. They will be '
                            'here when she has.'
                      : 'These are the readings you already had. New ones '
                            'arrive when her side is reachable.',
                ),
              )
            else
              for (final r in _grouped(_readings))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ContentCard(
                    kind: 'reading',
                    sign: titled(r.sign),
                    mark: _signMark(r.sign),
                    date: periodLabel(r.period, r.covers),
                    excerpt: r.opening,
                    // ⚠ A card for the CURRENT period opens in the app; an
                    // older one still opens the site, because that is where
                    // the archive lives. `_readHerReadings` decides, so the
                    // rule lives in one place rather than at every call.
                    onOpen: () => _readHerReadings(
                      period: r.period, covers: r.covers, sign: r.sign),
                  ),
                ),

            if (_articles.isNotEmpty) ...[
              const SizedBox(height: Gap.xl),
              SectionHeader(
                eyebrow: 'Longer',
                title: 'Latest articles',
                action: 'All',
                onAction: () => _open('/journal'),
              ),
              const SizedBox(height: Gap.md),
              for (final a in _articles.take(2))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ContentCard(
                    kind: 'article',
                    title: a.title,
                    date: a.publishedAt.length >= 10
                        ? a.publishedAt.substring(0, 10)
                        : a.publishedAt,
                    excerpt: a.opening,
                    onOpen: () => _open(a.url),
                  ),
                ),
            ],

            const SizedBox(height: Gap.xl),
            const SectionHeader(
              eyebrow: 'Hers',
              title: 'Offers',
              rule: true,
              mark: '☉',
            ),
            const SizedBox(height: Gap.md),
            if (_offers.isEmpty)
              const EmptyState(
                compact: true,
                mark: '♃',
                title: 'Nothing open just now',
                body:
                    'Classes run in terms. The next one is announced on '
                    'Discord first.',
              )
            else
              for (final o in _offers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _Offer(offer: o, onOpen: _open),
                ),

            const SizedBox(height: Gap.xl),
            const SectionHeader(eyebrow: 'Elsewhere', title: 'Her site'),
            const SizedBox(height: Gap.md),
            ListGroup(
              children: [
                ListRow(
                  label: 'shrutivtuber.com',
                  description:
                      'Instruments for magick, built live from Athens.',
                  external: true,
                  onTap: () => _open('/'),
                ),
                ListRow(
                  label: 'Support her work',
                  description: 'One-off, or monthly',
                  external: true,
                  onTap: () => _open('/support'),
                ),
                ListRow(
                  label: 'The shop',
                  description: 'Prints, and other made things',
                  external: true,
                  onTap: () => _open('/shop'),
                ),
                ListRow(
                  label: 'Watch on Twitch',
                  external: true,
                  onTap: () => _open('https://www.twitch.tv/shrutivtuber'),
                ),
                ListRow(
                  label: 'Discord',
                  description: 'Streams are announced here first',
                  external: true,
                  onTap: () => _open('https://discord.gg/Q8FW4AZNS6'),
                ),
              ],
            ),
            const SizedBox(height: Gap.sm),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Gap.xs),
              child: Text(
                'Support, the shop and classes open in your browser, where the '
                'address bar says whose they are.',
                style: TextStyle(
                  fontFamily: Face.body,
                  fontFamilyFallback: [Face.glyph],
                  fontSize: Type.caption,
                  height: 1.5,
                  color: Tone.faint,
                ),
              ),
            ),
          ],
        ),
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

  static String? _signMark(String sign) {
    const marks = {
      'aries': '♈',
      'taurus': '♉',
      'gemini': '♊',
      'cancer': '♋',
      'leo': '♌',
      'virgo': '♍',
      'libra': '♎',
      'scorpio': '♏',
      'sagittarius': '♐',
      'capricorn': '♑',
      'aquarius': '♒',
      'pisces': '♓',
    };
    return marks[sign.toLowerCase()];
  }
}

/// A sponsor's deal, or money off something of hers.
///
/// ⚠ The code is copied to the clipboard rather than expecting somebody to
/// retype it from a phone screen into a checkout on the same phone. That
/// retyping is where an offer quietly stops being used.
class _Offer extends StatefulWidget {
  const _Offer({required this.offer, required this.onOpen});

  final Offer offer;
  final void Function(String) onOpen;

  @override
  State<_Offer> createState() => _OfferState();
}

class _OfferState extends State<_Offer> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.offer;
    return OfferCard(
      title: o.title,
      body: o.blurb.trim().isEmpty ? null : o.blurb,
      mark: o.from.isEmpty ? '☉' : '♃',
      membersOnly: o.kind == 'member',
      footnote: o.endsAt == null
          ? null
          : 'opens in your browser · until ${o.endsAt!.substring(0, 10)}',
      onOpen: o.url.isEmpty ? null : () => widget.onOpen(o.url),
      trailing: o.code.isEmpty
          ? null
          : GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: o.code));
                if (mounted) setState(() => _copied = true);
              },
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
                  children: [
                    Expanded(
                      child: Text(
                        o.code,
                        style: const TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: Type.label,
                          letterSpacing: 1.2,
                          color: Tone.ink,
                          fontFeatures: [FontFeature.tabularFigures()],
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
    );
  }
}
