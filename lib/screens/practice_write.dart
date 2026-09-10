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
      final body = await _room.draft(
        period: _period,
        covers: _covers,
        sign: _sign,
      );
      if (!mounted) return;
      _text.text = body;
      setState(() => _said = body.trim().isEmpty ? '' : 'kept');
    } on PracticeTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _keep() async {
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
      appBar: const Bar(title: 'Write a reading', hour: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.huge),
          children: [
            const Eyebrow('Which period'),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.sm,
              children: [
                for (final p in periods)
                  ChoiceChip(
                    label: Text(titled(p)),
                    selected: _period == p,
                    onSelected: (_) {
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
            const SizedBox(height: Gap.xs),
            Text(
              periodLabel(_period, _covers),
              style: const TextStyle(color: Tone.faint, fontSize: 13),
            ),

            const SizedBox(height: Gap.lg),
            const Eyebrow('Which sign'),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.xs,
              runSpacing: Gap.xs,
              children: [
                for (final s in zodiac)
                  ChoiceChip(
                    label: Text('${signGlyph[s]} ${titled(s)}'),
                    selected: _sign == s,
                    onSelected: (_) {
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

            if (_day != null) ...[
              const SizedBox(height: Gap.lg),
              const Eyebrow('The sky that day'),
              const SizedBox(height: Gap.sm),
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
              const Eyebrow('What happens in it'),
              const SizedBox(height: Gap.sm),
              PeriodEvents(events: _skyEvents),
            ],

            if (_sky.length > 1) ...[
              const SizedBox(height: Gap.lg),
              const Eyebrow('The sky across it'),
              const SizedBox(height: Gap.sm),
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
              const SizedBox(height: Gap.xs),
              const Text(
                'Each body from where it starts to where it ends. Ticks are '
                'sign changes, circles are stations. The inner ring is the '
                'period day by day — the Moon\'s phase, not its position.',
                style: TextStyle(color: Tone.faint, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: Gap.lg),
              const Eyebrow('What happens in it'),
              const SizedBox(height: Gap.sm),
              PeriodEvents(events: _skyEvents),
            ],

            const SizedBox(height: Gap.lg),
            if (_loading)
              const Text(
                'Fetching your draft…',
                style: TextStyle(color: Tone.faint),
              )
            else
              TextField(
                controller: _text,
                maxLines: null,
                minLines: 12,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() => _said = 'not kept yet'),
                decoration: const InputDecoration(
                  hintText: 'What does this sky ask of this sign?',
                  alignLabelWithHint: true,
                ),
              ),
            const SizedBox(height: Gap.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _said,
                    style: const TextStyle(color: Tone.faint, fontSize: 12),
                  ),
                ),
                TextButton(onPressed: _keep, child: const Text('Keep')),
              ],
            ),

            if (_trouble != null) ...[
              const SizedBox(height: Gap.sm),
              Text(
                _trouble!,
                style: const TextStyle(color: Tone.live, height: 1.45),
              ),
            ],

            const SizedBox(height: Gap.lg),
            FilledButton(
              onPressed: _sending ? null : _submit,
              child: Text(_sending ? 'Sending…' : 'Submit for others to read'),
            ),
            const SizedBox(height: Gap.sm),
            const Text(
              'Everything you have written for this period goes together, as one '
              'piece of work. Signs you left blank are not sent.',
              style: TextStyle(color: Tone.faint, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
