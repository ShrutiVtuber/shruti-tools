// SPDX-License-Identifier: AGPL-3.0-only
//
// Her drawings — which may not be there.
//
// ⚠ **Every placement has a designed art-absent state, and that is not a
// placeholder.** It is the state this app ships in until she has drawn the
// piece, AND the state a lawful fork ships in forever: the code is AGPL, the
// artwork is not, so a fork must replace every drawing and the app has to
// look finished with none of them.
//
// So the question "is there art here?" is asked once, at startup, and answered
// the same way everywhere afterwards. A screen never guesses, and never draws
// a broken-image box.
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// The slots, by the file names the artwork spec asks for — so a drawing lands
/// without anybody renaming it.
enum Art {
  portraitOffline('portrait-offline.png'),
  portraitLive('portrait-live.png'),
  emptyPractice('empty-practice.png'),
  emptyOffline('empty-offline.png'),
  emptyUnwritten('empty-unwritten.png'),
  liveBand('live-band.png'),
  wordmarkNight('wordmark-night.png');

  const Art(this.file);

  final String file;

  String get path => 'assets/art/$file';
}

/// Which of them actually exist in this build.
///
/// ⚠ Asked by TRYING to load, because Flutter has no "does this asset exist".
/// Once, at startup, into a set — a try/catch inside a build method would run
/// on every frame and swallow real errors along with the absence.
abstract final class Drawings {
  static Set<Art> _present = const {};

  static Future<void> look() async {
    final found = <Art>{};
    for (final art in Art.values) {
      try {
        await rootBundle.load(art.path);
        found.add(art);
      } catch (_) {
        // Not there. That is a designed state, not a failure — and the throw
        // is a FlutterError from the asset bundle, which lives in foundation;
        // catching it by name here would drag the whole of it in for one word.
      }
    }
    _present = found;
  }

  static bool has(Art art) => _present.contains(art);

  /// The image to draw, or null — which every placement knows how to handle.
  static AssetImage? of(Art art) =>
      _present.contains(art) ? AssetImage(art.path) : null;
}
