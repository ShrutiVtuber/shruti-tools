// SPDX-License-Identifier: AGPL-3.0-only
//
// A password is typed in dots.
//
// ⚠ **It was not, until 12 September 2026.** The `Field` widget had no way to
// obscure anything, so every password in the app was typed in the clear — and
// she found it by watching the screen recording made for App Review, where her
// own password is legible on the video.
//
// ⚠ Obscuring also turns off autocorrect and suggestions, which matters for a
// reason that is not obvious: a keyboard offering to complete a password puts
// it in the strip above the keys, where the next screenshot catches it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), ' ')
    .replaceAll(RegExp(r'^\s*///.*$', multiLine: true), ' ');

void main() {
  test('the field can keep a secret', () {
    final forms = _code('lib/widgets/forms.dart');
    expect(forms.contains('obscureText: secret'), isTrue);
    expect(forms.contains('autocorrect: !secret'), isTrue);
    expect(forms.contains('enableSuggestions: !secret'), isTrue);
  });

  test('every password field asks it to', () {
    // ⚠ Walks the whole app rather than one screen: a second password field
    // added later, somewhere else, must not quietly be in the clear.
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final source = _code(f.path);
      for (final match in RegExp(
        r'Field\((?:[^()]|\([^()]*\))*?\)',
      ).allMatches(source)) {
        final block = match.group(0)!;
        final looksLikeOne =
            block.contains("label: 'Password'") ||
            block.contains('controller: _password');
        if (looksLikeOne && !block.contains('secret: true')) {
          offenders.add('${f.path}: $block');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'a password field is shown in the clear:\n${offenders.join("\n")}',
    );
  });
}
