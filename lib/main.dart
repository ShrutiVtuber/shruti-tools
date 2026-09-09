// SPDX-License-Identifier: AGPL-3.0-only
//
// Shruti's Tools — a lite companion to shrutivtuber.com.
//
// What this app is for, in the order it matters:
//
//   1. The instruments, working offline. A chart and a station table are
//      arithmetic, and arithmetic does not need a server. The ephemeris is
//      bundled and every calculation happens on the phone.
//   2. Telling somebody she has gone live, while she is still live.
//   3. Her writing and her videos, without opening a browser.
//
// One and two are the reason it exists. Three is why somebody keeps it.
import 'package:flutter/material.dart';

import 'screens/shell.dart';
import 'services/ephemeris.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Before the first frame, because the home screen asks for today's stations
  // as it builds. It is a file copy and a library open — milliseconds — and
  // doing it here means no screen has to carry a "not ready yet" state.
  await startEphemeris();
  runApp(const ShrutiTools());
}

class ShrutiTools extends StatelessWidget {
  const ShrutiTools({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shruti's Tools",
      debugShowCheckedModeBanner: false,
      theme: shrutiTheme(),
      home: const Shell(),
    );
  }
}
