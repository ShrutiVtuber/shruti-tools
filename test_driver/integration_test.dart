// SPDX-License-Identifier: AGPL-3.0-only
//
// The host half of a driven integration run.
//
// `flutter test integration_test` cannot bring a picture back: it uninstalls
// the app when it finishes, so anything the test wrote to the phone is gone
// before anybody can look. Driven with `flutter drive`, screenshots come back
// over the wire and land here, which is the only way to actually SEE what the
// app drew rather than to count its pixels and hope.
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot:
      (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final file = File('build/shots/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes, flush: true);
        stdout.writeln('shot: ${file.path}');
        return true;
      },
);
