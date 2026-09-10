// SPDX-License-Identifier: AGPL-3.0-only
//
// The planetary hours of the day you are in.
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/chart.dart' show bodyGlyphs;
import '../services/ephemeris.dart';
import '../services/hours.dart';
import '../services/settings.dart';
import '../services/shell_state.dart';
import '../services/stations.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/data.dart';
import '../widgets/parts.dart';
import 'sunrise.dart';

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
    final shell = ShellScope.of(context);
    final hours = hoursFor(
      DateTime.now(),
      place.lat,
      place.lon,
      convention: settings.convention,
    );
    final standing = hourNow(hours, DateTime.now());
    final day = hours.where((h) => h.byDay).toList();
    final night = hours.where((h) => !h.byDay).toList();

    String clock(DateTime t) =>
        '${place.tell(t).hour.toString().padLeft(2, "0")}:'
        '${place.tell(t).minute.toString().padLeft(2, "0")}';

    Reference table(List<PlanetaryHour> set, String caption) => Reference(
      caption: caption,
      columns: const [
        Heading(label: '#', flex: 1),
        Heading(label: 'From', numeric: true, flex: 2),
        Heading(label: 'To', numeric: true, flex: 2),
        Heading(label: 'Ruler', flex: 4),
        Heading(label: 'Length', numeric: true, flex: 2),
      ],
      rows: [
        for (final h in set)
          Line([
            Cell('${h.index}'),
            Cell(clock(h.from)),
            Cell(clock(h.to)),
            Cell('${bodyGlyphs[h.ruler] ?? ""}\uFE0E ${h.ruler}'),
            Cell('${h.to.difference(h.from).inMinutes} m'),
          ], now: standing != null && identical(h, standing)),
      ],
    );

    final dayLength = day.isEmpty
        ? null
        : day.first.to.difference(day.first.from).inMinutes;
    final nightLength = night.isEmpty
        ? null
        : night.first.to.difference(night.first.from).inMinutes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Gap.gutterDense,
        Gap.md,
        Gap.gutterDense,
        Gap.huge,
      ),
      children: [
        if (hours.isEmpty)
          const EmptyState(
            mark: '☉',
            title: 'No hours to divide here today',
            body:
                'The planetary hours are twelfths of the daylight and '
                'twelfths of the night. Where the Sun does not set, there is '
                'nothing to divide.',
          )
        else ...[
          Pressable(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (shell?.ruler != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: HourChip(
                      ruler: shell!.ruler!,
                      ordinal: standing?.index,
                      diurnal: standing?.byDay ?? true,
                      ends: standing == null ? null : clock(standing.to),
                    ),
                  ),
                  const SizedBox(height: Gap.md),
                ],
                if (day.isNotEmpty) ...[
                  Fact(
                    mark: '☉',
                    label: 'Sunrise',
                    value: clock(day.first.from),
                  ),
                  Fact(mark: '☉', label: 'Sunset', value: clock(day.last.to)),
                ],
                if (dayLength != null)
                  Fact(label: 'Day hour', value: '$dayLength minutes'),
                if (nightLength != null)
                  Fact(label: 'Night hour', value: '$nightLength minutes'),
                const SizedBox(height: Gap.sm),
                Container(
                  padding: const EdgeInsets.only(top: Gap.sm),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Tone.line)),
                  ),
                  child: GestureDetector(
                    onTap: () => showSunriseSheet(context),
                    child: Text(
                      'Sunrise convention: '
                      '${settings.convention == RiseConvention.visibleDisc ? "upper limb" : "centre of the disc"}'
                      ' — change',
                      style: const TextStyle(
                        fontFamily: Face.body,
                        fontFamilyFallback: [Face.glyph],
                        fontSize: Type.caption,
                        height: 1,
                        fontWeight: FontWeight.w500,
                        color: Tone.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          if (day.isNotEmpty) table(day, 'Day hours · ${_today(place)}'),
          if (night.isNotEmpty) ...[
            const SizedBox(height: Gap.md),
            table(night, 'Night hours · ${_today(place)}'),
          ],
        ],

        const SizedBox(height: Gap.xxl),
        Provenance(
          facts: [
            ('engine', engineVersion),
            ('computed', 'on this phone · nothing sent, nothing stored'),
            (
              'the rule',
              'a twelfth of the daylight, then a twelfth of the night — so an '
                  'hour is 45 minutes in December and 75 in June',
            ),
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
    );
  }

  static String _today(Place place) {
    const months = [
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
    ];
    final t = place.tell(DateTime.now().toUtc());
    return '${t.day} ${months[t.month - 1]}';
  }
}
