// SPDX-License-Identifier: AGPL-3.0-only
//
// What somebody posts outlives their account, and they are told before the
// first post.
//
// ⚠ The site refuses a reading or a comment with 428 until the person has
// agreed that, if they delete their account, their public work stays up with
// their name taken off. An app that did not know that answer would show
// "That did not work (428)" and nothing else: a post that could never go
// through, with no way to find out why.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), ' ');

void main() {
  final service = _code('lib/services/practice.dart');
  final widget = _code('lib/widgets/publish_agreement.dart');

  test('a 428 is its own trouble, not a generic failure', () {
    final at428 = service.indexOf('statusCode == 428');
    final atAny = service.indexOf('statusCode >= 400');
    expect(at428, greaterThan(-1));
    expect(
      at428,
      lessThan(atAny),
      reason: 'the generic branch would catch it first',
    );
    expect(service.contains('throw NeedsPublishAgreement('), isTrue);
  });

  test('the words shown are the words the site files', () {
    expect(service.contains("'/api/account/consents'"), isTrue);
    expect(service.contains("['publish']"), isTrue);
    expect(service.contains("'kind': 'publish'"), isTrue);
    expect(service.contains("'source': 'app'"), isTrue);
  });

  test('never ticked for them, and nothing is agreed without the tick', () {
    expect(widget.contains('var ticked = false;'), isTrue);
    expect(widget.contains('onPressed: ticked ?'), isTrue);
  });

  test('a post and a comment both ask before going public', () {
    expect(
      _code(
        'lib/screens/practice_write.dart',
      ).contains('publishing(context, _room, () => _room.submit(id))'),
      isTrue,
    );
    expect(
      _code('lib/screens/practice_work.dart').contains('_room.say(widget.id'),
      isTrue,
    );
    expect(
      RegExp(
        r'publishing\(\s*context,\s*_room,\s*\(\) => _room\.say\(',
      ).hasMatch(_code('lib/screens/practice_work.dart')),
      isTrue,
    );
  });
}
