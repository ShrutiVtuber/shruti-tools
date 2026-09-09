// SPDX-License-Identifier: AGPL-3.0-only
//
// Letter-reckoning, and the languages it needs.
//
// The chooser is part of the tool rather than hidden in settings, because
// until a language is downloaded there is nothing to reckon with — and the
// sizes are on the buttons because a phone about to spend four megabytes of
// somebody's data should say so before it does.
import 'package:flutter/material.dart';

import '../services/isopsephy.dart';
import '../services/packs.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';

class IsopsephyScreen extends StatefulWidget {
  const IsopsephyScreen({super.key});

  @override
  State<IsopsephyScreen> createState() => _IsopsephyScreenState();
}

class _IsopsephyScreenState extends State<IsopsephyScreen> {
  final _field = TextEditingController();

  List<PackInfo> _offered = const [];
  Set<String> _installed = {};
  List<NumberSystem> _systems = const [];
  NumberSystem? _system;

  Reckoning? _result;
  List<Match> _found = const [];
  bool _looking = false;
  String? _busy;
  String? _failed;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final offered = await availablePacks();
    final installed = await installedPacks();
    final systems = await installedSystems();
    if (!mounted) return;
    setState(() {
      _offered = offered;
      _installed = installed;
      _systems = systems;
      // Keep the chosen system if it is still here; otherwise take the first.
      _system =
          systems.where((s) => s.id == _system?.id).firstOrNull ??
          (systems.isNotEmpty ? systems.first : null);
    });
  }

  Future<void> _install(PackInfo pack) async {
    setState(() {
      _busy = pack.file;
      _failed = null;
    });
    final why = await installPack(pack);
    if (!mounted) return;
    setState(() {
      _busy = null;
      // The reason, not a shrug. A download fails because the site is
      // unreachable, because there is no room, or because the container is not
      // what it claims — and "it didn't work" is none of those.
      _failed = why;
    });
    await _refresh();
  }

  Future<void> _remove(PackInfo pack) async {
    await removePack(pack.file);
    await _refresh();
  }

  Future<void> _reckon() async {
    final system = _system;
    if (system == null) return;
    final r = system.reckon(_field.text);
    setState(() {
      _result = r;
      _found = const [];
      _looking = r.total > 0;
    });
    if (r.total == 0) return;
    final found = await wordsAt(system.id, r.total);
    if (!mounted) return;
    setState(() {
      _found = found;
      _looking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final system = _system;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
      children: [
        Text('Isopsephy', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: Gap.xs),
        Text(
          'Letter-reckoning, each script by its own table. Matches are only '
          'ever found inside one system.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Gap.xl),

        if (system == null) ...[
          const Eyebrow('First, a language'),
          const SizedBox(height: Gap.sm),
          _Note(
            _offered.isEmpty
                ? 'Nothing to choose from — the site could not be reached. '
                      'Languages are downloaded once and work offline afterwards.'
                : 'Nothing is downloaded yet. A letter table is a few '
                      'kilobytes; the word lists are the large part, and you only '
                      'need the ones you actually read.',
          ),
        ] else ...[
          _SystemPicker(
            systems: _systems,
            chosen: system,
            onChanged: (s) => setState(() {
              _system = s;
              _result = null;
              _found = const [];
            }),
          ),
          const SizedBox(height: Gap.md),
          TextField(
            controller: _field,
            textDirection: system.rightToLeft
                ? TextDirection.rtl
                : TextDirection.ltr,
            style: Theme.of(context).textTheme.bodyLarge,
            onSubmitted: (_) => _reckon(),
            decoration: InputDecoration(
              hintText: system.script,
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              filled: true,
              fillColor: Tone.inset,
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
          const SizedBox(height: Gap.md),
          FilledButton(onPressed: _reckon, child: const Text('Reckon')),
          if (_result != null) ...[
            const SizedBox(height: Gap.xl),
            _Total(result: _result!, system: system),
            const SizedBox(height: Gap.lg),
            if (_looking)
              const Center(child: CircularProgressIndicator(color: Tone.accent))
            else if (_found.isNotEmpty) ...[
              Eyebrow('Also ${_result!.total}'),
              const SizedBox(height: Gap.sm),
              _Words(found: _found, rightToLeft: system.rightToLeft),
            ] else if (_result!.total > 0)
              _Note(
                'Nothing at ${_result!.total} in the lists you have. Adding a '
                'word list for this script would give it more to look in.',
              ),
          ],
        ],

        const SizedBox(height: Gap.xxl),
        const Eyebrow('Languages'),
        const SizedBox(height: Gap.sm),
        if (_failed != null) ...[
          _Note(_failed!, bad: true),
          const SizedBox(height: Gap.sm),
        ],
        ..._offered.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: Gap.sm),
            child: _PackRow(
              pack: p,
              installed: _installed.contains(p.file),
              busy: _busy == p.file,
              onInstall: () => _install(p),
              onRemove: () => _remove(p),
            ),
          ),
        ),
        if (_offered.isEmpty)
          _Note(
            'The list of languages needs a connection. Anything already '
            'downloaded still works.',
          ),
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _SystemPicker extends StatelessWidget {
  const _SystemPicker({
    required this.systems,
    required this.chosen,
    required this.onChanged,
  });

  final List<NumberSystem> systems;
  final NumberSystem chosen;
  final ValueChanged<NumberSystem> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final s in systems)
        ChoiceChip(
          label: Text(s.script.isEmpty ? s.name : s.script),
          selected: s.id == chosen.id,
          onSelected: (_) => onChanged(s),
          backgroundColor: Tone.card,
          selectedColor: Tone.accentWash,
          side: BorderSide(color: s.id == chosen.id ? Tone.accent : Tone.line),
          labelStyle: TextStyle(
            fontFamily: Face.body,
            fontSize: 14,
            color: s.id == chosen.id ? Tone.accent : Tone.soft,
          ),
        ),
    ],
  );
}

class _Total extends StatelessWidget {
  const _Total({required this.result, required this.system});

  final Reckoning result;
  final NumberSystem system;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(Gap.lg),
    decoration: BoxDecoration(
      color: Tone.card,
      borderRadius: BorderRadius.circular(Corner.md),
      border: Border.all(color: Tone.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(system.name),
        const SizedBox(height: Gap.sm),
        Text(
          '${result.total}',
          style: Theme.of(
            context,
          ).textTheme.displaySmall!.copyWith(color: Tone.accent),
        ),
        const SizedBox(height: Gap.xs),
        Text(
          '${result.counted.length} letter'
          '${result.counted.length == 1 ? "" : "s"} counted',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        // Not swallowed. A Latin A in a Greek reckoning looks exactly like
        // Alpha and is worth nothing, and the total gives no sign of it.
        if (result.ignored.isNotEmpty) ...[
          const SizedBox(height: Gap.sm),
          Text(
            'No value in this system: ${result.ignored.join(" ")}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Tone.rose),
          ),
        ],
      ],
    ),
  );
}

class _Words extends StatelessWidget {
  const _Words({required this.found, required this.rightToLeft});

  final List<Match> found;
  final bool rightToLeft;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Tone.card,
      borderRadius: BorderRadius.circular(Corner.md),
      border: Border.all(color: Tone.line),
    ),
    child: Column(
      children: [
        for (var i = 0; i < found.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: Gap.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: rightToLeft
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Text(
                    found[i].word,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (found[i].gloss.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    found[i].gloss,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 2),
                // Which corpus, because a match from the Hebrew Bible and one
                // from a 1912 index of Crowley's are different claims.
                Text(
                  found[i].corpus,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

class _PackRow extends StatelessWidget {
  const _PackRow({
    required this.pack,
    required this.installed,
    required this.busy,
    required this.onInstall,
    required this.onRemove,
  });

  final PackInfo pack;
  final bool installed;
  final bool busy;
  final VoidCallback onInstall;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Gap.md),
    decoration: BoxDecoration(
      color: Tone.card,
      borderRadius: BorderRadius.circular(Corner.sm),
      border: Border.all(color: installed ? Tone.lineStrong : Tone.line),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pack.name, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(
                // The size is the point of the row. Somebody choosing between
                // Greek and Hebrew is choosing between 4.3MB and 260KB, and
                // the names do not say so.
                '${pack.isTable ? "letter values" : "word list"} · ${pack.size}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: Gap.sm),
        if (busy)
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Tone.accent,
            ),
          )
        else
          TextButton(
            onPressed: installed ? onRemove : onInstall,
            child: Text(installed ? 'Remove' : 'Get'),
          ),
      ],
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text, {this.bad = false});

  final String text;
  final bool bad;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: bad ? Tone.live : Tone.soft),
  );
}
