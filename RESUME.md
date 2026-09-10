# Where this is, 9 September 2026

Written before a compaction. Read this and `CLAUDE.md` and you have the state.

## The app — https://github.com/ShrutiVtuber/astrolabe

AGPL-3.0, public, under her account. Flutter, Android + iOS, everything
computed on the device against a bundled Swiss Ephemeris.

**Five tabs, all working on her phone:** Stations · Hours · What next · Chart ·
Settings. 59 integration tests on the device, 8 on the VM.

Everything astronomical is checked against **shruti-astro**, her own engine,
not against whatever the code returns:

| | checked against |
|---|---|
| stations | USNO tables — London 03:43 / 20:21 / 12:02 UT on the solstice |
| chart | her engine, to 0.1° — bodies and both angles |
| hours | her engine, in BOTH sunrise conventions |
| events | her engine, to the minute |
| isopsephy | ΙΗΣΟΥΣ 888, ΑΒΡΑΣΑΞ 365, ἀγάπη 93 |

## Done since: isopsephy and sigils

Both letter tools are built, on the phone, and tested.

**Isopsephy** — `lib/services/{packs,isopsephy}.dart` plus
`lib/screens/isopsephy.dart`. The chooser lists every pack from `/api/packs` in
its own script with its size shown BEFORE the download, because 2 MB of word
list on mobile data is the reader's call. Letter values are 4 KB; the word list
is the expensive half and a separate choice.

**Sigils** — `lib/services/sigil.dart` is a PORT of
`../shurtiwebsite/frontend/site/src/lib/sigil.js`, not a fresh implementation,
and the two are held together byte for byte:

- `test/sigil_agrees_test.dart` here checks the Dart against
  `test/fixtures/sigil_agreement.json`
- `frontend/site/test/sigil-agreement.test.mjs` there checks the JavaScript
  against **the same fixture**, copied into both repos

⚠ Neither half can be satisfied by editing the fixture — it would have to be
re-copied to the other repo, where it would then fail. Both were verified by
mutating each engine and watching the other side go red. To change the geometry
on purpose: `node frontend/site/scripts/gen-sigil-fixture.mjs >
test/fixtures/sigil_agreement.json`, copy it here, ship both.

The figure leaves as a **2048px PNG through the share sheet** — the same size
the site exports, so the two are the same picture. `lib/widgets/sigil_figure.dart`
holds the painter and `pngOf`, kept out of the screen so the export can be
tested: `test/sigil_export_test.dart` counts actual ink rather than PNG byte
length. ⚠ The first version compared byte lengths and PASSED with `drawPath`
commented out — the difference it was reading came from the enclosure ring.
Every assertion in that file has since been checked by mutation.

The two tools share the **Letters** tab (`lib/screens/letters.dart`) behind a
segmented control. Seven bottom tabs is a row nobody can read, and they belong
together: both take letters and give back something that is not letters.
⚠ They deliberately do NOT share their input — see below.

**The statement never leaves the device.** No autosave, no analytics on that
screen, no `<title>`/`<desc>`/metadata in the exported SVG, and nothing carried
across to the reckoning field. Many hold a statement of intent is spent once
drawn. `integration_test/sigil_screen_test.dart` fails loudly if a later
convenience breaks it.

### Running the tests

```bash
adb reverse tcp:8200 tcp:8200
flutter test integration_test -d <device> \
  --dart-define=SHRUTI_SITE=http://127.0.0.1:8200
```

⚠ Point tests at the local stack. Against shrutivtuber.com they fail on the
phone's DNS and the failure says nothing about the tool under test.

⚠ **Wake the phone first** — `adb shell svc power stayon true`. A dozing device
stops producing frames, `pumpAndSettle` waits forever, and the run looks hung
rather than failed. Cost twenty minutes here.

⚠ A `ListView` only builds what is in the viewport. Anything below the fold is
invisible to a finder, and once you have scrolled down the TEXT FIELD is gone
from the tree, so a second `enterText` dies with "Bad state: No element". Type
once, then scroll.

## Done since: accounts

One account, both places. `lib/services/account.dart` holds a bearer token in
preferences; the site's `current_user` now reads `Authorization: Bearer` as well
as its cookie, and `signup`/`signin` return the token **only when asked** —
`bearer: true` in the body, which the website never sends. The httpOnly cookie
exists to keep that value away from any script on the page, so the browser's
replies are unchanged.

⚠ **The cookie wins when both are present.** A request carrying a cookie is a
browser; letting a header override it would let a script that cannot read the
cookie still choose whose account the request runs as.

⚠ **The consent wording is FETCHED** from `GET /api/account/consents`, never
copied into Dart. What a person reads must be what gets filed, and there were
already two copies (Python and TypeScript) held together by
`scripts/check_consent_wording.py` — which said "run in CI" and which **nothing
ran**. It runs in the backend suite now.

Sign-in is by password. Somebody whose site account has a magic link and no
password could otherwise never sign in on a phone, so the screen offers "Email
me a link to set a password", which goes through the existing reset flow.

Tests: `integration_test/account_test.dart` — six, including one that takes the
token the app is holding and asks the SITE who it belongs to. That is the half
that says it is the same account rather than two that agree.

## Done since: the practice room and notifications

**Practice** — `services/practice.dart`, the Practice tab, and the write and
read screens. ⚠ A WORK is the unit: switching sign while writing keeps you in
the same draft, and it is the SAME draft the website's desk holds.

**Six tabs, two of them pairs.** Day is Stations + Hours; Letters is Reckoning +
Sigil. A bottom bar holds about six before the labels stop being readable, and
the practice room needed one.

**`services/periods.dart`** is the third ISO-week implementation in the estate
(TypeScript on the site, Python in the bot). All three are held against ONE
fixture generated from the site's own code across 785 weeks of fifteen years —
including a 53-week year and weeks belonging to the previous year.

**Notifications** — the switches, where they are kept, sending them to the site
and taking the phone off the list are all built. ⚠ `_registrationToken()` in
`services/notifications.dart` returns null until Firebase exists: the five lines
to write are in the comment above it, and the app is deliberately NOT built
against `firebase_messaging` yet because adding the plugin without a
`google-services.json` does not compile.

## What is left

Nothing she has asked for. The two open things are hers to do:

1. **Firebase** — a project, `google-services.json`, two packages, five lines.
   `../shurtiwebsite/docs/PLAN-horoscope-practice.md` has the steps.
2. **APNs**, when there is an iOS build. The backend already sends the block.

## What is written down elsewhere

`../shurtiwebsite/docs/PLAN-horoscope-practice.md` carries eleven requirements
and two decisions she has made. Read it before the practice work.
