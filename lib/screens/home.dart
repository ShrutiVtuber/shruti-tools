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
import 'package:url_launcher/url_launcher.dart';

import '../models/place.dart';
import '../services/site.dart';
import '../services/stations.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // London until the app can ask where the phone is, or she picks somewhere.
  // Named on screen rather than assumed silently — a station table for the
  // wrong city is indistinguishable from a right one until somebody misses a
  // dawn.
  static const _place = Place.london;

  late List<Station> _today;
  LiveStatus _live = LiveStatus.offline;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _today = stationsFor(DateTime.now(), _place.lat, _place.lon);
    _refreshLive();
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

  Future<void> _refreshLive() async {
    final status = await liveStatus();
    if (mounted) setState(() => _live = status);
  }

  @override
  Widget build(BuildContext context) {
    final next = nextStation(_today, DateTime.now());
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: Tone.accent,
          backgroundColor: Tone.card,
          onRefresh: () async {
            _today = stationsFor(DateTime.now(), _place.lat, _place.lon);
            await _refreshLive();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Gap.lg,
              Gap.xl,
              Gap.lg,
              Gap.huge,
            ),
            children: [
              Text(
                "Shruti's Tools",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: Gap.xs),
              Text(
                'Instruments for magick',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: Gap.xl),
              _NextStationCard(next: next, place: _place),
              const SizedBox(height: Gap.md),
              _LiveCard(live: _live),
              const SizedBox(height: Gap.xl),
              const Eyebrow('Today'),
              const SizedBox(height: Gap.sm),
              _StationTable(stations: _today, next: next, place: _place),
            ],
          ),
        ),
      ),
    );
  }
}

/// The one thing worth putting above everything else.
class _NextStationCard extends StatelessWidget {
  const _NextStationCard({required this.next, required this.place});

  final Station? next;
  final Place place;

  @override
  Widget build(BuildContext context) {
    if (next == null) {
      return _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Next station'),
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
          Eyebrow('Next station · ${place.name}'),
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

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.live});

  final LiveStatus live;

  @override
  Widget build(BuildContext context) {
    return _Card(
      onTap: live.isLive ? () => launchUrl(Uri.parse(live.url)) : null,
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
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
                  live.isLive ? 'Live now' : 'Offline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  live.isLive && live.title.isNotEmpty
                      ? live.title
                      : 'Streams are announced on Discord first.',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (live.isLive)
            const Icon(Icons.arrow_outward, size: 18, color: Tone.accent),
        ],
      ),
    );
  }
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
  const _Card({required this.child, this.onTap, this.padding});

  final Widget child;
  final VoidCallback? onTap;
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
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Corner.md),
      child: card,
    );
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
