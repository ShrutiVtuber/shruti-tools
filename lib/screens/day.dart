// SPDX-License-Identifier: AGPL-3.0-only
//
// The sky over time: the day's stations, its hours, and what is coming.
//
// Three instruments under one tab. They belong together — each answers "where
// are we in something", and the first two are read from the same sunrise — and
// grouping them leaves room in a bar that holds about six before nobody can
// read the labels.
//
// ⚠ They share the sunrise convention through Settings, not through here. The
// two disagreeing about when the day starts is the bug `tabs_agree_test.dart`
// exists to catch.
import 'package:flutter/material.dart';

import '../services/period_sky.dart';
import '../services/settings.dart';
import '../services/shell_state.dart';
import '../services/stations.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/forms.dart';
import '../widgets/parts.dart';
import 'events.dart';
import 'sky_drawer.dart';
import 'home.dart';
import 'hours.dart';

class SkyScreen extends StatefulWidget {
  const SkyScreen({super.key});

  @override
  State<SkyScreen> createState() => _SkyScreenState();
}

class _SkyScreenState extends State<SkyScreen> {
  int _which = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Bar(
      title: 'Sky',
      subtitle: SettingsScope.of(context).place.name,
      actions: [
        Tap(
          icon: Icons.menu_book_outlined,
          label: 'Sky drawer',
          onTap: () => showSkyDrawer(context),
        ),
      ],
    ),
    body: Column(
      children: [
        // Sky's own surface: the day as an arc, the counterpart to Home's plate.
        // ⚠ Each tab gets one surface of its own and they are never the same
        // surface — repeat the plate here and six tabs read as one stack of
        // cards.
        const Padding(
          padding: EdgeInsets.fromLTRB(
            Gap.gutterDense,
            Gap.md,
            Gap.gutterDense,
            0,
          ),
          child: _TodayArc(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Gap.gutterDense,
            Gap.md,
            Gap.gutterDense,
            Gap.sm,
          ),
          child: Segmented<int>(
            options: const [(0, 'Stations'), (1, 'Hours'), (2, 'Coming')],
            chosen: _which,
            onChosen: (i) => setState(() => _which = i),
          ),
        ),
        Expanded(
          // IndexedStack: flipping between them must not recompute a table
          // that was right a second ago.
          child: IndexedStack(
            index: _which,
            children: const [StationsScreen(), HoursScreen(), EventsScreen()],
          ),
        ),
      ],
    ),
  );
}

/// The arc for today, at this place — computed here, so it is right in a
/// tunnel.
class _TodayArc extends StatelessWidget {
  const _TodayArc();

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final place = settings.place;
    final now = DateTime.now().toUtc();
    final today = stationsFor(
      now,
      place.lat,
      place.lon,
      convention: settings.convention,
    );

    final rise = today.firstWhere(
      (s) => s.kind == StationKind.dawn,
      orElse: () => today.first,
    );
    final set = today.lastWhere(
      (s) => s.kind == StationKind.dusk,
      orElse: () => today.last,
    );

    // ⚠ Both from the same day's table. Taking sunrise from today and sunset
    // from a table computed a moment later at a different convention would put
    // the Sun somewhere it is not, which is the one thing an arc must not do.
    final sky = skyAcross(now, now);
    final yesterday = skyAcross(
      now.subtract(const Duration(days: 1)),
      now.subtract(const Duration(days: 1)),
    );
    final lit = sky.isEmpty ? 0.0 : sky.first.lit;
    final waxing = yesterday.isEmpty || lit >= yesterday.first.lit;

    return DayArc(
      sunrise: place.tell(rise.at),
      sunset: place.tell(set.at),
      now: place.tell(now),
      lit: lit,
      waxing: waxing,
      ruler: ShellScope.of(context)?.ruler,
    );
  }
}
