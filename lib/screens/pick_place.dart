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
      appBar: const Bar(title: 'Where are you?'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.md),
            child: TextField(
              controller: _field,
              autofocus: true,
              onChanged: _onTyped,
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'City, or country',
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                filled: true,
                fillColor: Tone.inset,
                prefixIcon: const Icon(Icons.search, color: Tone.faint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Corner.sm),
                  borderSide: const BorderSide(color: Tone.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Corner.sm),
                  borderSide: const BorderSide(color: Tone.line),
                ),
              ),
            ),
          ),
          if (_looking)
            const LinearProgressIndicator(
              minHeight: 2,
              color: Tone.accent,
              backgroundColor: Colors.transparent,
            ),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_results.isNotEmpty) {
      return ListView.separated(
        itemCount: _results.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final p = _results[i];
          return ListTile(
            title: Text(p.name, style: Theme.of(context).textTheme.bodyLarge),
            // The zone is shown because it is the half that cannot be guessed
            // from a name, and the half that makes the table right.
            subtitle: Text(
              p.zone,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right, color: Tone.faint),
            onTap: () => Navigator.of(context).pop(p),
          );
        },
      );
    }
    if (_failed && _field.text.trim().length >= 2 && !_looking) {
      return _Note(
        'Nothing found for "${_field.text.trim()}".\n\n'
        'Searching needs a connection — the stations themselves do not. '
        'If you are offline, the place you last chose still works.',
      );
    }
    return const _Note(
      'Type a couple of letters.\n\n'
      'The place decides both when the sun rises and what time that is '
      'called, so a town in the right country is not close enough.',
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Gap.xl),
    child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
  );
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
