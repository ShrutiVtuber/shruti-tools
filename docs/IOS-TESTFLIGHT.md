# Getting Astrolabe onto TestFlight

Most of this is already done, because your Apple account is already set up from
Theourgia, AstroPractise and RebetiChord. ⚠ **A distribution certificate belongs
to the ACCOUNT, not to an app** — the one made for Theourgia signs this one too.
You do not need a new certificate, and you do not need a new API key.

Your team is **`L25T4F2NJ2`**, already filled in for you in the workflow and in
the Xcode project.

⚠ That certificate expires **2027-08-06**. After that, remake it and re-run the
secrets script.

---

## Already done

- the bundle id changed to `com.shrutivtuber.astrolabe` everywhere — ⚠ it was
  still `shrutiTools`, the name from before the app was renamed, and Firebase
  and the provisioning profile both match that string exactly
- manual signing set on the Runner target's **Release** configuration only —
  ⚠ not the project, and not the xcodebuild command line: those hit every
  target, and plugin pods cannot take a provisioning profile
- `.github/workflows/ios-testflight.yml`, copied step for step from
  AstroPractise's, which came from practiseapp's, which took seven attempts
- `scripts/set-ios-secrets.sh`, which reads five of the seven secrets straight
  off `~/keystores` so nothing is retyped

## Four things left, and only two need you at a keyboard for long

### 1. Let GitHub write secrets to the org

The `gh` token can write secrets to your personal repos but not to
`ShrutiVtuber/shruti-tools`, because that is an organisation and the OAuth app
has not been approved for it. Either approve it at
<https://github.com/settings/connections/applications> → GitHub CLI →
*Organization access* → grant for `ShrutiVtuber`, or run the script yourself
after `gh auth refresh -h github.com -s admin:org`.

### 2. Register the bundle id

developer.apple.com → Certificates, Identifiers & Profiles → Identifiers → **+**
→ App IDs → App. Description `Astrolabe`, Bundle ID **explicit**:

```
com.shrutivtuber.astrolabe
```

⚠ Tick **Push Notifications** while you are there. Adding the capability later
means regenerating the profile, which means redoing step 3.

### 3. Create the provisioning profile

Profiles → **+** → Distribution → **App Store** → the bundle id above → your
**existing** distribution certificate → name it exactly:

```
Astrolabe
```

⚠ The name is written in two places already — `PROVISIONING_PROFILE_SPECIFIER`
in `ios/Runner.xcodeproj/project.pbxproj`, and the ExportOptions plist inside
the workflow. A mismatch fails at export with an error that never mentions the
profile name, which is how an afternoon disappears.

Download it and save it as:

```
~/keystores/astrolabe-appstore.mobileprovision
```

### 4. Create the app record

appstoreconnect.apple.com → Apps → **+** → New App. Platform iOS, the bundle id,
a name, a primary language, and any unique SKU (`astrolabe` is fine).

⚠ **This is the one step the API cannot do.** And the name must be unique across
the whole App Store — better to find out now than with a build waiting for it.

---

## Then run one command

```bash
cd ~/Documents/development/shruti-tools
ASC_ISSUER_ID=<the uuid from App Store Connect> ./scripts/set-ios-secrets.sh
```

The issuer id is at Users and Access → Integrations → App Store Connect API,
above the key list. ⚠ It is the same for every app in the account, and it is the
one value that exists nowhere on this machine.

The script says which secrets it set and which it could not.

## Then build

Actions tab → **TestFlight** → *Run workflow*. Use the button before you use a
tag, so a failure is not also a botched release.

⚠ A Linux gate runs first — analyse, tests, Android release build — and the Mac
refuses to start unless it passes. Your reasoning, to another project: *"I don't
want to pay for mac os runners if things fail already in android."*

When it is genuinely working, cut the release by tagging:

```bash
git tag ios-v1.0.0 && git push origin ios-v1.0.0
```

## What is still missing for iOS notifications

Notifications on iOS need two more things, and the app works without both:

- an **iOS app in the Firebase project** (`GoogleService-Info.plist` into
  `ios/Runner/`, ⚠ *added to the Xcode project*, not merely copied into the
  folder)
- an **APNs key** uploaded to Firebase → Cloud Messaging

⚠ Without the APNs key, iOS notifications fail **silently** — Firebase accepts
the message and reports success. Exactly the shape of the Android bug fixed on
10 September, and exactly as hard to see.

Neither blocks a TestFlight build. Do them after the first green run.
