// SPDX-License-Identifier: AGPL-3.0-only
//
// The app points at the site. It never points at a way to pay.
//
// ⚠ **Her rule first, and Apple's second.** "Nothing takes money inside the
// app — support, shop and classes open her own checkout in a browser" was
// decided long before any of this. Apple's guideline 3.1.1 then says an app
// may not carry buttons or links directing people to a way of buying digital
// things outside its own store, and the Swara tiers unlock a members channel,
// the schedule a day early and monthly notes. Modest, and still digital.
//
// Taking that through Apple instead would mean StoreKit subscriptions, the
// paid-apps agreement, 15-30%, and two subscription systems for one tier to
// be reconciled forever. The link went instead.
//
// ⚠ Linking to her own website is NOT what 3.1.1 prohibits. A call to action
// to buy is. So one neutral row remains and the site does the rest.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every Dart file in the app, comments stripped.
///
/// ⚠ Stripped, because the paragraphs above name the very paths they forbid,
/// and a guard that greps raw source would find them there — a trap this
/// project has now walked into four separate times.
Iterable<String> _sources() sync* {
  for (final f in Directory('lib').listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart')) {
      yield f
          .readAsStringSync()
          .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
          .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), ' ');
    }
  }
}

void main() {
  test('nothing links to a page that charges', () {
    final offenders = <String>[];
    for (final source in _sources()) {
      for (final path in ['/support', '/shop', '/classes']) {
        if (source.contains("siteOrigin$path") ||
            source.contains("shrutivtuber.com$path")) {
          offenders.add(path);
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'the app links to ${offenders.join(", ")} — guideline 3.1.1',
    );
  });

  test('no purchase machinery was added instead', () {
    // ⚠ The other way to fail this: someone "fixes" 3.1.1 by adding in-app
    // purchase. That is a business decision with tax paperwork attached and
    // it is not one to arrive by accident in a pull request.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final shop in ['in_app_purchase', 'purchases_flutter', 'stripe']) {
      expect(
        pubspec.contains(shop),
        isFalse,
        reason: 'the app has grown a payment library ($shop)',
      );
    }
  });

  test('the site is still reachable from the app', () {
    // ⚠ The fix must not be "remove everything". Somebody in the app should
    // still be able to find the schedule, the horoscopes and the rest.
    final settings = File('lib/screens/settings.dart').readAsStringSync();
    expect(settings.contains('shrutivtuber.com'), isTrue);
    expect(settings.contains('url: siteOrigin'), isTrue);
  });
}
