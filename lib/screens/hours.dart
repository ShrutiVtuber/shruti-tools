// SPDX-License-Identifier: AGPL-3.0-only
//
// The planetary hours of the day you are in.
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/hours.dart';
import '../services/settings.dart';
import '../services/stations.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';
import 'pick_place.dart';

const _glyphs = {
  'Saturn': '♄',
  'Jupiter': '♃',
  'Mars': '♂',
  'Sun': '☉',
  'Venus': '♀',
  'Mercury': '☿',
  'Moon': '☽',
};

class HoursScreen extends StatefulWidget {
  const HoursScreen({super.key});

  @override
  State<HoursScreen> createState() => _HoursScreenState();
}

class _HoursScreenState extends State<HoursScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read, never remembered — see services/settings.dart.
    final settings = SettingsScope.of(context);
    final place = settings.place;
    final hours = hoursFor(
      DateTime.now(),
      place.lat,
      place.lon,
      convention: settings.convention,
    );
    final now = hourNow(hours, DateTime.now());
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
      children: [
        Text(
          'Planetary hours',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: Gap.xs),
        Text(
          'Sunrise to sunset in twelve, and the night in twelve more — so an '
          'hour is sixty minutes twice a year.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Gap.xl),

        if (hours.isEmpty)
          _Card(
            child: Text(
              'The sun does not both rise and set here today, so there is '
              'nothing to divide into hours.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else ...[
          _NowCard(
            hour: now,
            place: place,
            onChangePlace: () => pickPlaceInto(context),
          ),
          const SizedBox(height: Gap.md),
          _ConventionCard(
            convention: settings.convention,
            onChanged: settings.setConvention,
          ),
          const SizedBox(height: Gap.xl),
          const Eyebrow('Day'),
          const SizedBox(height: Gap.sm),
          _HourList(
            hours: hours.where((h) => h.byDay).toList(),
            current: now,
            place: place,
          ),
          const SizedBox(height: Gap.lg),
          const Eyebrow('Night'),
          const SizedBox(height: Gap.sm),
          _HourList(
            hours: hours.where((h) => !h.byDay).toList(),
            current: now,
            place: place,
          ),
        ],
      ],
    );
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({
    required this.hour,
    required this.place,
    required this.onChangePlace,
  });

  final PlanetaryHour? hour;
  final Place place;
  final VoidCallback onChangePlace;

  @override
  Widget build(BuildContext context) {
    if (hour == null) {
      return _Card(
        child: Text(
          'Between days.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    final left = hour!.to.difference(DateTime.now().toUtc());
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onChangePlace,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Eyebrow('This hour · ${place.shortName}'),
                const SizedBox(width: Gap.xs),
                const Icon(Icons.expand_more, size: 15, color: Tone.faint),
              ],
            ),
          ),
          const SizedBox(height: Gap.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _glyphs[hour!.ruler] ?? '',
                style: const TextStyle(
                  fontFamily: 'AstroSymbols',
                  fontSize: 30,
                  color: Tone.accent,
                ),
              ),
              const SizedBox(width: Gap.md),
              Text(
                hour!.ruler,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Text(
            '${_ordinal(hour!.index)} hour of the '
            '${hour!.byDay ? "day" : "night"} · '
            '${left.inMinutes} min left',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// The choice is on the screen, not buried in a settings page.
///
/// It moves every boundary below it by a few minutes, which is enough to
/// change which planet rules the moment somebody is standing in — so hiding it
/// would mean the table quietly answering a question the reader did not ask.
class _ConventionCard extends StatelessWidget {
  const _ConventionCard({required this.convention, required this.onChanged});

  final RiseConvention convention;
  final ValueChanged<RiseConvention> onChanged;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Sunrise is'),
        const SizedBox(height: Gap.sm),
        for (final c in RiseConvention.values)
          RadioListTile<RiseConvention>(
            value: c,
            // ignore: deprecated_member_use
            groupValue: convention,
            // ignore: deprecated_member_use
            onChanged: (v) => v == null ? null : onChanged(v),
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
        Text(
          'About four minutes apart — enough to move an hour boundary.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _HourList extends StatelessWidget {
  const _HourList({
    required this.hours,
    required this.current,
    required this.place,
  });

  final List<PlanetaryHour> hours;
  final PlanetaryHour? current;
  final Place place;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Tone.card,
      borderRadius: BorderRadius.circular(Corner.md),
      border: Border.all(color: Tone.line),
    ),
    child: Column(
      children: [
        for (var i = 0; i < hours.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          _HourRow(
            hour: hours[i],
            now: identical(hours[i], current),
            place: place,
          ),
        ],
      ],
    ),
  );
}

class _HourRow extends StatelessWidget {
  const _HourRow({required this.hour, required this.now, required this.place});

  final PlanetaryHour hour;
  final bool now;
  final Place place;

  @override
  Widget build(BuildContext context) {
    final tone = now ? Tone.accent : Tone.ink;
    final there = place.tell(hour.from);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              hour.displayIndex.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 26,
            child: Text(
              _glyphs[hour.ruler] ?? '',
              style: TextStyle(
                fontFamily: 'AstroSymbols',
                fontSize: 16,
                color: tone,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hour.ruler,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: tone),
            ),
          ),
          Text(
            '${there.hour.toString().padLeft(2, '0')}:'
            '${there.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: tone,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  /// A Material rather than a decorated Container.
  ///
  /// The radio rows inside paint their ink on the nearest Material ancestor,
  /// and a DecoratedBox in between hides it — Flutter says so outright:
  /// "ListTile background color or ink splashes may be invisible." Only in
  /// debug, which is why a release build looked fine and a widget test did
  /// not.
  @override
  Widget build(BuildContext context) => Material(
    color: Tone.card,
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
  );
}

String _ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}
