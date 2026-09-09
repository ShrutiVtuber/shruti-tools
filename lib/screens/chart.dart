// SPDX-License-Identifier: AGPL-3.0-only
//
// Cast a chart.
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/chart.dart';
import '../services/settings.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';
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
  Place _place = Place.london;
  Chart? _chart;

  @override
  void initState() {
    super.initState();
    savedPlace().then((p) {
      if (p != null && mounted) setState(() => _place = p);
    });
  }

  void _cast() {
    setState(() {
      _chart = castChart(
        when: DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ),
        place: _place,
        timeKnown: _timeKnown,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chart = _chart;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
      children: [
        Text('Cast a chart', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: Gap.xs),
        Text(
          'Computed here, on the phone. Nothing is sent anywhere.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Gap.xl),

        _Field(
          label: 'Born',
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
        const SizedBox(height: Gap.sm),
        _Field(
          label: 'At',
          value: _timeKnown
              ? '${_time.hour.toString().padLeft(2, '0')}:'
                    '${_time.minute.toString().padLeft(2, '0')}'
              : 'not known',
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
        _Field(
          label: 'In',
          value: _place.shortName,
          onTap: () async {
            final picked = await Navigator.of(context).push<Place>(
              MaterialPageRoute(builder: (_) => const PickPlaceScreen()),
            );
            if (picked == null || !mounted) return;
            await savePlace(picked);
            if (mounted) setState(() => _place = picked);
          },
        ),
        const SizedBox(height: Gap.md),

        // Not a checkbox tucked in a corner: an unknown birth time changes
        // what the chart can say, and the page says what it costs before
        // anybody wonders why the houses are missing.
        SwitchListTile(
          value: !_timeKnown,
          onChanged: (v) => setState(() => _timeKnown = !v),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: Tone.accent,
          title: Text(
            "I don't know the time",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            'The ascendant moves a degree every four minutes, so the angles, '
            'houses and sect are left undefined rather than guessed.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: Gap.md),
        FilledButton(onPressed: _cast, child: const Text('Cast')),

        if (chart != null) ...[
          const SizedBox(height: Gap.xxl),
          Wheel(chart: chart),
          const SizedBox(height: Gap.lg),
          if (chart.timeKnown) _Angles(chart: chart) else _NoTimeNote(),
          const SizedBox(height: Gap.lg),
          const Eyebrow('Positions'),
          const SizedBox(height: Gap.sm),
          _Positions(chart: chart),
        ],
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.onTap,
    this.enabled = true,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(Corner.sm),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      decoration: BoxDecoration(
        color: Tone.card,
        borderRadius: BorderRadius.circular(Corner.sm),
        border: Border.all(color: Tone.line),
      ),
      child: Row(
        children: [
          SizedBox(width: 56, child: Eyebrow(label)),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: enabled ? Tone.ink : Tone.faint,
              ),
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, size: 18, color: Tone.faint),
        ],
      ),
    ),
  );
}

class _Angles extends StatelessWidget {
  const _Angles({required this.chart});

  final Chart chart;

  @override
  Widget build(BuildContext context) {
    final asc = chart.ascendant!;
    final mc = chart.midheaven!;
    return Row(
      children: [
        Expanded(
          child: _Stat(label: 'Ascendant', value: _place_(asc)),
        ),
        const SizedBox(width: Gap.md),
        Expanded(
          child: _Stat(label: 'Midheaven', value: _place_(mc)),
        ),
      ],
    );
  }
}

class _NoTimeNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Gap.lg),
    decoration: BoxDecoration(
      color: Tone.card,
      borderRadius: BorderRadius.circular(Corner.sm),
      border: Border.all(color: Tone.line),
    ),
    child: Text(
      'No ascendant, midheaven, houses or sect — those need the time. '
      'Every planet still has its sign and degree, and the aspects between '
      'them by sign still hold.',
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Gap.lg),
    decoration: BoxDecoration(
      color: Tone.card,
      borderRadius: BorderRadius.circular(Corner.sm),
      border: Border.all(color: Tone.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(label),
        const SizedBox(height: Gap.xs),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

class _Positions extends StatelessWidget {
  const _Positions({required this.chart});

  final Chart chart;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Tone.card,
      borderRadius: BorderRadius.circular(Corner.md),
      border: Border.all(color: Tone.line),
    ),
    child: Column(
      children: [
        for (var i = 0; i < chart.bodies.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          _Row(
            body: chart.bodies[i],
            house: chart.houseOf(chart.bodies[i].longitude),
          ),
        ],
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.body, required this.house});

  final Body body;
  final int? house;

  @override
  Widget build(BuildContext context) {
    final deg = body.degreeInSign;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              bodyGlyphs[body.name] ?? '',
              style: const TextStyle(
                fontFamily: 'AstroSymbols',
                fontSize: 17,
                color: Tone.ink,
              ),
            ),
          ),
          SizedBox(
            width: 74,
            child: Text(
              body.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              '${deg.floor()}° ${signNames[body.signIndex]}'
              '${body.retrograde ? "  ℞" : ""}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (house != null)
            Text(
              '$house',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

String _place_(double longitude) {
  final sign = signNames[((longitude ~/ 30) % 12).toInt()];
  return '${(longitude % 30).floor()}° $sign';
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
