// SPDX-License-Identifier: AGPL-3.0-only
//
// The tabs, and the state the whole shell is in.
//
// Six tabs. Two of them hold a pair behind a segmented control rather than
// taking a slot each: Sky is the stations and the planetary hours, Letters is
// the reckoning and the sigils. A bar holds about six before the labels stop
// being readable, and the practice room needed one. Her writing and her videos
// will be a tab when the journal is mounted; deliberately not a stub in the
// bar meanwhile, because a tab that opens onto "coming soon" is worse than a
// tab that is not there yet.
//
// ⚠ The selected tab is marked THREE ways — a gilt hem above it, a filled
// icon, and a full-ink label. Colour is never the only signal, and a gold hem
// on its own would fail for the people the rule exists for.
import 'package:flutter/material.dart';

import '../services/settings.dart';
import '../services/shell_state.dart';
import '../theme/motion.dart';
import '../theme/tokens.dart';
import '../widgets/motifs.dart';
import 'chart.dart';
import 'day.dart';
import 'landing.dart';
import 'letters.dart';
import 'practice.dart';
import 'settings.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;
  ShellState? _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final place = SettingsScope.of(context).place;
    // ⚠ Built here rather than in initState: the place comes from an
    // InheritedNotifier, and reaching for one of those during initState throws.
    if (_state == null) {
      _state = ShellState(where: place);
    } else {
      _state!.place = place;
    }
  }

  @override
  void dispose() {
    _state?.dispose();
    super.dispose();
  }

  static const _tabs = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.wb_twilight_outlined, Icons.wb_twilight, 'Sky'),
    (Icons.brightness_3_outlined, Icons.brightness_3, 'Chart'),
    (Icons.abc_outlined, Icons.abc, 'Letters'),
    (Icons.forum_outlined, Icons.forum, 'Practice'),
    (Icons.tune_outlined, Icons.tune, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = _state!;
    return ShellScope(
      state: state,
      child: AnimatedBuilder(
        animation: state,
        builder: (context, _) => Ornament(
          colour: state.ornament,
          child: Scaffold(
            body: SafeArea(
              // IndexedStack rather than swapping the child: switching to the
              // chart and back should not lose a cast chart or re-run the
              // stations, and a tab that forgets what you did on it is a tab
              // you stop using.
              child: IndexedStack(
                index: _tab,
                children: const [
                  LandingScreen(),
                  SkyScreen(),
                  ChartScreen(),
                  LettersScreen(),
                  PracticeScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
            bottomNavigationBar: _TabBar(
              tab: _tab,
              onTab: (i) => setState(() => _tab = i),
              tabs: _tabs,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.tab, required this.onTab, required this.tabs});

  final int tab;
  final ValueChanged<int> onTab;
  final List<(IconData, IconData, String)> tabs;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Tone.card,
      border: Border(top: BorderSide(color: Tone.line)),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: Target.tabBar,
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _Tab(
                  icon: tabs[i].$1,
                  filled: tabs[i].$2,
                  label: tabs[i].$3,
                  chosen: i == tab,
                  onTap: () => onTab(i),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.filled,
    required this.label,
    required this.chosen,
    required this.onTap,
  });

  final IconData icon;
  final IconData filled;
  final String label;
  final bool chosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: chosen,
    button: true,
    label: label,
    child: InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          // The gilt hem — the mark of the selected tab, and the same hairline
          // that sits under the app bar, so the shell is hemmed top and bottom
          // in whatever colour the hour (or the stream) has made it.
          if (chosen) const Positioned(top: 0, left: 0, right: 0, child: Hem()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: Motion.of(context, Motion.quick),
                  child: Icon(
                    chosen ? filled : icon,
                    key: ValueKey(chosen),
                    size: 22,
                    color: chosen ? Tone.ink : Tone.faint,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: Face.body,
                    fontSize: 11.5,
                    fontWeight: chosen ? FontWeight.w600 : FontWeight.w400,
                    color: chosen ? Tone.ink : Tone.faint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
