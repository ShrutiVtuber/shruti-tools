# Getting Astrolabe onto TestFlight

⚠ **None of this has been run.** The workflow was written on a Linux machine
with no Apple account. The shape is right; the first run will almost certainly
stop on something small. That is normal for Apple signing and is not a sign the
approach is wrong — read the failing step's log and fix that one thing.

There are **eight secrets** to create, in four groups. Do them in this order;
each needs the one before it.

---

## 1. Apple Developer — the team

Sign in at <https://developer.apple.com/account>.

**Your Team ID** is on that page, top right, under your name — ten characters,
letters and numbers, like `A1B2C3D4E5`.

→ GitHub secret **`IOS_TEAM_ID`** = that string.

## 2. Apple Developer — the app and its certificate

**a. Register the App ID.** Certificates, Identifiers & Profiles → Identifiers →
**+** → App IDs → App. Description "Astrolabe", Bundle ID **explicit**:

```
com.shrutivtuber.astrolabe
```

⚠ Exactly that, and it must match the Android one. Tick **Push Notifications**
under Capabilities while you are here — adding it later means regenerating the
provisioning profile.

**b. Make a distribution certificate.** Certificates → **+** → *Apple
Distribution*. It asks for a "certificate signing request", which you make on a
Mac: Keychain Access → menu *Keychain Access* → Certificate Assistant →
*Request a Certificate from a Certificate Authority*, save to disk. Upload that,
download the `.cer`, double-click to install it.

**c. Export it as .p12.** In Keychain Access, find *Apple Distribution: your
name*, right-click → **Export** → `.p12`, and set a password you will remember.

⚠ Export the certificate **with its private key** — expand the arrow beside it
and check you are exporting the pair. A `.p12` holding only the certificate
imports cleanly on the runner and then fails to sign anything, with a message
about no identity found.

Then, in a terminal:

```bash
base64 -i Certificates.p12 | pbcopy
```

→ **`IOS_DIST_CERT_P12`** = that (paste it)
→ **`IOS_DIST_CERT_PASSWORD`** = the password you set

**d. Make a provisioning profile.** Profiles → **+** → *App Store Connect* →
select the Astrolabe App ID → select the distribution certificate → give it a
name. **Write that name down exactly.**

```bash
base64 -i Astrolabe_App_Store.mobileprovision | pbcopy
```

→ **`IOS_PROVISIONING_PROFILE`** = that
→ **`IOS_PROVISIONING_PROFILE_NAME`** = the name, character for character

⚠ The name is matched as a literal string inside the build. A trailing space or
a different capital letter produces "no profile matching" and nothing else.

## 3. App Store Connect — the app record and the upload key

**a. Create the app.** <https://appstoreconnect.apple.com> → Apps → **+** → New
App. Platform iOS, the Astrolabe bundle ID, SKU anything (`astrolabe-1` is
fine), and a name. ⚠ The **name must be unique across the whole App Store** — if
"Astrolabe" is taken, this is where you find out, and it is better to find out
now than after a build is sitting waiting for it.

**b. Make an API key.** Users and Access → Integrations → App Store Connect API
→ **+**. Access: **App Manager**. It downloads a `.p8` file.

⚠ **It downloads once.** There is no second chance and no way to view it again;
a lost key is replaced, not recovered.

→ **`APPSTORE_KEY_ID`** = the Key ID shown in the table
→ **`APPSTORE_ISSUER_ID`** = the Issuer ID at the top of that page
→ **`APPSTORE_PRIVATE_KEY`** = the whole contents of the `.p8`, including the
  `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` lines

## 4. Firebase — the iOS half of notifications

The Android app already works. iOS needs its own registration and its own key.

**a.** Firebase console → the `astrolabe-508f1` project → Add app → **iOS**.
Bundle ID `com.shrutivtuber.astrolabe`. Download **`GoogleService-Info.plist`**
and tell me where it landed — it goes in `ios/Runner/`, and ⚠ it must be ADDED
to the Xcode project, not merely copied into the folder, or the app builds and
then cannot find it at runtime.

**b. An APNs key.** developer.apple.com → Keys → **+** → tick *Apple Push
Notifications service (APNs)* → download the `.p8`. Upload it in Firebase →
Project settings → Cloud Messaging → *APNs Authentication Key*, with its Key ID
and your Team ID.

⚠ Without this, iOS notifications fail **silently** — Firebase accepts the
message and reports success, exactly as it did on Android before the display
code existed. The backend already sends the APNs block, so nothing changes
server-side.

---

## Where the secrets go

GitHub → the `shruti-tools` repo → Settings → Secrets and variables → Actions →
*New repository secret*, one per name above.

## Running it

Either push a version tag:

```bash
git tag v1.0.0 && git push origin v1.0.0
```

…or use the **Run workflow** button on the Actions tab, which builds without
making a release out of it. **Use the button first.**

⚠ It does not build on every push, deliberately. A macOS runner costs about ten
times a Linux one, and a workflow that built on every commit would eat the free
allowance in a fortnight.

## What "done" looks like

The job goes green, and ten to thirty minutes later the build appears in App
Store Connect → your app → TestFlight, first as *Processing* and then ready to
install. Apple emails if it rejects the binary, usually about a missing privacy
declaration rather than anything in the code.

## Still to do on this side, once you have the above

- `GoogleService-Info.plist` into `ios/Runner/` and into the Xcode project
- an iOS notification icon — Android's white-silhouette rule does not apply,
  iOS uses the app icon
- `NSUserTrackingUsageDescription` is **not** needed: the app tracks nobody
- a privacy manifest (`PrivacyInfo.xcprivacy`), which Apple now requires. It
  needs to declare what the app collects — which is very little, and honestly
  declaring "nothing" is the easy case
