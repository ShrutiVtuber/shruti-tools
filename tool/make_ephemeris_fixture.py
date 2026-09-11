#!/usr/bin/env python3
"""
Write down what the WEBSITE says the sky is, so a replacement can be held to it.

⚠ **This is the measuring stick, and it is built before the thing it measures.**
The iOS build has to drop the Swiss Ephemeris — Apple's terms and the AGPL
cannot both be satisfied in one binary — and whatever replaces it has to agree
with the website, which keeps using it. "Agrees with the web" is the
requirement that actually matters and the easiest one to get subtly wrong, so
it is recorded first, as numbers, from the engine that is currently right.

⚠ Read from `shruti-astro` — the SITE's own engine — and not from the app's
copy of the same library. That makes agreement true by construction rather than
by assertion: the fixture is literally what shrutivtuber.com would answer.

⚠ Running this is not distribution. The Swiss Ephemeris stays in the Android
build and on the server, both AGPL and published; this only asks a local
service what it says.

    docker ps | grep shruti-astro      # it must be running
    python3 tool/make_ephemeris_fixture.py > test/fixtures/ephemeris.json

The same arrangement as the sigil fixture: both engines are compared against
ONE file, so neither can be quietly satisfied by editing it.
"""
import json
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timezone

ASTRO = "http://127.0.0.1:8201"

#: Places to take the ascendant from.
#:
#: ⚠ Chosen for the awkward cases, not for variety. Reykjavík is far enough
#: north that rising times misbehave; Quito sits on the equator where the
#: ascendant moves most evenly; Sydney is southern, where a hemisphere mistake
#: shows up as a six-sign error rather than a small one.
PLACES = {
    "athens": (37.9838, 23.7275),
    "reykjavik": (64.1466, -21.9426),
    "quito": (-0.1807, -78.4678),
    "sydney": (-33.8688, 151.2093),
}


def moments():
    """
    Moments to sample.

    ⚠ Spread deliberately rather than randomly. The date picker accepts 1800 to
    2100, so the fixture covers that whole range — an engine that is right for
    this decade and wrong for 1830 fails the one person casting their
    great-grandmother's chart, and fails silently.
    """
    out = []
    for year in range(1800, 2101, 6):
        out.append(datetime(year, 3, 14, 7, 23, 11, tzinfo=timezone.utc))
        out.append(datetime(year, 9, 29, 19, 41, 3, tzinfo=timezone.utc))

    # Moments where an engine that is nearly right shows it.
    out += [
        datetime(1999, 8, 11, 11, 3, tzinfo=timezone.utc),   # total eclipse
        datetime(2024, 4, 8, 18, 17, tzinfo=timezone.utc),   # total eclipse
        datetime(2026, 1, 3, 17, 16, tzinfo=timezone.utc),   # perihelion
        datetime(2026, 7, 6, 5, 0, tzinfo=timezone.utc),     # aphelion
        datetime(2000, 1, 1, 12, 0, tzinfo=timezone.utc),    # J2000
        datetime(1900, 1, 1, 0, 0, tzinfo=timezone.utc),     # a round date
    ]
    return sorted(out)


def chart(when, lat, lon):
    q = urllib.parse.urlencode({
        "when": when.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "lat": lat, "lon": lon,
        "tradition": "hellenistic",
        "house_system": "whole_sign",
        "diagram": "false",
    })
    with urllib.request.urlopen(f"{ASTRO}/chart?{q}", timeout=20) as r:
        return json.load(r)


def main():
    samples = []
    for at in moments():
        # The bodies do not depend on the place; one call gives them.
        here = chart(at, *PLACES["athens"])

        positions = {}
        for b in here["bodies"]:
            positions[b["name"]] = {
                "longitude": round(b["longitude"], 6),
                "speed": round(b["speed"], 6),
                "retrograde": b["retrograde"],
            }

        ascendants = {}
        for name, (lat, lon) in PLACES.items():
            c = here if name == "athens" else chart(at, lat, lon)
            ascendants[name] = round(c["angles"]["ascendant"], 6)

        samples.append({
            "utc": at.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "positions": positions,
            "ascendant": ascendants,
        })

    json.dump({
        "note": ("Generated from shruti-astro — the WEBSITE's own ephemeris — by "
                 "tool/make_ephemeris_fixture.py. Do not hand-edit: both engines "
                 "are compared against this one file, so editing it to make one "
                 "pass makes the other fail."),
        "zodiac": "tropical",
        "houseSystem": "whole_sign",
        "generated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "places": {k: list(v) for k, v in PLACES.items()},
        "samples": samples,
    }, sys.stdout, indent=1)


if __name__ == "__main__":
    main()
