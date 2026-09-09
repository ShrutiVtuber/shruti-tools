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

## In flight: isopsephy

`lib/services/packs.dart` and `lib/services/isopsephy.dart` are **done and
tested** (9 tests). **The screen is not written.** That is the next thing.

What it needs: a language chooser listing `/api/packs` with each pack's size
shown BEFORE anybody spends it, install/remove, then a text field, the
reckoning, and the matches.

```bash
adb reverse tcp:8200 tcp:8200
flutter test integration_test -d <device> \
  --dart-define=SHRUTI_SITE=http://127.0.0.1:8200
```

⚠ Point tests at the local stack. Against shrutivtuber.com they fail on the
phone's DNS, and the failure says nothing about isopsephy.

## Then, in her order

1. **The sigil generator** — the other tool she asked for in the app.
2. **Accounts in the app.** `/api/accounts/{signup,signin,me}` are already
   JSON; they set a signed session in a cookie, and the app needs that same
   token returned in the body to hold as a bearer. One account, both places.
   ⚠ Sign-up must work IN the app, not by sending somebody to the website.
3. **Practice readings** — submit, read, comment, vote. Account required.
4. **The Discord bridge**, gateway — see the site's PLAN doc.
5. **Notifications**, last, deliberately: the features decide what is
   notifiable. Three of the four kinds need no server at all.

## What is written down elsewhere

`../shurtiwebsite/docs/PLAN-horoscope-practice.md` carries eleven requirements
and two decisions she has made. Read it before the practice work.
