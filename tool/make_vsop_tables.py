#!/usr/bin/env python3
"""
Turn the published VSOP87 coefficients into Dart.

⚠ **Generated, never typed.** These are twenty-five thousand numbers; hand
transcription of even a fraction of them would introduce errors that look like
an ephemeris bug and are nothing of the kind. This reads the published tables
and writes the Dart, so the only thing a person can get wrong is the threshold.

⚠ **The coefficients are public domain.** VSOP87 is Bretagnon and Francou's
analytic theory, published by the Bureau des Longitudes in Astronomy &
Astrophysics. They are read here out of PyMeeus, which is a convenient copy —
the numbers are the published theory's, not PyMeeus's, and nothing of PyMeeus's
own is taken.

    pip download pymeeus --no-deps -d /tmp/pm && tar xzf /tmp/pm/PyMeeus-*.tar.gz -C /tmp/pm
    python3 tool/make_vsop_tables.py /tmp/pm/PyMeeus-0.5.12/pymeeus

⚠ THRESHOLD is the only judgement in the file. A term's amplitude is in units
of 1e-8 radian, which is 0.00206 arcseconds, so a threshold of 5 drops nothing
larger than a hundredth of an arcsecond. The agreement test against the website
is what says whether that was enough — not this number.
"""
import ast
import re
import sys
from pathlib import Path

THRESHOLD = 5

BODIES = ["Earth", "Mercury", "Venus", "Mars", "Jupiter", "Saturn"]


def table(src: str, which: str):
    m = re.search(r"^VSOP87_" + which + r" = \[(.*?)^\]", src, re.S | re.M)
    if not m:
        return []
    groups = ast.literal_eval("[" + m.group(1) + "]")
    return [[t for t in g if abs(t[0]) >= THRESHOLD] for g in groups]


def dart(name: str, groups) -> str:
    out = [f"const Series {name} = ["]
    for g in groups:
        out.append("  [")
        for a, b, c in g:
            out.append(f"    [{a!r}, {b!r}, {c!r}],")
        out.append("  ],")
    out.append("];")
    return "\n".join(out)


def main():
    where = Path(sys.argv[1])
    kept = 0

    print("// SPDX-License-Identifier: AGPL-3.0-only")
    print("//")
    print("// VSOP87 coefficients — GENERATED, do not edit by hand.")
    print("//")
    print("// ⚠ Written by tool/make_vsop_tables.py from the published tables.")
    print("// Twenty-five thousand numbers were never going to be transcribed")
    print("// correctly by a person, and an error in one of them looks exactly")
    print("// like an ephemeris bug.")
    print("//")
    print("// ⚠ Public domain: Bretagnon and Francou's analytic theory, published")
    print("// by the Bureau des Longitudes. Not anybody's software licence, which")
    print("// is the reason the iOS build can carry it.")
    print("//")
    print(f"// Truncated at amplitude {THRESHOLD} (units of 1e-8 radian, so nothing")
    print(f"// larger than {THRESHOLD * 0.00206:.4f} arcseconds was dropped). Whether that")
    print("// was enough is answered by the agreement test, not by this comment.")
    print("library;")
    print()
    print("import 'vsop.dart';")
    print()

    for body in BODIES:
        src = (where / f"{body}.py").read_text()
        for which in ("L", "B", "R"):
            groups = table(src, which)
            kept += sum(len(g) for g in groups)
            print(dart(f"{body.lower()}{which}", groups))
            print()

    print(f"// {kept} terms kept.", file=sys.stderr)


if __name__ == "__main__":
    main()
