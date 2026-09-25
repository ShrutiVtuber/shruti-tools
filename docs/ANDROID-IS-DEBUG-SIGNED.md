# ⚠ The Android release build is signed with the debug key

Found 25 September 2026 while looking at what stood between the app and Google
Play. **Not urgent**, because Play is blocked on her company registration anyway.
Recorded so it is not rediscovered later under time pressure.

`android/app/build.gradle.kts`, in the `buildTypes` block, still carries Flutter's
generated placeholder:

```kotlin
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        // Signing with the debug keys for now, so `flutter run --release` works.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

**Google Play refuses a debug-signed upload.** So a release bundle built today
cannot be uploaded, and the failure arrives at the end of the upload rather than at
build time.

There is also no keystore for this app. `~/keystores/` holds release keys for
rebetichord, sheetsmith and theourgia, and nothing for astrolabe. `key.properties`
does not exist, and is correctly gitignored in both `.gitignore` and
`android/.gitignore`, along with `**/*.jks` and `**/*.keystore`.

## What it needs, when the registration comes through

1. A release keystore at `~/keystores/astrolabe-release.jks`, with its password in
   `~/keystores/astrolabe-release-password.txt`, which is the pattern
   `sheetsmith-release-password.txt` already follows. ⚠ Never in the repo.
2. `android/key.properties` pointing at it.
3. The release `signingConfig` in `build.gradle.kts` reading from it, and falling
   back to debug when `key.properties` is absent so that a clean checkout still
   builds.
4. ⚠ Under Play App Signing this keystore is an **upload key**, not the final
   signing key, so losing it is recoverable by asking Google to reset it. That is
   a relief but not a reason to skip the backup.

⚠ **Not to be done in advance.** Generating the key is trivial; generating it
twice, or generating it before there is a Play account to attach it to, is how the
wrong key ends up in the wrong place. Do it as part of the first upload.

## Also noted

`pubspec.yaml` is at `version: 1.0.0+1` while iOS has been through build 8. The
two tracks number independently and that is fine, but the first Play upload should
not assume the iOS build number.
