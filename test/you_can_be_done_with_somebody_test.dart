// SPDX-License-Identifier: AGPL-3.0-only
//
// Blocking a person, and the four ways it could be here and not work.
//
// ⚠ **This is an App Store requirement, not a preference.** Apple's guideline
// 1.2 requires an app carrying other people's writing to offer a filter, a way
// to report, published contact details, and the ability to block an abusive
// user. The room had the first three. This was the missing one, and a missing
// 1.2 item is found by a reviewer rather than by a test — which is why these
// exist.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String get _service => File('lib/services/practice.dart').readAsStringSync();
String get _work => File('lib/screens/practice_work.dart').readAsStringSync();

void main() {
  test('the room knows how to block, unblock, and list', () {
    for (final method in ['blockPerson', 'unblockPerson', 'blocked()']) {
      expect(
        _service.contains(method),
        isTrue,
        reason: 'the practice service has no $method',
      );
    }
  });

  test('a work says who wrote it, and a remark does too', () {
    // ⚠ Without the id there is a name to show and nothing to act on.
    expect(_service.contains('final int? authorId;'), isTrue);
    expect(
      'final int? authorId;'.allMatches(_service).length,
      2,
      reason: 'only one of Work and Remark carries its author id',
    );
  });

  test('the id is nullable, because Discord has no account behind it', () {
    // ⚠ A bridged comment is somebody on Discord. Nobody signed up, so there
    // is nobody to block — and `int?` is what says so in the type system
    // rather than in a comment somebody may delete.
    expect(_service.contains('final int authorId;'), isFalse);
  });

  test('the block button is not drawn when it could not work', () {
    expect(
      _work.contains('if (work.authorId != null)'),
      isTrue,
      reason: 'a block button is offered for a work with no author id',
    );
  });

  test('blocking is confirmed, and says where the undo lives', () {
    expect(_work.contains('_askBlock'), isTrue);
    expect(
      _work.contains('undo it in Settings'),
      isTrue,
      reason: 'the confirmation does not say how to undo it',
    );
  });

  test('the undo exists and is reachable from Settings', () {
    final settings = File('lib/screens/settings.dart').readAsStringSync();
    expect(settings.contains('BlockedScreen'), isTrue);
    final screen = File('lib/screens/blocked.dart').readAsStringSync();
    expect(screen.contains('unblockPerson'), isTrue);
  });

  test('the list says a block is not a report', () {
    // ⚠ A screen headed only "Blocked" reads as a record of complaints made
    // to her. It is not one: nobody was told and nothing moved for anybody
    // else, and somebody deciding whether to press the button deserves to
    // know which of the two they are doing.
    final screen = File('lib/screens/blocked.dart').readAsStringSync();
    expect(screen.contains('Nobody was told'), isTrue);
  });
}
