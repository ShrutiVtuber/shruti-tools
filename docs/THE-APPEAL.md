# Escalating the 4.3(b) rejection

Submission `8a45fcfb-0fda-47c8-a247-11bf367e6d33` · version 1.0.0 (8) ·
reviewed 15 September 2026 on an iPad Air 11-inch (M3).
Written 25 September 2026. Every Apple document quoted here was fetched that day.

⚠ **This repository is public.** Nothing here is secret, but decide whether you
want a live dispute with Apple readable by anyone before it is committed.

---

## The one paragraph this all turns on

From the rejection of 15 September, verbatim:

> These app features may be useful, informative or entertaining, and **the app
> may include features or characteristics that distinguish it. However, there are
> already enough of these apps on the App Store.**

Now Guideline 4.3(b) as published, last updated 8 June 2026:

> Don't submit apps that are indistinguishable from what's already widely
> available. … Certain kinds of apps, such as dating, flashlight, sound effects,
> wallpaper, simple timers, and fortune telling, are well established on the App
> Store and **we will not accept new submissions unless they offer a meaningfully
> different or improved experience.**

The guideline is a bar **with a stated exception**, and the exception is being
meaningfully different. The rejection letter concedes in its own words that your
app may have features that distinguish it, and then sets that aside as
irrelevant. That is the letter declining to apply the second half of Apple's own
sentence.

Three more things the published guideline does not say:

- **"Saturated" appears nowhere in the App Review Guidelines.** Not once. The
  phrase is reviewer vocabulary, not a rule.
- **"There are already enough of these apps" is not the published test.** The
  test is a comparison, "indistinguishable from what's already widely available",
  not a headcount.
- **Astrology is not a named category.** The list is "dating, flashlight, sound
  effects, wallpaper, simple timers, and fortune telling". The words astrology,
  horoscope, tarot, divination and occult appear nowhere in 4.3. So whether a
  computational chart and an ephemeris are "fortune telling" is a
  characterisation Apple has to make and stand behind, not something the rule
  states.

That is your appeal. It is not a complaint about fairness in the abstract. It is
Apple's own published rule, and the rejection letter failing the second half of
it in writing.

---

## Where the leverage actually is

⚠ **An escalation built on the word discrimination will be closed without a
decision.** 4.3 is applied to a whole class of apps; a rule applied to everyone
in a class is not discrimination in any sense Apple or a regulator acts on,
however arbitrary it feels from inside it. Every paragraph spent on prejudice is
a paragraph Apple answers with the letter you have already had twice.

But your instinct that you were treated unfairly has a formal home. Apple
publishes **two** grounds for an App Review Board appeal, and the second is
exactly yours:

> If your app didn't pass review and you feel **we misunderstood your app's
> concept and functionality**, or that **you were treated unfairly by Apple in
> the course of our review**, you may choose to submit an appeal to the App
> Review Board.

Use both grounds by name. The second one is a process ground, and a reply that
links two design videos, one of them about games, to a nine-day-old substantive
submission is a process complaint, not a matter of taste.

The four things Apple cannot answer with a form letter:

1. **The exception in their own rule, above.** They conceded the premise of it
   and then ignored it.
2. **The comparison has never been made.** The letter's stated basis is that the
   app "duplicate[s] the content and functionality of similar apps that are
   already widely available". You have asked twice which apps. Nobody has named
   one. You cannot correct a resemblance you have not been shown.
3. **The Extended Review sentence has no published basis.** More on this below.
   It is the most serious sentence in the exchange and the easiest to make them
   substantiate or withdraw.
4. **The order.** A 4.3(b) judgement needs the name, description, screenshots,
   category and review notes. All of those sat in front of the first reviewer on
   12 September. It does not need in-app account deletion, an in-app privacy
   link, the removal of the support links, or a video shot on a physical device.

---

## ⚠ Fix this before you send anything

In your 15 September reply you wrote that the instruments "are computed by our
own server (Swiss Ephemeris, licensed)."

**That is true of the website and false of the iOS app.** The iOS build cannot
ship the Swiss Ephemeris at all: it is AGPL and the licence conflicts with
Apple's terms, which is the entire reason `tool/make_ios_variant.sh` exists. The
iOS app casts every chart on the phone from VSOP87 and ELP-2000/82. Your
12 September answer to their question 4 said so correctly: "All astronomical
calculation happens on the device … no server is asked for a chart." I checked
the source: `lib/services/chart.dart` opens with "A chart, cast on the phone" and
makes no network call.

So the same review conversation holds two incompatible answers about external
services, and the wrong one is the newer. Correct it yourself, in one sentence.
It costs nothing, and it is worth more than the error costs, because the whole
appeal asks them to be precise. Draft A does it in item 2.

---

## ⚠ Three traps in your own argument

**1. Do not say the app is for a closed group.** The first rejection already
pointed you at this, in its "Prevent Common Issues" list:

> Guideline 3.2 - Other Business Models: If your app is intended to be used by
> specific businesses, organizations or employees then use one of the other
> distribution options available to you through the Apple Developer Program
> Account.

The harder you press "this is my community's app", the closer you get to an
answer you do not want: then distribute it privately. Hold the line that the
community is **open to anybody who finds it**. The app is free, needs no
invitation, and anyone who installs it can read the letters and join the practice
room. A public app with a community in it, not an internal tool.

**2. The likeliest innocent explanation is also your best question.** The
practice room is the only surface behind a sign-in. The sky, the chart, the
hours, the letters and the horoscopes all open without an account. A reviewer who
did not use the demo account saw an astrology app with instruments in it, on an
iPad, and rejected it correctly on what was in front of them. Asking whether the
demo account was used is not an accusation, it is cheap to answer, and if the
answer is no then the finding was made about the only part of the app you already
agree resembles others.

**3. Apple's contract gives them absolute discretion, so ask for reasons, not
acceptance.** Developer Program Licence Agreement §6.9(b): Apple may "reject Your
Application for distribution for any reason, even if Your Application meets the
Documentation and Program Requirements." Nothing below changes that. What the EU
routes add is **procedural** duty: reasons, individualised answers, a complaint
system. That is the whole game. Ask to be told why, not to be let in.

---

## ⚠ One correction to what I told you before

I previously recorded the Extended Review notice as boilerplate attached to 4.3
rejections. **There is no evidence for that.** Searching Apple's guidelines,
their Digital Services Act risk assessment, the App Review pages and the App
Store Connect help, the sentence you were sent does not appear anywhere:

> This app was found to include one or more issues that present significant
> safety, security, or quality concerns to users.

Extended review is documented, by developers on Apple's own forums, as an
investigation of the **account**, and the boilerplate they quote is different
text about needing more time. The nearest published Apple wording is about
malware scanning, and its third term is **privacy**, not quality.

So treat that sentence as unexplained rather than routine. The removal threat
that follows it does have a basis, because 4.3(b) ends "Repeated submissions of
this kind may lead to removal from the Apple Developer Program." The safety and
security finding does not. That is the asymmetry to press.

---

## ⚠ Check the screenshots before you file

`BEFORE-THE-APP-STORE.md` records the instruction for the listing screenshots as:

> Three shots: the **Sky** tab, a **Chart**, the **Practice** room

If that is the order on the listing, then two of the three things a reviewer sees
first are astrological instruments, and the practice room is last. **That is very
likely the answer to the question you asked them and they would not answer.** A
reviewer scanning a listing whose first two images are a sky and a natal chart
sees an astrology app, and would have refused it correctly on what was in front
of them. The App Store listing is where this rejection probably happened, not in
the binary.

**Do this before you file:**

1. Open the listing in App Store Connect and look at the screenshots in order.
2. If the practice room is not first, **put it first**, and give it a caption that
   says what it is. Something like "Post a reading. Get it read back." Her words,
   not mine.
3. Screenshots and captions are **metadata**. Changing them needs no new build, so
   it does not touch the do-not-resubmit rule, and a reordered listing is not a
   resubmission of the same shape.
4. Check the subtitle and the keywords the same way. If the subtitle names
   astrology before it names the community, it is doing the rejection's work for
   it.

⚠ **Do not quietly change it and let the appeal describe the old listing.** If you
reorder before filing, add one sentence to Draft A, at the end of section 4:

> Since the review I have reordered the listing so that the practice room is the
> first screenshot rather than the third, because on reflection the listing led
> with the instruments and that is a fair thing to have been misled by.

That sentence costs you nothing and it gives the Board something to say yes to. A
reviewer who was misled by a listing can be shown a corrected listing. A reviewer
who is told they were wrong has to defend themselves.

⚠ **This does not make the appeal unnecessary.** The safety and security finding,
the unnamed comparison and the set-aside exception all stand whatever the
screenshots show. But if the screenshots are the cause, the appeal has a much
better chance with them fixed, and you will have found the answer they refused to
give you.

---

# How to file it

## Before you open the form

1. **Save the whole review conversation as a PDF.** Every message, both
   directions, with its date and timestamp. In App Store Connect, open the
   submission's App Review conversation and print to PDF. Do this first. It is
   the evidence base for every later step, you do not control how long it stays
   available to you, and Draft C quotes from it.
2. **Save the submission as it was reviewed.** The App Store listing screenshots,
   description, subtitle, keywords, category, age rating, and the App Review
   Information notes. The appeal argues about what a reviewer had in front of
   them, so keep a copy of what that was.
3. **Check whether Apple has answered this morning's message.** Apple's own
   instruction is "Respond to any requests for additional information before
   submitting an appeal." If they have asked you something, answer it first. ⚠ **If
   they name an app, stop.** The appeal then becomes a much shorter and much
   stronger letter about that one app, and it should be rewritten before sending.
4. **Do not cancel the submission and do not upload a build.** Leave it exactly
   where it is. An appeal against a submission you have withdrawn or replaced has
   nothing to attach to.

## Filing

5. Sign in at `developer.apple.com` with the Apple Account that holds the
   Developer Program membership, the Account Holder, not a secondary one.
6. Go to `https://developer.apple.com/contact/app-store/?topic=appeal`
7. **Read the form before you type.** Note the character limit on the free-text
   box, and whether there is a slot to attach a file. If the box is limited, paste
   the compressed version and add one line: "Full detail is available on request
   or in the review conversation."
8. Have the submission ID ready: `8a45fcfb-0fda-47c8-a247-11bf367e6d33`
9. Paste, read it through once, send. ⚠ One appeal per rejected submission. There
   is no second attempt, so the read-through matters.
10. Screenshot the confirmation screen and log the date and time.

## After

11. **Do not chase it for at least a week.** Apple publishes no timeline for
    appeal answers and no decision criteria. Any number you have read for this is
    somebody's estimate, not Apple's.
12. **Log every message in and out, with dates**, in `THE-DISPUTE-LOG.md` beside
    this file. Not for drama. Because Draft C and the mediation form both need a
    dated sequence, and reconstructing one from memory in six weeks is how a good
    case gets weak.
13. **If the answer names an app**, that is a win even though it will not feel
    like one. You can act on a named app. Answer on it.
14. **If the answer is boilerplate again**, Draft B if it ignores the safety
    finding, then Draft C, then mediation.

## What not to do, in one place

- **Not the word discrimination**, in any message, ever. It converts a procedural
  case into an accusation that Apple closes without a decision.
- **Not "this app is for my community."** Open to anyone who finds it. The first
  rejection already pointed you at Guideline 3.2 and private distribution.
- **Not a new build**, on any account, while this is open.
- **Not the guideline-change form yet.** That is a separate route for asking Apple
  to reword 4.3(b). It is worth doing one day. It is not this.
- **Not Draft A and Draft C together.** Mediation eligibility is keyed to an App
  Review Board decision, so the appeal has to exist and be answered first.

## On tone, once

Every inconsistency in Draft A is a matter of record, and the letter states each
one flatly and then asks for the rule to be applied. Keep it that way if you edit
it. The reader is a person who has to be able to say yes, and a letter that reads
as catching them out makes saying yes expensive. The last section, where you offer
to change whatever they name, is not politeness. It is the part that lets them
move.

---

# Draft A. The appeal to the App Review Board

**Route:** `https://developer.apple.com/contact/app-store/?topic=appeal`

⚠ **One appeal per rejected submission.** This has to be complete first time.

⚠ **Written as plain text on purpose.** No tables, no markdown, no characters
that might not survive. The form's box is almost certainly plain text, so this
pastes as it reads.

⚠ The form needs a signed-in Apple Account, so its field list and character limit
could not be checked from outside. **Look at the box before you paste.** If it is
short, send the compressed version below and offer the full text.

---

Appeal of the rejection of Shruti's Astrolabe under Guideline 4.3(b)

Submission ID: 8a45fcfb-0fda-47c8-a247-11bf367e6d33
App: Shruti's Astrolabe, version 1.0.0 (8)
Reviewed: 15 September 2026, iPad Air 11-inch (M3)

I am appealing on both of the grounds Apple states for an appeal: that the app's
concept and functionality were misunderstood, and that I was treated unfairly in
the course of the review. I have responded to every request for additional
information, and the earlier Guideline 2.1 issues were resolved in full before
this rejection was issued.

I am asking the Board for four things:

(a) That Guideline 4.3(b) be applied as written, including its exception.
(b) The apps the duplication finding refers to, or the finding set aside.
(c) Confirmation that the demo account was used to open the practice room, which
    is the app's primary surface and cannot be reached without signing in.
(d) The basis for the safety and security finding in the same message, or a
    record that there is none.


1. THE INCONSISTENCIES I AM ASKING THE BOARD TO RESOLVE

I have set these out plainly because each is a matter of record rather than of
opinion, and because I have not been able to get any of them addressed in the
review conversation.

1.1 The rejection sets aside the exception in the guideline it cites. Guideline
4.3(b) reads: "Certain kinds of apps, such as dating, flashlight, sound effects,
wallpaper, simple timers, and fortune telling, are well established on the App
Store and we will not accept new submissions unless they offer a meaningfully
different or improved experience." Being meaningfully different is therefore the
test. The rejection instead reads: "there are already enough of these apps on the
App Store." That is a different standard from the one the guideline sets.

1.2 The same paragraph concedes the exception's premise and then dismisses it.
"the app may include features or characteristics that distinguish it. However,
there are already enough of these apps on the App Store." Under the guideline as
written, if the app includes features that distinguish it, that is the beginning
of the analysis and not the end of it. I have never been told what was weighed.

1.3 The rejection reasons by duplication, and duplication is 4.3(a), not 4.3(b).
The stated issue is that the app's features "duplicate the content and
functionality of similar apps that are already widely available". Duplication of
one's own app across multiple Bundle IDs is the entire subject of 4.3(a). 4.3(b)
contains no duplication test; its test is whether the app is indistinguishable
from what is already widely available, which is a comparison to named things.

1.4 The category named in the rejection is not a category the guideline names.
4.3(b)'s list is dating, flashlight, sound effects, wallpaper, simple timers and
fortune telling. The words astrology, horoscope, tarot and divination do not
appear in Guideline 4.3 at all.

1.5 The rejection describes features the app does not have. It cites "astrology,
horoscopes, palm reading, fortune telling or zodiac reports". The app contains no
palm reading and no fortune telling. It publishes no zodiac report, no horoscope
feed and no daily sign content of any kind. It computes positions and draws
charts, and it predicts nothing about anybody's life.

1.6 The two review messages cannot both be true. The message of 12 September was
an information request under Guideline 2.1 and reported no defect, no crash and
no issue with the app itself. The message of 15 September states that the app
"was found to include one or more issues that present significant safety,
security, or quality concerns to users". Between those two dates the only changes
to the app were subtractions and additions I made at Apple's request: account
deletion added, a privacy policy link added, and the links that led to pages
where something could be bought removed. Nothing was introduced that could create
a safety or security issue, and the 15 September rejection itself identifies none.
I have also not been able to find that sentence in any published Apple document.

1.7 The reply of 24 September recommends material for a different kind of app and
engages with nothing I wrote. Nine days after a detailed submission, the answer
was to "consider ways to make the app stand out", with links to Essential Design
Principles, Design Tips for Great Games, and the Human Interface Guidelines. This
app is not a game. The reply does not mention the practice room, the community,
the absence of a horoscope feed, or any other point raised.

1.8 The objection that ended the submission required nothing the submission
produced. A 4.3(b) judgement rests on what the app is and what it offers: the
name, the description, the screenshots, the category and the review notes. All of
those were in front of the first reviewer on 12 September. In-app account
deletion, an in-app privacy link, the removal of the support links and a video
shot on a physical device change such a judgement by nothing. If the concept was
never going to be accepted, it could have been said on 12 September.

I am not asking the Board to agree that Apple must publish my app. I am asking
for the guideline to be applied as it is written, and for the questions above to
be answered rather than replaced.


2. WHAT THE APP IS, AND A CORRECTION I WOULD RATHER MAKE MYSELF

Shruti's Astrolabe is the companion app to shrutivtuber.com and to a live
streaming community that already exists. It is free, open to anyone who finds it,
and needs no invitation. Its surfaces are:

- The practice room. A moderated space where members post readings they have
  written themselves and receive feedback from other people learning the same
  craft. Reporting and blocking are built into it. The demo account in App Review
  Information opens directly onto it. This is the app's primary surface and the
  reason it exists.
- Stream notices. A push notification when the stream goes live and when a letter
  is published. Off until the person asks for them.
- The letters and the monthly horoscopes, written by one person by hand for this
  community, the same texts that are on the website. There is no generated feed.
- Instruments for a practice rather than reports: a whole-sign natal chart drawn
  to one tradition's conventions, planetary hours and the sunrise and sunset
  stations for the person's own place, a transit wheel, Greek letter-reckoning
  and a sigil builder.

A correction to my reply of 15 September, which I would rather make myself than
leave standing. I wrote there that the instruments are computed by our server
using the Swiss Ephemeris. That is true of the website and not of the iOS app,
which computes every position on the device from two published analytic theories,
VSOP87 and ELP-2000/82, and requests no chart from any server. This is what I
told you in answer to your question 4 on 12 September, and it is the accurate
one. The iOS build contains no third-party ephemeris.

There is nothing to buy in the app. No advertising, no analytics, no tracking, no
purchases, no subscriptions, no third-party authentication, no AI service.


3. THE DUPLICATION FINDING NAMES NO APP

I searched the App Store for another app in which people write astrological
readings for one another and receive feedback on them, and did not find one. I
asked which apps the finding refers to on 15 September, and again on
25 September. Neither reply named an app.

I cannot answer a comparison that has not been made, and I cannot change my app
to stop resembling apps I have not been shown. I am asking the Board either to
name them or to set the finding aside.


4. WHAT THE REVIEW APPEARS TO HAVE EXERCISED

The practice room is behind a sign-in. Everything else in the app opens on
launch: the sky, the chart, the hours, the letters. So a review that does not use
the demo account sees only the instruments, and the instruments on their own are
much closer to the thing 4.3(b) describes.

I am not asserting that this is what happened. I am asking to be told whether the
demo account in App Review Information was used, because if it was not, the
surface the whole submission rests on was never seen.

The submission was reviewed on an iPad Air 11-inch (M3). If any part of the app
presented badly at that size I would like to know, and I will fix it. That is a
report I can act on, and it is not what either message contained.


5. THE SAFETY AND SECURITY FINDING

Point 1.6 above sets out why the two messages cannot both be true. I want to be
plain about why this matters more to me than the rejection does.

If there is a safety or security issue in this app, I want to know what it is
more than I want this appeal, and I will fix it today. If there is not, I am
asking for it to be recorded that there is not. As it stands, an unexplained
safety finding and a warning about removal from the Apple Developer Program sit
against an account whose only submission was refused for being in a crowded
field, and I intend to submit other apps from this account.


6. WHAT I AM ASKING FOR, AND WHAT I WILL DO

I am not asking for an exception to Guideline 4.3, and I am not disputing that
Apple may decline an app at its discretion. I accept that there are a great many
astrology apps and that Apple is entitled to say so.

I am asking to be told what specifically is indistinguishable, so that I can
change it. I have now asked three times. If the Board's position is that this app
cannot be accepted in any form, I am asking to be told that in one sentence,
because I will then stop submitting it and build something else, and I would
rather learn that from the Board than from a fourth link to a design video.

Thank you for reading this.

Sophia Antonopoulou

---

## The compressed version, if the form has a small box

Plain text, around 400 words.

---

Appeal of the rejection of Shruti's Astrolabe under Guideline 4.3(b).
Submission 8a45fcfb-0fda-47c8-a247-11bf367e6d33, version 1.0.0 (8).

I appeal on both grounds Apple states: that the app's concept was misunderstood,
and that I was treated unfairly in the course of review. The earlier Guideline
2.1 issues were resolved in full first.

Four inconsistencies I am asking the Board to resolve.

1. Guideline 4.3(b) refuses new submissions in well-established categories
"unless they offer a meaningfully different or improved experience". The
rejection says instead that "there are already enough of these apps on the App
Store", and in the same paragraph concedes that my app "may include features or
characteristics that distinguish it". Under the guideline as written, that
concession is where the analysis starts. I have never been told what was weighed.

2. The rejection reasons by duplication, which is the subject of 4.3(a). 4.3(b)
asks whether an app is indistinguishable from what is already widely available.
That is a comparison, and I have asked twice which apps it is a comparison to.
Neither reply named one.

3. The rejection describes features the app does not have: palm reading, fortune
telling, zodiac reports. It has none of those. It has no horoscope feed and no
daily sign content. Astrology is not among the categories 4.3(b) names.

4. The 12 September review reported no defect. The 15 September message states
the app "was found to include one or more issues that present significant safety,
security, or quality concerns to users". Between those dates the only changes were
ones Apple asked for: deletion added, a privacy link added, purchase links
removed. Both messages cannot be true, and I cannot find that wording in any
published Apple document.

The app's primary surface is a practice room where members of a streaming
community write astrological readings for one another and get feedback, with
reporting and blocking built in. It is behind a sign-in, so a review that did not
use the demo account never saw it. Nothing in the app is for sale.

I am asking for four things: that 4.3(b) be applied including its exception; the
apps the duplication finding refers to, or the finding set aside; confirmation
that the demo account was used to open the practice room; and the basis for the
safety and security finding, or a record that there is none.

If the Board's position is that this app cannot be accepted in any form, I would
rather be told so plainly. Full detail on request.

Sophia Antonopoulou

---

# Draft B. The Extended Review finding, on its own

Send only if the appeal answer does not touch item 7. Through Contact Us, under
account matters, not into the review conversation.

> I am asking about an account-level finding rather than an app decision.
>
> The App Review message of 15 September 2026 for submission
> 8a45fcfb-0fda-47c8-a247-11bf367e6d33 states that the app "was found to include
> one or more issues that present significant safety, security, or quality
> concerns to users", and that repeated submissions of apps with these issues can
> lead to removal from the Apple Developer Program.
>
> No review of this app identified a safety issue, a security issue, or a defect.
> The first review, on 12 September, was an information request under Guideline
> 2.1 and reported nothing broken. The second, on 15 September, was a Guideline
> 4.3(b) decision about how many similar apps already exist. I have also not been
> able to find that wording in the App Review Guidelines or in any other
> published Apple document.
>
> Two questions.
>
> 1. What is the safety, security or quality issue? If there is one in my app I
>    will fix it, and I would rather fix it than appeal anything.
> 2. If that sentence is standard text rather than a finding about this app,
>    please confirm that, and please confirm that no safety or security finding is
>    recorded against this account.
>
> I am asking because the sentence is specific and serious, because I intend to
> submit other apps from this account, and because I need to know whether I am
> carrying a finding whose content I have never been told.

---

# Draft C. The P2B complaint

This is the real escalation, and it turns out Apple runs it themselves.

**Route:** `https://developer.apple.com/contact/p2b/` — Apple's complaint route
for developers established in the EU, required by the Developer Program Licence
Agreement and by Regulation (EU) 2019/1150. Free, and needs no lawyer.

**Why it is worth using.** Apple publishes its own annual figures for this route
at `developer.apple.com/support/p2b/`. For 13 July 2025 to 12 July 2026:

| | |
|---|---|
| Complaints filed, whole EU, whole App Store | 116 |
| Average time to process | 4.23 calendar days |
| Reversed | 14 |

One hundred and sixteen in a year. A carefully written complaint is not lost in a
queue, and Apple's own published average is four days.

**The ground to use** is Apple's own (c) from the Licence Agreement, which does
not require you to allege that Apple broke the Regulation: "measures taken by or
behavior of Apple that affect You and relate directly to distribution of Your
Licensed Application on the App Store in the region in which you are
established."

**The two sentences with the most weight.** Article 4(5) says a statement of
reasons "shall contain a reference to the specific facts or circumstances … that
led to the decision". Article 11(2)(c) says the outcome must be communicated "in
an individualised manner and drafted in plain and intelligible language".
Boilerplate is the named failure in both.

⚠ **The honest caveat, which you should know before you spend the effort.** Every
one of the 14 reversals Apple describes concerns an app already on the store that
was removed, or an account terminated or flagged. Apple's own summary of what the
route is for says "decisions to restrict or suspend distribution of apps from the
platform or terminate developer accounts". **None of the described cases is a new
submission that was never published.** The words of the Regulation are wide
enough to argue it covers a refusal to distribute, but nothing found says so, and
Apple's published practice does not show it. So this is arguable, not
established. Expect the first answer possibly to be that it is the wrong route,
which is why the draft asks them to say which one is right.

⚠ Send this **after** Draft A, not instead of it, and not at the same time.

> **Complaint under Regulation (EU) 2019/1150**
>
> Developer: [legal name exactly as it appears on the Apple Developer Program
> account], established in Belgium.
> App: Shruti's Astrolabe.
> Submission ID: 8a45fcfb-0fda-47c8-a247-11bf367e6d33.
> Ground: (c) — measures taken by or behaviour of Apple that affect me and relate
> directly to distribution of my licensed application on the App Store in the
> region in which I am established.
>
> On 15 September 2026 Apple declined to distribute this app under Guideline
> 4.3(b). I have asked three times which apps the finding compares mine to: in
> the review conversation on 15 September, again on 25 September, and in my appeal
> to the App Review Board on [date]. No answer has named an app. The reply of
> 24 September consisted of links to two development videos, one of them about
> games, and addressed none of the points I had made nine days earlier.
>
> I am not complaining that Apple refused my app. I am complaining that I have
> not been told why in terms I can act on. My complaint is about three things.
>
> **1. No statement of the specific facts.** The decision's stated basis is that
> my app's features "duplicate the content and functionality of similar apps that
> are already widely available". That is a comparison, and the comparison has
> never been stated. I cannot change my app to stop resembling apps that have not
> been identified.
>
> **2. The reasoning sets aside the exception in the guideline cited.** Guideline
> 4.3(b) provides that submissions in well-established categories are not
> accepted "unless they offer a meaningfully different or improved experience".
> The rejection states that my app "may include features or characteristics that
> distinguish it. However, there are already enough of these apps on the App
> Store." I have had no answer on whether the app offers a meaningfully different
> or improved experience, which is the test the guideline sets.
>
> **3. An unexplained safety and security finding.** The same message states that
> the app "was found to include one or more issues that present significant
> safety, security, or quality concerns to users", and warns of removal from the
> Apple Developer Program. No review of this app identified any safety issue,
> security issue or defect, and I have not found that wording in any published
> Apple document. I am asking what the finding is, or for confirmation that none
> is recorded against me.
>
> I am asking Apple to communicate the outcome in an individualised manner, and to
> provide a statement of reasons referring to the specific facts or circumstances
> that led to the decision.
>
> If this is not the correct route for a decision refusing a first submission
> rather than removing a published app, I would be grateful to be told which route
> is, and I will use it.
>
> [Signature]

---

## The order, and why the appeal is the gate

1. **Wait for the answer to this morning's message.** If it names an app, the
   picture changes and the appeal gets much shorter: you answer on the named app.
2. **Send Draft A to the App Review Board.** Once. Do not chase it for a week.
   Apple publishes no timeline for appeal answers, so any figure you have read
   elsewhere is not theirs.
3. **Send Draft B** if the appeal answer ignores the safety finding.
4. **Send Draft C** if the appeal answer names no app.
5. **Then, if you want to keep going: free mediation.** CEDR administers an EU
   mediation scheme for Apple, under the Digital Markets Act, free to you because
   Apple bears the cost. ⚠ **Eligibility is keyed to an App Review Board decision
   made on or after 7 March 2024.** So the appeal is not only worth making on its
   merits, it is the gate to this. The application form takes a summary of the
   facts in at most 500 words, which the compressed version of Draft A nearly
   is. Apple has 15 working days to agree to mediate.
   `cedr.com/mediation-services/schemes/platform-to-business-services/apple-eu-mediation/`

Two routes not worth your time. The Digital Services Act has certified
out-of-court dispute bodies, but none of the eleven covers app developers, and
none names Apple. And Belgium's designated authority for the P2B Regulation could
not be confirmed from a primary source, so do not write to a national regulator
naming one. If it ever comes to that, the confirmed Belgian contact is the
telecoms regulator BIPT, which is the Digital Services Act coordinator, not the
P2B one.

⚠ **Do not resubmit a build while any of this is open.** Nothing in the appeal
survives a resubmission of the same shape, and the repeated-submissions sentence
in 4.3(b) is real.

⚠ **None of this is a plan for shipping.** The durable answer is still the one
from 15 September: the app is the companion to a stream and a community that
already exist, and it should read that way from the App Store listing inward. The
appeal argues for this build; the repositioning is for the next one. They do not
contradict each other, as long as the appeal does not promise a change you then
make anyway.

---

# The mediation route

## What it is

Not a court, and not binding on anybody. A mediator is a neutral third party who
sits between you and Apple and tries to get you to an agreement. Nobody rules.
Nobody can order Apple to publish the app.

What it does give you, and this is the whole point, is **a named person at Apple
in a conversation with a neutral present**. For a solo developer that is the only
forum in the entire process where Apple has to engage with the substance rather
than send a letter. Every step before it can be answered with boilerplate. This
one cannot.

## Who runs it and what it costs

The **Centre for Effective Dispute Resolution**, CEDR, administers a mediation
scheme for Apple under the Digital Markets Act.

`cedr.com/mediation-services/schemes/platform-to-business-services/apple-eu-mediation/`

It is **free to you. Apple bears the cost of the mediation.** You pay only for any
legal help you choose to bring, and you do not need any.

Separately, Apple also names CEDR as its panel of mediators for the purposes of
Article 12 of the P2B Regulation, in the Developer Program Licence Agreement
itself. Same administrator, overlapping routes, and not worth untangling unless
someone asks you to. ⚠ The address Apple names is in London, outside the Union.

## Who is eligible

Per CEDR's page:

- A developer **established in the EU** who offers or **intends to offer**
  applications to customers located in the EU. You are in Belgium, so yes. Note
  "intends to offer", which on its face does not require the app to have been
  published, and that matters here because yours never was.
- ⚠ **The dispute must be about an App Review Board decision made on or after
  7 March 2024.** This is the gate, and it is why the appeal had to come first.
  Until the Board answers, there is nothing to mediate.
- The subject must concern access to **EU storefronts of the App Store**, or the
  Notarization process.

## How it runs

An online application form asking for your name, developer ID, contact details,
the app, your availability, and **a summary of the facts in at most 500 words**.
The compressed version of Draft A, further up this file, is 434 words and is
almost exactly that summary. It will need its opening changed from an appeal to a
description of the dispute, and a line added about what the Board answered.

Then, per CEDR's page:

| Step | Time |
|---|---|
| Apple decides whether to agree to mediate | 15 working days |
| Mediator contacts both parties after appointment | 5 working days |
| The session itself, from an eligible application | typically 30 to 45 business days |

⚠ **Those figures are CEDR's page as it read on 25 September 2026, and were not
checked against the scheme rules document.** Read the scheme rules before relying
on any deadline.

⚠ **Apple has to agree.** The form goes in, and Apple has fifteen working days to
decide whether to engage. Nothing found says they must.

## What to expect from it, honestly

Most likely: an explanation, and possibly a route. Someone tells you what the
objection actually was, which is the thing you have been asking for since
15 September and have never been given. If the screenshots were the problem, this
is where you would find that out for certain.

Least likely: Apple agreeing to publish this build as it stands.

That is worth knowing before you spend the effort, and it is still worth doing,
because an explanation is what you asked for and it is what the next app needs.

## When to start it

**Only after the Board answers.** Log the answer verbatim first. If the answer
names an app or gives real reasons, you may not want mediation at all, because you
will have got the thing mediation was for.

---

## Sources

Everything quoted above, with a URL and a fetch date for every claim, is in
`THE-APPEAL-SOURCES.md` beside this file. It also lists what could not be
verified, which matters: the phrase "significant safety, security, or quality
concerns" was found in no Apple document, Belgium's P2B authority could not be
confirmed to a primary source, and the appeal form's field limits could not be
read because the form needs a signed-in account.

⚠ Re-check the Regulation's wording against the Official Journal before filing
Draft C. The text used came from a secondary consolidation because the official
database blocked automated access, and the UK's amended version of the same
Regulation reads differently in exactly the places that matter.
