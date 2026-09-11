# Why the iOS build computes the sky differently

⚠ **Temporary.** When the Swiss Ephemeris commercial licence is bought, iOS goes
back to the same engine as Android and most of this is deleted. It is written to
make that deletion easy.

## The problem

AGPL software cannot be distributed through Apple's App Store. Apple's terms
impose DRM and per-device restrictions that the GPL family explicitly forbids
adding, and the conflict is old and well known — VLC was pulled over it in 2011.

Astrolabe's own code is hers, so she could grant an exception for it. ⚠ **The
Swiss Ephemeris is not hers.** It is licensed to her under the AGPL by its own
authors, and no permission of hers can cover somebody else's copyright.

Android is unaffected: Google Play has no equivalent conflict, and the app there
carries the library as it always has.

## What replaces it

| | |
|---|---|
| Planets | **VSOP87** — Bretagnon and Francou's analytic theory |
| Moon | **ELP-2000/82**, in its abridged form |
| True node | the node of the Moon's instantaneous orbit, from `r × v` |
| Ascendant, midheaven, rise, set | standard spherical astronomy |

Both theories are published science under no software licence. ⚠ The
coefficients are **generated** by `tool/make_vsop_tables.py`, never typed —
twenty-five thousand numbers, where one wrong digit looks like a geometry bug
rather than a typo.

## How good it is

Measured against `shruti-astro` — the website's own engine — over 108 moments
from 1800 to 2100:

```
Sun 5"    Mercury 7"    Venus 6"    Mars 3"    Jupiter 1"    Saturn 1"
true node 43"    ascendant 2-7" at four latitudes    Moon 3" to 2050
```

The app is held to **one arcminute**, which is the finest unit any reading is
written in, and to **exact sign agreement**, which is the thing that is not a
rounding difference but a different reading.

⚠ **After about 2050 the Moon drifts to about an arcminute, and that is not the
theory's fault.** The two engines disagree about ΔT — the gap between atomic
time and the Earth's actual rotation — which is *measured*, not derived. Nobody
knows what the Earth will do, every model's future is an extrapolation, and
these two extrapolate differently. The tolerance widens there and says so.
Fitting to the other engine's guess would mean re-fitting every time they
revise it.

## How the variant is made

`tool/make_ios_variant.sh` rewrites the checkout in place:

1. points `lib/sky/current.dart` at the public-domain engine
2. deletes `lib/sky/swiss.dart`
3. removes `sweph` and its assets from `pubspec.yaml`
4. removes the device test that can only run against the library

⚠ **A runtime switch would not be enough.** A package listed in `pubspec.yaml`
has its native side compiled into the binary whether or not a line of Dart calls
it. The dependency has to be *absent*, and CI fails the build if it survives.

Verified by opening the APK: zero files matching `sweph`, no `libsweph.so`, no
`.se1` data.

## Putting it back

When the licence is bought:

1. delete `lib/sky/public.dart`, `vsop*.dart`, `moon*.dart`, `angles.dart`,
   `time.dart`
2. delete `tool/make_ios_variant.sh`, `tool/make_vsop_tables.py` and this file
3. delete `test/the_public_sky_agrees_test.dart` and
   `test/the_ios_variant_is_clean_test.dart`
4. remove the "Make the iOS variant" step from the workflow

`lib/sky/sky.dart`, `swiss.dart` and `current.dart` stay — one engine behind one
interface is a better arrangement than what was there before, and it is what
made this possible in an afternoon.

⚠ Nothing above `lib/sky/sky.dart` knows which engine answered. That is the
property that keeps the deletion small, and `test/the_ios_variant_is_clean_test.dart`
is what holds it.
