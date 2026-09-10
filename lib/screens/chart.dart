// SPDX-License-Identifier: AGPL-3.0-only
//
// Cast a chart.
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/chart.dart';
import '../services/settings.dart';
import '../services/ephemeris.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/data.dart';
import '../widgets/eyebrow.dart';
import '../widgets/forms.dart';
import '../widgets/parts.dart';
import '../widgets/wheel.dart';
import 'pick_place.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  DateTime _date = DateTime(1990, 5, 4);
  TimeOfDay _time = const TimeOfDay(hour: 14, minute: 30);
  bool _timeKnown = true;
  Chart? _chart;

  /// The birth place, which is NOT the settings place.
  ///
  /// Deliberately separate: the place in settings is where the reader is, and
  /// a chart is cast for where somebody was born. Sharing them would mean
  /// choosing a birth city silently changed every station table.
  Place? _born;

  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _cast(Place place) {
    setState(() {
      _chart = castChart(
        when: DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ),
        place: place,
        timeKnown: _timeKnown,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Defaults to where the reader is, then stays where they put it.
    final place = _born ?? SettingsScope.of(context).place;
    final chart = _chart;

    if (chart == null) return _form(place);
    return _result(chart, place);
  }

  /// The form. One question per row, and the one that changes what the chart
  /// can say — an unknown birth time — states its cost in the row itself.
  Widget _form(Place place) => Scaffold(
    appBar: const Bar(title: 'Cast a chart', hour: false),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        Gap.gutter,
        Gap.gutter,
        Gap.gutter,
        Gap.huge,
      ),
      children: [
        Field(label: 'Name', controller: _name, hint: 'Whose chart is this?'),
        const SizedBox(height: 14),
        _Picked(
          label: 'Date of birth',
          value: '${_date.day} ${_month(_date.month)} ${_date.year}',
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(1800),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _date = picked);
          },
        ),
        const SizedBox(height: 14),
        _Picked(
          label: 'Time of birth',
          value: _timeKnown
              ? '${_time.hour.toString().padLeft(2, "0")}:'
                    '${_time.minute.toString().padLeft(2, "0")}'
              : 'not known',
          helper: _timeKnown
              ? 'Local clock time at the place of birth.'
              : 'Left unknown — the angles will not be reckoned.',
          enabled: _timeKnown,
          onTap: !_timeKnown
              ? null
              : () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (picked != null) setState(() => _time = picked);
                },
        ),
        const SizedBox(height: Gap.sm),
        // ⚠ Not a checkbox tucked in a corner: an unknown birth time changes
        // what the chart CAN say, and the row says what it costs before
        // anybody wonders why the houses are missing.
        ChoiceRow(
          radio: false,
          label: 'The time of birth is unknown',
          rule:
              'The chart is still cast. The ascendant, the midheaven and '
              'the houses are not — the ascendant moves a degree every four '
              'minutes, so they are left undefined rather than guessed.',
          checked: !_timeKnown,
          onChanged: (v) => setState(() => _timeKnown = !v),
        ),
        const SizedBox(height: Gap.md),
        ListGroup(
          children: [
            ListRow(
              label: 'Place of birth',
              value: place.shortName,
              onTap: () async {
                final picked = await Navigator.of(context).push<Place>(
                  MaterialPageRoute(builder: (_) => const PickPlaceScreen()),
                );
                if (picked != null && mounted) {
                  setState(() => _born = picked);
                }
              },
            ),
            const ListRow(label: 'Zodiac', value: 'Tropical'),
            ListRow(
              label: 'Houses',
              value: _timeKnown ? 'Whole sign' : 'Not reckoned',
            ),
          ],
        ),
        const SizedBox(height: Gap.md),
        const Pressable(
          tone: Surface.inset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow('Cast here, on the phone'),
              SizedBox(height: Gap.sm),
              Text(
                'Nothing is sent anywhere. The ephemeris is bundled with the '
                'app, so a chart cast in a tunnel is the same chart cast at a '
                'desk.',
                style: TextStyle(
                  fontFamily: Face.body,
                  fontFamilyFallback: [Face.glyph],
                  fontSize: Type.caption,
                  height: 1.6,
                  color: Tone.faint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        Push(
          label: 'Cast the chart',
          size: Bulk.lg,
          full: true,
          onTap: () => _cast(place),
        ),
      ],
    ),
  );

  /// The chart itself.
  Widget _result(Chart chart, Place place) {
    final known = chart.timeKnown;
    final rising = ((chart.ascendant ?? 0) ~/ 30) % 12;
    return Scaffold(
      appBar: Bar(
        title: _name.text.trim().isEmpty ? 'The chart' : _name.text.trim(),
        subtitle:
            '${_date.day} ${_month(_date.month)} ${_date.year} · '
            '${known ? "${_time.hour.toString().padLeft(2, "0")}:${_time.minute.toString().padLeft(2, "0")}" : "time unknown"}'
            ' · ${place.shortName}',
        hour: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _chart = null),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Gap.gutterDense,
          Gap.md,
          Gap.gutterDense,
          Gap.huge,
        ),
        children: [
          // ⚠ The cannot-compute state offers the honest alternative rather
          // than a fabricated answer.
          if (!known) ...[
            const NoticeBar(
              tone: BannerTone.caution,
              title: 'The angles are not reckoned',
              text:
                  'With no birth time there is no ascendant and no '
                  'midheaven, so this wheel has no houses. Everything drawn '
                  'here is true; the things that are missing are missing on '
                  'purpose.',
            ),
            const SizedBox(height: Gap.md),
          ],
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: WheelPainter(
                chart: chart,
                rising: rising,
                houseNumbers: known,
              ),
            ),
          ),
          const SizedBox(height: Gap.md),
          TagRow(
            children: [
              const Tag(label: 'Tropical', selected: true),
              const Tag(label: 'Sidereal · Lahiri', disabled: true),
              Tag(label: 'Whole sign', selected: known, disabled: !known),
            ],
          ),
          const SizedBox(height: Gap.md),
          Pressable(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Eyebrow('Positions'),
                const SizedBox(height: Gap.sm),
                for (final b in chart.bodies)
                  Fact(
                    mark: bodyGlyphs[b.name],
                    label: b.name,
                    value: _degrees(b.longitude),
                    tone: b.retrograde ? Tone.rose : Tone.ink,
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
                        label: 'Ascendant',
                        value: known
                            ? _degrees(chart.ascendant!)
                            : 'Not reckoned',
                        tone: known ? Tone.ink : Tone.faint,
                      ),
                      Fact(
                        label: 'Midheaven',
                        value: known
                            ? _degrees(chart.midheaven!)
                            : 'Not reckoned',
                        tone: known ? Tone.ink : Tone.faint,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.xxl),
          Provenance(
            facts: [
              ('engine', engineVersion),
              ('computed', 'on this phone · nothing sent, nothing stored'),
              ('zodiac', 'tropical'),
              ('houses', known ? 'whole sign' : 'not reckoned'),
              ('cast for', '${place.name} · ${place.zone}'),
            ],
          ),
        ],
      ),
    );
  }

  /// Degrees and minutes, with the sign's own mark.
  static String _degrees(double longitude) {
    final within = longitude % 30;
    final degrees = within.floor();
    final minutes = ((within - degrees) * 60).round();
    final sign = signGlyphs[((longitude ~/ 30) % 12).toInt()];
    return '${degrees.toString().padLeft(2, "0")}°'
        '${minutes.toString().padLeft(2, "0")}′ $sign';
  }
}

/// A value chosen from a picker, wearing a text field's clothes so the form
/// reads as one form rather than as three different kinds of control.
class _Picked extends StatelessWidget {
  const _Picked({
    required this.label,
    required this.value,
    this.helper,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final String value;
  final String? helper;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: Face.body,
              fontFamilyFallback: [Face.glyph],
              fontSize: Type.caption,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: Tone.soft,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: Target.min,
            padding: const EdgeInsets.symmetric(horizontal: Gap.md),
            decoration: BoxDecoration(
              color: Tone.inset,
              borderRadius: BorderRadius.circular(Corner.sm),
              border: Border.all(color: Tone.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: Face.body,
                      fontFamilyFallback: [Face.glyph],
                      fontSize: Type.body,
                      color: Tone.ink,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const Icon(Icons.expand_more, size: 18, color: Tone.faint),
              ],
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Text(
              helper!,
              style: const TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.caption,
                height: 1.45,
                color: Tone.faint,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

String _month(int m) => const [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][m - 1];
