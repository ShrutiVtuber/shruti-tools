// SPDX-License-Identifier: AGPL-3.0-only
//
// What somebody opening the app wants first.
//
// The order is deliberate and it is the site's order, for the same reason: the
// next station goes above everything, because a person opening this at four in
// the afternoon wants "sunset in 2h 14m" before they want a table. Whether she
// is live goes second — it is the only thing here that is urgent, and only
// sometimes.
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/ephemeris.dart';
import '../services/settings.dart';
import '../services/stations.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';
import '../widgets/parts.dart';
import 'pick_place.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // The countdown is only useful if it counts.
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
    // Read, never remembered. Every tab is alive at once — this is an
    // IndexedStack so a cast chart survives a visit elsewhere — and a screen
    // holding its own copy went on answering for the place it was built with.
    final settings = SettingsScope.of(context);
    final place = settings.place;
    final today = stationsFor(
      DateTime.now(),
      place.lat,
      place.lon,
      convention: settings.convention,
    );
    final next = nextStation(today, DateTime.now());
    return RefreshIndicator(
      color: Tone.accent,
      backgroundColor: Tone.card,
      // Pulling down recomputes the day for the chosen place. It is
      // arithmetic, so it is instant and needs no network.
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
        children: [
          // ⚠ The page's own name, not the app's. This said "Astrolabe" and
          // carried the live card, which made the stations table look like a
          // home screen and buried the one urgent thing in the app inside an
          // astronomical table. Both moved to Home.
          Text('Stations', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: Gap.xs),
          Text(
            'Sunrise, noon, sunset and midnight, computed here',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: Gap.xl),
          _NextStationCard(
            next: next,
            place: place,
            onChangePlace: () => pickPlaceInto(context),
          ),
          const SizedBox(height: Gap.xl),
          const Eyebrow('Today'),
          const SizedBox(height: Gap.sm),
          _StationTable(stations: today, next: next, place: place),

          const SizedBox(height: Gap.xxl),
          Provenance(
            facts: [
              ('engine', engineVersion),
              ('computed', 'on this phone · nothing sent, nothing stored'),
              (
                'sunrise',
                settings.convention == RiseConvention.visibleDisc
                    ? "the Sun's upper limb clears the horizon, refracted"
                    : 'the centre of the disc, no refraction',
              ),
              ('for', '${place.name} · ${place.zone}'),
            ],
          ),
        ],
      ),
    );
  }
}

/// The one thing worth putting above everything else.
class _NextStationCard extends StatelessWidget {
  const _NextStationCard({
    required this.next,
    required this.place,
    required this.onChangePlace,
  });

  final Station? next;
  final Place place;
  final VoidCallback onChangePlace;

  @override
  Widget build(BuildContext context) {
    if (next == null) {
      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlaceLine(place: place, onTap: onChangePlace),
            const SizedBox(height: Gap.sm),
            Text(
              'Nothing further today',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: Gap.xs),
            Text(
              'The table below is the whole of it.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    final away = next!.at.difference(DateTime.now().toUtc());
    // In the PLACE's time, not the phone's. See models/place.dart — this line
    // used to read `.toLocal()` and put Athens times under a London heading.
    final there = place.tell(next!.at);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlaceLine(place: place, onTap: onChangePlace),
          const SizedBox(height: Gap.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                next!.kind.label,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: Gap.md),
              Text(
                _clock(there),
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall!.copyWith(color: Tone.accent),
              ),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'in ${_away(away)} · ${next!.kind.godform}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// The place, and the way to change it.
///
/// Tapping the name is the whole control. A settings screen for one setting is
/// a place to hide the only thing that makes the table wrong.
class _PlaceLine extends StatelessWidget {
  const _PlaceLine({required this.place, required this.onTap});

  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(Corner.sm),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Eyebrow('Next station · ${place.shortName}'),
          const SizedBox(width: Gap.xs),
          const Icon(Icons.expand_more, size: 15, color: Tone.faint),
        ],
      ),
    ),
  );
}

class _StationTable extends StatelessWidget {
  const _StationTable({
    required this.stations,
    required this.next,
    required this.place,
  });

  final List<Station> stations;
  final Station? next;
  final Place place;

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty) {
      return _Card(
        child: Text(
          'The sun neither rises nor sets here today.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < stations.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _StationRow(
              station: stations[i],
              current: identical(stations[i], next),
              place: place,
            ),
          ],
        ],
      ),
    );
  }
}

class _StationRow extends StatelessWidget {
  const _StationRow({
    required this.station,
    required this.current,
    required this.place,
  });

  final Station station;
  final bool current;
  final Place place;

  @override
  Widget build(BuildContext context) {
    final tone = current ? Tone.accent : Tone.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              station.kind.label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: tone),
            ),
          ),
          Expanded(
            child: Text(
              station.kind.godform,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            _clock(place.tell(station.at)),
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
  const _Card({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: Tone.card,
        borderRadius: BorderRadius.circular(Corner.md),
        border: Border.all(color: Tone.line),
      ),
      child: child,
    );
    return card;
  }
}

/// A wall clock in some named place. Takes a DateTime whose FIELDS are already
/// that place's — `Place.tell` produces one — never a UTC instant to be
/// squinted at.
String _clock(DateTime there) =>
    '${there.hour.toString().padLeft(2, '0')}:'
    '${there.minute.toString().padLeft(2, '0')}';

/// "2h 14m", "14m". Never "0h 14m", and never a bare number of minutes when
/// the answer is nearly a day away.
String _away(Duration d) {
  if (d.isNegative) return 'now';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h == 0) return '${m}m';
  return '${h}h ${m}m';
}
