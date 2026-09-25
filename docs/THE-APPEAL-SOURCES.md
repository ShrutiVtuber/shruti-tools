# App Store 4.3(b) rejection — escalation research

Research compiled **25 September 2026**. Developer: individual, established in Belgium (EU).
Rejection: Guideline 4.3(b) Design - Spam, following an earlier 2.1 Information Needed rejection that was resolved.

**How to read this document.** Every factual claim carries the URL it came from and the date it was
fetched. Where a page is an unofficial consolidation, a mirror, or where I could not verify something,
it is marked **[UNVERIFIED]** or **[INFERENCE]**. Nothing here is legal advice and nothing here
predicts an outcome.

---

## 1. Current exact text of Guideline 4.3

**Source:** https://developer.apple.com/app-store/review/guidelines/ — fetched 25 September 2026.

**Version/date caveat:** the page as fetched carried **no visible "last updated" or version date** in the
rendered text. Apple does not stamp a revision date on the guidelines page itself; it announces
changes separately in Developer News. So I can confirm only *what the page said on 25 September 2026*,
not which revision it is. **[Flagged as unverified: the revision date.]**

### 4.3 Spam — verbatim

> **4.3 Spam**
>
> **(a)** Don't create multiple Bundle IDs of the same app (for example, submitting a separate map app
> for every city in the world instead of a single worldwide map that allows users to search any city).
> This practice results in unnecessary apps, which makes it hard for users to find the apps they want.
> If your app has different versions for specific locations, sports teams, universities, etc., consider
> submitting a single app and providing the variations using in-app purchase.
>
> **(b)** Don't submit apps that are indistinguishable from what's already widely available.
> Opportunistically creating variants of existing app categories or popular apps degrades App Store
> discovery, reduces overall app quality, and harms both users and developers. Certain kinds of apps,
> such as dating, flashlight, sound effects, wallpaper, simple timers, and fortune telling, are well
> established on the App Store and we will not accept new submissions unless they offer a meaningfully
> different or improved experience. We may remove these apps from the App Store going forward if they
> are not updated, improved, or do not attract customers. Other kinds of apps, such as drinking games,
> Kama Sutra, fart, and burp apps, are mediocre, low-quality, or low-effort and do not add value to the
> App Store. Repeated submissions of this kind may lead to removal from the Apple Developer Program.

Note: 4.3(a) carries an inline "ASR & NR" key icon on the page (`/app-store/review/images/key-icon.svg`),
marking it as a guideline that applies to Alternative App Marketplaces / Notarization. 4.3(b) as
rendered does **not** carry that icon.

### What the rule actually requires — reading the text closely

These are readings of the quoted words, not Apple policy statements.

1. **"Saturation" alone is not the stated test.** 4.3(b)'s first sentence sets the test as
   *"indistinguishable from what's already widely available."* That is a comparative test about **this
   app versus the existing field**, not a headcount of the category.

2. **For a named, "well established" category the text sets an explicit and narrow exception.** The
   operative clause is: *"we will not accept new submissions unless they offer a meaningfully different
   or improved experience."* So even inside a named category, the rule is not a bar — it is a bar
   **with a stated exception**, and the exception is "meaningfully different or improved experience."
   A rejection that does not engage with whether the app is meaningfully different or improved has not
   applied the second half of Apple's own sentence.

3. **"Astrology" is NOT named. "Fortune telling" IS named.** The list is verbatim:
   *"dating, flashlight, sound effects, wallpaper, simple timers, and fortune telling."*
   The word "astrology" does not appear anywhere in 4.3. Neither does "horoscope", "tarot",
   "divination" or "occult". **[Verified by reading the fetched page text for section 4.3.]**
   Whether a computational ephemeris/chart tool is a "fortune telling" app is therefore a
   characterisation Apple would have to make and defend, not something the guideline states.

4. **The second list is a separate, harsher category.** *"drinking games, Kama Sutra, fart, and burp
   apps"* are described as *"mediocre, low-quality, or low-effort"* — and it is that list, not the
   "well established" list, that the "Repeated submissions of this kind may lead to removal from the
   Apple Developer Program" sentence follows. **[INFERENCE from sentence order; the text does not say
   the removal sentence is limited to the second list.]**

5. **4.3(a) is about duplication; 4.3(b) is not.** Duplication (multiple Bundle IDs of the same app) is
   the whole subject of (a). (b) contains no duplication requirement. So a 4.3(b) citation cannot be
   answered only by showing the developer has one app — but equally, Apple cannot rely on (a)'s
   duplication logic to support a (b) rejection.

### Adjacent guideline text that may be quoted at the developer (for context)

**4.2 Minimum Functionality**, verbatim, same page and fetch date:

> Your app should include features, content, and UI that elevate it beyond a repackaged website. If
> your app is not particularly useful, unique, or "app-like," it doesn't belong on the App Store. If
> your App doesn't provide some sort of lasting entertainment value or adequate utility, it may not be
> accepted. Apps that are simply a song or movie should be submitted to the iTunes Store. Apps that are
> simply a book or game guide should be submitted to the Apple Books Store.

Also verbatim from 4.2:

> **4.2.4** Intentionally omitted.
> **4.2.5** Intentionally omitted.

---

## 1b. Version date of the guidelines — RESOLVED

The rendered page body does carry a date, at the very end of the "After You Submit" section:

> Last Updated: June 8, 2026

**Source:** https://developer.apple.com/app-store/review/guidelines/ — raw HTML fetched 25 September 2026.
So the text quoted in section 1 is the **8 June 2026** revision, current as at 25 September 2026.

### Word-frequency checks on the full guidelines page (raw text, 25 September 2026)

These are exhaustive counts over the whole guidelines document, not just 4.3:

| Term | Occurrences |
|---|---|
| `astrolog` (astrology / astrological) | **0** |
| `horoscope` | **0** |
| `tarot` | **0** |
| `divination` | **0** |
| `occult` | **0** |
| `fortune` | **1** (only in 4.3(b), as "fortune telling") |
| `saturat` (saturated / saturation) | **0** |
| `Extended Review` | **0** |
| `App Review Board` | **0** |

**Why this matters, stated plainly:** the phrase *"saturated category"* — which App Review commonly
uses in 4.3(b) rejection messages — **does not appear anywhere in the App Review Guidelines.** Neither
does "astrology". Both are reviewer vocabulary, not guideline text. A rejection message that rests on
"saturated category" is therefore citing a standard Apple has not published. **[Verified by exhaustive
string search of the fetched page text; I am reporting the count, not asserting how Apple would
characterise it.]**

---

## 2. The App Review Board appeal process

### 2.1 The three distinct routes Apple publishes

**Source:** https://developer.apple.com/distribute/app-review/ — fetched 25 September 2026.
The link targets were also confirmed by extracting `<a href>` values from the raw HTML of
https://developer.apple.com/app-store/review/guidelines/ — fetched 25 September 2026.

| Route | Exact URL | Apple's own label |
|---|---|---|
| Appeal a review outcome | `https://developer.apple.com/contact/app-store/?topic=appeal` | "Submit an appeal" / "submit an appeal" |
| Suggest a guideline change | `https://developer.apple.com/contact/app-store/?topic=guideline` | "Make a suggestion" / "suggest changes to the guidelines" |
| Expedited review | `https://developer.apple.com/contact/app-store/?topic=expedite` | "Request an expedited review" |

**Yes — the two routes you asked about still both exist and are still separate.** Disputing the
*application* of a guideline to your app is the `?topic=appeal` route to the App Review Board.
Asking Apple to *change or clarify the guideline itself* is the `?topic=guideline` route. Apple's own
prose at the end of the guidelines page puts them in one sentence, which is useful to quote back:

> **Appeals** : If you disagree with the outcome of your review, please submit an appeal. This may help
> get your app on the store. You may also suggest changes to the guidelines themselves to help us
> improve the App Review process or identify a need for clarity in our policies.

**Source:** https://developer.apple.com/app-store/review/guidelines/ — fetched 25 September 2026.

**[INFERENCE, flagged]** Because these are two separate forms, a 4.3(b) case that argues *both* "you
applied it wrongly to my app" *and* "the guideline's category list is not clear enough about what it
covers" can legitimately be filed twice, once on each form, without breaching the one-appeal-per-
rejection rule (which is expressed as a rule about appeals). Apple does not say this anywhere; it is a
reading of the form structure.

### 2.2 What the appeal accepts — verbatim

**Source:** https://developer.apple.com/distribute/app-review/ — fetched 25 September 2026.

> **Appeals**
>
> If your app didn't pass review and you feel we misunderstood your app's concept and functionality,
> or that you were treated unfairly by Apple in the course of our review, you may choose to submit an
> appeal to the App Review Board. If you file an appeal, make sure to:
>
> - Provide specific reasons why you believe your app complies with the App Review Guidelines.
> - Submit only one appeal per submission that didn't pass review.
> - Respond to any requests for additional information before submitting an appeal.

Three things worth noting about that wording:

1. **There are two stated grounds, not one.** "we misunderstood your app's concept and functionality"
   **or** "you were treated unfairly by Apple in the course of our review". The second ground is
   about *process*, and boilerplate replies that do not engage with substantive points are a process
   complaint, not a concept complaint.
2. **"Respond to any requests for additional information before submitting an appeal."** The earlier
   2.1 Information Needed rejection was resolved — so this precondition is satisfied and can be said
   to be satisfied explicitly in the appeal.
3. **One appeal per rejected submission.** So the appeal text needs to be complete first time.

### 2.3 Stated timelines

- **Review timeline**, verbatim from https://developer.apple.com/distribute/app-review/ (fetched
  25 September 2026): *"On average, 90% of submissions are reviewed in less than 24 hours."*
- **Appeal response timeline: Apple publishes none.** I could find **no Apple-published SLA or target
  time for an App Review Board appeal response** on either the App Review page or the guidelines page.
  Third-party guides state "typically 5–7 business days" but that is **not** an Apple figure.
  **[UNVERIFIED — third-party estimate only; do not cite it to Apple as if it were Apple's.]**
- **Published criteria for how the Board decides: none found.** Apple publishes what to *include* in
  an appeal (the three bullets above). I found **no published decision criteria, no standard of
  review, no reasoned-decision commitment, and no published statistics** for the App Review Board
  itself. **[Flagged: absence of evidence after checking developer.apple.com/distribute/app-review/,
  the guidelines page, and Apple's DSA redress page.]**
  *However*, Apple does publish aggregate outcome statistics for its **P2B** complaint route — see
  section 3.2, which is the closest thing to published appeal statistics that exists.

### 2.4 The forms require sign-in — flagged limitation

All three `developer.apple.com/contact/...` URLs return **HTTP 302** to
`https://idmsa.apple.com/IDMSWebAuth/signin.html?...` when fetched unauthenticated
(checked 25 September 2026). So **I could not read the appeal form itself** — I cannot tell you its
field list, character limits, or whether it offers a file upload. That has to be checked while signed
in with the Apple Account that owns the app. **[UNVERIFIED: the contents of the appeal form.]**

The same is true of the P2B complaint form at `https://developer.apple.com/contact/p2b/`
(also 302 to idmsa sign-in, checked 25 September 2026).

### 2.5 What the Apple Developer Program License Agreement says about rejection discretion

Worth knowing before drafting, because Apple may rely on it. **Source:**
`https://developer.apple.com/support/downloads/terms/apple-developer-program/Apple-Developer-Program-License-Agreement-English.pdf`
— downloaded 25 September 2026. Document footer marks it **`LYL255` / `August 18, 2026`**.

Section 6.9 "Selection by Apple for Distribution", verbatim:

> You understand and agree that if You submit Your Application to Apple for distribution via the App
> Store, Custom App Distribution, or TestFlight, Apple may, in its sole discretion:
>
> (a) determine that Your Application does not meet all or any part of the Documentation or Program
> Requirements then in effect;
> (b) reject Your Application for distribution for any reason, even if Your Application meets the
> Documentation and Program Requirements; or
> (c) select and digitally sign Your Application for distribution via the App Store, Custom App
> Distribution, or TestFlight.

**Read this before writing anything that depends on Apple being contractually obliged to accept a
compliant app. It is not.** The contractual position is broad discretion. That is precisely why the
EU statutory routes in section 3 matter: they impose **procedural** duties (reasons, complaint
handling, mediation) that sit on top of that discretion, and they do so regardless of what the
contract says. **[INFERENCE about the interplay; I am not offering a legal conclusion.]**

---

## 3. EU escalation rights as a BUSINESS USER of the App Store

### 3.1 Regulation (EU) 2019/1150 (P2B) — operative text

**Sourcing note, important.** EUR-Lex was unreachable throughout this research: every attempt to
`https://eur-lex.europa.eu/...` returned **HTTP 202 with `x-amzn-waf-action: challenge`** and a
zero-length body (checked 25 September 2026, from a Belgian CloudFront edge, BRU51-P1). I therefore
took the text from **legislation.gov.uk**, which publishes the EU instrument and offers an explicit
**"Original (As adopted by EU)"** view alongside its UK-amended version.

- Full as-adopted text used: `https://www.legislation.gov.uk/eur/2019/1150/adopted` — downloaded
  25 September 2026.
- **Do not quote the legislation.gov.uk "Latest available (Revised)" view in an EU filing.** It is
  UK-amended. Concretely: in the revised view Article 12(1) second subparagraph reads *"outside the
  United Kingdom"*, whereas the as-adopted EU text reads *"outside the Union"*. I verified both.
  Everything quoted below is from the **as-adopted** view.
- **[Flagged]** Before filing, re-verify each quote against EUR-Lex itself
  (`https://eur-lex.europa.eu/eli/reg/2019/1150/oj/eng`) when that site is reachable, and cite the
  OJ reference (OJ L 186, 11.7.2019) rather than legislation.gov.uk.

#### Is the App Store in scope? Yes — and the Regulation says so in terms.

**Recital 11**, verbatim, as adopted:

> Examples of online intermediation services covered by this Regulation should consequently include
> online e-commerce market places, including collaborative ones on which business users are active,
> **online software applications services, such as application stores**, and online social media
> services, irrespective of the technology used to provide such services.

(Emphasis added.) That is the express answer to "are app stores in scope as online intermediation
services": the co-legislators named application stores as an example.

**Article 2(2)** — the definition itself, verbatim:

> (2) 'online intermediation services' means services which meet all of the following requirements:
> (a) they constitute information society services within the meaning of point (b) of Article 1(1) of
> Directive (EU) 2015/1535 of the European Parliament and of the Council;
> (b) they allow business users to offer goods or services to consumers, with a view to facilitating
> the initiating of direct transactions between those business users and consumers, irrespective of
> where those transactions are ultimately concluded;
> (c) they are provided to business users on the basis of contractual relationships between the
> provider of those services and business users which offer goods or services to consumers;

**Article 2(1)** — "business user", verbatim. Note that it expressly covers a sole individual:

> (1) 'business user' means **any private individual acting in a commercial or professional capacity**
> who, or any legal person which, through online intermediation services offers goods or services to
> consumers for purposes relating to its trade, business, craft or profession;

(Emphasis added.) An individual developer in Belgium selling or offering an app to EU consumers fits
the words of this definition. **[The words fit; whether a particular developer is a "business user" on
the facts is a legal characterisation, not something I can verify.]**

**Article 1(2)** — territorial scope, verbatim:

> 2. This Regulation shall apply to online intermediation services and online search engines provided,
> or offered to be provided, to business users and corporate website users, respectively, that have
> their place of establishment or residence in the Union and that, through those online intermediation
> services or online search engines, offer goods or services to consumers located in the Union,
> irrespective of the place of establishment or residence of the providers of those services and
> irrespective of the law otherwise applicable.

Two things to notice. First, the hook is **the business user's** establishment (Belgium = Union), not
Apple's. Second, *"or offered to be provided"* — the scope sentence is not limited to services already
being provided. **[INFERENCE that this helps a never-published app; the Regulation does not say so.]**

#### Article 4 — Restriction, suspension and termination (statement of reasons)

Verbatim, as adopted:

> **Article 4 Restriction, suspension and termination**
>
> 1. Where a provider of online intermediation services decides to restrict or suspend the provision of
> its online intermediation services to a given business user in relation to individual goods or
> services offered by that business user, it shall provide the business user concerned, prior to or at
> the time of the restriction or suspension taking effect, with a statement of reasons for that
> decision on a durable medium.
>
> 2. Where a provider of online intermediation services decides to terminate the provision of the whole
> of its online intermediation services to a given business user, it shall provide the business user
> concerned, at least 30 days prior to the termination taking effect, with a statement of reasons for
> that decision on a durable medium.
>
> 3. In the case of restriction, suspension or termination, the provider of online intermediation
> services shall give the business user the opportunity to clarify the facts and circumstances in the
> framework of the internal complaint-handling process referred to in Article 11. Where the
> restriction, suspension or termination is revoked by the provider of online intermediation services,
> it shall reinstate the business user without undue delay, including providing the business user with
> any access to personal or other data, or both, that resulted from its use of the relevant online
> intermediation services prior to the restriction, suspension or termination having taken effect.
>
> 4. The notice period in paragraph 2 shall not apply where a provider of online intermediation
> services:
> (a) is subject to a legal or regulatory obligation which requires it to terminate the provision of
> the whole of its online intermediation services to a given business user in a manner which does not
> allow it to respect that notice period; or
> (b) exercises a right of termination under an imperative reason pursuant to national law which is in
> compliance with Union law;
> (c) can demonstrate that the business user concerned has repeatedly infringed the applicable terms
> and conditions, resulting in the termination of the provision of the whole of the online
> intermediation services in question.
>
> In cases where the notice period in paragraph 2 does not apply, the provider of online intermediation
> services shall provide the business user concerned, without undue delay, with a statement of reasons
> for that decision on a durable medium.
>
> 5. The statement of reasons referred to in paragraphs 1, and 2 and in the second subparagraph of
> paragraph 4 shall contain a reference to the specific facts or circumstances, including contents of
> third party notifications, that led to the decision of the provider of online intermediation
> services, as well as a reference to the applicable grounds for that decision referred to in point (c)
> of Article 3(1).
>
> A provider of online intermediation services does not have to provide a statement of reasons where it
> is subject to a legal or regulatory obligation not to provide the specific facts or circumstances or
> the reference to the applicable ground or grounds, or where a provider of online intermediation
> services can demonstrate that the business user concerned has repeatedly infringed the applicable
> terms and conditions, resulting in termination of the provision of the whole of the online
> intermediation services in question.

**The load-bearing words for a boilerplate-reply complaint are in Article 4(5):** the statement of
reasons *"shall contain a reference to the **specific facts or circumstances** ... that led to the
decision"*. Not the ground. The **facts**. A reply that restates the guideline number and the phrase
"saturated category" states a ground and no facts.

Article 4(5) also cross-refers to **Article 3(1)(c)**, which is the obligation to have published the
grounds in the first place. Verbatim:

> 1. Providers of online intermediation services shall ensure that their terms and conditions: ...
> (c) set out the grounds for decisions to suspend or terminate or impose any other kind of restriction
> upon, in whole or in part, the provision of their online intermediation services to business users;

Note **"or impose any other kind of restriction"** — the drafting is deliberately wider than
suspension and termination.

And **Article 4(3)** is the hinge to the complaint system: the provider *"shall give the business user
the opportunity to clarify the facts and circumstances in the framework of the internal complaint-
handling process referred to in Article 11."* That is a **right to be heard on the facts**, not merely
a right to be told the outcome.

#### Article 11 — Internal complaint-handling system

Verbatim, as adopted:

> **Article 11 Internal complaint-handling system**
>
> 1. Providers of online intermediation services shall provide for an internal system for handling the
> complaints of business users.
>
> That internal complaint-handling system shall be easily accessible and free of charge for business
> users and shall ensure handling within a reasonable time frame. It shall be based on the principles
> of transparency and equal treatment applied to equivalent situations, and treating complaints in a
> manner which is proportionate to their importance and complexity. It shall allow business users to
> lodge complaints directly with the provider concerned regarding any of the following issues:
>
> (a) alleged non-compliance by that provider with any obligations laid down in this Regulation which
> affects the business user lodging the complaint ('the complainant');
> (b) technological issues which relate directly to the provision of online intermediation services,
> and which affect the complainant;
> (c) measures taken by, or behaviour of, that provider which relate directly to the provision of the
> online intermediation services, and which affect the complainant.
>
> 2. As part of their internal complaint-handling system, providers of online intermediation services
> shall:
> (a) duly consider complaints lodged and the follow-up which they may need to give to the complaint in
> order to adequately address the issue raised;
> (b) process complaints swiftly and effectively, taking into account the importance and complexity of
> the issue raised;
> (c) communicate to the complainant the outcome of the internal complaint-handling process, in an
> individualised manner and drafted in plain and intelligible language.
>
> 3. Providers of online intermediation services shall provide in their terms and conditions all
> relevant information relating to the access to and functioning of their internal complaint-handling
> system.
>
> 4. Providers of online intermediation services shall establish and make easily available to the
> public information on the functioning and effectiveness of their internal complaint-handling system.
> They shall verify the information at least annually and where significant changes are needed, they
> shall update that information.
>
> That information shall include the total number of complaints lodged, the main types of complaints,
> the average time period needed to process the complaints and aggregated information regarding the
> outcome of the complaints.
>
> 5. The provisions of this Article shall not apply to providers of online intermediation services that
> are small enterprises within the meaning of the Annex to Recommendation 2003/361/EC.

**Two phrases are directly usable against boilerplate.** Article 11(2)(a): *"duly consider complaints
lodged"*. Article 11(2)(c): *"communicate to the complainant the outcome ... in an **individualised
manner** and drafted in plain and intelligible language."* "Individualised" is the opposite of
boilerplate, and it is the Regulation's own word.

Also note **Article 11(1)(c)** is broad: *"measures taken by, or behaviour of, that provider"*. A
complaint does not have to allege a breach of the Regulation (that is 11(1)(a)); it can simply be
about a measure Apple took. **[Reading of the text.]**

#### Article 12 — Mediation

Verbatim, as adopted (paragraphs 1 and 2 confirmed against the "Original (As adopted by EU)" view;
paragraphs 3–7 are identical in both views):

> **Article 12 Mediation**
>
> 1. Providers of online intermediation services shall identify in their terms and conditions two or
> more mediators with which they are willing to engage to attempt to reach an agreement with business
> users on the settlement, out of court, of any disputes between the provider and the business user
> arising in relation to the provision of the online intermediation services concerned, including
> complaints that could not be resolved by means of the internal complaint-handling system referred to
> in Article 11.
>
> Providers of online intermediation services may only identify mediators providing their mediation
> services from a location outside the Union where it is ensured that the business users concerned are
> not effectively deprived of the benefit of any legal safeguards laid down in Union law or the law of
> the Member States as a consequence of the mediators providing those services from outside the Union.
>
> 2. The mediators referred to in paragraph 1 shall meet the following requirements:
> (a) they are impartial and independent;
> (b) their mediation services are affordable for business users of the online intermediation services
> concerned;
> (c) they are capable of providing their mediation services in the language of the terms and
> conditions which govern the contractual relationship between the provider of online intermediation
> services and the business user concerned;
> (d) they are easily accessible either physically in the place of establishment or residence of the
> business user, or remotely using communication technologies;
> (e) they are capable of providing their mediation services without undue delay;
> (f) they have a sufficient understanding of general business-to-business commercial relations,
> allowing them to contribute effectively to the attempt to settle the disputes.
>
> 3. Notwithstanding the voluntary nature of mediation, providers of online intermediation services and
> business users shall engage in good faith throughout any mediation attempts conducted pursuant to
> this Article.
>
> 4. Providers of online intermediation services shall bear a reasonable proportion of the total costs
> of mediation in each individual case. A reasonable proportion of those total costs shall be
> determined, on the basis of a suggestion by the mediator, by taking into account all relevant
> elements of the case at hand, in particular the relative merits of the claims of the parties to the
> dispute, the conduct of the parties, as well as the size and financial strength of the parties
> relative to one another.
>
> 5. Any attempt to reach an agreement through mediation on the settlement of a dispute in accordance
> with this Article shall not affect the rights of the providers of online intermediation services and
> of the business users concerned to initiate judicial proceedings at any time before, during or after
> the mediation process.
>
> 6. If requested by a business user, before entering into or during mediation, the provider of online
> intermediation services shall make available, to the business user, information on the functioning
> and effectiveness of mediation related to its activities.
>
> 7. The obligation set out in paragraph 1 shall not apply to providers of online intermediation
> services that are small enterprises within the meaning of the Annex to Recommendation 2003/361/EC.

**Article 12(6) is a free, low-cost, concrete ask** that most developers never make: on request, Apple
must hand over information on the functioning and effectiveness of mediation related to its activities.
It is a one-sentence request with a statutory basis.

### 3.2 Apple's published P2B route for EU developers — it exists, and here is where

This is the most immediately useful finding in the whole document. **Apple runs a P2B complaint route
specifically for EU developers, and publishes annual statistics on it, and almost nobody uses it.**

#### The complaint form

> **https://developer.apple.com/contact/p2b/**

**Sources, both fetched/downloaded 25 September 2026:**

1. Apple's DSA redress page, https://www.apple.com/legal/dsa/en/redress-options.html, under the
   heading "Developer Account Terminations & App Removals", verbatim:

   > If you have a concern regarding measures taken by or behavior of Apple that affect you and relate
   > directly to distribution of your licensed app on the App Store in the region in which you are
   > established, you may submit a complaint pursuant to the Regulation (EU) 2019/1150 of the European
   > Parliament and of the Council of 20 June 2019 on promoting fairness and transparency for business
   > users of online intermediation services. Apple will consider and process such complaints and
   > communicate the outcome to you.

   (The words "submit a complaint" hyperlink to `https://developer.apple.com/contact/p2b/`.)

2. The **Apple Developer Program License Agreement** itself, Schedule 1 / section 3 "Redress Options
   Pursuant to P2B and DSA Regulations" (document `LYL255`, dated **August 18, 2026**), verbatim:

   > Developers established in, and which offer goods or services to customers located in, a region
   > subject to a platform-to-business regulation ("P2B Regulation"), such as the Regulation of the
   > European Parliament and of the Council on promoting fairness and transparency for business users of
   > online intermediation services may submit complaints pursuant to such P2B Regulation related to the
   > following issues at https://developer.apple.com/contact/p2b/: (a) Apple's alleged non-compliance
   > with any obligations set forth in the P2B Regulation which affect You in the region in which you are
   > established; (b) technological issues that affect You and relate directly to distribution of Your
   > Licensed Application on the App Store in the region in which you are established; or (c) measures
   > taken by or behavior of Apple that affect You and relate directly to distribution of Your Licensed
   > Application on the App Store in the region in which you are established. Apple will consider and
   > process such complaints and communicate the outcome to you.

   Source: `https://developer.apple.com/support/downloads/terms/apple-developer-program/Apple-Developer-Program-License-Agreement-English.pdf`
   (listed from https://developer.apple.com/support/terms/) — downloaded 25 September 2026.

   Note that Apple's own (a)/(b)/(c) map exactly onto **Article 11(1)(a)/(b)/(c)**. Ground **(c)**
   — *"measures taken by or behavior of Apple that affect You and relate directly to distribution of
   Your Licensed Application"* — is the one that fits a rejection and a boilerplate reply, and it does
   **not** require alleging a breach of the Regulation.

#### Apple's named mediators — CEDR, and only CEDR

Same DPLA section, verbatim:

> For Developers established in, and which offer goods or services to customers located in, the
> European Union, Apple identifies the following panel of mediators with which Apple is willing to
> engage to attempt to reach an agreement with developers established in, and which offer goods or
> services to customers located in, the European Union on the settlement, out of court, of any disputes
> between Apple and You arising in relation to the provision of the App Store services concerned,
> including complaints that could not be resolved by means of our complaint-handling system:
>
> Centre for Effective Dispute Resolution
> P2B Panel of Mediators
> 70 Fleet Street
> London
> EC4Y 1EU
> United Kingdom
> https://www.cedr.com/p2bmediation/

**Observation, offered as an observation only.** Article 12(1) requires the provider to identify
*"two or more mediators"*. Apple identifies **one body** (CEDR) hosting a *panel*. CEDR's own page
states: *"The P2B Regulation requires Platforms to name at least two mediators that the Platform is
willing to engage in a dispute. CEDR's P2B panel includes over 50 mediators based around the EU."*
(https://www.cedr.com/p2bmediation/ — fetched 25 September 2026.) So the panel-of-50 framing is CEDR's
answer to the two-mediator requirement. Also note the named address is **London, United Kingdom** —
i.e. outside the Union, which engages the second subparagraph of Article 12(1). **[I am recording what
the documents say. Whether naming one UK-based panel satisfies Article 12(1) is a legal question I am
not answering.]**

#### Apple's Article 11(4) annual report — the numbers

**Source:** https://developer.apple.com/support/p2b/ — fetched 25 September 2026. Titled
*"App Store annual report on P2B internal complaint-handling system"*, subtitled *"Provided pursuant to
Article 11 of Regulation (EU) 2019/1150..."*. It carries six reporting periods (2020-21 through
2025-26).

**Most recent period, 13 July 2025 – 12 July 2026**, verbatim figures:

| Metric | Value |
|---|---|
| Total number of complaints filed | **116** |
| Average time to process | **4.23 calendar days** |
| Upheld | **102 of 116** |
| Reversed | **14** |

Prior periods for trend: 2024-25 = **48** complaints (3.96 days, 5 reversed of 48);
2023-24 = **42** complaints (4.33 days, 5 reversed of 42).

Apple's own description of what the route is used for, verbatim (2025-26 period):

> Types of complaints: the P2B complaints received by Apple related to decisions to restrict or suspend
> distribution of apps from the platform or terminate developer accounts.

And the breakdown of the 14 reversals, verbatim:

> Two apps removed from the platform due to an unresolved App Review Guideline violation were restored
> after the developer submitted information to address the violation.
> Eight developers that were terminated submitted new information to address violations of the App
> Review Guidelines and the Apple Developer Program License Agreement. Accordingly, the decisions to
> terminate were reversed and relevant apps were restored to the App Store.
> The decisions to flag three developer accounts for termination were reversed and relevant apps were
> restored to the App Store after investigations identified evidence to support maintaining the
> accounts.
> The decision to terminate one developer account was reversed and the relevant app was restored to the
> App Store after investigations identified evidence to support maintaining the account.

**Three things to take from this, stated carefully:**

1. **Volume is tiny.** 116 complaints in a year, across the entire EU, for the whole App Store. This is
   a route almost no one uses. A well-drafted complaint is not lost in a queue.
2. **Turnaround is fast — 4.23 calendar days average, by Apple's own published figure.** That is far
   faster than the (unpublished) App Review Board appeal, and Apple has published the number, so it can
   be cited back.
3. **CAVEAT, and it is a real one.** Every single one of the 14 reversals described involves an **app
   already on the store that was removed**, or a **developer account terminated or flagged for
   termination**. **None of the described reversals is a rejection of a new submission that was never
   published.** Apple's own "Types of complaints" sentence likewise speaks of *"restrict or suspend
   distribution"* and *"terminate developer accounts"*.
   **[This is the central uncertainty in the P2B route for this case, and it should not be glossed.]**
   Against that: Article 4(1) speaks of a decision to *"restrict ... in relation to individual goods or
   services"*, Article 3(1)(c) speaks of *"any other kind of restriction"*, Article 11(1)(c) speaks of
   *"measures taken by, or behaviour of, that provider"*, and Apple's own ground (c) in the DPLA is
   *"measures taken by or behavior of Apple ... that relate directly to distribution of Your Licensed
   Application"*. Those words are wide enough to be argued to cover a refusal to distribute. **But no
   source I found says so, and Apple's published practice does not show it.** Treat the P2B route for a
   never-published app as **arguable, not established.**

### 3.3 Digital Services Act (Regulation (EU) 2022/2065)

#### Is the App Store a designated VLOP? Yes.

**Source:** https://digital-strategy.ec.europa.eu/en/policies/list-designated-vlops-and-vloses —
fetched 25 September 2026; the page states it was last updated **7 September 2026**.

- Designated service: **"App Store"**
- Provider of main establishment: **Apple Distribution International Limited**
- **Designation date: 25 April 2023** (shown as `25.04.2023`)

(The list names the service simply as "App Store", not "Apple App Store".)

#### DSA Articles 17, 20, 21 — text and who they cover

**Sourcing caveat, please read.** EUR-Lex was unreachable (see 3.1). The verbatim DSA text below is
from **https://www.eu-digital-services-act.com/**, an **unofficial** consolidation which labels itself
*"the final text of the Digital Services Act"* and identifies the instrument as *"Regulation (EU)
2022/2065 ... of 19 October 2022"*. Pages fetched 25 September 2026
(`/Digital_Services_Act_Article_17.html`, `_20.html`, `_21.html`).
**[UNVERIFIED against EUR-Lex. Re-verify every DSA quote against EUR-Lex / OJ L 277, 27.10.2022 before
filing anything. Cite the OJ, not this site.]**

**Article 17(1), verbatim:**

> Providers of hosting services shall provide a clear and specific statement of reasons to any affected
> recipients of the service for any of the following restrictions imposed on the ground that the
> information provided by the recipient of the service is illegal content or incompatible with their
> terms and conditions:
> (a) any restrictions of the visibility of specific items of information provided by the recipient of
> the service, including removal of content, disabling access to content, or demoting content;
> (b) suspension, termination or other restriction of monetary payments;
> (c) suspension or termination of the provision of the service in whole or in part;
> (d) suspension or termination of the recipient of the service's account.

**Article 17(3), verbatim** (this is the anti-boilerplate provision):

> The statement of reasons referred to in paragraph 1 shall at least contain the following information:
> (a) information on whether the decision entails either the removal of, the disabling of access to, the
> demotion of or the restriction of the visibility of the information, or the suspension or termination
> of monetary payments related to that information, or imposes other measures referred to in paragraph 1
> with regard to the information, and, where relevant, the territorial scope of the decision and its
> duration;
> (b) the facts and circumstances relied on in taking the decision, including, where relevant,
> information on whether the decision was taken pursuant to a notice submitted in accordance with
> Article 16 or based on voluntary own-initiative investigations and, where strictly necessary, the
> identity of the notifier;
> (c) where applicable, information on the use made of automated means in taking the decision, including
> information on whether the decision was taken in respect of content detected or identified using
> automated means;
> (d) where the decision concerns allegedly illegal content, a reference to the legal ground relied on
> and explanations as to why the information is considered to be illegal content on that ground;
> (e) where the decision is based on the alleged incompatibility of the information with the terms and
> conditions of the provider of hosting services, a reference to the contractual ground relied on and
> explanations as to why the information is considered to be incompatible with that ground;
> (f) clear and user-friendly information on the possibilities for redress available to the recipient of
> the service in respect of the decision, in particular, where applicable through internal
> complaint-handling mechanisms, out-of-court dispute settlement and judicial redress.

**Article 17(4), verbatim:**

> The information provided by the providers of hosting services in accordance with this Article shall be
> clear and easily comprehensible and as precise and specific as reasonably possible under the given
> circumstances. The information shall, in particular, be such as to reasonably allow the recipient of
> the service concerned to effectively exercise the possibilities for redress referred to in of
> paragraph 3, point (f).

**Point (e) is the one to hold onto:** where the decision rests on incompatibility with the provider's
terms, the statement must give *"a reference to the contractual ground relied on **and explanations as
to why** the information is considered to be incompatible with that ground."* A guideline number plus
"saturated category" is a reference without an explanation.

**Article 20(1), verbatim** (note precisely who is covered):

> Providers of online platforms shall provide recipients of the service, including individuals or
> entities that have submitted a notice, for a period of at least six months following the decision
> referred to in this paragraph, with access to an effective internal complaint-handling system that
> enables them to lodge complaints, electronically and free of charge, against the decision taken by the
> provider of the online platform upon the receipt of a notice or against the following decisions taken
> by the provider of the online platform on the grounds that the information provided by the recipients
> constitutes illegal content or is incompatible with its terms and conditions:
> (a) decisions whether or not to remove or disable access to or restrict visibility of the information;
> (b) decisions whether or not to suspend or terminate the provision of the service, in whole or in
> part, to the recipients;
> (c) decisions whether or not to suspend or terminate the recipients' account;
> (d) decisions whether or not to suspend, terminate or otherwise restrict the ability to monetise
> information provided by the recipients.

**Article 20(4) and 20(6), verbatim:**

> 4. Providers of online platforms shall handle complaints submitted through their internal
> complaint-handling system in a timely, non-discriminatory, diligent and non-arbitrary manner. Where a
> complaint contains sufficient grounds for the provider of the online platform to consider that its
> decision not to act upon the notice is unfounded or that the information to which the complaint relates
> is not illegal and is not incompatible with its terms and conditions, or contains information
> indicating that the complainant's conduct does not warrant the measure taken, it shall reverse its
> decision referred to in paragraph 1 without undue delay.
>
> 6. Providers of online platforms shall ensure that the decisions, referred to in paragraph 5, are
> taken under the supervision of appropriately qualified staff, and not solely on the basis of automated
> means.

**"non-arbitrary"** in 20(4) and **"not solely on the basis of automated means"** in 20(6) are both
directly on point for repeated boilerplate.

**Article 21(1), verbatim** (out-of-court dispute settlement):

> Recipients of the service, including individuals or entities that have submitted notices, addressed by
> the decisions referred to in Article 20(1) shall be entitled to select any out-of-court dispute
> settlement body that has been certified in accordance with paragraph 3 of this Article in order to
> resolve disputes relating to those decisions, including complaints that have not been resolved by
> means of the internal complaint-handling system referred to in that Article.

Cost rules, **Article 21(5), verbatim**, first two subparagraphs:

> If the out-of-court dispute settlement body decides the dispute in favour of the recipient of the
> service, including the individual or entity that has submitted a notice, the provider of the online
> platform shall bear all the fees charged by the out-of-court dispute settlement body, and shall
> reimburse that recipient, including the individual or entity, for any other reasonable expenses that it
> has paid in relation to the dispute settlement.
>
> If the out-of-court dispute settlement body decides the dispute in favour of the provider of the online
> platform, the recipient of the service, including the individual or entity, shall not be required to
> reimburse any fees or other expenses that the provider of the online platform paid or is to pay in
> relation to the dispute settlement, unless the out-of-court dispute settlement body finds that that
> recipient manifestly acted in bad faith.

Last subparagraph of 21(5), verbatim: *"For recipients of the service, the dispute settlement shall be
available free of charge or at a nominal fee."*
Timing, **Article 21(4)**: decisions *"within a reasonable period of time and no later than 90 calendar
days after the receipt of the complaint"*, extendable once by up to 90 days for highly complex disputes,
*"resulting in a maximum total duration of 180 days."*
**Article 21(2)**: *"The certified out-of-court dispute settlement body shall not have the power to
impose a binding settlement of the dispute on the parties."* Non-binding — worth knowing before
investing effort.

#### Does Apple apply Articles 17/20/21 to developers, or only to end users? — Apple applies them to developers, but framed around removals and terminations

**This is the precise answer, and the precision matters.**

**Apple does apply the DSA redress framework to developers, not only to consumers.** Evidence, both
from 25 September 2026:

- https://www.apple.com/legal/dsa/en/redress-options.html has a developer-facing section headed
  **"Developer Account Terminations & App Removals"**, and a later section headed **"DSA Out-of-Court
  Dispute Settlement – App Store, Apple Books (ebooks) or Apple Podcasts Subscriptions"**, which says
  verbatim:

  > If you disagree with a decision that Apple has taken with respect to App Store, Apple Books (ebooks)
  > or Apple Podcasts Subscriptions to restrict or remove your content or account in the ways described
  > above or if you disagree with a decision that Apple has made in response to a notice submitted to
  > Apple's DSA Notice and Action portal regarding these services, you are entitled to engage with a DSA
  > certified out-of-court dispute settlement body with a view to resolving your dispute.

- The DPLA (LYL255, 18 August 2026) says verbatim:

  > For Developers established in, and which offer goods or services to customers located in, the
  > European Union and subject to the Regulation (EU) 2022/2065 ... more information about redress
  > options available to You in connection with action Apple took against You, **for example termination
  > of Your developer account or removal of Your app from the App Store**, is available here:
  > https://www.apple.com/legal/dsa/redress-options.

  (Emphasis added.)

**Now the limits, honestly stated:**

1. **Apple's framing is "restrict or remove ... in the ways described above"** and its examples are
   *account termination* and *app removal*. **A rejection of a submission that was never published is
   not among Apple's stated examples.** **[This is the key uncertainty. Do not assert that Apple applies
   Article 20 to new-submission rejections; nothing I found says it does.]**
2. **The internal-complaint route Apple points developers to is not called an Article 20 mechanism.**
   For developer account terminations Apple points to *"petition the App Review Board to reinstate your
   account"* via `https://developer.apple.com/contact/app-store/`, and separately to the **P2B** form.
   I found **no Apple page that labels any developer-facing mechanism as its DSA Article 20 internal
   complaint-handling system.** **[Flagged: absence of evidence, after checking Apple's DSA redress page,
   the DPLA, developer.apple.com/distribute/app-review/ and developer.apple.com/support/p2b/.]**
3. **The doctrinal question I cannot resolve for you:** whether a refusal to admit an app in the first
   place counts as a *"restriction of the visibility of ... information"* under Article 17(1)(a) /
   Article 20(1)(a), or as a *"restriction of the provision of the service ... in part"* under
   17(1)(c)/20(1)(b). The words are arguably wide enough; there is no source I found that decides it.
   **[Genuinely uncertain. Say so in any filing rather than overclaiming.]**
4. **Apple publishes no DSA-Article-20 statistics for developers** comparable to its P2B report.
   Apple's DSA transparency reporting lives at https://www.apple.com/legal/dsa/ and the App Store
   transparency report at https://www.apple.com/legal/app-store/transparency/ — **I did not audit either
   for developer-complaint figures. [Not checked.]**

#### Certified ODS bodies

Apple names none. It points to the Commission's list, verbatim from the same page:

> The European Commission maintains information about DSA out-of-court dispute settlement and a list of
> certified bodies and their areas of expertise on this dedicated webpage:
> https://digital-strategy.ec.europa.eu/en/policies/dsa-out-court-dispute-settlement

And adds a real warning, verbatim:

> You should confirm on the Commission's website whether a particular out-of-court dispute settlement
> body has been certified to resolve a dispute involving Apple (for example, some only resolve disputes
> involving certain social media platforms).

**[NOT CHECKED: I did not fetch the Commission's ODS list, so I cannot tell you which certified bodies
(if any) accept App Store disputes, or whether any accepts a developer-side dispute. This needs doing
before relying on the Article 21 route.]**

### 3.4 The DMA route: Apple's CEDR mediation scheme for EU developers

Distinct from P2B mediation, and it is the one Apple actually operationalises for App Review decisions.

**Source:** https://www.cedr.com/mediation-services/schemes/platform-to-business-services/apple-eu-mediation/
— fetched 25 September 2026.

Per that page:
- Described as an alternative dispute settlement mechanism, **independent and free of charge**, for
  eligible disputes between Apple and developers, administered by **CEDR**, under the **Digital Markets
  Act**.
- **Eligibility:** developers **established in the EU** who **offer or intend to offer applications to
  customers located in the EU**.
- **Eligible disputes:** developers dissatisfied with an **App Review Board decision made on or after
  7 March 2024**, concerning access to **EU storefronts of the App Store or the Notarization process**.
- **Cost:** *"No. Apple will bear the cost of the mediation, although you will have to bear any legal
  costs that you choose to incur."*
- **Process/timings:** online Application Form (developer name, ID, contact, app details, summary of
  facts **max 500 words**, availability); Apple has **15 working days** to agree to mediate; mediator
  contacts parties within **5 working days** of appointment; session typically **within 30–45 business
  days** of an eligible Application Form.

**[Caveat: these are the page's figures as summarised on fetch; I did not separately verify each number
against the scheme rules PDF. Re-read the scheme rules before relying on a deadline.]**

**The operationally important point:** eligibility is keyed to an **App Review Board decision**. That
makes the order of operations matter — the App Review Board appeal is not merely worth doing on its own
merits, it is **the gate to this free mediation route**. Note also "or intend to offer", which on its
face does not require the app to have been published. **[Reading of the wording as summarised; verify.]**

### 3.5 Belgium: who enforces, and where to go

#### DSA — verified

**Belgium's Digital Services Coordinator is the BIPT / IBPT.** Verbatim entry from
https://digital-strategy.ec.europa.eu/en/policies/dsa-dscs (fetched 25 September 2026; page states last
updated **2 July 2026**):

> Institut belge des services postaux et des télécommunications | Belgisch Instituut voor postdiensten
> en telecommunicatie | Belgisches Institut für Postdienste und Telekommunikation | Belgian Institute
> for Postal Services and Telecommunications

with website: **https://www.bipt.be/operators/digital-service-act**

#### P2B — NOT verified to primary source

**I could not verify from a primary Belgian source which authority Belgium designated under Article 15
of the P2B Regulation.** What I established:

- **Article 15** leaves enforcement design to Member States. Verbatim, as adopted
  (https://www.legislation.gov.uk/eur/2019/1150/adopted, downloaded 25 September 2026), recital 46:
  > Member States should be required to ensure adequate and effective enforcement of this Regulation.
  > Different enforcement systems already exist in Member States, and they should not be obliged to set
  > up new national enforcement bodies. Member States should have the option to entrust existing
  > authorities, including courts, with the enforcement of this Regulation. This Regulation should not
  > oblige Member States to provide for ex officio enforcement or to impose fines.
- The Belgian FPS Economy does publish a P2B explainer at
  https://economie.fgov.be/nl/themas/online/tussenhandeldiensten-en/platform-business-verordening
  (fetched 25 September 2026). It explains the internal-complaint and mediation duties, e.g. verbatim:
  > Aanbieders van onlineplatforms die aan bepaalde voorwaarden voldoen (meer dan 50 werknemers of een
  > jaaromzet van meer dan 10 miljoen euro) moeten een intern systeem opzetten en toepassen voor de
  > behandeling van klachten van zakelijke gebruikers.
  **But that page names no Belgian enforcement authority and no complaint point.** **[Verified absence
  on that page.]**
- Secondary/search-derived material attributes P2B enforcement in Belgium to the **Directorate-General
  for Economic Inspection (Economische Inspectie / Inspection économique) of the FPS Economy**, with
  the Regulation folded into the **Code of Economic Law (WER/CDE)**. **[UNVERIFIED — I could not open a
  primary source. The Belgian Chamber document 55K2177 and the EUR-Lex SWD(2023) 300 evaluation, which
  likely contain the authority table, were both unreachable: the Chamber PDF returned a 244-byte
  non-PDF, and EUR-Lex is WAF-blocked. DO NOT state Belgium's designated P2B authority as fact without
  checking.]**

#### The verified Belgian route a business can actually use today

**https://meldpunt.belgie.be/meldpunt/** — the Belgian federal **business** reporting point (consumers
are directed to ConsumerConnect instead). Verbatim from the page (fetched 25 September 2026):

> Bent u een onderneming?
> Klik dan op "Nieuwe melding", kies een thema en beantwoord enkele vragen om een inbreuk te melden aan
> de bevoegde inspectiedienst. Het Meldpunt maakt het mogelijk informatie te verzamelen om de kwaliteit
> van de controles door de verschillende inspectiediensten te verbeteren. De bevoegde dienst zal uw
> melding analyseren en mogelijk een onderzoek instellen. De bevoegde dienst verstrekt in principe geen
> informatie over het onderzoek en komt niet tussen bij de oplossing van uw geschil.

**Read that last sentence before investing hope in it:** the competent service *"in principle provides
no information about the investigation and does not intervene in the resolution of your dispute."*
This is a regulatory tip-off channel, **not** a route to getting an app approved. Available in NL / FR /
DE / EN (language links on the page; note `/meldpunt/en/` returned 404 on 25 September 2026, so reach
the English version via the on-page EN link rather than by guessing the URL).

#### EU-level route

- **The Commission does not run an individual P2B complaints desk.** The Commission's P2B page
  (https://digital-strategy.ec.europa.eu/en/policies/platform-business-trading-practices, fetched
  25 September 2026) describes the framework and the **Observatory on the Online Platform Economy**, and
  **does not** describe any individual complaint mechanism or list national authorities. **[Verified
  absence on that page.]**
- For the **DSA**, the App Store is a VLOP, so the **Commission** is the primary supervisor for VLOP-
  specific obligations, with the DSC (BIPT) as the national entry point. **[INFERENCE from the DSA's
  supervisory architecture; I did not quote Articles 56/65, so treat the split as needing verification.]**

---

## 4. Documented 4.3(b) reversals, and the "Extended Review" language

### 4.1 Publicly documented 4.3(b) reversals — thin, and I want to be straight about that

**I found no rigorously documented, verifiable case of a 4.3(b) rejection being reversed on appeal with
the winning argument recorded.** What exists is practitioner blog advice and developer-forum complaints.
Specifically:

- **Apple's own P2B report is the single best evidence that reversals happen at all** — 14 of 116 in
  2025-26 (see 3.2). But Apple does not break these down by guideline, and **none of the described
  reversals is a 4.3(b) new-submission rejection.** Source: https://developer.apple.com/support/p2b/,
  fetched 25 September 2026.
- **Developer forum threads consistently show 4.3(b) appeals failing, not succeeding.** E.g.
  https://developer.apple.com/forums/thread/812196 (fetched 25 September 2026, thread created January
  2026): a developer reports 4.3(b) "Spam – saturated category" plus a 2.1 rejection; no Apple staff
  reply; no reversal. Other threads in the same vein: /820697, /811633, /812849.
  **[These are user posts. They are evidence of what developers report, not of what Apple decided.]**
- A claimed reversal for a game called **"PinPoint Master"** after a formal App Review Board escalation
  surfaced in search-result summaries. **[UNVERIFIED — I could not locate the underlying forum thread or
  any primary post. Do not cite it.]**
- https://medium.com/@andriygordiychuk/our-4-3-design-spam-saga-33105602d255 looked like a documented
  case but returned **HTTP 403** on fetch (25 September 2026). **[NOT READ.]**

### 4.2 What practitioner sources say works — clearly labelled as third-party opinion

None of this is Apple guidance. It is consistent across independent sources, which is worth something,
but it is opinion.

- https://ezscreenshots.com/blog/design-spam-rejection-4-3b (article dated **31 May 2026**, fetched
  25 September 2026) reproduces the standard rejection language as:
  > "The app duplicates the content and functionality of similar apps in a saturated category. There are
  > already enough of these apps on the App Store."

  and advises: establish prior approval history; **name concrete features competitors lack rather than
  arguing the category is not saturated**; if rejected on an update, show the core concept is unchanged;
  stay factual rather than argumentative. It asserts appeals *"frequently overturn the original
  decision — especially when the original rejection was on an update to a previously approved app"*
  but **gives no figures**. **[Third-party claim, unquantified, uncorroborated.]**
- https://www.molfar.io/blog/apple-review (article dated **11 January 2026**, fetched 25 September 2026)
  says the arguments that **do not** work are *"there are dozens of similar apps you approved, and only
  mine was rejected"*, pointing to Google Play availability, and cosmetic UI changes. Notably, for an
  astrology app it recommends making astrology *"the engine, not the product"* — i.e. reposition so the
  computational/tooling layer is the product. **[Third-party opinion. But it converges with the
  strongest point available from Apple's own text: 4.3(b)'s exception is "meaningfully different or
  improved experience", so the appeal has to be built on concrete, named, checkable functional
  differences — not on fairness comparisons.]**

**The one argument with a genuine textual foundation**, drawn from Apple's own 4.3(b) wording rather
than from any blog: *"fortune telling"* is the named category, and an ephemeris/chart-computation tool
is arguably not a fortune-telling app; and even within a named category the guideline's own exception is
"meaningfully different or improved experience", which requires Apple to engage with the specific
features. **[This is a reading of Apple's text, set out in section 1. It is not a prediction.]**

### 4.3 "Extended Review" — what I verified and what I could not

**The phrase "significant safety, security, or quality concerns" — I COULD NOT VERIFY IT ANYWHERE.**
Checked, all on 25 September 2026:
- the full App Review Guidelines page text: **0 occurrences** of "Extended Review"; **0** of
  "safety, security, or quality";
- Apple's DSA risk assessment report
  (https://www.apple.com/legal/dsa/20241212_app-store_risk-assessment-report_non-confidential.pdf,
  downloaded and text-extracted): no match;
- https://developer.apple.com/distribute/app-review/, and the App Store Connect help pages for
  submissions with unresolved issues and for compliance review: no match;
- multiple web searches on the exact phrase returned no source reproducing it.

**[So: I cannot confirm that Apple uses that sentence at all, cannot confirm it is boilerplate attached
to all 4.3 rejections, and found no instance of it being retracted. If it appeared in the actual
rejection correspondence, that correspondence is the only evidence of it — quote it from the Resolution
Center verbatim and do not rely on my being able to corroborate it.]**

The closest wording that **does** appear on Apple's own pages is from the guidelines' introduction, and
it is about malware scanning, with **privacy** rather than "quality" as the third term:

> We also scan each app for malware and other software that may impact user safety, security, and
> privacy.

(https://developer.apple.com/app-store/review/guidelines/, fetched 25 September 2026.)

**What "extended review" verifiably is.** It is an account-and-submission investigation, during which
the App Store Connect status reads "Rejected" although no action is required from the developer. The
boilerplate that developers report receiving, quoted from
https://developer.apple.com/forums/thread/798871 (fetched 25 September 2026; thread opened August 2025,
Apple staff reply September 2025):

> Your submission's review will require additional time as we take this new information into account. We
> do not require any further information at this time. Once we have thoroughly reviewed your submission,
> we will either contact you in App Store Connect to communicate any issues found, or your submission
> will be approved.

and, later in the same thread:

> We apologize for the delay. Your submission is still in review but is requiring additional time. We
> will provide further status updates as soon as we are able.

A closely related boilerplate reported widely in forum threads (e.g. /716428, /705016, /708387):

> We need additional time to evaluate your submission and Apple Developer Program account. Your
> submission status will appear as "Rejected" in App Store Connect while we investigate. However, we do
> not require a revised binary or additional information from you at this time.

**[These are developer-reported quotations from forum posts, not Apple published policy. The "usually 7
business days" figure attached to the second message in forum discussion is likewise developer-reported
and I did not find it on an Apple page. UNVERIFIED.]**

**Is it boilerplate attached to all 4.3 rejections? No evidence that it is.** Extended review as
documented above is about **evaluating the developer account**, which is a different thing from a
guideline rejection. I found no source linking it specifically or systematically to 4.3.
**[UNVERIFIED either way.]**

**Has anyone had it retracted? Unknown.** Forum threads show extended review ending in approval after
waits of weeks, which is resolution by completion rather than retraction. I found **no** documented case
of the notice itself being withdrawn as wrongly issued. **[Flagged: not found.]**

### 4.4 Apple's official statements about 4.3 — not found

I found **no Apple press statement, newsroom post, or developer-news item specifically defending,
explaining or narrowing 4.3(b)**, and no press reporting of a 4.3(b) reversal, within this research.
**[Flagged: absence of evidence, not evidence of absence. I did not exhaustively search news archives
or Apple's developer-news feed by date.]**

---

## Loose ends, listed so nothing is mistaken for settled

1. Belgium's designated **P2B** enforcement authority — **not verified to a primary source.**
2. Whether any **certified DSA ODS body** accepts App Store developer-side disputes — **not checked**
   (Commission list not fetched).
3. The contents of the **appeal form**, the **guideline-suggestion form** and the **P2B form** — all
   behind Apple sign-in; **not seen.**
4. All **DSA** quotes come from an **unofficial** consolidation; EUR-Lex was WAF-blocked. **Re-verify
   against OJ L 277, 27.10.2022.**
5. P2B quotes come from **legislation.gov.uk's "as adopted by EU"** view. Sound, but **re-verify against
   OJ L 186, 11.7.2019** and cite the OJ.
6. Whether **P2B Article 4 / DSA Article 20 reach a never-published app** (as opposed to a removal or
   termination) — **genuinely unresolved.** Apple's published practice covers removals and terminations.
7. The phrase **"significant safety, security, or quality concerns"** — **not found in any source.**
8. Apple's **App Store Transparency Report** and DSA transparency reports — **not audited** for
   developer-complaint or 4.3 figures.
9. Whether the **CEDR/DMA mediation** scheme's "or intend to offer" wording admits a rejected, never-
   published app — **inference from a summary; verify against the scheme rules.**

---

## Addendum — Certified DSA out-of-court dispute settlement bodies (loose end 2, now closed)

**Source:** https://digital-strategy.ec.europa.eu/en/policies/dsa-out-court-dispute-settlement —
fetched 25 September 2026; page states last updated **11 September 2026**.

Eleven certified bodies are listed. **None names Apple or the App Store in its certified scope, and
none is described as covering app developers.** The scopes skew heavily toward social media content
moderation. The ones whose stated scope is at least not *expressly* limited to social media:

| Body | Member State | Stated scope (as listed) |
|---|---|---|
| Online Platform Vitarendező Tanács | Hungary | "All types of disputes" |
| Central European Appeals Hub | Slovakia | "Illegal content and violations of the terms and conditions of online platforms" |
| IH21 – Digitálny ombudsman | Slovakia | "Illegal content and violations of the terms and conditions of online platforms" |
| ADROIT | Malta | includes "B2B, B2C and P2P trading platforms and marketplaces" |

By contrast, **Appeals Centre Europe (Ireland)** is scoped to *"Application and enforcement of terms and
conditions of social media online platforms"* and lists Facebook, Instagram, TikTok, YouTube, Google
Maps, Pinterest, Threads — **not the App Store**. **User Rights (Germany)**, **Platform Control
(Germany)** and **Impress (Ireland)** are similarly social-media-scoped.

**Practical consequence, stated as a consequence and not as advice:** Apple's own page already warns to
check certification scope before approaching a body. On this list, a developer-side App Store dispute
has **no body certified for it by name**, and would depend on one of the broadly-scoped bodies above
accepting it. **[I have not contacted any body or verified that any would accept such a dispute. The
DSA Article 21 route is therefore the least practically ready of the options in this document.]**
