// SPDX-License-Identifier: AGPL-3.0-only
//
// Which engine answers.
//
// ⚠ **This is the ONLY file in the app that names an implementation.**
// Everything else asks `sky` and does not know or care what is behind it. That
// is what makes the iOS variant a one-file change rather than an excavation,
// and what will make deleting the whole arrangement easy when the commercial
// licence is bought and both platforms go back to one engine.
//
// ⚠ A runtime switch would not be enough on its own: a package listed in
// pubspec.yaml has its native side compiled in whether or not anything calls
// it, so the iOS build must not merely avoid the Swiss implementation — it must
// not contain it. `tool/make_ios_variant.sh` rewrites this file and removes the
// dependency together.
import 'sky.dart';
import 'swiss.dart';

/// The sky, as this build computes it.
const Sky sky = SwissSky();
