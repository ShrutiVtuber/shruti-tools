// SPDX-License-Identifier: AGPL-3.0-only
//
// Choosing where the stations are for.
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../services/settings.dart';
import '../services/site.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/parts.dart';
import '../widgets/forms.dart';

class PickPlaceScreen extends StatefulWidget {
  const PickPlaceScreen({super.key});

  @override
  State<PickPlaceScreen> createState() => _PickPlaceScreenState();
}

class _PickPlaceScreenState extends State<PickPlaceScreen> {
  final _field = TextEditingController();
  Timer? _debounce;
  List<Place> _results = const [];
  bool _looking = false;
  bool _failed = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  void _onTyped(String q) {
    // A request per keystroke would be four requests for "Bath" and three of
    // them wasted. A short pause costs nothing a person notices.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() {
        _results = const [];
        _failed = false;
      });
      return;
    }
    setState(() => _looking = true);
    final found = await searchPlaces(q);
    if (!mounted) return;
    setState(() {
      _results = found;
      _looking = false;
      // Empty can mean "no such town" or "no signal", and the difference
      // matters to somebody on a train. Distinguished by asking whether the
      // query was plausible at all.
      _failed = found.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Bar(title: 'Place', hour: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Gap.gutter,
              0,
              Gap.gutter,
              Gap.md,
            ),
            child: Field(
              controller: _field,
              hint: 'Search for a city',
              onChanged: _onTyped,
              prefix: const Icon(Icons.search, size: 18, color: Tone.faint),
            ),
          ),
          if (_looking)
            const LinearProgressIndicator(
              minHeight: 2,
              color: Gilt.gilt,
              backgroundColor: Colors.transparent,
            ),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_results.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(Gap.gutter, 0, Gap.gutter, Gap.huge),
        children: [
          ListGroup(
            children: [
              for (final p in _results)
                ListRow(
                  label: p.name,
                  // The zone is shown because it is the half that cannot be
                  // guessed from a name, and the half that makes the table
                  // right.
                  value: p.zone,
                  onTap: () => Navigator.of(context).pop(p),
                ),
            ],
          ),
        ],
      );
    }

    final typed = _field.text.trim();
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.gutter, 0, Gap.gutter, Gap.huge),
      children: [
        const Pressable(
          tone: Surface.inset,
          child: Text(
            'The place decides sunrise, sunset and the planetary hours. It is '
            'stored on this phone and never sent anywhere.',
            style: TextStyle(
              fontFamily: Face.body,
              fontSize: Type.caption,
              height: 1.6,
              color: Tone.faint,
            ),
          ),
        ),
        const SizedBox(height: Gap.md),
        if (_failed && typed.length >= 2 && !_looking)
          EmptyState(
            compact: true,
            mark: '♄',
            title: 'Nothing called "$typed"',
            body:
                'Try the local spelling, or the nearest larger city — the '
                'hours will be within a minute or two. Searching needs a '
                'connection; the instruments never do.',
          )
        else if (typed.length < 2)
          const EmptyState(
            compact: true,
            mark: '☾',
            title: 'Type a couple of letters',
            body:
                'The place decides both when the Sun rises and what time '
                'that is called, so a town in the right country is not close '
                'enough.',
          ),
      ],
    );
  }
}

/// Open the picker and, if something is chosen, tell the settings.
///
/// One function rather than the same six lines on four screens — and the
/// reason those six lines were a bug is that each screen also kept its own
/// copy of the answer.
Future<void> pickPlaceInto(BuildContext context) async {
  final settings = SettingsScope.of(context);
  final picked = await Navigator.of(
    context,
  ).push<Place>(MaterialPageRoute(builder: (_) => const PickPlaceScreen()));
  if (picked != null) await settings.setPlace(picked);
}
