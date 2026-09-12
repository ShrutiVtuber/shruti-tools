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

## The video — one continuous recording, on the iPhone

Apple asked for a screen recording taken on a physical device, beginning with
the app launching. ⚠ It has to show account creation, sign-in, **deletion**, and
the reporting and blocking controls.

⚠ **Use an address you can actually read on the phone.** Confirming is now part
of signing up, so the recording includes opening the email. A Gmail plus-alias
works and is a distinct address —
`sophiawillowood+appreview@gmail.com` — and delivers straight to your inbox.
Do NOT use an address that already has an account: yours,
`appreview@shrutivtuber.com` and `sample@shrutivtuber.com` are all taken, and
the app will say "check your email" without sending anything.

⚠ Leave the newsletter box unticked. It is the only consent that sends a second
email, and it would confuse the recording.

 1. Launch the app from the home screen
 2. **Settings → Account** → sign up with the plus-alias address
 3. The app says **check your email**
 4. Open Mail, follow the confirmation link — it opens the site and signs you in
 5. Back to the app → **sign in** with the same address
 6. **Practice** → open "Aries, week of 7 September" by Practice Sample
 7. Its **⋮ menu** → show **Report this reading** and **Block Practice Sample**
 8. Block them → **Settings → Blocked** → **Unblock**
 9. **Settings → Privacy** — show the policy opens (Apple asks for this too)
10. **Settings → Account → Delete this account** → type DELETE → confirm

⚠ Delete the account you just made, not `appreview@shrutivtuber.com`. Deleting
the demo account locks the next reviewer out of the practice room.

Screen recording on iOS: Settings → Control Centre → add **Screen Recording**,
then swipe down from the top-right corner and press the record button.

---

## The reply to paste into Resolution Center

> Thank you for the review.
>
> A screen recording is attached. It was taken on an iPhone 12 Pro Max running
> the current iOS, begins with the app launching, and shows account
> registration, sign-in, the user-generated content area with its reporting and
> blocking controls, and account deletion.
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
