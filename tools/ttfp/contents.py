#!/usr/bin/env python3
"""Build tools/ttfp/sections.json from the table of contents of the original.

The contents pages list every section as `<chapter>.<n> <English title> <page>`
in order, which is far more reliable than guessing from the chapter text (the
running heads and the page-top layout make heuristics fragile).

The scaffold files carry the Ukrainian headings for the same sections, in the
same order, so the two lists line up 1:1 and give every translation job an
explicit original -> translation heading mapping.

Usage: python3 tools/ttfp/contents.py
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")

# the contents pages of the original PDF, raw 0-based indices
CONTENTS_PAGES = range(6, 13)


def parse_contents(pages):
    """{chapter number or 'A'..: [(num, title)]} in printed order."""
    out = {}
    cur = None
    for p in pages:
        for raw in p.splitlines():
            ln = raw.rstrip()
            if not ln.strip():
                continue
            if re.match(r"^\s*Contents\s*$", ln) or re.match(r"^\s*[ivx]+\s+Contents", ln):
                continue
            # chapter/appendix start: "12  Mathematics in λD: a first attempt  257"
            m = re.match(r"^\s*(\d{1,2})\s+([A-Z].*?)\s{2,}(\d{1,3})\s*$", ln)
            if m and int(m.group(1)) <= 20:
                cur = m.group(1)
                out.setdefault(cur, [])
                continue
            m = re.match(r"^\s*Appendix\s+([A-D])\s+(.*?)\s{2,}(\d{1,3})\s*$", ln)
            if m:
                cur = m.group(1)
                out.setdefault(cur, [])
                continue
            m = re.match(r"^\s*(\d{1,2}\.\d{1,2})\s+(\S.*?)\s{2,}(\d{1,3})\s*$", ln)
            if m and cur and "." in m.group(1) and m.group(1).split(".")[0] == cur:
                out[cur].append({"num": m.group(1), "en": m.group(2).strip()})
                continue
            m = re.match(r"^\s*([A-D]\.\d)\s+(\S.*?)\s{2,}(\d{1,3})\s*$", ln)
            if m and cur == m.group(1)[0]:
                out[cur].append({"num": m.group(1), "en": m.group(2).strip()})
                continue
            m = re.match(r"^\s*Exercises\s{2,}(\d{1,3})\s*$", ln)
            if m and cur:
                out[cur].append({"num": None, "en": "Exercises"})
    return out


def main():
    pages = open(os.path.join(TT, "raw", "book.txt"), encoding="utf-8",
                 errors="replace").read().split("\f")
    toc = parse_contents([pages[i] for i in CONTENTS_PAGES])
    chapters = json.load(open(os.path.join(TT, "chapters.json")))
    out, bad = {}, []
    for key, meta in chapters.items():
        ch = meta.get("prefix") or str(meta["chapter"])
        sections = toc.get(ch, [])
        # the scaffold headings, in order, that these sections map to
        heads = [l[3:].rstrip("\n") for l in open(os.path.join(ROOT, meta["file"]),
                                                  encoding="utf-8")
                 if l.startswith("== ")]
        # appB/appD have no subsections at all
        if not sections and heads:
            bad.append(f"{key}: contents has no sections but scaffold has {len(heads)}")
        if sections and len(sections) != len(heads):
            if len(sections) == len(heads) - 1:
                sections.append({"num": None, "en": "Exercises"})
            else:
                bad.append(f"{key}: {len(sections)} sections vs {len(heads)} headings")
        for s, h in zip(sections, heads):
            s["uk"] = h
        out[key] = sections
    json.dump(out, open(os.path.join(TT, "sections.json"), "w"), indent=1,
              ensure_ascii=False)
    for key, secs in out.items():
        print(f"{key:6s} {len(secs):2d} sections")
        for s in secs[:2] + (secs[-1:] if len(secs) > 2 else []):
            print(f"      {s['num'] or '-':6s} {s['en'][:44]:46s} -> {s['uk'][:36]}")
    if bad:
        print("\nPROBLEMS:")
        for b in bad:
            print("  " + b)
        sys.exit(1)


if __name__ == "__main__":
    main()
