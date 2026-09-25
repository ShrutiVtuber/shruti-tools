# The other door onto an iPhone

Researched 25 September 2026. Every Apple page quoted here was fetched that day,
and every claim is sourced in `THE-OTHER-DOOR-SOURCES.md` beside this file.

⚠ **Read the date twice.** Apple's unified EU terms take effect **1 October
2026**, six days after this was written. Anything below about fees or agreements
must be re-checked on or after that date. What will not change is the finding in
the next section.

---

## The finding

**Guideline 4.3(b) does not apply outside the App Store.** The rule that ended the
submission has no purchase on an app distributed through an alternative app
marketplace.

This is not an inference. Apple's guidelines page carries a control called
"Highlight Notarization Review Guidelines Only", and the script behind it
(`scripts/filterNotarized.js`) greys out every element that does not carry a
`data-nr` attribute:

```js
if (!elem.hasAttribute("data-nr")) { ... elem.classList.add("lighter-2"); }
```

On the live page:

- **4.3(a)** is `<li data-nr>` and carries the "ASR & NR" icon. In scope for
  Notarization.
- **4.3(b)** is a bare `<li>`, with no `data-nr` and no icon. **Apple's own page
  greys it out** when a reader asks to see the Notarization Review Guidelines.

Apple's authoritative statement is on that page: "You can see which guidelines
apply to Notarization for iOS and iPadOS apps by clicking on 'Highlight
Notarization Review Guidelines Only' in the menu to the left." There is no
separate Notarization document; Apple's own "Notarization Review Guidelines" link
points back to the same page.

⚠ **The one gap.** Apple never writes the sentence "4.3(b) does not apply to
Notarization" in prose. The finding rests on the page's own markup and filter,
confirmed on three independent markers. It is corroborated by the rule's text,
whose every consequence is an App Store consequence: "degrades App Store
discovery", "we will not accept new submissions", "We may remove these apps from
the App Store".

So: notarization is a security and integrity check, not a taste check. The
objection was that there are enough astrology apps in Apple's shop. Outside
Apple's shop, that is not a thing anyone is deciding.

---

## What is open, and what is not

### ✅ An alternative app marketplace. This is the route.

**There is no eligibility screen on her at all.** The seven-criteria list that
keeps coming up gates *operating* a marketplace and gates Web Distribution. It
does not gate putting an app on somebody else's marketplace. For that she needs
only:

1. Her existing Apple Developer Program membership.
2. The updated Developer Program Licence Agreement accepted. A click, free.
3. **Notarization** of the build by Apple.
4. An alternative marketplace willing to carry it, and its token.

Marketplaces verified as operating: **AltStore PAL, Epic Games Store, Aptoide,
Skich, Onside, Mobivention**. ⚠ **Setapp Mobile shut down on 16 February 2026**,
so ignore anything that names it.

AltStore PAL's own documentation says: "You can distribute apps with AltStore PAL
from anywhere." ⚠ Read that marketplace's own terms before committing; a
marketplace is a second gatekeeper with its own rules, and this note has not
audited any of them.

### ❌ Web distribution from her own site. Closed.

This is the one she believed Apple "legally has to allow". It is a real Apple
programme and she does not qualify. It now requires meeting **one of seven**
criteria, and the rules changed from what was widely reported:

- More than **one million first annual installs worldwide** (not EU) **and** two
  continuous years or more of membership.
- Or a nonprofit, school or government fee waiver.
- Or a Dun & Bradstreet Global Business Ranking of Low or Below-Average Risk.
- Or a listing on a stock exchange.
- Or venture funding from a firm on Apple's named list.
- Or a USD 1,000,000 stand-by letter of credit held for six months.
- Or an audited unqualified opinion.

She meets none, and the criteria are written for "your organization". ⚠ Note also
that requests approved now are "issued to your account on October 1, 2026".

### ❌ Handing a user an installable file. Does not exist.

Notarization "applies to all apps, regardless of their distribution channel", and
the device's install-time check requires the install to have been "initiated
through an authorized alternative app marketplace or an approved developer's
website". Ad Hoc is capped at 100 devices per product family per membership year
with identifiers registered in advance, and the licence limits its audience to
people affiliated with her. The free-form distribution right in the agreement is
granted for **macOS only**.

### ⚠ TestFlight external. Worse than I told her.

Apple's own TestFlight overview says an external build "gets sent to App Review to
make sure it follows **the App Review Guidelines**". The full set. There is no
Notarization carve-out, so **4.3(b) is in scope for external TestFlight**. I
previously described this as a lighter beta review that a 4.3 flag "could" bite.
It is the same guidelines, and it would.

**Internal** testing, up to 100 App Store Connect users, still goes through no
review at all. That remains true and remains safe.

---

## What it costs

**Zero, either way.** From 1 October 2026 the Core Technology Fee is replaced by a
**Core Technology Commission of 5% of sales**. Install volume stops mattering
entirely. A free app with nothing sold inside it has a base of zero, so the
commission is zero.

⚠ **The one thing that keeps it zero.** Attachment 14, clause C reaches sales
"required to download or access" the app. So the rule she already follows is what
holds this at nothing: the Guides hosting tiers must stay **optional and web-only**,
and no app may require a purchase to be used. That was already the rule for other
reasons. It is now also the fee rule.

---

## On publishing the account of all this

The research went looking for a confidentiality clause covering review
correspondence and **did not find one**. The agreement's definition of Apple
Confidential Information is a closed list: pre-release software, services,
documentation, hardware, and one deployment package. "Resolution Center" appears
zero times in the entire agreement, and a separate clause expressly makes *her*
submissions non-confidential, in Apple's favour.

⚠ **But the live clause is a different one**, §9.4, Press Releases and Other
Publicity:

> You may not issue any press releases or make any other public statements
> regarding this Agreement, its terms and conditions, or the relationship of the
> parties without Apple's express prior written approval.

That names the Agreement and the relationship of the parties. It does not name
rejection letters. But it is broad, and where Apple draws the line is not
established. What this means in practice:

- **Quoting the guidelines and quoting the rejection letter** is quoting published
  policy and a decision about her own app. Developers do this constantly and Apple
  does not appear to act on it.
- **Writing about "the relationship of the parties"** is closer to the clause's
  words. A post that is a sourced account of a review is safer than one framed as
  a statement about her standing with Apple.
- The distinction is not a licence to be reckless, and none of this is legal
  advice. It is what the text says.

---

## What to do, in order

1. **Wait for the App Review Board.** The appeal is filed and it is still the
   cheapest route to the App Store itself, which reaches people who will never
   install a marketplace.
2. **After 1 October 2026**, re-read `/support/apps-in-the-eu/` and
   `/support/alternative-app-marketplace-in-the-eu/`. The terms change that day and
   this note was written before they landed.
3. **Accept the updated Developer Program Licence Agreement** when it appears in
   App Store Connect. Free, and nothing works without it.
4. **Pick a marketplace and read its terms.** AltStore PAL is the obvious first
   look because its documentation says it accepts apps from anywhere.
5. **Submit the build for notarization** rather than for App Review. Different
   process, different rulebook, and 4.3(b) is not in it.
6. ⚠ **Do not upload a build anywhere while the appeal is open.** Not because
   notarization would be refused, but because a resubmission of the same shape
   while the Board is deciding is the one move the rejection letter warned about.

⚠ **One process trap for whoever reads Apple's docs next.** Apple serves **soft
404s**: HTTP 200 with a "Page Not Found" body. Several plausible URLs, including
both Addendum URLs and `/support/notarization-ios/`, return 200 and are dead. The
live pages are `/support/web-distribution-eu/`, `/support/apps-in-the-eu/` and
`/support/alternative-app-marketplace-in-the-eu/`.
