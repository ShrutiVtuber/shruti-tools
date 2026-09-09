# Working on Shruti's Tools

A lite companion to shrutivtuber.com: the instruments, her writing and her
videos, and a notification when she goes live. AGPL-3.0.

## What it is for, in order

1. **The instruments, offline.** A chart and a station table are arithmetic,
   and arithmetic does not need a server. Swiss Ephemeris is bundled and
   everything is computed on the phone. This is the reason the app exists
   rather than a bookmark.
2. **Telling somebody she is live, while she is still live.**
3. Her writing and her videos, without opening a browser.

One and two are why it exists. Three is why somebody keeps it.

## ⚠ The traps, all of which look fine

**A wrong time is indistinguishable from a right one.** The screen once showed
London's sunrise in the phone's timezone — a card headed LONDON reading 07:24
for a sunrise London calls 06:24. Same instant, wrong answer, and it survived a
build, an install and a look at the screen. A `Place` carries its zone for
exactly this reason; never render a station with `.toLocal()`.

**East-positive longitude.** Swiss Ephemeris and the site's places API both use
it. Enter a west longitude as positive and every station is hours out while the
table still looks like a normal day.

**`epheFilesPath` must be ABSOLUTE.** `Sweph.init` defaults to the relative
string `ephe_files` and uses it verbatim. On desktop the working directory
makes that resolve; on Android it is `/` and the copy fails read-only. Inherited
from astropractise, where a fully green unit suite once coexisted with an app
that could not open its ephemeris at all.

**Unit tests cannot touch the ephemeris.** `flutter test` runs on the Dart VM
with no plugins linked, so `libsweph.so` is simply absent. Anything needing it
lives in `integration_test/` and runs against a real target.

## Suites

```bash
flutter analyze
flutter test                                       # pure Dart only
flutter test integration_test -d <device>          # the real ephemeris
dart format --output=none --set-exit-if-changed .
```

The station times are checked against the US Naval Observatory's tables, not
against whatever the code returns today.

## The device

```bash
adb uninstall com.shrutivtuber.shruti_tools     # ⚠ ALWAYS first
adb install build/app/outputs/flutter-apk/app-release.apk
```

Never `install -r`: saved places and settings survive it, so the screen becomes
new UI over stale state and a screenshot stops meaning anything.

⚠ **iOS cannot be built on this machine** — Arch Linux, no Xcode. TestFlight
goes through a GitHub macOS runner, as astropractise does.

## Android build settings that are not optional

`android/build.gradle.kts` carries two blocks **ported from astropractise**,
where they were worked out against this same sweph version:

- **Raising every plugin's compileSdk.** sweph declares 31; its own AndroidX
  dependencies demand 34+. Without it the build stops in
  `:sweph:checkDebugAarMetadata` with twenty conflicts, none of which name the
  module whose setting must change. Raising it on `:app` alone does nothing.
- **16 KB page-size alignment.** A Play Store release blocker that produces no
  build error. Only `libsweph.so` is affected, and only because it is built
  from source at app-build time, which is what makes it fixable here.

Both must be registered **before** the `evaluationDependsOn(":app")` block —
that evaluates projects eagerly, and Gradle then refuses `afterEvaluate`.

`flutter_timezone` is deliberately absent: it still compiles Kotlin for Java 11
while every other plugin is on 17, and no combination satisfies both.

## What could send a notification

Written down as the features land, because the list is what the settings
screen has to offer and it is easier to keep than to reconstruct:

| | from | needs |
|---|---|---|
| a solar station — the adorations | on the device | a local schedule, no server |
| a planetary hour beginning, or one ruler in particular | on the device | as above |
| she has gone live | `/api/live` | a push, while it is still true |
| a new video | `/api/videos` | a push |
| a new piece of writing | the journal, once it is mounted | a push |

The first two are **local** and want no network at all — the phone already
knows when tomorrow's dawn is. Only the last three need a server to speak
first, and only those need FCM. Worth keeping separate in the settings, since
one set works on a plane and the other does not.

## Standing constraints

- **AGPL, and she is the sole copyright holder.** That is what makes an App
  Store release possible at all — GPL-family terms conflict with Apple's, and
  the holder granting an exception is the way through. It stops being true the
  moment an outside contribution lands without a CLA.
- The design comes from **shrutivtuber.com's own tokens**, in `lib/theme/`.
  Lifted from the site's stylesheet rather than re-picked by eye: a colour that
  is nearly the accent reads as a mistake, not a choice.
- Whole-sign houses throughout, as everywhere else in her work.
- **Plain language.** Lead with what changed for a reader, not the mechanism.
