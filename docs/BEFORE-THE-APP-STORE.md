# Before the App Store — what is left, and who does it

Build 4 is on TestFlight and installable now. This is everything between that
and a v1.0.0 release.

⚠ **There will be ONE more iOS build**, at the end, carrying all of it. macOS
runners bill at ten times Linux minutes. Nothing below needs a build to be
prepared.

---

## Already done

- the app record, the bundle id, signing, the distribution profile
- the listing text, subtitle, keywords, support and marketing URLs
- the age rating questionnaire — answered, and it is why blocking now exists
- export compliance, so builds stop stalling in processing
- the icon, at all nineteen sizes, hers rather than Flutter's
- Firebase configured for iOS: the app exists in the project, the plist is a
  repository secret, the push entitlement matches the profile
- blocking a person, which Apple requires and the room did not have
  — ⚠ built and deployed to the site, but **not in build 4**. The final build
  carries it.

---

## 1. The APNs key — 5 minutes, and only you can do it

Without it, iOS notifications do nothing. There is no API for making one.

1. **developer.apple.com** → Account → **Certificates, Identifiers & Profiles**
2. **Keys** in the left column → the **+** button
3. Name it `Astrolabe APNs`. Tick **Apple Push Notifications service (APNs)**.
4. Continue → Register → **Download**. ⚠ **You can only download it once.**
   Put it in `~/keystores/` and tell me the filename.
5. Note the **Key ID** from that page, and your **Team ID** is `L25T4F2NJ2`.

Then, in Firebase:

6. **console.firebase.google.com** → project **astrolabe-508f1** → the gear →
   **Project settings** → **Cloud Messaging**
7. Under the iOS app **Shruti's Astrolabe**, **APNs Authentication Key** →
   **Upload**. Give it the .p8, the Key ID, and the Team ID.

Tell me when it is done and I will send a test notice to your iPhone.

---

## 2. The privacy policy — 10 minutes, from your own admin

⚠ Apple reads the page. Ours currently says it covers shrutivtuber.com, which
is the exact sentence that gets an app rejected.

The three changes are written out for you, ready to paste, in
`shurtiwebsite/docs/PRIVACY-THE-APP.md`. Read them — they are claims you have
to stand behind, and every fact in them came out of the app's source.

---

## 3. App Privacy — 15 minutes, and the answers are below

App Store Connect → your app → **App Privacy** → Get Started. It cannot be
done through the API, so it has to be clicked.

**Do you collect data from this app?** → **Yes**

Then tick exactly these four, and nothing else:

| Category | Type | Linked to them? | Tracking? | What for |
|---|---|---|---|---|
| Contact Info | **Email Address** | Yes | **No** | App Functionality |
| Identifiers | **User ID** | Yes | **No** | App Functionality |
| Identifiers | **Device ID** | Yes | **No** | App Functionality |
| User Content | **Other User Content** | Yes | **No** | App Functionality |

**Say No to tracking every time.** There is no advertising and no analytics in
the app, and nothing is shared with a data broker.

⚠ **Do NOT tick Location.** The app has no GPS and asks for no location
permission. The city you type is passed straight through to the gazetteer and
nothing is written down — under Apple's rules that is not collection.

⚠ **Do NOT tick Sensitive Info**, and this one is worth knowing about. Birth
data used for a reading arguably reveals philosophical belief — your own
policy says so. But the app **computes every chart on the phone** and never
sends birth details anywhere, including to us. There is nothing to declare
because there is nothing collected. That is a genuinely good position and it
is worth not losing by accident later.

- Email Address, User ID: only if somebody makes an account. Reading needs none.
- Device ID: the notification address, only if they turn notifications on.
- Other User Content: what they write in the practice room.

---

## 4. Screenshots — the last thing, and art can come later

Apple needs at least one set, **6.9" iPhone** (1290 × 2796). Plain screens of
the app are fine and can be replaced any time without a new build.

Take them on your iPhone from build 4: Sky, a chart, and the practice room are
the three that show what it is.

---

## 5. Then, and only then, the one build

When 1–4 are done, say so and I will run the single TestFlight build carrying
blocking and anything else outstanding, check it processes, and walk the
submission with you.
