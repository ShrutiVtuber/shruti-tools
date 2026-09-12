// SPDX-License-Identifier: AGPL-3.0-only
//
// An account made in the app can be deleted in the app.
//
// ⚠ **Apple's guideline 5.1.1(v), and version 1.0.0 was rejected without it.**
// An app that lets somebody create an account must let them delete it there —
// not on a website, not by writing to anybody. The reviewer asked to be shown
// the flow on video, which is hard to film when it does not exist.
//
// ⚠ It is also right on its own terms: an account you can open in the app and
// can only close in a browser is a door that opens one way.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    // ⚠ Comments out, every time. Four guards in this project have passed on
    // deleted code by finding the word in the prose that explained it.
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), ' ');

void main() {
  final service = _code('lib/services/account.dart');
  final screen = _code('lib/screens/account.dart');

  test('the service can delete the account', () {
    expect(service.contains('deleteAccount'), isTrue);
    expect(
      service.contains("http\n          .delete(_at('/api/account/')") ||
          service.contains(".delete(_at('/api/account/')"),
      isTrue,
      reason: 'nothing calls the delete endpoint',
    );
  });

  test('deleting signs the phone out too', () {
    // ⚠ An account that is gone must not leave a phone claiming to be signed
    // in to it — every later call would 401 against a screen saying otherwise.
    // ⚠ Sliced on CODE, not on a doc comment: `_code` strips comments, so a
    // boundary written as `/// Ask the site` is not there to be found. That
    // mistake made this test fail on correct code, which is the better way
    // round but still a mistake.
    final body = service.substring(service.indexOf('deleteAccount'));
    final method = body.substring(0, body.indexOf('Future<void> refresh'));
    expect(method.contains('signOut()'), isTrue);
  });

  test('a dead token counts as already deleted', () {
    // ⚠ 401 means the account is gone or the session expired. Treating it as
    // a failure would leave somebody pressing delete on an account that is
    // already not there, and being told it did not work.
    final body = service.substring(service.indexOf('deleteAccount'));
    expect(body.contains('401'), isTrue);
  });

  test('the door is on the account screen', () {
    expect(screen.contains('Delete this account'), isTrue);
    expect(screen.contains('_askDelete'), isTrue);
  });

  test('it cannot be done by one stray tap', () {
    // ⚠ Immediate, irreversible, and it takes the nativity with it. A single
    // confirm button under a thumb is not enough — the word has to be typed.
    expect(
      screen.contains("== 'DELETE'"),
      isTrue,
      reason: 'deleting an account needs more than one tap to confirm',
    );
    // And the confirm button stays dead until it is typed.
    expect(screen.contains('ready ?'), isTrue);
  });

  test('the warning says what actually goes', () {
    for (final promised in ['nativity', 'monthly letter', 'cannot be']) {
      expect(
        screen.toLowerCase().contains(promised.toLowerCase()),
        isTrue,
        reason: 'the confirmation does not mention $promised',
      );
    }
  });
}
