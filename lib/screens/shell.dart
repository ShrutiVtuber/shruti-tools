// SPDX-License-Identifier: AGPL-3.0-only
//
// The tabs.
//
// Two for now, and both are instruments. Her writing and her videos will be a
// third when the journal is mounted — deliberately not a stub in the bar
// meanwhile, because a tab that opens onto "coming soon" is worse than a tab
// that is not there yet.
import 'package:flutter/material.dart';

import 'chart.dart';
import 'home.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // IndexedStack rather than swapping the child: switching to the chart
        // and back should not lose a cast chart or re-run the stations, and a
        // tab that forgets what you did on it is a tab you stop using.
        child: IndexedStack(
          index: _tab,
          children: const [StationsScreen(), ChartScreen()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_twilight_outlined),
            selectedIcon: Icon(Icons.wb_twilight),
            label: 'Stations',
          ),
          NavigationDestination(
            icon: Icon(Icons.brightness_3_outlined),
            selectedIcon: Icon(Icons.brightness_3),
            label: 'Chart',
          ),
        ],
      ),
    );
  }
}
