// SPDX-License-Identifier: AGPL-3.0-only
//
// The app's half of confirming an address.
//
// ⚠ Her decision, 12 September 2026: "we need the email verification — on the
// site and on the app." Signing up no longer signs anybody in; a link is sent
// and following it does both.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), ' ');

void main() {
  final service = _code('lib/services/account.dart');
  final screen = _code('lib/screens/account.dart');

  test('the app can ask for the link again', () {
    expect(service.contains('resendConfirmation'), isTrue);
    expect(service.contains('/api/account/verify/resend'), isTrue);
  });

  test('a refusal carries its status, not just a sentence', () {
    // ⚠ Matching on the wording would break the first time somebody edits the
    // wording. The status is what the screen decides on.
    expect(service.contains('this.status'), isTrue);
    expect(service.contains('needsConfirming'), isTrue);
    expect(service.contains('status: r.statusCode'), isTrue);
  });

  test('an unconfirmed sign-in offers the way out', () {
    // ⚠ That person has the RIGHT password and is being told it will not
    // work. Explaining why without offering the fix is half an answer.
    expect(screen.contains('e.needsConfirming'), isTrue);
    expect(screen.contains('Send the link again'), isTrue);
    expect(screen.contains('_resend('), isTrue);
  });

  test('signing up says to check the email, not that you are in', () {
    expect(screen.contains('Check your email'), isTrue);
    // The old wording explained a privacy answer. It is now the ordinary path.
    expect(
      screen.contains('If that address can have an account'),
      isFalse,
      reason: 'the sign-up message still describes the old behaviour',
    );
  });

  test('the resend button is offered after signing up too', () {
    // Twenty minutes is short, and the screen that says "check your email" is
    // exactly where somebody stands when it runs out.
    final go = screen.substring(screen.indexOf('SignUpOutcome.checkEmail'));
    expect(go.substring(0, 400).contains('_canResend = true'), isTrue);
  });
}
