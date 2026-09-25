# Distributing an iOS app outside the App Store in the EU — what is and is not open to a new solo developer

Research date: **25 September 2026**. Every claim below carries the URL it came from and the date it was fetched.
All page fetches done by direct HTTP GET of the live Apple page on 25 Sep 2026.

**Method note:** quotes in blockquotes are copied from the live page text. Where I am reasoning rather than
quoting, the line is prefixed `INFERENCE:`. Anything I could not verify is marked `UNVERIFIED`.

---

## 0. The single most important context change: unified EU terms from 1 October 2026

Source: <https://developer.apple.com/support/apps-in-the-eu/> ("Changes for apps in the European Union"), fetched 25 Sep 2026.

> The Apple Developer Program License Agreement, updated on August 18, 2026, introduces new business terms and policies for apps distributed in the EU, following close collaboration with the European Commission. Members of the Apple Developer Program can now review and agree to the updated terms. The primary updates, which go into effect on October 1, 2026, include:

> **Unified business terms.** Apps distributed in the EU are now subject to a single set of terms, under which Apple charges a commission on the sale of digital goods and services. The Core Technology Fee, a per-install fee for developers who achieve extraordinary scale, will be replaced by the Core Technology Commission, a simple 5% commission on digital transactions in apps distributed outside the App Store. The new terms also eliminate the Initial Acquisition Fee and Store Services Fee.

> **Eligibility for operating an alternative app marketplace and Web Distribution.** Eligibility requirements for both have been expanded to include additional options. Companies are no longer required to have a legal entity or be established in the EU to operate an alternative app marketplace or use Web Distribution.

> As Apple moves to a unified business model in the EU for all developers, the Alternative Terms Addendum for Apps in the EU and StoreKit External Purchase Link Entitlement (EU) Addendum are being phased out. Starting October 1, 2026, these terms will be superseded by Attachment 14 of the Apple Developer Program License Agreement.

So: we are six days before the switchover. The old "Alternative Terms Addendum" world and the new
"Attachment 14 / unified terms" world are both quoted below, because which one applies depends on the date.

---

## 1. Web Distribution (distributing from her own website in the EU)

Source: <https://developer.apple.com/support/web-distribution-eu/>, fetched 25 Sep 2026.

### What it is

> Web Distribution lets authorized developers distribute their iOS and iPadOS apps to users in the European Union (EU) directly from a website owned by the developer. Apple provides access to APIs that facilitate the distribution of developers' apps from the web, integrate with system functionality, back up and restore users' apps, and more. Apps offered through Web Distribution must meet Notarization requirements to protect platform integrity, like all iOS and iPadOS apps, and can only be installed from a website domain that the developer has registered in App Store Connect. These capabilities are available to EU users on devices running a minimum of iOS 17.5 or iPadOS 18.

> Using App Store Connect, developers can easily download signed binary assets and host them on their website for distribution. When installing an app, a system sheet will display information that developers have submitted to Apple for review, like the app name, developer name, app description, screenshots, and system age rating.

### Full eligibility criteria, verbatim

> ### Eligibility and requirements
>
> Distributing apps directly from a website requires responsibility for and oversight of the user experience, including the ability to manage apps and provide customer support and refunds. Apple will authorize developers after meeting specific criteria and committing to ongoing requirements that help protect users.
>
> If you're interested in using Web Distribution, the Account Holder of your Apple Developer Program membership will first need to agree to the latest Apple Developer Program License Agreement. Once you've agreed, you can submit a request for access. To qualify, your organization must:
>
> - Only offer apps from your developer account.
> - Be responsive to communications from Apple regarding your apps distributed through Web Distribution, particularly regarding any fraudulent, malicious, or illegal behavior, or anything else that Apple believes impacts the safety, security, or privacy of users.
> - Publish transparent data collection policies and offer users control over how their data is collected and used.
> - Follow applicable laws of the jurisdictions where you operate (for example, the Digital Services Act, the General Data Protection Regulation, and consumer protection laws).
> - Be responsible for handling governmental and other requests regarding your apps.
> - Meet one of the following eligibility criteria:
>   - **Fee waiver.** You're a nonprofit organization, accredited educational institution, or government entity which has been approved for an Apple Developer Program fee waiver.
>   - **Global Business Ranking (GBR) score from Dun & Bradstreet (D&B) rating.** Your organization's GBR score from D&B qualifies you for the "Low Risk" or "Below Average Risk" categories.
>   - **Stock exchange listing.** Your organization is publicly traded or is part of a corporate group that is publicly traded, on a stock exchange listed on the World Federation of Exchanges (WFE), or an exchange operated by Euronext.
>   - **Venture capital funding.** Your organization is funded by a venture capital firm listed on the Midas List, Midas List Europe, Invest Europe, or the HEC-Dow Jones Venture Capital Performance Ranking. There is no minimum funding amount required.
>   - **Stand-by letter of credit.** Provide Apple with a stand-by letter of credit in the amount of USD 1,000,000 (or the equivalent in local currency) from a financial institution that's at least "BBB-" rated or equivalent by S&P, Fitch, or Moody's, and maintain that stand-by letter of credit for at least 6 months after your app is available to customers.
>   - **Financial audit.** Provide Apple with confirmation of a financial audit with an unqualified and unmodified opinion conducted within the last three years by an accredited accounting or assurance firm, such as one under the EU Statutory Audit Directive. Apple will not assess your financial standing or the value of your assets.
>   - **One million first annual installs worldwide.** Be enrolled in the Apple Developer Program in good standing for two continuous years or more, and have an app that had more than one million first annual installs worldwide on iOS and/or iPadOS in the prior calendar year.

### Answers to the specific sub-questions

**(a) Is there still a continuous Apple Developer Program membership duration requirement, and what is it?**
Partly. The two-year requirement survives, but **only inside one of the seven alternative criteria**, not as a
blanket gate. Verbatim, from the seventh option:

> Be enrolled in the Apple Developer Program in good standing for **two continuous years or more**, and have an app that had more than one million first annual installs worldwide on iOS and/or iPadOS in the prior calendar year.

The other six options (fee waiver, D&B GBR, stock exchange, VC funding, USD 1,000,000 stand-by letter of
credit, financial audit) state **no** membership-duration requirement on the page. This is a change from the
original 2024 rules, which applied the two-year + one-million test to everyone.

**(b) Is there still a first-annual-installs threshold on iOS in the EU in the prior calendar year, and what is the number?**
The threshold still exists, but it is **not EU-scoped and it is not mandatory**. Two differences from the
2024 rule:
- the number is **more than one million first annual installs *worldwide*** on iOS and/or iPadOS in the prior
  calendar year — the page says "worldwide", not "in the EU";
- it is only **one of seven** ways to qualify, so it can be bypassed entirely.

**(c) Is enrolment in the Alternative Terms Addendum for Apps in the EU required?**
It depends on the date, and the Addendum is being retired.

> You can request access for Web Distribution now. If approved, the capability will be issued to your account on October 1, 2026.
>
> If you need access sooner, you can apply using the "One million first annual installs worldwide" option and agree to the Alternative Terms Addendum for Apps in the EU. Note that as Apple moves to a unified business model in the EU for all developers, the Alternative Terms Addendum is being phased out. Starting October 1, 2026, it will be superseded by Attachment 14 of the Apple Developer Program License Agreement.

> To move to the unified EU terms before then, you'll need to agree to the updated Apple Developer Program License Agreement. Once you do, your account will be subject to the unified EU terms starting October 1, 2026, or the date you agree, whichever is later. If you owe Apple fees or commissions accrued under the discontinued agreement, you'll remain responsible for paying those amounts.

INFERENCE: read plainly, from 1 Oct 2026 the required agreement is the **updated Apple Developer Program
License Agreement including Attachment 14** (agreed by the Account Holder), not the Alternative Terms
Addendum. The Addendum is only relevant to someone who needs the capability *before* 1 Oct 2026, and the
only pre-October route named for Web Distribution is the one-million-installs option.

**(d) Notarization requirement?** Yes, explicitly:

> Apps offered through Web Distribution must meet Notarization requirements to protect platform integrity, like all iOS and iPadOS apps

and in the requirements list: "Apps must meet Notarization requirements."

**(e) Restricted to users physically in the EU?** The page frames it as EU users on modern OS versions:

> These capabilities are available to EU users on devices running a minimum of iOS 17.5 or iPadOS 18.

There is a travel allowance coming. From <https://developer.apple.com/support/apps-in-the-eu/> (fetched 25 Sep 2026), under "App installation experience updates … In fall 2026, we will make the following updates in the EU":

> Let EU users install alternative app marketplaces and alternatively distributed apps for 90 days when traveling outside the EU.

INFERENCE: eligibility follows the *user's* EU status (an EU Apple Account / EU region), with a 90-day
travel grace period arriving in fall 2026. It is not a service she could offer to, say, a US viewer.

### Does a brand-new developer with a never-published app qualify?

**On the plain text of the page: not by the install/tenure route, and almost certainly not at all.** Walking the seven:

| Criterion | Her position |
|---|---|
| Fee waiver (nonprofit / accredited educational institution / government entity) | No — she is a solo commercial developer. Would require actually being one of those entity types and being approved for the ADP fee waiver. |
| D&B Global Business Ranking "Low Risk"/"Below Average Risk" | The only criterion that is not obviously closed. Requires an *organization* with a D&B GBR score in those bands. UNVERIFIED whether a Belgian sole trader / small BV registered a few months ago can obtain a qualifying GBR score; the page gives no guidance and Apple does not publish the score mapping. |
| Publicly traded | No. |
| VC funding from a firm on Midas List / Midas List Europe / Invest Europe / HEC-Dow Jones | No. (Note: "There is no minimum funding amount required" — so a token cheque from a listed firm would count. Not her situation today.) |
| USD 1,000,000 stand-by letter of credit, maintained 6+ months | Not realistic for a solo developer. |
| Financial audit, unqualified and unmodified opinion, within last three years, by an accredited firm | An audit of a company incorporated in 2026 with no trading history is not something an accredited firm would produce an unqualified opinion on for this purpose; and the cost is out of proportion. UNVERIFIED whether Apple would accept a first-year audit. |
| Two continuous years ADP + >1M first annual installs worldwide in prior calendar year | **No on both halves.** Membership began ~August 2026 (about 1 month), and the app has zero installs. |

Also note the wording throughout: "To qualify, **your organization** must…" — the criteria are written for
organizations. INFERENCE: an Individual/Sole Proprietor ADP membership is a poor fit for most of these
criteria, and several (D&B GBR, stock listing, VC funding, audit) presuppose a registered company.

**Conclusion on item 1: Web Distribution is not open to her.** Her belief that "Apple legally has to allow"
her to distribute outside the App Store is not supported by Apple's published rules: the DMA-driven
capability exists, but Apple gates it behind eligibility criteria she does not meet, and none of the seven
criteria is satisfied by simply being an EU-established developer with a paid membership.

---

## 2. Alternative app marketplaces in the EU

### 2a. DISTRIBUTING *through* someone else's marketplace — the requirements are light

Source: <https://developer.apple.com/support/apps-in-the-eu/>, fetched 25 Sep 2026, section "Distributing on an alternative app marketplace":

> An alternative app marketplace is an app whose primary purpose is the discovery and distribution of notarized iOS and iPadOS apps. To distribute your app on an alternative app marketplace in the EU, you'll use App Store Connect and the App Store Connect API to complete tasks, such as:
>
> - Registering the alternative app marketplace and providing your Developer ID.
> - Adding the marketplace token (provided to you by the marketplace).
> - Selecting which of your apps are eligible for alternative distribution.
> - Sending notifications to the marketplace when updates are available.
>
> If you distribute your app on an alternative app marketplace:
>
> - App Store functionality like Apple In-App Purchase is not available.
> - The sale of digital goods or services from your app is subject to a Core Technology Commission (CTC). For additional details, see the business terms section below.

**Key point: no install threshold, no tenure requirement, and no eligibility screen on the *distributing*
developer appears anywhere on this page.** The seven-criteria eligibility list applies to *operating* a
marketplace, not to putting your app on one. What the distributing developer needs is: an Apple Developer
Program membership, the updated DPLA agreed, notarization of the app, alternative distribution enabled in
App Store Connect, and a marketplace token from a marketplace that agrees to carry the app.

**Is Notarization by Apple required?** Yes, unavoidably. From the same page:

> Notarization for iOS and iPadOS apps is a baseline review that applies to all apps, regardless of their distribution channel, focused on platform policies for security and privacy and to maintain device integrity. Through a combination of automated checks and human review, notarization helps check that apps are free of known malware, viruses, or other security threats, function as promised, and don't expose users to egregious fraud.

> Apple encrypts and signs all iOS and iPadOS apps intended for alternative distribution to help protect developers' intellectual property and ensure that users get apps from known parties. Notarized apps also undergo a series of checks during installation to ensure that they haven't been tampered with and that the installation was initiated through an authorized alternative app marketplace or an approved developer's website. If Apple determines that an app contains known malware after it's been installed, it will be prevented from launching, and new installations will be blocked.

**Does she need the Alternative Terms Addendum?** Before 1 Oct 2026, alternative distribution ran under the
Addendum. From 1 Oct 2026 it is superseded by Attachment 14 of the DPLA (quotes in §0). From
<https://developer.apple.com/support/apps-in-the-eu/>, fetched 25 Sep 2026:

> The Apple Developer Program License Agreement has been updated to include new options and business terms for apps distributed in the EU. To agree to these terms in your Apple Developer account, you'll need to be the Account Holder of your membership. After agreeing to the terms, starting October 1, 2026, your developer account will:
> - Have access to the entitlement you'll need to offer alternative payment options for digital goods and services in your app on the App Store in EU storefronts.
> - **Have access to alternative distribution tools in App Store Connect.**
> - Be subject to unified business terms for apps distributed in the EU.

INFERENCE: agreeing to the updated DPLA (which she can do as Account Holder of her own membership, at no
cost) is what unlocks the alternative distribution tools in App Store Connect from 1 Oct 2026. That is a
click, not an eligibility review. The eligibility review is only for *operating* a marketplace or for *Web
Distribution*.

### 2b. OPERATING a marketplace — same seven criteria, plus more

Source: <https://developer.apple.com/support/alternative-app-marketplace-in-the-eu/>, fetched 25 Sep 2026.

> If you're interested in becoming a marketplace developer in the EU, the Account Holder of your Apple Developer Program membership will first need to agree to the latest version of the Apple Developer Program License Agreement. Once you've agreed, you can submit a request for the entitlement. To qualify for the entitlement, you must:
>
> - Be enrolled in the Apple Developer Program as an organization.
> - Agree to build an app whose primary purpose is discovery and distribution of other notarized apps.
> - Agree to provide and publish terms (if your marketplace distributes other developers' apps), including those pertaining to content and business model, for any apps you will distribute.
> - Agree to publish transparent data collection policies and offer users control over how their data is collected and used.
> - Agree to follow applicable laws of the jurisdictions where you operate.
> - Agree to be responsible for handling governmental and other requests to take down listings of apps in your alternative app marketplace.
> - Agree to engage in ongoing monitoring and detection of fraudulent, malicious, or illegal apps, activity in apps, or developers in your alternative app marketplace.
> - Agree to not distribute any apps that infringe the intellectual property of others, including Apple.
> - Agree to implement a mechanism for reviewing other developers' apps for intellectual property infringement prior to distributing them through your alternative app marketplace.
> - Agree to provide a process to handle intellectual property disputes related to your alternative app marketplace or apps in your alternative app marketplace.
> - Meet one of the following: [same seven criteria as Web Distribution, verbatim identical wording]

Note "Be enrolled in the Apple Developer Program **as an organization**" — an Individual membership cannot
operate a marketplace at all.

There is a useful split between development and distribution entitlements:

> The development entitlement is assigned to your developer account shortly after submission, so you can immediately start building and testing your marketplace components with Xcode.
>
> The distribution entitlement, which enables you to distribute your marketplace app, requires review and verification of your eligibility. If approved, the entitlement will be assigned to your developer account on October 1, 2026, or the date you've been approved, whichever is later.

And a CTC waiver aimed at small operators:

> **CTC waiver for small marketplace operators.** If you're a small marketplace operator, you qualify to have the CTC waived on fees your EU marketplace app charges to download your alternative app marketplace, or subscription fees to access apps distributed by your alternative app marketplace. To qualify you need to earn less than:
> - €10 million in global revenue in the last 12 months; and
> - €1 million in total lifetime revenue from your EU marketplace app's download price or subscription fees to access apps distributed by your marketplace.

INFERENCE: the small-operator waiver reduces the *fee* burden but does nothing about the *eligibility*
gate, which is the binding constraint for her.

---

## 3. Notarization review scope — does 4.3(b) apply outside the App Store?

### Apple's authoritative statement of which guidelines apply

Source: <https://developer.apple.com/app-store/review/guidelines/>, fetched 25 Sep 2026, Introduction:

> In some markets and on certain platforms, developers can also distribute notarized apps from alternative app marketplaces and directly from their website. Learn more about alternative app marketplaces, Web Distribution, and Notarization for iOS and iPadOS apps. **You can see which guidelines apply to Notarization for iOS and iPadOS apps by clicking on "Highlight Notarization Review Guidelines Only" in the menu to the left.** For everything else there is always the open Internet. If the App Store model and guidelines or alternative distribution and Notarization for iOS and iPadOS apps are not best for your app or business idea that's okay, we provide Safari for a great web experience too.

So there is **no separate Notarization Review Guidelines document**. Apple's own "Notarization Review
Guidelines" link, from <https://developer.apple.com/support/apps-in-the-eu/> (fetched 25 Sep 2026), points
at `/app-store/review/guidelines/` — the same page. The scope is expressed *only* through the per-guideline
key icon and the sidebar checkbox.

The checkbox markup on that page, verbatim from the HTML:

```html
<input type="checkbox" name="group1" id="checkbox-1" class="form-checkbox-input">
<label class="form-label no-margin-bottom checkbox-flex-content" for="checkbox-1">
  <span class="form-checkbox-indicator smaller"></span>
  <span class="custom-tooltip-icon"><img src="/app-store/review/images/key-icon.svg" height="32" class="asr-nr" alt="ASR &amp; NR" /></span>
  <span class="checkbox-span">Highlight Notarization Review Guidelines Only</span>
</label>
```

The key icon's alt text is literally `ASR & NR` and its CSS class is `asr-nr`. Guidelines in scope for
Notarization also carry a `data-nr` attribute on their list item.

App Store Connect states the same split. Source:
<https://developer.apple.com/help/app-store-connect/distributing-apps-in-the-european-union/submit-for-notarization>, fetched 25 Sep 2026:

> If you've set up alternative distribution, you can choose to make your app version eligible only for alternative distribution by selecting to have it evaluated based on the **Notarization Review Guidelines (a subset of the App Review Guidelines)**. Otherwise, App Review uses the App Review Guidelines to evaluate your app version to make it eligible for distribution on the App Store, alternative app marketplaces, and your website (in the EU) if approved.

> Note: The Review Type selection applies to each version individually. If you want to publish a later version through the App Store instead, select App Store in this same step when you submit that version.

The five headings Apple gives for what notarization checks, from <https://developer.apple.com/support/apps-in-the-eu/> (fetched 25 Sep 2026):

> To get your app notarized, select the alternative distribution option in App Store Connect when you submit it for review. Your app will be evaluated against the Notarization Review Guidelines, a subset of the App Review Guidelines. Notarization will check for:
>
> - **Accuracy.** Apps must accurately represent the developer, capabilities, and costs to users.
> - **Functionality.** Binaries must be reviewable, free of serious bugs or crashes, and compatible with the current version of iOS and/or iPadOS. They cannot manipulate software or hardware in ways that negatively impact the user experience.
> - **Safety.** Apps cannot promote physical harm of the user or public.
> - **Security.** Apps cannot enable distribution of malware or of suspicious or unwanted software. They cannot download executable code, read outside of the container, or direct users to lower the security on their system or device. Also, apps must provide transparency and allow user consent to enable any party to access the system or device, or reconfigure the system or other software.
> - **Privacy.** Apps cannot collect or transmit private, sensitive data without a user's knowledge or in a manner contrary to the stated purpose of the software.

INFERENCE: none of those five headings is about market saturation, category duplication or app quality
relative to what else is on sale. "Spam" in the 4.3(b) sense has no home in that list.

### Verifying the 4.3(a) / 4.3(b) icon claim — CONFIRMED

This is the exact HTML of guideline 4.3 as served on 25 Sep 2026 from
<https://developer.apple.com/app-store/review/guidelines/> (whitespace preserved, nothing removed):

```html
<li data-nr data-sidenav="4.3 Spam" id="spam"><span id="4.3"></span><strong>4.3 Spam</strong>
  <ul class="no-bullet margin-top-small">
    <li data-nr><strong>(a)</strong><span class="custom-tooltip-icon"><img src="/app-store/review/images/key-icon.svg" height="17" class="asr-nr" alt="ASR &amp; NR" /></span> Don't create multiple Bundle&nbsp;IDs of the same app (for example, submitting a separate map app for every city in the world instead of a single worldwide map that allows users to search any city). This practice results in unnecessary apps, which makes it hard for users to find the apps they want. If your app has different versions for specific locations, sports teams, universities, etc., consider submitting a single app and providing the variations using in-app purchase.</li>
    <li><strong>(b)</strong> Don't submit apps that are indistinguishable from what's already widely available. Opportunistically creating variants of existing app categories or popular apps degrades App&nbsp;Store discovery, reduces overall app quality, and harms both users and developers. Certain kinds of apps, such as dating, flashlight, sound effects, wallpaper, simple timers, and fortune telling, are well established on the App&nbsp;Store and we will not accept new submissions unless they offer a meaningfully different or improved experience. We may remove these apps from the App&nbsp;Store going forward if they are not updated, improved, or do not attract customers. Other kinds of apps, such as drinking games, Kama Sutra, fart, and burp apps, are mediocre, low-quality, or low-effort and do not add value to the App&nbsp;Store. Repeated submissions of this kind may lead to removal from the Apple&nbsp;Developer&nbsp;Program.</li>
  </ul>
</li>
```

### Apple's own filter script — mechanical proof of the scope

The "Highlight Notarization Review Guidelines Only" checkbox is driven by a script Apple ships at
<https://developer.apple.com/app-store/review/guidelines/scripts/filterNotarized.js>, fetched 25 Sep 2026.
It is 464 bytes, and this is the whole file:

```js
document.addEventListener("DOMContentLoaded", () => {
	document.getElementById("checkbox-1").addEventListener("change", function () {
		const elements = document.querySelectorAll("#content-container li, #content-container h3, #content-container p");

		elements.forEach((elem) => {
			if (!elem.hasAttribute("data-nr")) {
				if (this.checked) {
					elem.classList.add("lighter-2");
				} else {
					elem.classList.remove("lighter-2");
				}
			}
		});
	});
});
```

This removes the guesswork. Apple's page defines the Notarization Review Guidelines as **exactly the
elements carrying `data-nr`**. Tick the box and every `li`, `h3` and `p` *without* `data-nr` is greyed out
with the `lighter-2` class. Guideline **4.3(b)'s `<li>` has no `data-nr`, so Apple's own page greys 4.3(b)
out when a reader asks to see the Notarization Review Guidelines.** 4.3(a)'s `<li>` has `data-nr` and stays
lit.

That is not an inference about Apple's intent. It is what Apple's published code does to 4.3(b).

**The prior finding is confirmed, on three independent markers:**

1. **The key icon.** 4.3(a) carries `<img … class="asr-nr" alt="ASR & NR" />`. 4.3(b) carries no icon.
2. **The `data-nr` attribute.** 4.3(a) is `<li data-nr>`. 4.3(b) is a bare `<li>`.
3. **Apple's filter script.** `filterNotarized.js` greys out every element without `data-nr`, so ticking
   "Highlight Notarization Review Guidelines Only" greys out 4.3(b) and leaves 4.3(a) lit.

(The parent `4.3 Spam` heading carries `data-nr` because its child (a) is in scope. The sub-item (b) does
not.)

For scale: the served page contains **65** instances of `key-icon.svg` across the whole guidelines document,
so the notarization subset is a small minority of the guidelines. 4.3(a) is in it; 4.3(b) is not. By
contrast the very next guideline, `4.4 Extensions`, does carry the icon:

```html
<li data-nr data-sidenav="4.4 Extensions" id="extensions"><span id="4.4"></span><strong>4.4<span class="custom-tooltip-icon"><img src="/app-store/review/images/key-icon.svg" height="17" class="asr-nr" alt="ASR &amp; NR" /></span> Extensions</strong>
```

— which shows the markup is applied deliberately item by item, not haphazardly.

### The answer

**Does Guideline 4.3(b) apply to an app distributed through an alternative app marketplace or Web Distribution?**

**No — on Apple's own published marking, 4.3(b) is not part of the Notarization Review Guidelines.**

The supporting chain, all from pages fetched 25 Sep 2026:
1. Apple: "You can see which guidelines apply to Notarization for iOS and iPadOS apps by clicking on
   'Highlight Notarization Review Guidelines Only' in the menu to the left."
   (<https://developer.apple.com/app-store/review/guidelines/>)
2. That control highlights exactly the items carrying the `ASR & NR` key icon / `data-nr` marker.
3. 4.3(a) carries it. 4.3(b) does not.
4. App Store Connect confirms the subset is real and selectable per version: "you can choose to make your
   app version eligible only for alternative distribution by selecting to have it evaluated based on the
   Notarization Review Guidelines (a subset of the App Review Guidelines)."
   (<https://developer.apple.com/help/app-store-connect/distributing-apps-in-the-european-union/submit-for-notarization>)
5. Apple's five notarization check categories (Accuracy, Functionality, Safety, Security, Privacy) contain
   no saturation/duplication/quality-relative-to-market test.

Corroborating textual point: **every consequence 4.3(b) names is an App Store consequence.** Its own words
are "degrades App Store discovery", "are well established on the App Store", "we will not accept new
submissions", "We may remove these apps from the App Store going forward", "do not add value to the App
Store". The rule is written as a curation rule for a store Apple runs.

**Caveats, stated honestly:**
- Apple publishes no *prose sentence* of the form "4.3(b) does not apply to notarization". The finding rests
  on Apple's marker scheme — but Apple both (i) designates that scheme as the authoritative expression of
  scope ("You can see which guidelines apply to Notarization … by clicking on 'Highlight Notarization Review
  Guidelines Only'") and (ii) ships the code that implements it. The absence of a prose sentence is a
  documentation gap, not a genuine ambiguity about what Apple's page asserts.
- 4.3(b) is *only* disapplied if the app is actually submitted with Review Type = Notarization for
  alternative distribution. If she submits for the App Store, the full App Review Guidelines including
  4.3(b) apply — that is exactly what happened on 15 Sep 2026.
- The last bullet of 4.3(b) — "Repeated submissions of this kind may lead to removal from the Apple
  Developer Program" — is a *program-level* sanction, and program membership is upstream of every
  distribution channel. INFERENCE (not quoted anywhere as applying to notarization): repeatedly
  resubmitting the same rejected shape to the App Store carries a risk that reaches beyond the App Store.
  This is consistent with the existing "never resubmit the same shape" rule of thumb.

---

## 2c. Which alternative marketplaces actually operate in the EU right now

Apple does not publish a list of authorized marketplaces, so this is **third-party sourced** and I flag it as
weaker evidence than the Apple pages above.

Source: TechCrunch, "Move over, Apple: Meet the alternative app stores available in the EU and elsewhere",
<https://techcrunch.com/2026/02/22/move-over-apple-meet-the-alternative-app-stores-available-in-the-eu-and-elsewhere/>,
published 22 Feb 2026, fetched 25 Sep 2026:

| Marketplace | Status per that article | Notes |
|---|---|---|
| **AltStore PAL** | Operating | Open-source, co-created by Riley Testut. Accepts third-party developers' apps. Article: "developers download an alternative distribution packet (ADP) and upload it to their server". |
| **Epic Games Store** | Operating | Launched Aug 2024. Games, mostly Epic's own plus partners. |
| **Aptoide** | Operating | Lisbon-based, launched invite-only beta June 2024; "a 10% to 20% commission on in-app purchases on iOS". |
| **Skich** | Operating | Launched March 2025, Tinder-like discovery UI, games-focused. |
| **Onside** | Operating | Available since 17 Feb 2026. |
| **Mobivention Marketplace** | Operating | B2B / enterprise internal-app focus. |
| **Setapp Mobile (MacPaw)** | **Closed** | "the company announced it would sunset the Setapp Mobile service on February 16, 2026", attributed to "still-evolving and complex business terms that don't fit Setapp's current business model." |

`UNVERIFIED`: whether each of these is still live on 25 Sep 2026, and whether any of them would accept a
solo astrology/tarot companion app. AltStore PAL is the one with published open developer onboarding.

### AltStore PAL's own stated developer requirements

Source: <https://faq.altstore.io/developers/distribute-with-altstore-pal>, fetched 25 Sep 2026. This is
AltStore's documentation, not Apple's.

> You will still submit apps through App Store Connect using your paid Apple Developer account

> Your apps will only be available in the EU, Japan, and Brazil.

> You can distribute apps with AltStore PAL from anywhere.

> You still need to submit your app(s) to Apple for Notarization before they can be distributed.

The onboarding steps AltStore documents are: request the EU Terms Addendum from Apple → register your
Developer ID with AltStore PAL's REST API → paste the returned security token into App Store Connect under
**Users and Access → Integrations → Marketplace** → select the apps → submit for Notarization.

`FLAG — possibly stale`: AltStore's page says to request the **Alternative EU Terms Addendum**. Apple's own
pages (fetched 25 Sep 2026) say that Addendum is being phased out and superseded by **Attachment 14 of the
DPLA on 1 October 2026**. AltStore's documentation has probably not been updated for the transition. Trust
Apple's page over AltStore's on which agreement to sign.

**Crucially: no install threshold, no membership-tenure test, and no D&B/VC/audit eligibility screen appears
in either Apple's "Distributing on an alternative app marketplace" text or AltStore's developer
documentation.** The heavy eligibility criteria attach to *operating* a marketplace and to *Web
Distribution*, not to being a developer whose app sits on someone else's marketplace.

### Users must be in the EU

Source: <https://support.apple.com/en-eu/118110> (Apple Support, user-facing), fetched 25 Sep 2026:

> The country or region of your Apple Account must be set to one of the countries or regions of the European Union

and on travel:

> you can continue to update apps from alternative app distribution for up to 90 days after you leave

> you must be in your eligible country or region to install alternative app marketplaces and new apps

INFERENCE: so both marketplace distribution and Web Distribution reach EU-account, EU-located users only.
A viewer in the US or UK cannot install from either channel.

---

## 4. Can she just hand a user an .ipa from her own website, with no Apple involvement?

### Short answer from the sources: no.

There is no "sideloading" on iOS in the sense of a user downloading an arbitrary `.ipa` and installing it.
Every route Apple documents runs through Apple signing and, outside the App Store, through Notarization.

Source: <https://developer.apple.com/support/apps-in-the-eu/>, fetched 25 Sep 2026:

> Notarization for iOS and iPadOS apps is a baseline review that applies to **all apps, regardless of their distribution channel**, focused on platform policies for security and privacy and to maintain device integrity.

> Apple encrypts and signs all iOS and iPadOS apps intended for alternative distribution to help protect developers' intellectual property and ensure that users get apps from known parties. Notarized apps also undergo a series of checks during installation to ensure that they haven't been tampered with and that **the installation was initiated through an authorized alternative app marketplace or an approved developer's website**.

INFERENCE: the install-time check for "an authorized alternative app marketplace or an approved developer's
website" is precisely what makes a loose `.ipa` from an unregistered domain non-installable. Even holding a
notarized package, the domain has to be one registered in App Store Connect under an approved Web
Distribution authorization.

The DPLA enumerates the channels. Source:
<https://developer.apple.com/support/downloads/terms/apple-developer-program/Apple-Developer-Program-License-Agreement-English.pdf>
(current version as published 25 Sep 2026; md5 66fd5638b7ab8d9da6884cfafa694d4c), Section 7:

> Applications developed under this Agreement for iOS, iPadOS, macOS, tvOS, visionOS, or watchOS can be distributed: (1) through the App Store, if selected by Apple, (2) through Ad Hoc distribution in accordance with Section 7.3, and (3) for beta testing through TestFlight in accordance with Section 7.4. Applications developed for iOS, iPadOS, macOS, and tvOS can additionally be distributed through Custom App Distribution, if selected by Apple. **Applications for macOS can additionally be separately distributed as described in this Agreement.**

INFERENCE: the last sentence is the giveaway — free-form distribution outside a store is a **macOS**
privilege in the base agreement. iOS gets it only via the EU Attachment 14 / Addendum mechanisms, which are
gated as described in §1 and §2.

### Ad Hoc distribution — a testing channel, and it needs UDIDs

Source: DPLA Section 7.3 "Distribution on Registered Devices (Ad Hoc Distribution)", fetched 25 Sep 2026:

> Subject to the terms and conditions of this Agreement, You may also distribute Your Applications for iOS, watchOS, iPadOS, tvOS, and visionOS **to individuals within Your company, organization, educational institution, group, or who are otherwise affiliated with You** for use on a limited number of Registered Devices (as specified in the Program web portal), if Your Application has been digitally signed using Your Apple Certificate as described in this Agreement.

> You also agree to be solely responsible for determining which individuals within Your company, organization, educational institution or affiliated group should have access to and use of Your Applications and Registered Devices, and for managing such Registered Devices.

**Device count.** Source: <https://developer.apple.com/help/account/register-devices/devices-overview/>, fetched 25 Sep 2026:

> By registering an Apple device in your developer account, you can install your app directly on the device using Ad Hoc distribution. You can register devices automatically with Xcode or manually through Certificates, Identifiers & Profiles. Members of the Apple Developer Program and Apple Developer Enterprise Program can register **up to 100 of the following devices, per product family, per membership year**:

> At the start of your new membership year, Account Holders, Admins, and App Managers will be presented with the option to remove listed devices and restore the available device count to 100 when first signing in to Certificates, Identifiers & Profiles. You can remove specific devices, remove all devices to restore your available device count to 100 per product family, or continue without removing any devices. Once you complete this process, new devices can be added.

**UDID registration is required.** Source:
<https://developer.apple.com/help/account/register-devices/register-a-single-device/>, fetched 25 Sep 2026:

> You need a registered device to create a development or ad hoc provisioning profile. To register a device using your developer account, you need to have the device name and device ID.

> Select the platform, enter a device name, and the **Unique Device Identifier (UDID)**.

So: 100 iPhones per membership year, each one's UDID collected in advance and entered into her account.
The DPLA restricts the audience to people "within Your company, organization, educational institution,
group, or who are otherwise affiliated with You". This is **not public distribution** — it is limited
distribution to an affiliated group. Ad Hoc does not require App Review, but it also cannot be a storefront.

### TestFlight external testing — a testing channel, and it does require App Review

**Tester counts.** Source:
<https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview>, fetched 25 Sep 2026:

> Create groups for testers, then assign specific builds to them. After you've added builds to a group, you can add **external testers (up to 10,000 people)** and **internal testers (up to 100 App Store Connect users with access to your content)** to test your app. If you invite external testers, your beta build may require review. When you add the first build of your app to a group, **the build gets sent to App Review to make sure it follows the App Review Guidelines**. A review is required only for the first build. Subsequent builds may not require a full review. Testing can begin once a build is approved.

Source: <https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers>, fetched 25 Sep 2026:

> External testers are people you invite to test your app who aren't App Store Connect users. After uploading your build, you can invite **up to 10,000 external testers per app**. To make your build available for external testing, you need to create an external group, add builds, and invite testers using their email addresses or by sharing a public invitation link.

> To create an external group for external testing, you must first create an internal group for internal testing.

> Note: You can submit up to six builds for TestFlight App Review within a 24-hour period.

> After you submit your build to TestFlight App Review, Apple reviews the build and its accompanying metadata. The first build you submit requires a full review, but later builds for the same version might not.

> If Apple rejects your build or metadata, the status of the build will be Rejected. You can click App Review from the sidebar under General to view the rejection details for your beta build.

**Review is mandatory for external testing** — the DPLA is explicit. Source: DPLA Section 6.5 "TestFlight Submission", fetched 25 Sep 2026:

> If You would like to distribute Your Application to Beta Testers outside of Your company or organization through TestFlight, **You must first submit Your Application to Apple for review.**

> Thereafter, Apple may permit You to distribute updates to such Application directly to Your Beta Testers without Apple's review, unless such an update includes significant changes, in which case You agree to inform Apple in App Store Connect and have such Application re-reviewed. Apple reserves the right to require You to cease distribution of Your Application through TestFlight, and/or to any particular Beta Tester, at any time in its sole discretion.

`IMPORTANT NUANCE, and a correction to the working assumption that TestFlight is a safe workaround:`
Apple's TestFlight overview says the beta build is reviewed "to make sure it follows **the App Review
Guidelines**" — the full set, not the Notarization subset. There is **no** "Highlight Notarization Review
Guidelines Only" carve-out for TestFlight, and the App Store Connect Review Type choice of "Notarization" is
described only in the *alternative distribution* help page. INFERENCE: **4.3(b) is in scope for TestFlight
external review**, which is why external TestFlight is not a reliable end-run around a 4.3(b) rejection.
TestFlight *internal* testing (up to 100 App Store Connect users on her own team) is the part that needs no
App Review.

### Summary table for item 4

| Route | Public distribution? | Apple review? | Hard limit | Notes |
|---|---|---|---|---|
| Loose `.ipa` from her own site | **Does not exist on iOS** | — | — | Install-time check requires an authorized marketplace or approved registered domain. |
| Web Distribution | Yes, EU users | Notarization | — | Blocked by eligibility (§1). |
| Alternative marketplace | Yes, EU users | Notarization | — | **Open to her** (§2a). |
| Ad Hoc | **No** — affiliated group only | No | 100 devices per product family per membership year, UDIDs registered in advance | Development/testing channel per DPLA 7.3. |
| TestFlight external | **No** — beta testing | **Yes, full App Review Guidelines** | 10,000 testers per app | DPLA 6.5: "You must first submit Your Application to Apple for review." |
| TestFlight internal | **No** — own team only | No | 100 App Store Connect users | Safe, but not distribution. |

---

## 5. Fees — would the CTF or CTC bite a free app with low installs?

### The mechanism is changing on 1 October 2026

Source: <https://developer.apple.com/support/apps-in-the-eu/>, fetched 25 Sep 2026:

> **Unified business terms.** Apps distributed in the EU are now subject to a single set of terms, under which Apple charges a commission on the sale of digital goods and services. **The Core Technology Fee, a per-install fee for developers who achieve extraordinary scale, will be replaced by the Core Technology Commission, a simple 5% commission on digital transactions in apps distributed outside the App Store.** The new terms also eliminate the Initial Acquisition Fee and Store Services Fee.

### Core Technology Commission (CTC) — the mechanism from 1 Oct 2026

Rate and scope, from <https://developer.apple.com/support/apps-in-the-eu/>, fetched 25 Sep 2026:

> **5%** — Alternative app marketplaces, apps distributed through them, or apps distributed via Web Distribution are subject to a commission on the sales of paid apps and digital goods or services (including one-time purchases and auto-renewing subscriptions) for use within apps on an Apple platform.

> The CTC covers the following types of transactions:
> - Sales of digital goods and services within alternative app marketplaces, apps distributed via alternative app marketplaces, and apps distributed via Web Distribution.
> - Sales of digital goods or services (including one-time purchases and auto-renewing subscriptions) required to access or download alternative app marketplaces, apps distributed via alternative app marketplaces, and apps distributed via Web Distribution, including paid subscriptions to access or download app content or catalogs of apps.
> - Sales when alternative app marketplaces, apps distributed via alternative app marketplaces, or apps distributed via Web Distribution direct users to offers and promotions with actionable links that open in a web browser to a website for the purchase of promoted digital goods and services. Only sales made within 7 days of the link tap are subject to this commission.

The DPLA states it as a percentage with no per-install component. Source: DPLA Attachment 14, Section 4, fetched 25 Sep 2026:

> **4. Core Technology Commission**
>
> A. The terms of this Section 4 apply to Alternative App Marketplaces (EU), or to Applications distributed on an Alternative App Marketplace (EU) or from Your Website (EU).
>
> B. The Core Technology Commission applies to any sales of digital goods or services (including one-time purchases and auto-renewing subscriptions) that are completed in Your Alternative App Marketplace (EU), or in Your Application distributed on an Alternative App Marketplace (EU) or from Your Website (EU), and can be used in an Application distributed on an Apple platform.
>
> C. The Core Technology Commission also applies to any sales of digital goods or services on an Apple platform (including one-time purchases and auto-renewing subscriptions) that are required to download or access an Alternative App Marketplace (EU), or an Application distributed on an Alternative App Marketplace (EU) or from Your Website (EU).
>
> D. Lastly, the Core Technology Commission applies to any sales on a website of promoted digital goods or services … if the sales were initiated within seven (7) calendar days after the end user taps or scans an actionable link …

And the rate, Attachment 14 Section 4.E, quoted in full:

> E. The Core Technology Commission is five percent (5%) of all sales covered in this Section 4. Such commission applies to all amounts payable by each end user, subject to any refunds, reversals, or chargebacks, net of transaction taxes charged by You.

(Section 4.F adds the small-marketplace-operator waiver: "if You distribute an Alternative App Marketplace (EU) and You earned less than €10 million in global revenue in the past 12 months, You may register following the instructions in the Apple Materials as a small marketplace operator." Not applicable to her.)

**Answer for a free app with low installs, distributed outside the App Store in the EU:** the CTC is a
percentage **of sales**. There is no per-install charge and no fixed floor in the text. INFERENCE: with no
paid app price, no in-app digital goods, no paid download of the app, and no link-outs to paid digital goods,
**the CTC base is zero, so €0 is payable.** Install volume is irrelevant to the CTC — the old per-install
threshold logic is gone.

`Important caveat for her specific product:` the Squirrel Guides hosting tiers (€5/month, €50/year, sold on
/account) are *digital services*. If a subscription is "required to download or access" the app, or is sold
inside an app distributed via a marketplace, clause B/C would reach it at 5%. The existing decision to sell
those tiers only on the website and never in the app is the thing that keeps this at zero — but clause C
("required to download or access") means a *paywalled* app would still be caught even if the payment happens
on the website. `UNVERIFIED`: exactly how Apple applies clause C to a free app whose optional hosting
subscription is bought on the web; the text says "required to download or access", so an optional add-on
reads as outside it, but that is my reading, not Apple's statement.

Note also the reporting duty even at zero. Source: <https://developer.apple.com/support/apps-in-the-eu/>, fetched 25 Sep 2026:

> **Reporting transactions.** Developers who distribute their apps via alternative distribution, including those who operate marketplaces, are responsible for reporting their transactions of digital goods and services to Apple. **All transactions subject to the Core Technology Commission must be reported, including transactions that didn't result in a completed sale.**

### Core Technology Fee (CTF) — the old mechanism, and why it does not apply to her

Source: <https://developer.apple.com/help/app-store-connect/understanding-the-core-technology-fee/core-technology-fee-overview>
(this is where <https://developer.apple.com/support/core-technology-fee/> now redirects to — verified 25 Sep 2026), fetched 25 Sep 2026:

> **Note: The information in this section is only for developers who have signed the Alternative Terms Addendum for Apps in the EU. If you have agreed to the latest version of the Developer Program License Agreement (DPLA), this information will no longer be applicable starting October 1, 2026.**

The CTF numbers, for completeness, same page, fetched 25 Sep 2026:

> **One million free first annual installs.** Membership in the Apple Developer Program includes one million first annual installs per year for free for apps distributed from the App Store, Web Distribution, and/or alternative marketplaces.

> **Fee for each first annual install over one million.** Developers pay a CTF of **€0.50** for each first annual install over one million in the past 12 months.

Who pays nothing:

> Developers whose apps do not surpass one million first annual installs per year.

And the small-developer on-ramp:

> Small developers (earning less than €10 million in global business revenue) who haven't previously exceeded one million first annual installs are provided with a 3-year free on-ramp to the CTF. During this period that starts once a developer signs the Alternative Terms Addendum for Apps in the EU, they won't pay the CTF for first annual installs that exceed the threshold so long as they continue to earn less than €10 million in global business revenue within the 3 years.

> Note: You must declare your revenue before your first app surpasses one million first annual installs in order to receive these on-ramp benefits. If any of your apps exceed one million first annual installs before you declare your revenue, you will not be eligible.

One CTF trap worth recording, same page:

> Developers of alternative app marketplaces pay the Core Technology Fee for every first annual install of their app marketplace, **including installs that occur before one million**.

INFERENCE: irrelevant to her unless she operated a marketplace, which she cannot.

**Bottom line on fees: whichever mechanism applies, a free app with low install counts pays €0.** Under the
CTF she is far below the one-million free allowance; under the CTC there are no sales to take 5% of. The
fees are not the obstacle. Eligibility is.

---

## 6. Confidentiality — may she publish her App Review / Resolution Center correspondence?

Source: <https://developer.apple.com/support/downloads/terms/apple-developer-program/Apple-Developer-Program-License-Agreement-English.pdf>,
downloaded 25 Sep 2026 (md5 `66fd5638b7ab8d9da6884cfafa694d4c`; re-downloaded twice the same day, byte-identical,
so this is the live file). This is the version that includes Attachment 14 and the Core Technology Commission,
i.e. the agreement updated 18 August 2026.

`NOT LEGAL ADVICE. What follows is the text and what it names.`

### Section 9.1 — what the agreement actually designates as confidential

> **9.1 Information Deemed Apple Confidential**
>
> You agree that all pre-release versions of the Apple Software and Apple Services (including pre-release Documentation), pre-release versions of Apple hardware, and the FPS Deployment Package will be deemed "Apple Confidential Information"; provided however that upon the commercial release of the Apple Software the terms and conditions that disclose pre-release features of the Apple Software or services will no longer be confidential. Notwithstanding the foregoing, Apple Confidential Information will not include: (i) information that is generally and legitimately available to the public through no fault or breach of Yours, (ii) information that is generally made available to the public by Apple, (iii) information that is independently developed by You without the use of any Apple Confidential Information, (iv) information that was rightfully obtained from a third party who had the right to transfer or disclose it to You without limitation, or (v) any FOSS included in the Apple Software and accompanied by licensing terms that do not impose confidentiality obligations on the use or disclosure of such FOSS. Further, Apple agrees that You will not be bound by the foregoing confidentiality terms with regard to technical information about pre-release Apple Software and services disclosed by Apple at WWDC (Apple's Worldwide Developers Conference), except that You may not post screenshots of, write public reviews of, or redistribute any pre-release Apple Software, Apple Services or hardware.

**What 9.1 names:** pre-release Apple Software and Services, pre-release Documentation, pre-release Apple
hardware, and the FPS Deployment Package. That is the whole enumerated list. It does **not** name App Review
correspondence, Resolution Center messages, rejection notices, or guideline-application decisions.

### Section 9.2 — the obligation, which attaches only to what 9.1 defined

> **9.2 Obligations Regarding Apple Confidential Information**
>
> You agree to protect Apple Confidential Information using at least the same degree of care that You use to protect Your own confidential information of similar importance, but no less than a reasonable degree of care. You agree to use Apple Confidential Information solely for the purpose of exercising Your rights and performing Your obligations under this Agreement and agree not to use Apple Confidential Information for any other purpose, for Your own or any third party's benefit, without Apple's prior written consent. You further agree not to disclose or disseminate Apple Confidential Information to anyone other than: (i) those of Your employees and contractors, or those of Your faculty and staff if You are an educational institution, who have a need to know and who are bound by a written agreement that prohibits unauthorized use or disclosure of the Apple Confidential Information; or (ii) except as otherwise agreed or permitted in writing by Apple. You may disclose Apple Confidential Information to the extent required by law, provided that You take reasonable steps to notify Apple of such requirement before disclosing the Apple Confidential Information and to obtain protective treatment of the Apple Confidential Information. You acknowledge that damages for improper disclosure of Apple Confidential Information may be irreparable; therefore, Apple is entitled to seek equitable relief, including injunction and preliminary injunction, in addition to all other remedies.

### Section 9.3 — information flowing *to* Apple is expressly non-confidential

> **9.3 Information Submitted to Apple Not Deemed Confidential**
>
> Apple works with many application and software developers and some of their products may be similar to or compete with Your Applications. Apple may also be developing its own similar or competing applications and products or may decide to do so in the future. To avoid potential misunderstandings and except as otherwise expressly set forth herein, Apple cannot agree, and expressly disclaims, any confidentiality obligations or use restrictions, express or implied, with respect to any information that You may provide in connection with this Agreement or the Program, including but not limited to information about Your Application, Licensed Application Information, and metadata (such disclosures will be referred to as "Licensee Disclosures"). You agree that any such Licensee Disclosures will be non-confidential. Except as otherwise expressly set forth herein, Apple will be free to use and disclose any Licensee Disclosures on an unrestricted basis without notifying or compensating You. You release Apple from all liability and obligations that may arise from the receipt, review, use, or disclosure of any portion of any Licensee Disclosures. Any physical materials You submit to Apple will become Apple property and Apple will have no obligation to return those materials to You or to certify their destruction.

**Note the asymmetry:** 9.3 makes *her* side of the conversation non-confidential, in Apple's favour. It says
nothing that makes Apple's side confidential.

### Section 9.4 — the clause that actually constrains public statements

> **9.4 Press Releases and Other Publicity**
>
> You may not issue any press releases or make any other public statements regarding this Agreement, its terms and conditions, or the relationship of the parties without Apple's express prior written approval, which may be withheld at Apple's discretion.

**What 9.4 names:** "this Agreement", "its terms and conditions", and "the relationship of the parties". It is
a publicity clause, not a confidentiality clause. It does not name App Review correspondence, the Resolution
Center, or rejection reasons.

### Searches run across the whole agreement

I searched the full extracted text of the current DPLA for the obvious terms, 25 Sep 2026:

- `"Resolution Center"` — **zero occurrences** anywhere in the agreement.
- `"App Review"` — occurs only in references to the **App Review Guidelines** as a compliance obligation
  (e.g. "this Agreement, including without limitation the App Review Guidelines"), never in a
  confidentiality context.
- No section imposes a duty of confidence on communications Apple sends the developer about a submission.

### So does rejection correspondence fall inside or outside?

Stating only what the text supports, no legal conclusion:

- **Outside §9.1/§9.2 on the face of the text.** §9.1 is a closed enumeration (pre-release software, services,
  documentation, hardware, FPS Deployment Package). A Resolution Center message about guideline 4.3(b) is
  none of those. §9.2's obligations apply only to "Apple Confidential Information" as §9.1 defines it.
- **Expressly outside §9.3 as to her own submissions** — her app information and metadata are declared
  non-confidential.
- **§9.4 is the live question, and it is about framing rather than the correspondence itself.** Quoting the
  rejection letter is not obviously a statement "regarding this Agreement, its terms and conditions, or the
  relationship of the parties". Writing a post *about her relationship with Apple*, or about the DPLA's
  terms, is much closer to what 9.4 names. `UNCLEAR`: where Apple would draw that line. The clause is broad
  ("any other public statements", "the relationship of the parties") and approval "may be withheld at
  Apple's discretion".
- There is also §9.1's carve-out (i)/(ii) for information already public — irrelevant here, since a private
  rejection letter is not public.
- `UNVERIFIED`: whether any other Apple agreement she has accepted (the separate **Apple Developer
  Agreement**, App Store Connect terms of use, or any NDA attached to a specific appeal process) adds a
  confidentiality duty. I only examined the Apple Developer Program License Agreement, as asked.

Observable practice, offered as context and not as a source of permission: developers routinely publish
rejection screenshots and Resolution Center transcripts, and Apple has publicly quoted review correspondence
itself during litigation. `UNVERIFIED` as to whether Apple has ever enforced 9.4 against a developer for
publishing a rejection.

---

## 7. URL status notes (all checked 25 Sep 2026)

Apple serves **soft 404s**: these return HTTP 200 with a "Page Not Found" body. Do not mistake the 200 for a
live page.

| URL | Status 25 Sep 2026 |
|---|---|
| `https://developer.apple.com/support/web-distribution-eu/` | **Live** — the authoritative Web Distribution page. |
| `https://developer.apple.com/programs/alternative-terms-addendum-eu/` | HTTP 200 but **"Page Not Found"** body. Dead. |
| `https://developer.apple.com/support/alternative-terms-addendum-eu/` | HTTP 200 but **"Page Not Found"** body. Dead. |
| `https://developer.apple.com/support/notarization-ios/` | HTTP 200 but **"Page Not Found"** body. Dead — there is no standalone notarization page at that path. |
| `https://developer.apple.com/support/alternative-app-marketplace-eu/` | Dead. Correct path is `.../alternative-app-marketplace-in-the-eu/`. |
| `https://developer.apple.com/support/core-technology-commission/` | Dead. CTC is documented inside `/support/apps-in-the-eu/` and DPLA Attachment 14. |
| `https://developer.apple.com/support/core-technology-fee/` | **Redirects** to `https://developer.apple.com/help/app-store-connect/understanding-the-core-technology-fee/core-technology-fee-overview`. |
| `https://developer.apple.com/support/dma-and-apps-in-the-eu/` | **Live**, serves the same content as `/support/apps-in-the-eu/` (byte-identical fetch). |
| `https://developer.apple.com/support/apps-in-the-eu/` | **Live** — "Changes for apps in the European Union". The main EU hub page. |
| `https://developer.apple.com/support/alternative-app-marketplace-in-the-eu/` | **Live** — "Operating an alternative app marketplace in the EU". |
| `https://developer.apple.com/app-store/review/guidelines/` | **Live** — and is also the Notarization Review Guidelines. |

Corroborating the "no standalone notarization document" point: Apple's
<https://developer.apple.com/support/terms/> ("Agreements and Guidelines"), fetched 25 Sep 2026, lists the
**App Review Guidelines** among its guidelines documents and lists **no** separate "Notarization Review
Guidelines" document. It also no longer lists the **Alternative Terms Addendum for Apps in the EU** as a
downloadable agreement — consistent with Apple's statement that it is being superseded by Attachment 14.

---

## 8. Bottom line

### Can she distribute outside the App Store?

**Yes, by one route: putting the app on an existing alternative app marketplace.** That route has no install
threshold, no membership-tenure test, and no financial-eligibility screen on her. What it needs is: her
existing Apple Developer Program membership, the Account Holder agreeing to the updated DPLA (free, a click),
alternative distribution enabled in App Store Connect, a marketplace token from a marketplace that will carry
her, and **Apple Notarization of the build**. AltStore PAL publishes an open onboarding path and explicitly
does not require the developer to be in the EU.

**No, by the route she has in mind.** Web Distribution — serving the app from shrutivtuber.com — requires
Apple authorization against seven eligibility criteria, and she meets none of them. The install threshold is
now "more than one million first annual installs **worldwide** … in the prior calendar year" coupled with
"two continuous years or more" of membership, and that is only one of seven options; the other six are a fee
waiver for nonprofits/schools/governments, a D&B Global Business Ranking in the Low/Below-Average Risk bands,
a stock exchange listing, VC funding from a named-list firm, a USD 1,000,000 stand-by letter of credit held
six months, or an audited financial statement with an unqualified opinion. None fits a solo Belgian developer
one month into membership with a never-published app.

**And no, there is no unmediated route.** There is no iOS "sideloading" in the sense of handing a user an
`.ipa`. Notarization "applies to all apps, regardless of their distribution channel", and install-time checks
require the install to have been "initiated through an authorized alternative app marketplace or an approved
developer's website". Ad Hoc (100 devices per product family per membership year, UDIDs registered in
advance, audience limited by the DPLA to people affiliated with her) and TestFlight (10,000 external testers,
but **external testing requires App Review against the full App Review Guidelines**) are development and
testing channels, not public distribution.

So the belief that "Apple legally has to allow" her to distribute outside the App Store is **half right and
half wrong**. The DMA did force Apple to open alternative distribution, and she can use it — but via a
marketplace, not from her own site. Apple's obligation was never read by Apple as "any developer may serve
apps from their own domain"; Web Distribution is the DMA-driven capability and Apple gates it behind
eligibility criteria that exclude almost every solo developer.

### Does 4.3(b) apply outside the App Store?

**No.** Verified on the live guidelines page, 25 Sep 2026: **4.3(a) carries the `ASR & NR` key icon and the
`data-nr` marker; 4.3(b) carries neither.** Apple's own instruction is "You can see which guidelines apply to
Notarization for iOS and iPadOS apps by clicking on 'Highlight Notarization Review Guidelines Only' in the
menu to the left", and App Store Connect lets her pick Review Type = Notarization to be "evaluated based on
the Notarization Review Guidelines (a subset of the App Review Guidelines)". 4.3(b) is not in that subset,
and its own wording is entirely about App Store curation ("degrades App Store discovery", "we will not accept
new submissions", "We may remove these apps from the App Store").

This is not a soft inference. Apple's own `filterNotarized.js` greys out every element lacking `data-nr`
when the reader ticks "Highlight Notarization Review Guidelines Only" — so Apple's page actively greys out
4.3(b) when asked to show the Notarization Review Guidelines. The only caveat is that Apple never prints the
sentence in prose.

Second caveat: 4.3(b)'s last sentence — "Repeated submissions of this kind may lead to removal from the Apple
Developer Program" — is a program-level sanction, and program membership sits upstream of every distribution
channel including notarization. Escaping 4.3(b) by choosing notarization does not make repeated App Store
resubmission of the same shape safe.
