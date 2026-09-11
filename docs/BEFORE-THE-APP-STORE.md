# Before the App Store — what is left

**Updated 11 September 2026, after the single release build.**

⚠ **One iOS build, when the app is finished.** macOS runners bill at ten times
Linux minutes and she pays for them. Everything short of the .ipa is provable
for free — see the top of `.github/workflows/ios-testflight.yml`.

---

## Done

**Hers, this evening:**

- the APNs authentication key, made at Apple and given to Firebase
  — ⚠ it went into the **development** slot first, which is useless to a
    TestFlight or App Store build. The production row is the one that matters,
    and the same .p8 serves both.
- the App Privacy questionnaire: four data types, all "App Functionality", all
  linked to identity, **none** used for tracking

**Mine:**

- the app record, bundle id, signing, distribution profile
- listing text, subtitle, keywords, support and marketing URLs
- age rating — answered honestly, which is what surfaced the missing block
- App Review Information: contact details, and a demo account created on the
  site and proved to sign in, with notes telling the reviewer exactly where the
  report, block and unblock controls are
- the privacy policy now covers the app, and the URL is on the listing
- iOS Firebase end to end, **proved by a real notice arriving on her iPhone**
- blocking a person — Apple's guideline 1.2 — in the app, on the website, and
  in the database
- ⚠ the sunrise bug: every station in the iOS build was wrong and the suite was
  green. See `test/the_public_sky_rises_test.dart`.

---

## Left: screenshots

The only thing between here and submitting.

Apple needs at least one set. Her iPhone 12 Pro Max takes **1284 × 2778**,
which is Apple's 6.5-inch size and is usable as it stands; for the 6.9-inch
slot it scales to 1290 × 2796, a difference of half a percent.

1. **TestFlight → Shruti's Astrolabe → Update**, to the newest build
2. Three shots: the **Sky** tab, a **Chart**, the **Practice** room
3. ⚠ Transfer them at full size. AirDrop keeps it; email and messaging apps
   silently shrink to 740 × 1600, which Apple will not take and which cannot be
   upscaled without looking soft.

Artwork can replace them later without a new build.

---

## Worth checking on the new build, on her phone

- the **Sky** tab shows sensible station times — dawn in the morning, dusk in
  the evening. ⚠ Build 4 and earlier showed all four within four minutes of
  midnight.
- a notification arrives **with the app open**. ⚠ That path did not exist
  before this build.
- **Settings → Blocked** exists, and a reading by somebody else offers
  "Block …" in its menu.
