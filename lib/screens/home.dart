// SPDX-License-Identifier: AGPL-3.0-only
//
// Sky · Stations — the four hinges of the day, at this place.
//
// The order is deliberate and it is the site's order, for the same reason: the
// next station goes above everything, because a person opening this at four in
// the afternoon wants "sunset in 2h 14m" before they want a table.
//
// ⚠ The design system calls the reference table dense on purpose, and this is
// where that starts: thirty-pixel rows, thirteen-point tabular figures, and no
// sideways scrolling ever. The table FITS or a column is cut.
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/ephemeris.dart';
import '../services/period_sky.dart';
import '../services/settings.dart';
import '../services/stations.dart';
import '../theme/glyph.dart';
import '../theme/tokens.dart';
import '../widgets/data.dart';
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
    final now = DateTime.now().toUtc();
    final today = stationsFor(
      now,
      place.lat,
      place.lon,
      convention: settings.convention,
    );
    final next = today.where((s) => s.at.isAfter(now)).firstOrNull;
    final retrograde = _retrograde(now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Gap.gutterDense,
        Gap.md,
        Gap.gutterDense,
        Gap.huge,
      ),
      children: [
        _NextStation(
          next: next,
          place: place,
          onChangePlace: () => pickPlaceInto(context),
        ),
        const SizedBox(height: Gap.md),

        if (today.isEmpty)
          const EmptyState(
            mark: '☉',
            title: 'The Sun neither rises nor sets here today',
            body:
                'Above the Arctic circle in summer, or below it in winter, '
                'the day has no hinges. Everything else still reckons.',
          )
        else
          Reference(
            caption:
                '${place.name} · ${place.zone} · '
                '${settings.convention == RiseConvention.visibleDisc ? "upper limb, refracted" : "centre of the disc"}',
            columns: const [
              Heading(label: 'Station', flex: 3),
              Heading(label: 'Godform', flex: 3),
              Heading(label: 'Time', numeric: true, flex: 2),
            ],
            rows: [
              for (final s in today)
                Line([
                  Cell(s.kind.label),
                  Cell(s.kind.godform, muted: true),
                  Cell(_clock(place.tell(s.at))),
                ], now: identical(s, next)),
            ],
          ),

        // ⚠ ℞ AND rose AND the word. A retrograde marked by tint alone is a
        // retrograde a printed page loses and a colour-blind reader never had.
        if (retrograde.isNotEmpty) ...[
          const SizedBox(height: Gap.md),
          Pressable(
            tone: Surface.warning,
            padding: const EdgeInsets.all(Gap.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Glyph('℞', size: 17, color: Tone.rose),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        retrograde.length == 1
                            ? '${retrograde.first} is retrograde'
                            : '${retrograde.take(retrograde.length - 1).join(", ")} '
                                  'and ${retrograde.last} are retrograde',
                        style: const TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: Type.label,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: Tone.rose,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Every affected figure carries ℞ as well as the tint.',
                        style: TextStyle(
                          fontFamily: Face.body,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: Type.caption,
                          height: 1.5,
                          color: Tone.soft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: Gap.xxl),
        Provenance(
          facts: [
            ('Engine', engineVersion),
            ('Computed', 'on this phone · nothing sent, nothing stored'),
            (
              'the rule',
              settings.convention == RiseConvention.visibleDisc
                  ? "sunrise: the Sun's upper limb clears the horizon, refracted"
                  : 'sunrise: the centre of the disc, no refraction',
            ),
            ('For', '${place.name} · ${place.zone}'),
          ],
        ),
      ],
    );
  }

  /// Which planets are retrograde right now — read from the day's motion, not
  /// from a table of dates that would have to be kept.
  List<String> _retrograde(DateTime now) {
    final today = skyAcross(now, now);
    final tomorrow = skyAcross(
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 1)),
    );
    if (today.isEmpty || tomorrow.isEmpty) return const [];
    final out = <String>[];
    for (final body in periodBodies) {
      if (body == 'Sun' || body == 'Moon') continue;
      final a = today.first.longitudes[body];
      final b = tomorrow.first.longitudes[body];
      if (a == null || b == null) continue;
      var step = b - a;
      // Unwrap: 359° → 1° is +2, not −358.
      if (step < -180) step += 360;
      if (step > 180) step -= 360;
      if (step < 0) out.add(body);
    }
    return out;
  }

  static String _clock(DateTime t) =>
      '${t.hour.toString().padLeft(2, "0")}:'
      '${t.minute.toString().padLeft(2, "0")}';
}

/// The one thing worth putting above everything else.
class _NextStation extends StatelessWidget {
  const _NextStation({
    required this.next,
    required this.place,
    required this.onChangePlace,
  });

  final Station? next;
  final Place place;
  final VoidCallback onChangePlace;

  @override
  Widget build(BuildContext context) {
    final station = next;
    final at = station == null ? null : place.tell(station.at);
    final away = station?.at.difference(DateTime.now().toUtc());

    return Pressable(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onChangePlace,
            child: Row(
              children: [
                Text(
                  'NEXT STATION · ${place.shortName.toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: Type.eyebrow,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.54,
                    color: Tone.faint,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, size: 15, color: Tone.faint),
              ],
            ),
          ),
          const SizedBox(height: Gap.sm),
          if (next == null)
            Text(
              'Nothing further today',
              style: Theme.of(context).textTheme.titleLarge,
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  station!.kind.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: Gap.md),
                Text(
                  '${at!.hour.toString().padLeft(2, "0")}:'
                  '${at.minute.toString().padLeft(2, "0")}',
                  style: const TextStyle(
                    fontFamily: Face.body,
                    fontFamilyFallback: [Face.glyph],
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Tone.accent,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          if (next != null) ...[
            const SizedBox(height: Gap.xs),
            Text(
              'in ${_away(away!)} · ${station!.kind.godform}',
              style: const TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.caption,
                height: 1.4,
                color: Tone.faint,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _away(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours <= 0) return '${d.inMinutes}m';
    return '${hours}h ${minutes}m';
  }
}
