# Where this is, 9 September 2026

Written before a compaction. Read this and `CLAUDE.md` and you have the state.

## The app — https://github.com/ShrutiVtuber/shruti-tools

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

## Then, in her order

1. **Accounts in the app.** `/api/accounts/{signup,signin,me}` are already
   JSON; they set a signed session in a cookie, and the app needs that same
   token returned in the body to hold as a bearer. One account, both places.
   ⚠ Sign-up must work IN the app, not by sending somebody to the website.
2. **Practice readings** — submit, read, comment, vote. Account required.
   Series is a first-class thing, not a tag.
3. **The Discord bridge**, gateway — see the site's PLAN doc. The cheap half
   (a slash command returning the material to write from) can ship first; the
   bot already answers signed interactions.
4. **Notifications**, last, deliberately: the features decide what is
   notifiable. Three of the four kinds need no server at all.

## What is written down elsewhere

`../shurtiwebsite/docs/PLAN-horoscope-practice.md` carries eleven requirements
and two decisions she has made. Read it before the practice work.
