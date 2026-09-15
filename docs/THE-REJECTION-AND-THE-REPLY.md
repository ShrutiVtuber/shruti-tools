# Rejection of 1.0.0, and what was done about it

**12 September 2026 — Guideline 2.1, Information Needed.**

Not a defect report. It is the standard request made of a developer account
with no review history: show us the app working before we approve a first
submission. No crash, no bug, nothing they found broken.

⚠ **But one line of it was a real failure**, and two more were found by reading
the guidelines rather than by being told:

| | What was wrong | Needed a build |
|---|---|---|
| **5.1.1(v)** | No account deletion in the app at all. An account could be made in it and only closed in a browser. They asked to be shown the flow on video. | yes |
| **5.1.1(i)** | No privacy policy link anywhere inside the app. Required in App Store Connect *and* in the app. | yes |
| **3.1.1** | Settings linked out to the support page, whose €5/month tiers unlock a members Discord channel, the schedule early and monthly notes — digital content bought outside Apple's store. | yes |

All three are in build 6. The review notes in App Store Connect were rewritten
to answer their six questions and are now there for every future submission.

---

## The video — step by step

One continuous recording on the iPhone, about two minutes. Apple needs to see
registration, sign-in, deletion, and the reporting and blocking controls.

### Before you start

- **TestFlight → Shruti's Astrolabe → Update**, so you are on build 7
- ⚠ **Turn on Do Not Disturb.** A screen recording captures notification
  banners, and this video goes to a stranger at Apple
- **Settings → Control Centre → add Screen Recording**, if it is not there
- Decide the address: `sophiawillowood+appreview@gmail.com`
  ⚠ It must be one you can read ON THE PHONE, and must not already have an
  account — yours, `appreview@` and `sample@` are all taken

### Recording

Swipe down from the top-right corner, press the **record** button, wait for the
countdown, then go to the home screen.

 1. **Tap the Astrolabe icon.** Let it open and sit for a second.
 2. **Settings** tab, bottom right.
 3. Tap **Account**.
 4. Tap **I need an account** — the small text button below the form.
 5. Fill in **Name**, **Email** (the plus-alias), **Password**.
    ⚠ Leave the newsletter tick-box **unticked**. Leave the account one ticked.
 6. Tap **Make the account**.
 7. You should see: *"Check your email. A link is on its way…"* — pause here so
    it is readable.
 8. **Leave the app**, open **Mail**, find "Confirm your address".
 9. **Tap the link.** Safari opens, confirms, and lands you on your account
    page signed in. Pause.
10. **Back to the app.** Settings → Account → **Sign in** with the same address
    and password.
11. **Practice** tab.
12. Open **"Aries, week of 7 September"** by Practice Sample.
13. Tap the **⋮** at the top right (labelled "Report or block").
14. The sheet shows **Report this reading** and **Block Practice Sample** —
    pause so both are readable. This is the shot Apple most needs.
15. Tap **Block Practice Sample** → **Block** in the dialog.
16. **Settings → Blocked** → tap **Unblock** next to Practice Sample.
17. **Settings → Privacy** — show the policy opening. Come back.
18. **Settings → Account → Delete this account.**
19. Type **DELETE**, tap **Delete it**.
20. Stop the recording — swipe down, tap the red timer, **Stop**.

⚠ Delete the account you made in step 5, **not** `appreview@shrutivtuber.com`.
Deleting the demo account locks the next reviewer out of the practice room.

### Then

The video is in Photos. Attach it to the Resolution Center reply below.

---

## The reply to paste into Resolution Center

> Thank you for the review.
>
> A screen recording is attached. It was taken on an iPhone 12 Pro Max running
> the current iOS, begins with the app launching, and shows: account
> registration including the confirmation email and the link that activates the
> account; signing in; the practice room with its reporting and blocking
> controls, a person being blocked and then unblocked; account deletion; and an
> attempt to sign in afterwards, which is refused — demonstrating that deletion
> removes the account rather than only hiding it.
>
> Since the previous build we have added account deletion inside the app
> (Settings → Account → Delete this account), added a link to the privacy
> policy inside the app (Settings → Privacy), removed the links that led to
> pages where something could be bought, and added email confirmation: a new
> account now sends a link to the address and does not work until that link is
> followed. Nothing in the app directs anyone to a purchase of any kind.
>
> Answers to your questions 2 to 6 are below, and have also been added to the
> App Review Information notes for future submissions.
>
> **2. Purpose and audience.** Shruti's Astrolabe is a set of astrological
> instruments for people who study or practise traditional astrology: charts,
> the planetary hours, the solar stations and Greek letter-reckoning. The
> audience is students and practitioners of Hellenistic astrology. The app is
> free, with nothing to buy in it, no advertising, no analytics and no tracking.
>
> **3. Setting up and reaching the features.** Most of the app needs no
> account: the Sky, Chart and Letters tabs work on launch. An account is needed
> only to write in the practice room, and demo credentials are in the App
> Review Information fields. To reach the reporting and blocking controls, sign
> in and open the reading "Aries, week of 7 September" by Practice Sample in
> the Practice tab — it is another member's work, so the controls appear on it.
> Account deletion is at Settings → Account → Delete this account.
>
> **4. External services.** The app talks to shrutivtuber.com, which is our own
> server, for accounts, the practice room, horoscopes, video listings, live
> status and city name lookup. Notifications, which are off until the user asks
> for them, use Firebase Cloud Messaging and the Apple Push Notification
> service. City names are resolved by Open-Meteo over the GeoNames dataset, and
> that request is made by our server rather than by the app. There are no
> payment processors, no third-party authentication, no AI services and no data
> brokers. All astronomical calculation happens on the device from published
> analytic theory (VSOP87 and ELP-2000/82); no server is asked for a chart.
>
> **5. Regions.** The app behaves identically everywhere. There are no regional
> differences in features or content. The interface and content are in English.
>
> **6. Regulated industry and third-party material.** Neither applies.
> Astrological content is offered for study and practice and makes no medical,
> psychological, financial or legal claims. All written content is our own, the
> typefaces are open-licensed, and the astronomical theories are published
> science.

---

## Then

Resubmit. ⚠ The open submission sits in `UNRESOLVED_ISSUES` and may need
cancelling first — check before assuming a fresh submission will attach.

---

# Second verdict, 15 September 2026 — Guideline 4.3(b), Design, Spam

Version 1.0.0 (8), reviewed on an iPad Air 11-inch (M3). Not a defect and not
an information request: a category judgement. "The app primarily features
astrology, horoscopes … that duplicate the content and functionality of
similar apps that are already widely available." They suggest a web app, or a
new concept. The message carries the standard "extended review" warning about
repeated submissions.

## What it means

- A 4.3(b) verdict is about what the app is FOR in the reviewer's eyes, so a
  rebuild with the same shape gets the same answer. Nothing technical is wrong.
- ⚠ Do not resubmit the same binary, and do not resubmit with cosmetic changes:
  the warning about repeated submissions is boilerplate on 4.3 rejections, but
  the account-level consequence in it is real.
- TestFlight with internal testers (you, as a team member) does not go through
  App Review. Squirrel Guides can be built to TestFlight and held on the phone
  without touching this.

## The three moves, in order

1. **Reply in Resolution Center** (below), once, factually. Reversals of 4.3(b)
   happen for apps that are a companion to an existing community or service
   rather than a standalone horoscope app, and that is what this one is.
2. If the reply is refused: **appeal to the App Review Board** once, with the
   same facts. Then stop pushing this shape.
3. The durable answer, with or without the appeal: **make the app the companion
   to the stream and the community, not an astrology app with a community in
   it.** The practice room, stream notices, the letters and her hand-written
   monthly horoscopes are the primary surface; the chart, the hours and the
   sunrise are instruments inside it; the name says whose it is. Whether
   Squirrel Guides folds into that same companion is her call — one app for one
   world is the strongest 4.3 argument there is.

## The reply to paste into Resolution Center

Thank you for the review. I would like to ask you to look at this one again,
because it is not a horoscope or zodiac-report app and does not duplicate one.

Shruti's Astrolabe is the companion app to shrutivtuber.com and to a live
streaming community that already exists. Its primary surfaces are:

- The practice room: a moderated space where members of the community post
  their own readings and study notes, with reporting and blocking built in
  (this is what the demo account opens onto).
- Stream notices: push notifications when the stream goes live and when a
  letter is published.
- The letters and monthly horoscopes: written by one person, by hand, for
  this community — the same texts that appear on the website. There is no
  generated horoscope feed and no daily "your sign today" content.

The astrological instruments in the app are tools for a practice, not
reports: a whole-sign natal chart drawn to one tradition's conventions,
planetary hours and sunrise/sunset stations for the person's own place, a
transit wheel for the events page, isopsephy and a sigil builder. They are
computed by our own server (Swiss Ephemeris, licensed) and are the same
instruments the website offers — the app exists so this community can carry
them and its room in a pocket.

There are no ads, no purchases and no subscriptions in the app; nothing in
it is sold. The demo account in App Review Information opens the practice
room directly.

If a particular screen gave the impression of a generic zodiac app, I would
be glad to know which, and to adjust it. Thank you for your time.
