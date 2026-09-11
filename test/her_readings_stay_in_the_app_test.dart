// SPDX-License-Identifier: AGPL-3.0-only
//
// Where her horoscopes are read, and where they are not.
//
// Her words on 10 September 2026: readers "need to be able to read all my
// horoscopes for the current cycle in the app itself — if they want to see an
// archive one (for a previous month or week) then they can be redirected to
// the website."
//
// ⚠ **This is a decision about where traffic goes, not a technical limit.** The
// endpoint would serve any period just as happily, which is exactly why the
// boundary has to be drawn deliberately and held by a test: the easy mistake is
// to make the app read everything, which quietly removes the reason to visit
// the site at all.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String p) => File(p).readAsStringSync();

/// Source with comments stripped — every check below looks for a token this
/// file's own prose also contains.
String _code(String s) => s
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), ' ');

void main() {
  final home = _code(_read('lib/screens/landing.dart'));
  final screen = _code(_read('lib/screens/horoscopes.dart'));
  final service = _code(_read('lib/services/site.dart'));

  test('the current period is read in the app, not launched at the site', () {
    expect(
      home.contains('HoroscopesScreen'),
      isTrue,
      reason: 'Home never opens the in-app reader',
    );
    // ⚠ The ACTION specifically, not merely that the screen is mentioned
    // somewhere. The first version of this check was satisfied by the reading
    // CARDS using the in-app reader while "All twelve" still launched the
    // website — a half-fix that passed.
    expect(
      RegExp(
        r"action:\s*'All twelve',[\s\S]{0,400}?onAction:\s*_readHerReadings",
      ).hasMatch(home),
      isTrue,
      reason:
          '"All twelve" does not open the in-app reader, which sends '
          'somebody out of the app to read the thing the app exists to carry',
    );
  });

  test('an older reading still goes to the site', () {
    // ⚠ The other half. An app that reads the archive too is an app that
    // removes the reason to visit the site, which is the opposite of what she
    // asked for.
    expect(
      home.contains('currentCovers('),
      isTrue,
      reason:
          'nothing compares a reading against the current period, so '
          'either everything opens in the app or everything opens the site',
    );
    expect(
      RegExp(r"_open\('/horoscopes/").hasMatch(home),
      isTrue,
      reason: 'an archive reading has no route to the website',
    );
  });

  test('the link out of the app says where it goes', () {
    // ⚠ On Android a browser opens over the app with no warning, which reads
    // as the app crashing.
    expect(
      screen.contains('shrutivtuber.com'),
      isTrue,
      reason: 'the archive link does not name where it goes',
    );
  });

  test('an unwritten sign is not shown as a blank reading', () {
    // Saying she has written nothing for you is different from saying she has
    // not written it yet.
    expect(
      service.contains("r['published']"),
      isTrue,
      reason:
          'unpublished signs are not filtered out, so a sign she has not '
          'written appears as an empty reading with her name on it',
    );
  });

  test('unreachable and unwritten are told apart', () {
    // ⚠ Telling somebody she has written nothing when the truth is that the
    // network is gone is the one that makes her look absent.
    expect(
      screen.contains('out of reach'),
      isTrue,
      reason: 'a network failure is shown as her having written nothing',
    );
    expect(
      screen.contains('Nothing written'),
      isTrue,
      reason: 'an empty period has no state of its own',
    );
  });
}
