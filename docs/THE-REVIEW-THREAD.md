# The review conversation, verbatim

Transcript of the App Store Connect review conversation for submission
`8a45fcfb-0fda-47c8-a247-11bf367e6d33`, Shruti's Astrolabe 1.0.0 (8).

⚠ **This is a transcript, not an official export.** It was captured on
25 September 2026 from the Resolution Center text. It preserves the content
against the thread becoming unavailable, and it is what Drafts A and C quote. It
is not a substitute for printing the conversation to PDF from App Store Connect,
which is still worth doing because a PDF carries Apple's own timestamps and
formatting.

---

## Apple, 12 September 2026 — Guideline 2.1, Information Needed, New App Submission

> This app has been submitted by a developer account that has a limited App
> Review history. We need additional information to better understand the app and
> complete the review.
>
> Note: Before submitting, run the submitted build through your own testing and
> quality assurance process on supported physical devices. App Review is intended
> for apps and metadata that are complete and ready for App Store customers.
>
> If the app is ready for review, follow the directions below.
>
> **Next Steps**
>
> Reply in App Store Connect with all of the following information and also add
> this information to the Notes field of the App Review Information section in App
> Store Connect, for reference on future submissions:
>
> 1. A screen recording captured on a physical device, running the latest
> operating system, demonstrating the app's functionality. The recording must
> begin with launching the app and show the typical user flow. If the app has any
> of the following, include them in the recording:
>
> - Account registration, login, and account deletion flows. Account deletion is
>   required in apps that support account creation.
> - Any user-generated content, including the required content reporting and
>   blocking mechanisms.
> - Accessing paid content or features within the app.
>
> 2. A description of the app's purpose and target audience, including the problem
> it solves and the value it provides
> 3. Instructions for setting up and accessing the app's main features, including
> any required login credentials or sample files
> 4. A list of the external services, tools, or platforms the app uses to deliver
> its core functionality (for example, data providers, authentication services,
> payment processors, or AI services)
> 5. Describe any regional differences in the app's features or content, or
> confirm that the app functions consistently across all regions
> 6. If the app operates in a highly regulated industry or includes protected
> third-party material, provide any relevant documentation or credentials to
> demonstrate you are authorized to provide these services or protected material
>
> **Prevent Common Issues**
>
> - Guideline 2.1 - Bugs and crashes: Apps are reviewed on physical devices to
>   mirror real-world conditions. Test the app on each supported device platform
>   before submitting. Use TestFlight to distribute builds for beta testing on real
>   devices.
> - Guideline 2.1 - Accessing the app: If the app includes account-based features,
>   provide up-to-date login credentials for a demo account in App Store Connect.
>   If the app has multiple account types, provide credentials for each type in the
>   Notes field.
> - Guideline 2.3.3 - Screenshots: App screenshots on the App Store must show the
>   actual app in use, and not merely the title art, login page, or splash screen.
> - Guideline 3.1.1 - In-App Purchase: In-App Purchase products should be
>   configured and submitted alongside the app.
> - Guideline 3.2 - Other Business Models: If your app is intended to be used by
>   specific businesses, organizations or employees then use one of the other
>   distribution options available to you through the Apple Developer Program
>   Account.
>
> iOS App 1.0.0 App Version
> Rejection Reasons: 2.1.0 Performance: App Completeness

⚠ Note for the appeal: this message **reports no defect, no crash and no issue
with the app itself**. It is an information request. The "Prevent Common Issues"
block is a standard list of things to avoid, not findings.

## Sophia Antonopoulou, 12 September 2026, 12:11

> Thank you for the review.
>
> A screen recording is attached. It was taken on an iPhone 12 Pro Max running the
> current iOS, begins with the app launching, and shows: account registration
> including the confirmation email and the link that activates the account; signing
> in; the practice room with its reporting and blocking controls, a person being
> blocked and then unblocked; account deletion; and an attempt to sign in
> afterwards, which is refused demonstrating that deletion removes the account
> rather than only hiding it.

Attachment: `app-review-video-smaller.mp4`

The full text of the answers to items 2 to 6 sent with it is in
`THE-REJECTION-AND-THE-REPLY.md`. ⚠ The answer to item 4 stated: "All
astronomical calculation happens on the device from published analytic theory
(VSOP87 and ELP-2000/82); no server is asked for a chart." **This is the accurate
one**, and it is contradicted by the 15 September reply below.

## Apple, 15 September 2026, 14:46 — Guideline 4.3(b), Design, Spam

> Hello,
>
> Thank you for your efforts to follow our guidelines. There are some outstanding
> issues that still need your attention.
>
> If you have any questions, we are here to help. Reply to this message in App
> Store Connect and let us know.
>
> **Review Environment**
> Submission ID: 8a45fcfb-0fda-47c8-a247-11bf367e6d33
> Review date: September 15, 2026
> Review Device: iPad Air 11-inch (M3)
> Version reviewed: 1.0.0 (8)
>
> **Guideline 4.3(b) - Design - Spam**
>
> **Issue Description**
>
> The app primarily features astrology, horoscopes, palm reading, fortune telling
> or zodiac reports that duplicate the content and functionality of similar apps
> that are already widely available.
>
> These app features may be useful, informative or entertaining, and the app may
> include features or characteristics that distinguish it. However, there are
> already enough of these apps on the App Store.
>
> **Next Steps**
>
> We encourage you to reconsider the app concept and submit a new app that
> provides a unique experience not already found on the App Store.
>
> **Resources**
>
> - You may consider creating a web app, which looks and behaves like a native app
>   when the user adds it to their Home screen. See Configuring Web Applications
>   for more information.
> - To learn more about our policies for saturated app categories, see guideline
>   4.3.
>
> Extended Review: This app was found to include one or more issues that present
> significant safety, security, or quality concerns to users. Repeated submissions
> of apps with these issues will result in extended review times. Accounts that
> repeatedly submit apps that do not follow the App Review Guidelines and the
> Apple Developer Program License Agreement face removal from the Apple Developer
> Program.
>
> iOS App 1.0.0 App Version
> Rejection Reasons: 4.3.0 Design: Spam

⚠ Three things in this message to hold on to:
1. It concedes "the app may include features or characteristics that distinguish
   it" and then answers "there are already enough of these apps."
2. Its resources link speaks of "saturated app categories". **The word saturated
   appears nowhere in the App Review Guidelines.**
3. The Extended Review sentence asserts safety, security and quality concerns.
   Nothing in this message or the previous one identifies any, and the wording was
   found in no published Apple document.

## Sophia Antonopoulou, 15 September 2026, 19:16

> Thank you for the review. I would like to ask you to look at this one again,
> because it is not a horoscope or zodiac-report app and does not duplicate one.
>
> Shruti's Astrolabe is the companion app to shrutivtuber.com and to a live
> streaming community that already exists. Its primary surfaces are:
> - The practice room: a moderated space where members of the community post their
>   own readings and study notes, with reporting and blocking built in (this is what
>   the demo account opens onto).
> - Stream notices: push notifications when the stream goes live and when a letter
>   is published.
> - The letters and monthly horoscopes: written by one person, by hand, for this
>   community — the same texts that appear on the website. There is no generated
>   horoscope feed and no daily "your sign today" content.
>
> The astrological instruments in the app are tools for a practice, not reports: a
> whole-sign natal chart drawn to one tradition's conventions, planetary hours and
> sunrise/sunset stations for the person's own place, a transit wheel for the
> events page, isopsephy and a sigil builder. They are computed by our own server
> (Swiss Ephemeris, licensed) and are the same instruments the website offers — the
> app exists so this community can carry them and its room in a pocket.
>
> There are no ads, no purchases and no subscriptions in the app; nothing in it is
> sold. The demo account in App Review Information opens the practice room
> directly.
>
> If a particular screen gave the impression of a generic zodiac app, I would be
> glad to know which, and to adjust it. Thank you for your time.

⚠ **The error to correct.** "computed by our own server (Swiss Ephemeris,
licensed)" is true of the website and false of the iOS app, which casts every
chart on the phone from VSOP87 and ELP-2000/82 and ships no Swiss Ephemeris. See
`THE-IOS-EPHEMERIS.md`. The appeal corrects this in its own words.

## Apple, 24 September 2026, 22:38

> Hello,
>
> Thank you for your response. We encourage you to consider ways to make the app
> stand out.
>
> We understand that it can be difficult to determine what the best experience is
> to offer your users.
>
> While there isn't one set answer that works for every app, the following
> development videos offer great information for helping understand how the app can
> provide a great user experience:
>
> – Essential Design Principles
> – Design Tips for Great Games
>
> You may also want to review the Human Interface Guidelines available on Apple
> Developer.
>
> Best regards,
>
> App Review

⚠ Nine days after the substantive reply. It engages with none of it, and one of
the two videos is about games.

## Sophia Antonopoulou, 25 September 2026, 10:25

> Hello,
>
> I would like some clarification on how this application being a platform where
> many can practise writing horoscopes and receive feedback from others who are
> practising already exists. I searched for that on the shop and found nothing like
> it. Again, it's not just a basic astrology application. It is also a community hub
> for a vtuber channel. I responded to the claim that it was a generic astrology
> application and I didn't have any of those points addressed in the second review.
> If you could please give me some clarification specifically related to the issues
> claimed for this app so that I can then take that to the appeal on the review
> board.
>
> Thank you.

---

## Awaiting

Apple's answer to the message of 25 September. Record it here when it arrives, and
add every message after it.
