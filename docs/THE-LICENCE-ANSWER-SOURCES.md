# AGPL-3.0 and iOS distribution outside the App Store (EU)

Research compiled 25 September 2026. All fetch dates are 25 September 2026 unless stated.
Conventions: `>` blockquote = exact quote from the cited source. **INFERENCE** marks my
reasoning, not a source's words. **UNVERIFIED** marks a point I could not settle from a
primary source.

---

## 1. What exactly is the incompatibility?

### 1a. The operative AGPL-3.0 text

Source: <https://www.gnu.org/licenses/agpl-3.0.txt> (the plain-text licence served by gnu.org,
identical in substance to the HTML at <https://www.gnu.org/licenses/agpl-3.0.en.html>).
Fetched 25 Sep 2026.

**Section 10, third paragraph — "Automatic Licensing of Downstream Recipients".** This is the
clause that does the work:

> You may not impose any further restrictions on the exercise of the
> rights granted or affirmed under this License.  For example, you may
> not impose a license fee, royalty, or other charge for exercise of
> rights granted under this License, and you may not initiate litigation
> (including a cross-claim or counterclaim in a lawsuit) alleging that
> any patent claim is infringed by making, using, selling, offering for
> sale, or importing the Program or any portion of it.

And the first paragraph of section 10, which is what the restriction attaches to:

> Each time you convey a covered work, the recipient automatically
> receives a license from the original licensors, to run, modify and
> propagate that work, subject to this License.  You are not responsible
> for enforcing compliance by third parties with this License.

**Section 12 — "No Surrender of Others' Freedom".** This is why "Apple made me do it" is not a
defence, and why the remedy is not to convey at all:

> If conditions are imposed on you (whether by court order, agreement or
> otherwise) that contradict the conditions of this License, they do not
> excuse you from the conditions of this License.  If you cannot convey a
> covered work so as to satisfy simultaneously your obligations under this
> License and any other pertinent obligations, then as a consequence you may
> not convey it at all.  For example, if you agree to terms that obligate you
> to collect a royalty for further conveying from those to whom you convey
> the Program, the only way you could satisfy both those terms and this
> License would be to refrain entirely from conveying the Program.

**Section 6 — "Conveying Non-Source Forms", the User Product / Installation Information
paragraphs.** These are the anti-tivoization clauses, relevant to item 6 (whether a user can
build and install their own modified version):

> A "User Product" is either (1) a "consumer product", which means any
> tangible personal property which is normally used for personal, family,
> or household purposes, or (2) anything designed or sold for incorporation
> into a dwelling.  In determining whether a product is a consumer product,
> doubtful cases shall be resolved in favor of coverage.

> "Installation Information" for a User Product means any methods,
> procedures, authorization keys, or other information required to install
> and execute modified versions of a covered work in that User Product from
> a modified version of its Corresponding Source.  The information must
> suffice to ensure that the continued functioning of the modified object
> code is in no case prevented or interfered with solely because
> modification has been made.

> If you convey an object code work under this section in, or with, or
> specifically for use in, a User Product, and the conveying occurs as
> part of a transaction in which the right of possession and use of the
> User Product is transferred to the recipient in perpetuity or for a
> fixed term (regardless of how the transaction is characterized), the
> Corresponding Source conveyed under this section must be accompanied
> by the Installation Information.  But this requirement does not apply
> if neither you nor any third party retains the ability to install
> modified object code on the User Product (for example, the work has
> been installed in ROM).

**INFERENCE (flagged):** the Installation Information duty in section 6 is triggered by
conveying object code "in, or with, or specifically for use in, a User Product" as part of a
transaction transferring possession of *the User Product*. A developer shipping an app to a
phone the user already owns is not transferring the iPhone, so on its face this paragraph is
about the party who sells the hardware (Apple), not the app developer. I found no FSF
statement squarely on this app-vs-hardware distinction; treat as **UNVERIFIED**.

### 1b. What the FSF actually said conflicts — and it is not primarily the DRM

Source: Brett Smith (FSF), "More about the App Store GPL Enforcement",
<https://www.fsf.org/blogs/licensing/more-about-the-app-store-gpl-enforcement>, published
26 May 2010, fetched 25 Sep 2026. This is the single most important source for the question,
because it names the exact terms and the exact clause.

The FSF states the analysis applies to the AGPL too, not just GPLv2:

> Along the same lines, we'll be talking about GPLv2 specifically in this blog post, since
> that's the license at issue, but this analysis would apply to all versions of the GNU GPL
> and AGPL.

It then identifies the licence clause — GPLv2 s.6, whose GPLv3/AGPLv3 analogue is s.10:

> (Emphasis added.) This last sentence is a crucial part of the strong copyleft in the GPL and
> AGPL: it prevents distributors from using separate legal agreements, like Terms of Service or
> NDAs, to take away the freedoms that the license is supposed to grant. This is the license
> condition that Apple is violating when it distributes GPL-covered software through the App
> Store.

The conflicting Apple term is the **Usage Rules in the App Store Terms of Service, s.9(b)**,
quoted by the FSF as:

> You acknowledge that Products contain security technology that limits your usage of Products
> to the following applicable Usage Rules, and, whether or not Products are limited by security
> technology, you agree to use Products in compliance with the applicable Usage Rules.

Critically, the FSF says the mechanism is **legal, not technological** — the DRM and the Usage
Rules are two routes to the same restriction, and it is the Rules it objects to:

> The Terms go on to list the specific usage rules. In effect, the Usage Rules do the same
> thing as Apple's Digital Restrictions Management—narrowly limiting what you can do with the
> software—but the method is different: they work legally instead of technologically. Rules (i)
> and (iii) say that you are required to accept the Terms of Service to use the software, and
> that you may only install the software on five approved devices. These rules are exactly the
> kind of "further restrictions" that are prohibited by the GPL: they limit your ability to use
> and distribute the software.

And the reason a permissive developer licence does not cure it — s.9(c) makes the Usage Rules
apply on top of any other licence:

> Some people have pointed out that the App Store Terms of Service say that a separate license
> to the software is provided to you by the developer, and that's true. But the Usage Rules are
> imposed on you no matter how the software is licensed. The Terms themselves make this explicit
> this in section 9(c), which says:

> The Usage Rules shall govern your rights with respect to the Products, in addition to any
> other terms or rules that may have been established between you and another party. (Emphasis
> added.)

The FSF's own summary of the whole conflict:

> That's the problem in a nutshell: Apple's Terms of Service impose restrictive limits on use
> and distribution for any software distributed through the App Store, and the GPL doesn't
> allow that.

The outcome — Apple removed the app rather than change terms:

> Apple has removed GNU Go from the App Store, continuing their longstanding habit of
> preventing users from doing anything that Apple doesn't want them to do.

### 1c. The VLC / Applidium matter

Source: Brett Smith (FSF), "VLC developer takes a stand against DRM enforcement in Apple's App
Store", <https://www.fsf.org/blogs/licensing/vlc-enforcement>, published 29 Oct 2010, fetched
25 Sep 2026.

> Rémi Denis-Courmont is one of the primary developers of the VLC media player, which is free
> software and distributed under the GPL. Earlier this week, he wrote to Apple to complain that
> his work was being distributed through their App Store, under terms that contradict the GPL's
> conditions and prohibit users from sharing the program.

The FSF quotes Denis-Courmont's own announcement:

> VLC media player is free software licensed solely under the terms of the... GNU General
> Public License (a.k.a. GPL). Those terms are contradicted by the products usage rules of the
> AppStore through which Apple delivers applications to users of its mobile devices.

Note that Denis-Courmont's stated grievance is again the **usage rules**, not the encryption.
The FSF adds:

> We've written before about the Usage Rules in the App Store's legal terms, and how they
> conflict with the GNU GPL and AGPL.

> The GPL gives Apple permission to distribute this software through the App Store. All they
> would have to do is follow the license's conditions to help keep the software free. Instead,
> Apple has decided that they prefer to impose Digital Restrictions Management (DRM) and
> proprietary legal terms on all programs in the App Store, and they'd rather kick out GPLed
> software than change their own rules.

Apple removed the VLC port in January 2011 (secondary sources; the FSF post predates the
removal and only predicts it).

### 1d. GPL FAQ confirmation that s.10 is the GPLv3/AGPLv3 home of the rule

Source: <https://www.gnu.org/licenses/gpl-faq.html>, fetched 25 Sep 2026. Under
"Why is the original BSD license incompatible with the GPL?" (`#OrigBSD`):

> You may not impose any further restrictions on the recipients' exercise of the rights granted
> herein.

> GPLv3 says something similar in section 10. The advertising clause provides just such a
> further restriction, and thus is GPL-incompatible.

On DRM, the FAQ is explicit that the GPL does **not** ban DRM as such (`#DRMProhibited`):

> It does not; you can use code released under GPLv3 to develop any kind of DRM technology you
> like. However, if you do this, section 3 says that the system will not count as an effective
> technological "protection" measure, which means that if someone breaks the DRM, she will be
> free to distribute her software too, unhindered by the DMCA and similar laws.

> As usual, the GNU GPL does not restrict what people do in software, it just stops them from
> restricting others.

On tivoization (`#Tivoization`), which is the section 6 route rather than the section 10 route:

> When people distribute User Products that include software under GPLv3, section 6 requires
> that they provide you with information necessary to modify that software. User Products is a
> term specially defined in the license; examples of User Products include portable music
> players, digital video recorders, and home security systems.

### 1e. Section 1 conclusion (what the incompatibility *is*)

Reading the FSF's own words rather than the folklore: the operative conflict is
**AGPLv3 s.10's "no further restrictions" rule versus the App Store Terms of Service Usage
Rules** — a contract Apple imposes on the *end user*, which (i) conditions use of the app on
accepting Apple's ToS, (ii) caps installs at a number of Apple-approved devices, and (iii) by
its own s.9(c) applies *in addition to* the developer's licence. FairPlay DRM is described by
the FSF as doing "the same thing" by a technological route, and is the reason the Usage Rules
bite even absent agreement — but the clause the FSF invokes is the further-restrictions rule,
and the restriction it points at is textual. **INFERENCE:** that framing is what makes the EU
alternative-distribution question live at all — if neither an Apple-imposed end-user usage
rule nor DRM attaches to a copy delivered outside the App Store, the specific conflict the FSF
identified would not arise on those facts. Whether that is so is item 2.

---

## 2. Are EU alternatively-distributed apps subject to DRM or per-device install limits?

Short answer from primary sources: **yes, DRM — Apple's own word — is mandatory; no, there is no
Apple-imposed per-device install cap, and no Apple end-user Usage Rules attach.** The DRM is
operated by the distributor, not by Apple, and it can be configured never to expire.

### 2a. Apple encrypts and signs every alternatively-distributed app

Source: Apple, "Changes for apps in the European Union",
<https://developer.apple.com/support/dma-and-apps-in-the-eu/>, section "Notarizing apps",
fetched 25 Sep 2026.

> Apple encrypts and signs all iOS and iPadOS apps intended for alternative distribution to help
> protect developers' intellectual property and ensure that users get apps from known parties.
> Notarized apps also undergo a series of checks during installation to ensure that they haven't
> been tampered with and that the installation was initiated through an authorized alternative app
> marketplace or an approved developer's website. If Apple determines that an app contains known
> malware after it's been installed, it will be prevented from launching, and new installations
> will be blocked.

Two distinct restrictions in that paragraph:
1. Encryption and signing of the app binary.
2. Installation must have been "initiated through an authorized alternative app marketplace or an
   approved developer's website" — i.e. a copy cannot be installed from an arbitrary source.

Note what the paragraph does **not** say: it does not mention an Apple Account, a device count,
or any limit on the number of installs. **UNVERIFIED:** whether this encryption is the same
FairPlay per-Apple-Account mechanism used for App Store apps. I could not find an Apple primary
source stating the algorithm or the key-binding for alternative distribution. Secondary/community
sources (OWASP MASTG, <https://mas.owasp.org/MASTG/0x06a-Platform-Overview/>) describe App Store
FairPlay code encryption as decryptable only on devices associated with the purchaser's Apple
Account, but that describes the App Store path, not this one.

**INFERENCE (flagged, but strongly supported):** the web-distribution flow is inconsistent with
per-user keying, because the developer downloads one static package and serves it to everyone.
Apple's own description, <https://developer.apple.com/support/web-distribution-eu/>, fetched
25 Sep 2026:

> Using App Store Connect, developers can easily download signed binary assets and host them on
> their website for distribution.

and <https://developer.apple.com/documentation/marketplacekit/distributing-your-app-from-your-website>
(fetched 25 Sep 2026):

> If Apple approves your app for distribution, download your app's *alternative distribution
> package* from App Store Connect, this package contains everything that the system needs to
> install your app.

A single package served from the developer's own web server to all comers cannot be encrypted
under a per-recipient key. So the encryption is plausibly app-level (anti-tamper / provenance),
not user-level (copy control). I could not confirm this from an Apple statement; treat the
conclusion as **UNVERIFIED**.

### 2b. Apple *does* mandate DRM — and calls it that — but the developer operates it

This is the most important thing I found, and it is Apple's own documentation, not commentary.

Source: Apple, "App License Delivery SDK",
<https://developer.apple.com/documentation/applicensedeliverysdk>, fetched 25 Sep 2026.

> This Swift SDK enables *digital rights management* (DRM) for alternative distribution apps. Use
> this SDK to generate licenses for alternative app marketplaces you build with MarketplaceKit or
> other apps that you distribute from your website. Alternative app marketplaces use this SDK to
> generate a license for each app that developers distribute on the marketplace. By licensing each
> download individually, you provide a secure installation experience similar to the App Store.

> Use this SDK's framework to implement a license server on your website back end that's capable
> of running compiled Swift code.

Source: Apple, "Licensing alternative distribution apps",
<https://developer.apple.com/documentation/applicensedeliverysdk/licensing-alternative-distribution-apps>,
fetched 25 Sep 2026. The mandatory nature is explicit:

> iOS and iPadOS require each app that installs outside of the App Store to have a license issued
> by the developer. As the developer of an alternative app marketplace or other app that installs
> over the web, you use the `App License Delivery SDK` to generate a license for each download
> request for your app.

> The MarketplaceKit installation methods trigger the device's operating system to request a
> license from your web server before installing a particular app.

So: every install of an alternatively-distributed app is gated on a licence that the
**developer's own server** issues. The licence is a real enforcement mechanism, not a formality.

Source: Apple, "Renewing and revoking app licenses",
<https://developer.apple.com/documentation/applicensedeliverysdk/renewing-and-revoking-app-licenses>,
fetched 25 Sep 2026:

> An app license expires when its expiry date passes. The expiry date is the `duration` after the
> `issuedTime`. Your license server determines the value of those properties at the time of issuing
> a license.

> When an app's license expires, the device's operating system doesn't allow the app to launch. You
> determine the criteria for renewal, expiration, and revocation of licenses for apps that you
> distribute. Depending on the circumstances, you can renew a license before it expires, let it
> expire, or revoke the license deliberately in advance.

> Once a day, the system checks for app licenses set to expire within the next 24 hours and
> includes each in a license renewal request.

### 2c. The licence can be made non-expiring — this is the escape hatch

Source: Apple, `ALDLicenseAttribute.duration`,
<https://developer.apple.com/documentation/AppLicenseDeliverySDK/ALDLicenseAttribute/duration>,
fetched 25 Sep 2026:

> The maximum amount of time, in seconds, that iOS considers the license valid.

> The alternative app marketplace determines a value for this property at its discretion. iOS
> doesn't let an app launch if the duration of its license lapses.

> A value of `0` indicates that the license doesn't expire. To revoke a license, see Renewing and
> revoking app licenses.

So the developer can issue a perpetual, non-revoked licence at install time. The user's continued
ability to run the app then does not depend on the developer's server staying up.

### 2d. No Apple Usage Rules and no Apple standard EULA attach outside the App Store

The FSF's objection (item 1) was to the Apple Media Services Usage Rules and Apple's standard
EULA. Both are scoped to Apple's own Services.

Source: Apple Media Services Terms and Conditions,
<https://www.apple.com/legal/internet-services/itunes/us/terms.html>, fetched 25 Sep 2026.
Section A, defining scope:

> This Agreement governs your use of Apple's services ("Services") through which you can buy, get,
> license, rent or subscribe to content, Apps (as defined below), and other in-app services
> (collectively, "Content"). Content may be offered through the Services by Apple or a third party.
> Examples of Services include, where available, App Store, Subscriptions (as defined below), Apple
> Arcade, Apple Books, Apple Fitness+, Apple Games, Game Center, Apple Music, Apple News, Apple
> One, Apple Podcasts, Apple Sports, Apple TV, iTunes, and Shazam.

Section F, the Usage Rules, is expressly limited to that Content and those Services:

> Your use of the Services and Content must follow the rules set forth in this section ("Usage
> Rules"). Any other use of the Services and Content is a material breach of this Agreement.

The Standard EULA is expressly limited to App Store apps:

> **LICENSED APPLICATION END USER LICENSE AGREEMENT** Apps made available through the App Store are
> licensed, not sold, to you.

And its scope-of-licence clause is the restriction the AGPL cannot tolerate:

> a. Scope of License: Licensor grants to you a nontransferable license to use the Licensed
> Application on any Apple-branded products that you own or control and as permitted by the Usage
> Rules. [...] Except as provided in the Usage Rules, you may not distribute or make the Licensed
> Application available over a network where it could be used by multiple devices at the same time.
> You may not transfer, redistribute or sublicense the Licensed Application except as expressly
> permitted in this Agreement and, if you sell your Apple Device to a third party, you must remove
> the Licensed Application from the Apple Device before doing so. You may not copy (except as
> permitted by this license and the Usage Rules), reverse-engineer, disassemble, attempt to derive
> the source code of, modify, or create derivative works of the Licensed Application, any updates,
> or any part thereof (except as and only to the extent that any foregoing restriction is
> prohibited by applicable law or to the extent as may be permitted by the licensing terms
> governing use of any open-sourced components included with the Licensed Application).

Two things worth noting about that clause as it stands in 2026:
- It now carries an **open-source carve-out**, but only for the *copy / reverse-engineer /
  disassemble / modify / derivative-works* restrictions. The carve-out does **not** extend to
  "nontransferable", to "may not distribute or make the Licensed Application available over a
  network", or to "may not transfer, redistribute or sublicense". Those survive for open-source
  components, and they are squarely at odds with AGPL s.10.
- The FSF's 2010 "five approved devices" install cap is no longer the App Store wording. The
  current Usage Rules say instead:

> - You can use Content from up to five (5) different Apple Accounts on each device.

> - For any Service, you can have up to ten (10) devices (but only a maximum of five (5) computers)
> signed in with your Apple Account at one time [...] Devices can be associated with a different
> Apple Account once every ninety (90) days.

So the modern App Store restriction is account/device association, not a literal five-install cap.
The redistribution prohibition in the Standard EULA is now the sharper conflict.

### 2e. Does any of that reach alternative distribution? No — by express carve-out

See item 3. The Developer Agreement disapplies Schedules 1–3 (and hence the minimum-EULA
instructions that force the non-transferable, device-scoped licence) for alternative distribution.

### 2f. What I could not establish

- **UNVERIFIED:** whether Apple's encryption of alternative-distribution packages binds a copy to
  a device or an Apple Account. No Apple primary source states this either way.
- **UNVERIFIED:** whether the install-verification-token and licence flow record or cap the number
  of devices. Nothing in the documentation I read sets a numeric limit.
- **UNVERIFIED:** whether, in an EU alternative-distribution install, the user is presented with
  any Apple-authored end-user terms at all. I found no such document.

---

## 3. Do notarization or the Alternative Terms / Attachment 14 impose AGPL-forbidden terms?

### 3a. The decisive carve-out: Schedules 1, 2 and 3 do not apply

This is the single most useful contractual finding, and it appears in both the outgoing and the
incoming instrument.

Source: Apple, "Alternative Terms Addendum for Apps in the EU",
<https://developer.apple.com/contact/request/download/alternate_eu_terms_addendum.pdf>,
s.2.3(C), fetched 25 Sep 2026:

> C.      Terms of the Developer Agreement (Sections 1-14, and all Attachments) that apply to
> Applications or Licensed Applications (including when distributed on the App Store), also apply
> to Applications and Licensed Applications when they are distributed through Alternative App
> Marketplaces (EU) or Your Website (EU), as well as Alternative App Marketplaces (EU), except as
> follows:
> - Section 3.3.4(A)(iii);
> [...]
> - Section 6.3;
> - Section 7.1 and Section 7.2; and
> - Attachment 2.
> - For clarity, Schedules 1, 2, and 3 to the Developer Agreement do not apply.

Source: Apple Developer Program License Agreement (English, current as served
25 Sep 2026), <https://developer.apple.com/support/downloads/terms/apple-developer-program/Apple-Developer-Program-License-Agreement-English.pdf>,
Attachment 14 s.2.3(C). Attachment 14 is the instrument that takes over from the Addendum:

> This Attachment is effective as of October 1, 2026, or the date on which You sign this Agreement
> including this Attachment 14, whichever is later.

> This Attachment replaces and supersedes the terms of any "Alternative Terms Addendum for Apps in
> the EU" and "StoreKit External Purchase Link Addendum for Apps in the EU" that You signed
> previously.

> C.      Terms of the Agreement (Sections 1-14, and all Attachments, Schedules, and Exhibits)
> that apply to Applications or Licensed Applications (including when distributed on the App
> Store), also apply to Applications and Licensed Applications when they are distributed through
> Alternative App Marketplaces (EU) or Your Website (EU), as well as Alternative App Marketplaces
> (EU), except as follows:
> [...]
> - Schedules 1, 2, and 3 to the Agreement do not apply.

### 3b. Why that carve-out matters: it is Schedule 1 that forces an AGPL-incompatible EULA

For App Store distribution, the Developer Agreement *requires* the developer to impose a
non-transferable, device-scoped licence on the user. Source: APDLA Schedule 1, s.3.2 (fetched
25 Sep 2026):

> 3.2      You may deliver to Apple Your own EULA for any Licensed Application at the time that
> You deliver that Licensed Application to Apple [...] provided, however, that Your EULA must
> include and may not be inconsistent with the minimum terms and conditions specified on Exhibit B
> to this Schedule 1 [...] In the event that You do not furnish Your own EULA for any Licensed
> Application to Apple, You acknowledge and agree that each end-user's use of that Licensed
> Application shall be subject to Apple's standard EULA (which is part of the App Store Terms of
> Service).

And Exhibit B to Schedule 1, "Instructions for Minimum Terms of Developer's End-User License
Agreement", s.1 and s.2:

> 1.       Acknowledgement: [...] The EULA may not provide for usage rules for Licensed
> Applications that are in conflict with, the Apple Media Services Terms and Conditions or the
> Volume Content Terms as of the Effective Date (which You acknowledge You have had the opportunity
> to review).

> 2.        Scope of License: The license granted to the end-user for the Licensed Application
> must be limited to a non-transferable license to use the Licensed Application on any Apple-
> branded Products that the end-user owns or controls and as permitted by the Usage Rules set
> forth in the Apple Media Services Terms and Conditions, except that such Licensed Application
> may be accessed, acquired, and used by other accounts associated with the purchaser via
> Family Sharing, volume purchasing, or Legacy Contacts.

That is a contractual *obligation on the developer* to grant the user less than the AGPL grants:
"must be limited to a non-transferable license". A developer cannot simultaneously obey Exhibit B
s.2 and AGPL s.10. Exhibit B is an exhibit to Schedule 1, so when Schedule 1 "do[es] not apply",
Exhibit B goes with it.

**INFERENCE (flagged):** I read Attachment 14 s.2.3(C)'s "Schedules 1, 2, and 3 to the Agreement
do not apply" as carrying the exhibits to those schedules with them, because Exhibit B is titled
"(to Schedule 1)" and has no independent operative hook. Attachment 14's preamble to the same
sentence does separately enumerate "Attachments, Schedules, and Exhibits" as applying, which could
be read as keeping Exhibit B alive independently. I found no Apple statement resolving this.
**This is a genuine textual ambiguity and it is the sharpest unresolved contractual point.**

### 3c. What the addendum / Attachment 14 *do* require, and whether any of it is a
"further restriction" in the s.10 sense

Reading the whole of s.2 of both instruments, the obligations fall on the *developer and the
marketplace operator*, and concern eligibility, IP-dispute handling, monitoring, metadata,
export control, and trademark. I found **no** clause requiring the developer to restrict the
end user's copying, modification or redistribution. The nearest items:

Addendum s.2.1(A), final bullet (and the same in Attachment 14) — a pro-user requirement, not a
restriction:

> - Restoration (i.e., via iOS and/or iPadOS backups to iCloud or a computer) and redownloading of
> Applications distributed by Your Alternative App Marketplace (EU) or Your Website (EU) must be
> free of charge.

Addendum s.2.1(B) — the install-verification-token requirement, which does gate installs:

> B.      In addition, to help verify that installations of Applications from Your Alternative App
> Marketplace (EU) or Your Website (EU) are valid, Your Alternative App Marketplace (EU) or Your
> Website (EU) (as applicable) must:
> - Provide the install verification token as part of the URLs starting with the scheme as defined
> by MarketplaceKit for each installation (including initial installation, redownloads, updates,
> and any other form of installation) of Your Alternative App Marketplace (EU); and
> - Provide the install verification token as part of the URLs starting with the scheme as defined
> by MarketplaceKit for each installation (including initial installation, redownloads, updates,
> and any other form of installation) of an Application from Your Alternative App Marketplace (EU)
> or Your Website (EU).

Addendum s.2.1(A), for web distribution, restricts *who may distribute*:

> - For distribution from Your Website (EU):
>          - You must be a member in good standing of the Apple Developer Program for two (2)
>          continuous years or more, and have an Application that had more than one (1) million
>          First Annual Installs on iOS and/or iPadOS in the EU in the prior calendar year; and
>          - You may distribute Your Applications on iOS and/or iPadOS in the EU;

and Apple's support page states the domain lock, <https://developer.apple.com/support/web-distribution-eu/>,
fetched 25 Sep 2026:

> Apps offered through Web Distribution must meet Notarization requirements to protect platform
> integrity, like all iOS and iPadOS apps, and can only be installed from a website domain that
> the developer has registered in App Store Connect.

**This is the restriction that bites on the AGPL's redistribution freedom.** It is not a term the
developer imposes on the user by contract; it is a platform condition. A recipient who exercises
AGPL s.10's "propagate" right by hosting the binary on their own site cannot have it install on an
iPhone, because the domain is not registered and no authorised marketplace initiated the install.

### 3d. Notarization terms

Notarization is a review, and the Notarization Review Guidelines are a subset of the App Review
Guidelines. Apple's description of what notarization checks,
<https://developer.apple.com/support/dma-and-apps-in-the-eu/>, fetched 25 Sep 2026:

> Notarization for iOS and iPadOS apps is a baseline review that applies to all apps, regardless of
> their distribution channel, focused on platform policies for security and privacy and to maintain
> device integrity. Through a combination of automated checks and human review, notarization helps
> check that apps are free of known malware, viruses, or other security threats, function as
> promised, and don't expose users to egregious fraud.

The checks are listed as Accuracy, Functionality, Safety, Security and Privacy. Of these, the
Security bullet is the one that touches software freedom:

> Security. Apps cannot enable distribution of malware or of suspicious or unwanted software. They
> cannot download executable code, read outside of the container, or direct users to lower the
> security on their system or device. Also, apps must provide transparency and allow user consent
> to enable any party to access the system or device, or reconfigure the system or other software.

**INFERENCE (flagged):** "cannot download executable code" would prevent an AGPL app from
shipping a mechanism by which a user swaps in their own build of a linked library, but it does not
restrict what the recipient may do with the source the developer publishes.

Apple's consumer-facing description confirms notarization is not App Review and leaves content
policy to the distributor, <https://support.apple.com/en-us/118110>, fetched 25 Sep 2026:

> Apps installed through alternative app distribution undergo a Notarization process to ensure
> every app meets baseline platform integrity standards, but it is up to each alternative app
> distributor to review apps in accordance with their own processes and policies.

**Bottom line for item 3:** the Addendum and Attachment 14 do *not* contain an
end-user-facing further restriction, and they expressly disapply the Schedule 1 machinery that
does. The restrictions that remain are platform-level: notarization as a precondition to
installability, an Apple-registered domain or authorised marketplace as the only permitted
install origin, and a mandatory per-install licence (which can be perpetual).

---

## 4. What does the library's own licensor say?

### 4a. The dual licence, in Astrodienst's words

Source: Astrodienst, "Swiss Ephemeris — General Information",
<https://www.astro.com/swisseph/swephinfo_e.htm>, fetched 25 Sep 2026. The same text appears in the
`LICENSE` file of the official repository,
<https://raw.githubusercontent.com/aloistr/swisseph/master/LICENSE> (copyright line reads
"Copyright (C) 1997 - 2021 Astrodienst AG, Switzerland. All rights reserved."), fetched
25 Sep 2026:

> Swiss Ephemeris is made available by its authors under a dual licensing system. The software
> developer, who uses any part of Swiss Ephemeris in his or her software, must choose between one
> of the two license models, which are
> a) GNU Affero General Public License (AGPL)
> b) Swiss Ephemeris Professional License

> The choice must be made before the software developer distributes software containing parts of
> Swiss Ephemeris to others, and before any public service using the developed software is
> activated.

> If the developer choses the AGPL software license, he or she must fulfill the conditions of that
> license, which includes the obligation to place his or her whole software project under the AGPL
> or a compatible license. See https://www.gnu.org/licenses/agpl-3.0.html

Note also this clause, which bears on how the app credits the library:

> The names of the authors or of the copyright holder (Astrodienst) must not be used for promoting
> any software, product or service which uses or contains the Swiss Ephemeris. This copyright
> notice is the ONLY place where the names of the authors can legally appear, except in cases where
> they have given special permission in writing.

**Finding:** Astrodienst says nothing whatsoever about app stores, mobile distribution, iOS, or
DRM, on the licence page or in the `LICENSE` file. Their AGPL limb is plain vanilla AGPL-3.0 with
a name-use restriction. I searched their licence page, price page, and repository licence file and
found no statement on distributing the library in mobile apps or app stores. **UNVERIFIED /
negative finding:** there is no Astrodienst position on the App Store question to quote.

### 4b. The commercial licence: price and terms

Source: Astrodienst, "Swiss Ephemeris price list and order",
<https://www.astro.com/swisseph/swephprice_e.htm>, fetched 25 Sep 2026:

> Free Edition (download):
> 0.00 CHF

> Professional Edition unlimited license
> 700.00 CHF

> CHF are Swiss Francs. The amount is automatically converted at current exchange rates to EUR or
> USD, depending on your country.

> Only the license is sold, based on a signed license contract which you should email to
> order@astro.com. The actual software is to be downloaded by the licensee from the public Github
> repository.

Source: "Swiss Ephemeris Professional License contract, Edition June 2026",
<https://www.astro.com/swisseph/secont_e.pdf>, fetched 25 Sep 2026. The operative clauses:

> This contract is for
> [ X ] an unlimited license at CHF 700.-

> 2.    Validity of license for projects
>       The license is valid for distributed software apps: The licensee develops a software app
>       for which the copyright is held by the licensee. In this software he uses calls to
>       functions of the Swiss Ephemeris for calculating astrological or astronomical positions.
>       Even when the distributed app contains no calculation code itself but requests calculation
>       from a server providing it, this is considered an app containing Swiss Ephemeris.
>       The license is also valid for software use on a server: [...]

> 3.    Duration of the license and renewal: A license is valid for 99 years.

> 4.    Distribution: The licensee has, for a project of type 2, the right to distribute the Swiss
>       Ephemeris in compiled form as part of his software and to duplicate the required files for
>       this purpose.

> 5.    Distribution of source code:
>       The licensee is permitted, but not required to distribute the Swiss Ephemeris source code
>       together with his software app.
>       If the licensee chooses to distribute the source code, he must include the complete Swiss
>       Ephemeris source code. If he has made changes to the original source code, he is subject to
>       the same conditions for those changes as laid down in the AGPL.

> 9.    Use of author's names: The licensee will refrain from mentioning Astrodienst AG, Dr. Alois
>       Treindl, Dieter Koch or other authors of the Swiss Ephemeris in the context of his
>       software, neither in the documentation, the software itself or in advertising and
>       promotion. All exceptions require permission by Astrodienst in writing for each distinct
>       case.

> 10.   Copyright: The licensee must not remove or modify any copyright notices placed by
>       Astrodienst or other contributors in source files, library files or binary ephemeris files.

### 4c. Does the commercial licence make the question moot?

Reading the contract: clause 4 grants the right to distribute the library in compiled form as part
of the licensee's app; clause 5 makes source distribution optional; there is no copyleft, no
"no further restrictions" rule, and no channel restriction. Nothing in the contract mentions or
bars app stores, DRM or device limits.

**This is the cheap answer to the whole research question.** CHF 700, one-off, 99 years,
unlimited, and the entire App Store / alternative-distribution / AGPL analysis becomes irrelevant:
the library can then ship on iOS through the ordinary App Store with no licence conflict at all,
and the substitute VSOP87/ELP-2000 engine can be deleted. Two consequences worth naming:
- Clause 5's optionality means the commercial licence does **not** stop the app's own source from
  staying AGPL-3.0-only. But **INFERENCE (flagged):** if the app's own licence is AGPL-3.0-only
  and the app links a proprietary-licensed Swiss Ephemeris, the *app's* AGPL obligations run to
  the app's own code; the library would be a proprietary component the developer is licensed to
  ship. Whether that combination is internally coherent for a repository declared AGPL-3.0-only is
  a question about the developer's own licensing of their own code, not about Astrodienst's terms.
  Not resolved here.
- Clause 9 forbids naming Astrodienst, Treindl or Koch "in the context of his software", including
  in the software itself. Under the AGPL limb, by contrast, the copyright notice must be preserved.
  These pull in opposite directions and the choice of limb changes what the app's credits screen
  may say. Flagging for whoever writes the about screen.

---

## 5. AGPL section 13 specifically

### 5a. The text

Source: <https://www.gnu.org/licenses/agpl-3.0.txt>, fetched 25 Sep 2026. Section 13 in full:

> 13. Remote Network Interaction; Use with the GNU General Public License.
>
>   Notwithstanding any other provision of this License, if you modify the
> Program, your modified version must prominently offer all users
> interacting with it remotely through a computer network (if your version
> supports such interaction) an opportunity to receive the Corresponding
> Source of your version by providing access to the Corresponding Source
> from a network server at no charge, through some standard or customary
> means of facilitating copying of software.  This Corresponding Source
> shall include the Corresponding Source for any work covered by version 3
> of the GNU General Public License that is incorporated pursuant to the
> following paragraph.
>
>   Notwithstanding any other provision of this License, you have
> permission to link or combine any covered work with a work licensed
> under version 3 of the GNU General Public License into a single
> combined work, and to convey the resulting work.  The terms of this
> License will continue to apply to the part which is the covered work,
> but the work with which it is combined will remain governed by version
> 3 of the GNU General Public License.

### 5b. What it requires, and of whom, in plain terms

Reading the text element by element:

- **Trigger:** "if you modify the Program". Section 13 bites on a *modified* version. The Program
  here is the covered work — the Swiss Ephemeris, and by combination the app that links it.
- **Duty holder:** "you", the person who modified it and is running or conveying the modified
  version.
- **Beneficiaries:** "all users interacting with it remotely through a computer network (if your
  version supports such interaction)".
- **Obligation:** "prominently offer ... an opportunity to receive the Corresponding Source of
  your version by providing access to the Corresponding Source from a network server at no
  charge".

The direction of the network interaction is what matters, and it runs the opposite way from the
developer's worry. Section 13 is about people who interact **with the modified Program** over a
network — i.e. users on the far side of a network from the running copy. The classic case is
server-side software: a web service runs a modified AGPL program and the *remote users of that
service* gain the right to its source.

In this app's architecture the copy of the library runs **on the user's own phone**. The phone is
where the covered work executes; the user is a local user of it, not a remote one. The app then
makes outbound calls to the developer's server, but the developer's server is not "interacting
remotely with the modified Program" in the sense of being a *user* of it — and in any case the
duty, if triggered, is to offer *the source*, which the developer already publishes.

**INFERENCE (flagged, and it is the reading I am confident of):** section 13 adds **no obligation
the developer is not already discharging**. The app's Corresponding Source is published in a public
repository under AGPL-3.0-only. Whatever the direction of the network interaction, the remedy s.13
demands is access to Corresponding Source from a network server at no charge, and a public
repository satisfies that. The one thing s.13 adds that a bare repository might not is the word
"**prominently offer**": the offer must be made visible to remote users, not merely be true. So if
anything is outstanding it is a **UI/notice question, not an architecture question** — an in-app
or in-service "source available at <URL>" notice, prominently placed.

**Separate point, and it does bite:** s.13 covers the developer's *server* too, if the server
itself runs a modified copy of the Swiss Ephemeris. The memory note
`charts-cast-in-birthplace-time` and `the-app-and-the-site-disagreed` indicate chart computation
happens server-side as well as in the app. If the server runs the AGPL library (modified or not)
and users interact with it remotely over a network, then s.13's prominent offer is owed to **those
users** — the site's visitors. **UNVERIFIED:** whether the server-side copy is modified, which is
the trigger. Worth checking in the repo.

**What s.13 does not do:** it says nothing about distribution channels, DRM, app stores or device
limits. It is not a source of App Store incompatibility and it is not affected by which iOS
channel is used. The incompatibility question lives entirely in s.10 (and s.6/s.12), not s.13.

---

## 6. Counter-evidence: reasons this would NOT work

I looked specifically for arguments and terms against the proposition. Five hold up.

### 6a. FSFE says alternatively-distributed iOS apps ARE under DRM, and that users cannot freely redistribute

This is the strongest counter-evidence, and it comes from a free-software licensing body writing
in its Legal Column, after alternative distribution existed.

Source: FSFE, "Legal Corner: Apple's 'notarisation' – blocking software freedom of developers and
users!", <https://fsfe.org/news/2025/news-20251105-01.en.html>, dated 2025-11-05, fetched
25 Sep 2026.

> Even for the Free Software commercial ones, such as the Alt Store, Apple still applies a complete
> review and control, through an encryption layer over distributed source code.

> For Free Software developers, the implications are even more severe. Apple's notarisation regime
> requires developers to hold a paid Apple Developer account, accept restrictive legal terms, and
> submit binaries to a closed, opaque process. Once approved, the binaries are re-signed by Apple
> and distributed under digital restriction management (DRM).

> This breaks users' rights when it comes to Free Software freedoms. Users can no longer verify
> that the source code they read corresponds to the binary they run, nor can they freely
> redistribute software that Apple refuses to notarise. What makes this process absurd is that
> Apple applies this notarisation process to all apps running on iOS, no matter which channel of
> distribution.

> Notarisation forces all apps, even those distributed outside Apple's App Store, to be submitted
> to Apple's servers for scanning, approval, and cryptographic re-signing before installation. The
> result is that Apple retains full control over what software users can install and how developers
> can distribute it.

Read carefully, FSFE is making a **DMA-compliance** argument, not delivering a
licence-compatibility verdict, and the article never mentions GPL s.10 or AGPL. But its factual
claims — DRM on alternatively-distributed binaries, no free redistribution, mandatory notarisation
regardless of channel — are exactly the facts that would keep the AGPL conflict alive. And on the
DRM point, FSFE is corroborated by Apple's own documentation (item 2b), which uses the term
"digital rights management (DRM)" itself.

### 6b. A recipient cannot redistribute the binary — the install origin is locked

Two independent locks, both from Apple primary sources (fetched 25 Sep 2026):

> Notarized apps also undergo a series of checks during installation to ensure that they haven't
> been tampered with and that the installation was initiated through an authorized alternative app
> marketplace or an approved developer's website.
> — <https://developer.apple.com/support/dma-and-apps-in-the-eu/>

> Apps offered through Web Distribution [...] can only be installed from a website domain that the
> developer has registered in App Store Connect.
> — <https://developer.apple.com/support/web-distribution-eu/>

AGPL s.10 says the recipient "automatically receives a license from the original licensors, to run,
modify and propagate that work". **Propagation of the binary to another iPhone is not possible**:
the recipient's own website is not a registered domain and they are not an authorised marketplace.
This is a real curtailment, and it is not cured by moving off the App Store — it is a feature of
every non-App-Store channel Apple offers.

**INFERENCE (flagged):** the counter-argument is that s.10's prohibition binds *the conveyor*
("**You** may not impose any further restrictions"), and this restriction is imposed by Apple's
operating system on the recipient's hardware, not by the developer. But AGPL s.12 closes that
door for the developer's own obligations: "If conditions are imposed on you [...] that contradict
the conditions of this License, they do not excuse you from the conditions of this License." Whether
a platform-level install restriction counts as a condition "imposed on you" that you then pass on,
versus a pre-existing property of the recipient's device, is precisely the unresolved question.
I found no authority resolving it.

### 6c. Signing restrictions in the Developer Agreement

Source: APDLA s.5.1 "Certificate Requirements", sub-clauses (d) and (f) (as served 25 Sep 2026,
<https://developer.apple.com/support/downloads/terms/apple-developer-program/Apple-Developer-Program-License-Agreement-English.pdf>).
These apply to alternative distribution, because Attachment 14 s.2.3(C) disapplies only Sections
3.3.4(A)(iii), 6.3, 7.1, 7.2 and Attachment 2:

> [...] and You will not use Your Apple Certificates to sign any third party's application, pass,
> extension, notification, implementation, or site;

> (f) You will use Apple Certificates provided under this Program exclusively for the purpose of
> signing Your Passes, signing Your Safari Extensions, signing Your Site's registration bundle,
> accessing the APN service, and/or signing Your Applications for testing, submission to Apple, for
> MDM, and/or for limited distribution for use on Registered Devices or Authorized Test Units as
> contemplated under this Program, or as otherwise permitted by Apple, and only in accordance with
> this Agreement.

Effect: the developer cannot sign a user's modified build for them, and the user cannot get the
developer's signature on a fork. Anyone wanting to distribute a modified version must obtain their
own Apple Developer Program membership, be separately authorised, and re-notarise.

### 6d. Can a recipient build and run their own modified version on their own iPhone?

Partially, and the freedom is materially degraded rather than absent.

- With their own Apple Developer Program membership and Xcode, a user can build the AGPL source
  and install it on their own device via development/ad-hoc signing. Apple confirms device
  registration is required and capped, <https://developer.apple.com/documentation/xcode/distributing-your-app-to-registered-devices>,
  fetched 25 Sep 2026:

> First, use either Xcode or your developer account to register the devices that you want to test
> with. Consider that your team has a limited number of devices per product family per year for
> both development and testing.

- **UNVERIFIED:** the widely-reported free-account limits (provisioning profiles expiring after
  7 days, at most 3 apps per device) could **not** be confirmed from an Apple primary page in this
  research — the relevant Developer Account Help pages render only via JavaScript and I could not
  extract their text. Several community sources assert both limits. Treat the specific numbers as
  unconfirmed; treat the existence of a re-signing cadence on free accounts as likely but unproven.

- What is clear from primary sources: building and running your own version requires an Apple
  Account, Apple's proprietary toolchain, and Apple-issued credentials. So the AGPL s.6
  "Installation Information" goal — that "the continued functioning of the modified object code is
  in no case prevented or interfered with solely because modification has been made" — is not met
  by the platform, though as noted in item 1a it is arguable that the s.6 duty falls on the party
  conveying the *hardware*, not the app developer.

### 6e. No Apple term requires the developer to be the sole distributor — but eligibility does the same work

I searched the Addendum, Attachment 14 and the APDLA for a sole-distributor or exclusivity clause
and found none. APDLA Schedule 1 s.1.3 in fact says the opposite for the App Store relationship:

> [...] Schedule 1 is non-exclusive.

However, the web-distribution eligibility gate has an equivalent practical effect, because only the
qualifying developer can be an authorised origin. Addendum s.2.1(A) (fetched 25 Sep 2026):

> - For distribution from Your Website (EU):
>          - You must be a member in good standing of the Apple Developer Program for two (2)
>          continuous years or more, and have an Application that had more than one (1) million
>          First Annual Installs on iOS and/or iPadOS in the EU in the prior calendar year;

(Per instruction I am not researching eligibility thresholds; quoted only because it bears on
whether a *recipient* could ever become a redistributor. Note the parallel agent is covering the
current eligibility position and the 1 Oct 2026 expansion.)

### 6f. No FSF position on the EU channels, and the real-world precedent went the other way

- **Negative finding:** I could not find any FSF or gnu.org statement addressing whether EU
  alternative distribution or web distribution cures the GPL/App Store conflict. The FSF's
  App Store material remains the 2010 GNU Go and VLC posts. Searches limited to fsf.org and
  gnu.org returned only those and general anti-iOS campaign pages
  (<https://www.fsf.org/iphone>, <https://www.fsf.org/campaigns/iphone>), fetched 25 Sep 2026.
  So there is **no authority either endorsing or rejecting** the proposition in this task.
- The way the canonical case was actually resolved was by **changing the licence, not the channel**:
  VLC returned to the App Store after its core was relicensed from GPL to LGPL, a change that
  required collecting permission from its copyright holders. (Secondary sources only; I did not
  locate a primary VideoLAN relicensing announcement in this research. **UNVERIFIED** as to
  detail, though the outcome — VLC on the App Store today — is not in dispute.) The direct analogue
  here is buying the Swiss Ephemeris Professional Licence (item 4).

### 6g. A counter-point that cuts the *other* way, worth recording

Apple's current Standard EULA — the one that applies on the App Store, and that the FSF's argument
targets — now contains an explicit open-source carve-out for the copy/modify/reverse-engineer
restrictions (quoted in full at item 2d):

> (except as and only to the extent that any foregoing restriction is prohibited by applicable law
> or to the extent as may be permitted by the licensing terms governing use of any open-sourced
> components included with the Licensed Application)

This did not exist in the 2010 terms the FSF analysed. It weakens part of the historic argument
even for App Store distribution. It does **not** reach the "nontransferable", "may not distribute
[...] over a network" or "may not transfer, redistribute or sublicense" restrictions, which have no
open-source carve-out — so the redistribution conflict survives. Anyone relying on the 2010 FSF
analysis as-is is working from superseded Apple text.

---

## 7. Where the question turns

Assembling the above without drawing a legal conclusion, the answer depends on which of two
characterisations of the s.10 "further restrictions" rule is correct.

**The characterisation that favours dropping the substitute engine.** The FSF's own stated
conflict was with *terms Apple imposes on end users by contract* — the Media Services Usage Rules
and the standard EULA — plus the Schedule 1 obligation on the developer to grant only a
"non-transferable license". Every one of those is scoped to the App Store, and Attachment 14
s.2.3(C) expressly disapplies Schedules 1–3 for alternative distribution. On this reading the
specific restriction the FSF identified does not attach outside the App Store, the developer
imposes nothing on the recipient beyond the AGPL, and the app's source is already published.

**The characterisation that defeats it.** Apple still calls the alternative-distribution mechanism
"digital rights management (DRM)"; a licence issued by the developer's own server is a mandatory
precondition to every install; the OS refuses to launch an app whose licence has lapsed; the binary
is encrypted and signed by Apple; and installation is only possible from an Apple-registered domain
or an authorised marketplace, so **a recipient cannot propagate the binary at all**. FSFE, writing
in November 2025, states plainly that users of alternatively-distributed iOS apps "[cannot] freely
redistribute" them. If the s.10 test is about the *effective freedoms the recipient actually has*
rather than about *which document restricts them*, the conflict persists and moving channels
changes nothing.

**The two facts that most move the needle in favour:**
1. `duration = 0` — "A value of `0` indicates that the license doesn't expire." The developer
   controls the licence server and can make the DRM licence perpetual, so the run-freedom is not
   conditioned on the developer's continued cooperation.
2. "Schedules 1, 2, and 3 to the Agreement do not apply" — the contractual requirement to impose a
   non-transferable licence on the user is gone.

**The one fact that most moves it against:** apps "can only be installed from a website domain that
the developer has registered in App Store Connect" or via an authorised marketplace. That is a
platform-enforced bar on the recipient's s.10 right to propagate, and it exists on every iOS
channel including the alternative ones.

**The cheapest resolution, which sidesteps all of the above:** the Swiss Ephemeris Professional
License, CHF 700 one-off, unlimited, 99 years, with an express right to "distribute the Swiss
Ephemeris in compiled form as part of his software". That makes the AGPL irrelevant to the iOS
build, permits ordinary App Store distribution, and lets the substitute VSOP87/ELP-2000 engine be
deleted — without needing EU alternative distribution, its eligibility gates, or a licence-server
deployment at all.

### Unverified points, collected

- Whether Apple's encryption of alternative-distribution packages is FairPlay, and whether it binds
  a copy to a device or Apple Account. No Apple primary source found either way.
- Whether any numeric device/install cap applies to alternatively-distributed apps. None found in
  the documentation read; absence of evidence, not evidence of absence.
- Whether Exhibit B to Schedule 1 falls away with Schedule 1 under Attachment 14 s.2.3(C), given
  that the same sentence's preamble enumerates "Exhibits" as applying. Genuine textual ambiguity.
- Whether an end user in an EU alternative-distribution install is shown any Apple-authored
  end-user terms at all.
- The free-provisioning 7-day / 3-app limits (community-sourced only).
- Whether the developer's server-side chart code runs a *modified* Swiss Ephemeris, which is the
  trigger for AGPL s.13 obligations to the site's remote users.
- Whether AGPL s.6 Installation Information duties fall on an app developer at all, as opposed to
  the party conveying the hardware.
- Primary VideoLAN source for the GPL-to-LGPL relicensing that returned VLC to the App Store.
