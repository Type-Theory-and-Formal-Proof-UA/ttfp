#!/usr/bin/env python3
"""Compare the structure of each translated part against its English source.

Two things must survive translation: the *sections* (none dropped, none added,
same order) and, inside each section, the *declarations* -- the numbered
Definitions/Theorems/Lemmas/Corollaries/Propositions/Examples/Remarks/Notation.
A part can compile perfectly while having quietly lost a Lemma, so this is
checked mechanically rather than by eye.

The authoritative section list comes from ``manifest.json``: each part records
its sections in order, with the English title, the Ukrainian title and the
book's own number (``num`` is null for the unnumbered "Exercises").

How declarations are counted
----------------------------
Source side.  A declaration looks like ``Lemma 14.8.2`` and, in the book, the
first occurrence of that number IS the declaration; later occurrences are
cross-references ("by Lemma 14.8.2").  So the source is scanned for
kind+number, deduplicated by number, and then filtered down to the numbers that
belong to this part's own sections.  That filter matters twice over: a part
that discusses ``14.6`` is referring to the previous part's material, and the
Exercises are numbered ``N.M`` exactly like sections, so counting declarations
inside them would fabricate hits.

Translation side.  A declaration is a ``#definition[...]`` / ``#lemma[...]`` /
``#notation-item[...]`` macro appearing in the section's own body.

The two counts are compared per section.  The book resets numbering per
section, so per-section comparison catches a part that merged or split
sections even when the total is right.

Usage:
    python3 tools/ttfp/structure.py               # every part
    python3 tools/ttfp/structure.py ch01 ch14     # selected chapters
    python3 tools/ttfp/structure.py --verbose     # show the OK rows too
"""
import argparse
import json
import os
import re
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")

KINDS = {
    "Definition": "definition", "Deﬁnition": "definition",
    "Theorem": "theorem", "Lemma": "lemma", "Corollary": "corollary",
    "Proposition": "proposition", "Example": "example", "Examples": "example",
    "Remark": "remark", "Remarks": "remark", "Notation": "notation",
    "Convention": "convention", "Axiom": "axiom",
}
KIND_ALT = "|".join(sorted(KINDS, key=len, reverse=True))
SRC_DECL = re.compile(rf"({KIND_ALT})\s+(\d+\.\d+\.\d+)\b")
TYP_DECL = re.compile(
    r"#(definition|theorem|lemma|corollary|proposition|example|remark|"
    r"notation|convention|axiom)(?:-item)?\s*[\(\[]")
TYP_SEC = re.compile(r"(?m)^={2,3}\s+(.+?)\s*$")


def norm(s):
    """Normalise a heading for comparison (strip Typst escapes and spacing)."""
    s = s.replace("\u00ad", "")
    s = re.sub(r"[`$#]", "", s)
    return re.sub(r"\s+", " ", s).strip().lower()


def find_section(text, title):
    """(offset, exact) of the heading matching *title*, else (None, False).

    An inexact match (one normalized title containing the other) is still
    returned, but flagged so that a *renamed* heading -- which would otherwise
    satisfy the containment test -- is reported instead of silently accepted.
    """
    want = norm(title or "")
    if not want:
        return None, False
    for m in TYP_SEC.finditer(text):
        if norm(m.group(1)) == want:
            return m.start(), True
    for m in TYP_SEC.finditer(text):
        got = norm(m.group(1))
        if got and (want in got or got in want):
            return m.start(), False
    return None, False


def sec_bodies(text, secs):
    """[(section, body, exact)] bodies cut at whichever headings were found."""
    found = [find_section(text, s.get("uk")) for s in secs]
    offs = [f[0] for f in found]
    order = sorted(range(len(secs)), key=lambda i: (offs[i] is None, offs[i] or 0))
    out = []
    for j, i in enumerate(order):
        if offs[i] is None:
            out.append((secs[i], None, found[i][1]))
            continue
        nxt = None
        for i2 in order[j + 1:]:
            if offs[i2] is not None:
                nxt = offs[i2]
                break
        out.append((secs[i],
                    text[offs[i]: nxt if nxt is not None else len(text)],
                    found[i][1]))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("keys", nargs="*")
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args()

    man = json.load(open(os.path.join(TT, "manifest.json")))
    nparts = ndiff = 0
    for key in sorted(man):
        if a.keys and key not in a.keys:
            continue
        for p in sorted(man[key]["parts"], key=lambda x: x["part"]):
            part = p["part"]
            sf = os.path.join(TT, "out", key, f"src-part{part}.txt")
            tf = os.path.join(TT, "out", key, f"part{part}.typ")
            if not (os.path.exists(sf) and os.path.exists(tf)):
                continue
            secs = [s for s in (p.get("sections") or []) if s.get("num")]
            if not secs:
                continue          # appendices: no numbered sections to compare
            nparts += 1
            stext = open(sf, encoding="utf-8").read()
            ttext = open(tf, encoding="utf-8").read()
            issues = []
            seen = Counter()
            for s, body, exact in sec_bodies(ttext, secs):
                if body is None:
                    issues.append(f"§{s['num']} «{s.get('uk')}»: heading not found")
                    continue
                if not exact:
                    issues.append(f"§{s['num']}: heading matched only loosely -- "
                                  f"check «{s.get('uk')}»")
                tk = Counter(m.group(1) for m in TYP_DECL.finditer(body))
                seen += tk
                sk = src_decls_sec(stext, s["num"])
                if sk != tk:
                    d, x = sk - tk, tk - sk
                    msg = f"§{s['num']} «{s.get('uk')}»"
                    if d:
                        msg += f"  missing {dict(d)}"
                    if x:
                        msg += f"  extra {dict(x)}"
                    issues.append(msg)
            if issues or a.verbose:
                print(f"{'DIFF' if issues else 'OK  '} {key}/part{part}  "
                      f"({len(secs)} sections)")
                for i in issues:
                    print(f"       - {i}")
                ndiff += bool(issues)
    print(f"\n{nparts} parts compared, {ndiff} with differences")


def src_decls_sec(text, prefix):
    """Declaration kinds whose number starts with *prefix*."""
    first = {}
    for m in SRC_DECL.finditer(text):
        first.setdefault(m.group(2), KINDS[m.group(1)])
    return Counter(k for num, k in first.items() if num.startswith(prefix + "."))


if __name__ == "__main__":
    main()
