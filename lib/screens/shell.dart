// SPDX-License-Identifier: AGPL-3.0-only
//
// The tabs.
//
// Five tabs and the settings. Two of them hold a pair behind a segmented
// control rather than taking a slot each: Day is the stations and the planetary
// hours, Letters is the reckoning and the sigils. A bar holds about six before
// the labels stop being readable, and the practice room needed one. Her
// writing and her videos will be a tab when the journal is mounted;
// deliberately not a stub in the bar meanwhile, because a tab that opens onto
// "coming soon" is worse than a tab that is not there yet.
import 'package:flutter/material.dart';

import 'chart.dart';
import 'day.dart';
import 'landing.dart';
import 'practice.dart';
import 'letters.dart';
import 'settings.dart';

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_twilight_outlined),
            selectedIcon: Icon(Icons.wb_twilight),
            label: 'Sky',
          ),
          NavigationDestination(
            icon: Icon(Icons.brightness_3_outlined),
            selectedIcon: Icon(Icons.brightness_3),
            label: 'Chart',
          ),
          NavigationDestination(
            icon: Icon(Icons.abc_outlined),
            selectedIcon: Icon(Icons.abc),
            label: 'Letters',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
