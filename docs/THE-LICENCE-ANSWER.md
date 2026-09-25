# Can the iPhone build carry the real ephemeris?

Researched 25 September 2026. Sources, with a URL and fetch date for every claim,
in `THE-LICENCE-ANSWER-SOURCES.md` beside this file.

**Short answer: not on the strength of the channel change alone, and it is not
worth betting on. There is a CHF 700 answer that deletes the substitute engine
today and needs no EU distribution at all.**

---

## First, the folklore is wrong

`THE-IOS-EPHEMERIS.md` says "Apple's terms impose DRM and per-device restrictions
that the GPL family explicitly forbids adding". That is the story everybody tells
and both halves of it are wrong.

**The GPL does not forbid DRM.** The GNU licence FAQ says so directly. GPLv3 does
not prohibit it.

**What the Free Software Foundation actually objected to in 2010 was contract
text**, not encryption. The App Store Usage Rules, which Apple imposes on the end
user and which the agreement applies "in addition to any other terms". Brett Smith
of the FSF wrote that the Usage Rules "do the same thing as Apple's Digital
Restrictions Management … but the method is different: they work legally instead of
technologically."

So the operative clause is **AGPLv3 section 10**, the no-further-restrictions rule,
not section 6 and not section 13. ⚠ Correct the note in `THE-IOS-EPHEMERIS.md` if
that file is ever revised, because the wrong reason leads to the wrong fix.

---

## The two findings that support the channel argument

**1. Apple expressly switches off the offending machinery outside the App Store.**
Attachment 14, section 2.3(C) of the Developer Agreement, effective 1 October 2026:

> Schedules 1, 2, and 3 to the Agreement do not apply.

Schedule 1's Exhibit B is the thing that *forces* an AGPL-incompatible end-user
licence, because it requires the licence granted to the user be "limited to a
**non-transferable** license". The Media Services Usage Rules and Apple's Standard
EULA are both scoped to "Apps made available through the App Store", so neither
attaches either.

**2. The licence check can be made perpetual.** The App License Delivery SDK's
`duration` attribute: "A value of 0 indicates that the license doesn't expire."

---

## The finding that defeats it

Alternative distribution has its own DRM, and Apple calls it that. From the App
License Delivery SDK documentation:

> This Swift SDK enables digital rights management (DRM) for alternative
> distribution apps

> iOS and iPadOS require each app that installs outside of the App Store to have a
> license issued by the developer.

She would have to run a Swift licence server with `.well-known/marketplace-kit`
endpoints. Apple also "encrypts and signs all iOS and iPadOS apps intended for
alternative distribution."

And the part that actually decides it: an app can only be installed from a domain
the developer registered, or through an authorised marketplace. **A recipient
cannot pass the binary on at all**, which is precisely the freedom section 10
protects. The Free Software Foundation Europe said as much in November 2025: users
cannot freely redistribute alternatively-distributed iOS apps, which are
"distributed under digital restriction management". The developer agreement also
forbids using her certificates to sign any third party's application.

**So the question turns on this.** If section 10 asks *which document restricts the
user*, she wins, because Apple's restricting documents fall away. If it asks *what
the user can actually do*, nothing changed, because they still cannot redistribute.

⚠ **There is no authority either way.** No FSF or gnu.org statement addresses the
EU channels. ⚠ And there is a genuine textual ambiguity about whether Exhibit B
falls away with Schedule 1, because the same sentence's preamble enumerates
"Exhibits" as applying. That is the sharpest open contractual point, and it is not
a thing to build on.

⚠ Note how the canonical case was actually resolved: **VLC returned to the App
Store by relicensing to LGPL, not by changing channel.** The historical answer
points at the licence, not the shop.

---

## The answer that makes all of it moot

Astrodienst sells a **Professional License** for the Swiss Ephemeris.

| | |
|---|---|
| Price | CHF 700 |
| Payment | one-off |
| Term | 99 years |
| Scope | unlimited |

Contract Edition June 2026. Clause 4 grants the right to "distribute the Swiss
Ephemeris in compiled form as part of his software". Clause 5 makes distributing
source **optional**. No copyleft, no channel restriction, nothing about app stores.

What that buys, beyond the money:

- The iPhone build carries the same engine as Android, so it and the website agree
  by construction rather than by a tolerance test.
- `tool/make_ios_variant.sh` is deleted, and with it the one-file-switch
  arrangement in `lib/sky/current.dart`.
- `lib/sky/vsop_data.dart` and `moon_data.dart` go, along with the twenty-five
  thousand generated coefficients and `tool/make_vsop_tables.py`.
- The ΔT divergence caveat after 2050 stops being a thing that has to be explained.
- Ordinary App Store shipping becomes possible, whenever the 4.3(b) question is
  settled.

⚠ **It does not fix the rejection.** The licence and the 4.3(b) refusal are
unrelated problems. Buying it changes nothing about the appeal.

---

## ⚠ The trap in the commercial licence

Contract clause 9 **forbids** naming Astrodienst, Treindl or Koch "in the context
of his software."

That is the exact opposite of the AGPL's notice-preservation duty, and it inverts
the standing rule that those names may appear in the copyright notice and nowhere
else. On the commercial arm they appear **nowhere at all**.

So buying the licence is not only a payment. It is a change to:

- `lib/screens/licences.dart`, the in-app licences screen.
- Any licence listing on the website that names the Swiss Ephemeris.
- `ASSETS-LICENCE` and the repo's own notices, for the iOS arm.

⚠ And during any transition **both arms exist at once**: Android stays on the AGPL
until the licence covers it too, and the AGPL arm *must* keep the notice the
commercial arm *must not* have. Decide which arm each build is on before touching
a notice, and do not let one file serve both.

---

## AGPL section 13 is already satisfied. No action.

This was worth checking and it came out clean. `shruti_astro` links pyswisseph, so
the whole daemon is AGPL, and section 13 owes its source to anyone who talks to it
over a network. That is handled properly rather than gestured at:

- `shruti_astro/api/app.py` carries the reasoning in its own header and serves
  `GET /version`, which reports the licence, the commit and the source URL **for
  the build actually running**.
- Every response carries an `X-Source-Licence` header.
- The site surfaces it, with a comment in `coming-soon.astro` making the point
  that a licence file in a repository does not satisfy section 13 because a
  visitor is owed the source of what answered them.

Section 13 says "prominently offer", and that offer exists and is version-correct.
Nothing to do.

---

## What to do

1. **Nothing, until the Board answers.** This is orthogonal to the appeal.
2. **Then decide on the CHF 700.** It is the cheapest thing in this entire
   situation and the only one that removes work permanently rather than adding it.
   It also makes both the App Store route and the marketplace route simpler, so it
   is not a bet on either.
3. ⚠ **Do not build the marketplace route on the licence argument.** If the app
   goes to a marketplace before the licence is bought, it should carry the
   substitute engine exactly as it does now. The channel argument is unsettled, it
   has no authority behind it, and being wrong about it means distributing somebody
   else's copyrighted work outside its licence.
