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

import '../services/events.dart';
import '../services/period_sky.dart';
import '../services/periods.dart';
import '../services/practice.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/parts.dart';
import 'sky_drawer.dart';
import '../widgets/motifs.dart';
import '../widgets/forms.dart';
import '../theme/glyph.dart';
import '../models/place.dart';
import '../services/chart.dart';
import '../widgets/period_events.dart';
import '../widgets/period_wheel.dart';
import '../widgets/wheel.dart';
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

  List<SkyDay> _sky = const [];
  List<SkyEvent> _skyEvents = const [];
  Chart? _day;

  /// Which signs of this period already have words in them.
  ///
  /// ⚠ The one fact that turns a row of identical chips into a piece of work
  /// in progress. Without it, somebody writing twelve has to open all twelve
  /// to find the four they have done.
  Set<String> _written = const {};

  /// ⚠ Computed HERE, not fetched. The app carries Swiss Ephemeris, so the
  /// wheel draws a whole month on a train with no signal — which is the reason
  /// the instruments are on the phone at all.
  void _readTheSky() {
    final (start, end) = _span();
    setState(() {
      _sky = skyAcross(start, end);
      _skyEvents = eventsAcross(start, end);
      // ⚠ A single day has no movement to draw, so the movement wheel would be
      // a wheel of dots. That day's chart is the honest figure — the same swap
      // the website's desk makes, at the same moment and for the same reason.
      _day = _period == 'daily' ? chartAtStart(start, _greenwich) : null;
    });
  }

  /// ⚠ Greenwich at noon, matching the website exactly. A practice reading is
  /// for a sign rather than for a place, and if the two desks cast from
  /// different meridians the same period reads as two different skies.
  static const _greenwich = Place(
    name: 'Greenwich',
    lat: 51.4779,
    lon: 0,
    zone: 'Europe/London',
  );

  (DateTime, DateTime) _span() {
    switch (_period) {
      case 'weekly':
        final (a, b) = weekDays(_covers);
        return (DateTime.parse(a), DateTime.parse(b));
      case 'daily':
        final d = DateTime.parse(_covers);
        return (d, d);
      case 'monthly':
        final parts = _covers.split('-').map(int.parse).toList();
        return (
          DateTime.utc(parts[0], parts[1], 1),
          DateTime.utc(parts[0], parts[1] + 1, 0),
        );
      default:
        final y = int.tryParse(_covers) ?? DateTime.now().year;
        return (DateTime.utc(y, 1, 1), DateTime.utc(y, 12, 31));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      _fetch();
      _readTheSky();
    }
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
      final answer = await _room.draft(
        period: _period,
        covers: _covers,
        sign: _sign,
      );
      if (!mounted) return;
      _text.text = answer.bodyMd;
      setState(() {
        _written = answer.written.toSet();
        _said = answer.bodyMd.trim().isEmpty ? '' : 'kept';
      });
    } on PracticeTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _keep() async {
    // ⚠ The tick has to appear the moment the words are kept. Waiting for the
    // next fetch means writing a sign, looking up, and seeing nothing changed.
    setState(() {
      if (_text.text.trim().isEmpty) {
        _written = {..._written}..remove(_sign);
      } else {
        _written = {..._written, _sign};
      }
    });
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
      appBar: Bar(
        title: 'Write a reading',
        hour: false,
        actions: [
          // ⚠ The whole ephemeris, behind a button, as a sheet you close.
          // Her words: a reference you can open and shut while keeping the
          // working area clear. Below the box it would be a scroll away at
          // exactly the moment somebody wants to check a degree.
          Tap(
            icon: Icons.menu_book_outlined,
            label: 'The sky in full',
            onTap: () => showSkyDrawer(context, opensOn: _span().$1),
          ),
          Push(
            label: 'Save draft',
            weight: Weight.text,
            size: Bulk.sm,
            onTap: _keep,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Gap.gutter,
            Gap.gutter,
            Gap.gutter,
            Gap.huge,
          ),
          children: [
            const Eyebrow('Which period'),
            const SizedBox(height: Gap.sm),
            TagRow(
              children: [
                for (final p in periods)
                  Tag(
                    label: titled(p),
                    selected: _period == p,
                    onTap: () {
                      setState(() {
                        _period = p;
                        _covers = currentCovers(p);
                      });
                      _fetch();
                      _readTheSky();
                    },
                  ),
              ],
            ),
            const SizedBox(height: Gap.sm),
            Text(
              periodLabel(_period, _covers),
              style: const TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.caption,
                color: Tone.faint,
              ),
            ),

            const SizedBox(height: Gap.lg),
            Row(
              children: [
                const Eyebrow('Which sign'),
                const Spacer(),
                // ⚠ The count of what is done, where somebody choosing the
                // next sign is already looking. A progress bar would say the
                // same thing louder and no more usefully.
                Text(
                  _written.isEmpty
                      ? 'nothing written yet'
                      : '${_written.length} of 12 written',
                  style: TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: const [Face.glyph],
                    fontSize: Type.caption,
                    color: _written.length >= 12 ? Gilt.gilt : Tone.faint,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.sm),
            TagRow(
              children: [
                for (final s in zodiac)
                  Tag(
                    label: titled(s),
                    // ⚠ A tick, not only a tint: which signs are done has to
                    // survive a screen somebody cannot see colour on, and it
                    // is the whole reason to look at this row.
                    leading: _written.contains(s)
                        ? const Icon(Icons.check, size: 13, color: Gilt.gilt)
                        : Glyph(
                            signGlyph[s] ?? '',
                            size: 13,
                            color: _sign == s ? Tone.accent : Tone.faint,
                          ),
                    selected: _sign == s,
                    onTap: () {
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

            // ⚠ The sky goes ABOVE the box and the box goes below all of it,
            // because the box has to be tall enough to write something
            // meaningful in. Reference first, writing second.
            if (_day != null) ...[
              const SizedBox(height: Gap.xl),
              const SectionHeader(title: 'The sky that day'),
              const SizedBox(height: Gap.md),
              AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: WheelPainter(
                    chart: _day!,
                    rising: zodiac.indexOf(_sign),
                  ),
                ),
              ),
              const SizedBox(height: Gap.lg),
              const SectionHeader(title: 'What happens in it'),
              const SizedBox(height: Gap.md),
              PeriodEvents(events: _skyEvents),
            ],

            if (_sky.length > 1) ...[
              const SizedBox(height: Gap.xl),
              const SectionHeader(title: 'The sky across it'),
              const SizedBox(height: Gap.md),
              AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: PeriodWheelPainter(
                    days: _sky,
                    events: _skyEvents,
                    rising: zodiac.indexOf(_sign),
                  ),
                ),
              ),
              const SizedBox(height: Gap.sm),
              const Text(
                'Each body from where it starts to where it ends. Ticks are '
                'sign changes, circles are stations. The inner ring is the '
                "period day by day — the Moon's phase, not its position.",
                style: TextStyle(
                  fontFamily: Face.body,
                  fontFamilyFallback: [Face.glyph],
                  fontSize: Type.caption,
                  height: 1.5,
                  color: Tone.faint,
                ),
              ),
              const SizedBox(height: Gap.lg),
              const SectionHeader(title: 'What happens in it'),
              const SizedBox(height: Gap.md),
              PeriodEvents(events: _skyEvents),
            ],

            const SizedBox(height: Gap.xl),
            const Rule(),
            const SizedBox(height: Gap.lg),
            if (_loading)
              const Skeleton(height: 260)
            else
              Field(
                label: 'The reading',
                controller: _text,
                multiline: true,
                rows: 12,
                maxLength: 4000,
                counter: true,
                hint:
                    'A few hundred words on one sky. It does not have to be '
                    'right.',
                helper: _said.isEmpty ? null : _said,
                onChanged: (_) => setState(() => _said = 'not kept yet'),
              ),

            if (_trouble != null) ...[
              const SizedBox(height: Gap.md),
              NoticeBar(tone: BannerTone.warning, text: _trouble!),
            ],

            const SizedBox(height: Gap.lg),
            Row(
              children: [
                Expanded(
                  child: Push(
                    label: 'Save draft',
                    weight: Weight.outlined,
                    full: true,
                    onTap: _keep,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Push(
                    label: _sending ? 'Sending…' : 'Submit it',
                    loading: _sending,
                    full: true,
                    onTap: _sending ? null : _submit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.sm),
            const Text(
              'Everything you have written for this period goes together, as '
              'one piece of work. Signs you left blank are not sent.',
              style: TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.caption,
                height: 1.5,
                color: Tone.faint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
