#!/usr/bin/env python3
"""
Write down what the WEBSITE says the Sun's comings and goings are.

⚠ **This exists because the first version of the public sky got them wrong and
nothing noticed.** The agreement fixture next to this one records POSITIONS,
and positions were right to a few arcseconds — so the suite was green while
every sunrise on the iPhone was six hours out and sunset came before it. A test
that checks one kind of answer says nothing whatever about another.

The failure was found by looking at a screenshot. That is not a test strategy,
and this file is the correction.

⚠ Read from `shruti-astro`, the SITE's own engine, so agreement is true by
construction rather than by assertion.

    docker ps | grep shruti-astro       # it must be running
    python3 tool/make_stations_fixture.py > test/fixtures/stations.json

⚠ The places are chosen to break things, not to be representative: the equator
where the day barely moves, two latitudes north and south where it moves a
great deal, and Reykjavík, which in June and December has no sunrise at all and
where the honest answer is nothing.
"""
from __future__ import annotations

import json
import os
import sys
import urllib.request

BASE = os.environ.get("SHRUTI_ASTRO", "http://127.0.0.1:8201")

PLACES = [
    ("London", 51.5074, -0.1278),
    ("Athens", 37.9838, 23.7278),
    ("Kerasia", 38.9333, 22.9667),
    ("Quito", -0.1807, -78.4678),
    ("Sydney", -33.8688, 151.2093),
    ("Reykjavik", 64.1466, -21.9426),
    ("Anchorage", 61.2181, -149.9003),
    # ⚠ Inside the Arctic circle, unlike Reykjavík, which keeps a brief night
    # all summer. Without a place north of 66°34' the "it does not happen
    # today" branch is never taken and its `null` is never checked.
    ("Tromso", 69.6492, 18.9553),
]

# Solstices, equinoxes and a few ordinary days, across three centuries.
DATES = [
    "1850-03-20", "1850-06-21",
    "1935-12-22", "1935-09-23",
    "1988-08-08",            # hers
    "2026-01-15", "2026-03-20", "2026-06-21", "2026-09-11", "2026-12-22",
    "2071-05-04", "2099-11-30",
]


def one(lat: float, lon: float, date: str) -> dict:
    # ⚠ `start`, not `date`. An unknown query parameter is ignored in silence,
    # and the first draft of this file asked for twelve dates and was handed
    # today twelve times — the echoed "start" in the answer is what gave it
    # away. Checked against the answer's own date below, so it cannot recur.
    url = f"{BASE}/stations?start={date}&lat={lat}&lon={lon}&days=1"
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.load(r)


def main() -> None:
    rows = []
    for name, lat, lon in PLACES:
        for date in DATES:
            try:
                answer = one(lat, lon, date)
            except Exception as exc:                        # noqa: BLE001
                print(f"  ! {name} {date}: {exc}", file=sys.stderr)
                continue
            table = answer.get("table") or []
            if not table:
                continue
            # ⚠ Proven, not assumed: the engine must have answered for the day
            # that was asked for.
            got = table[0].get("date")
            if got != date:
                print(f"  ! asked {date}, got {got} — refusing", file=sys.stderr)
                raise SystemExit(1)
            for s in table[0].get("stations", []):
                rows.append({
                    "place": name, "lat": lat, "lon": lon, "date": date,
                    "station": s["name"],
                    # ⚠ null when it does not happen. Above the Arctic circle
                    # that is the true answer and the app must say it too.
                    "at": s["at"] if s.get("occurred") else None,
                })
    json.dump({"source": "shruti-astro", "rows": rows}, sys.stdout, indent=1)
    print(file=sys.stdout)
    print(f"  {len(rows)} stations from {len(PLACES)} places", file=sys.stderr)


if __name__ == "__main__":
    main()
