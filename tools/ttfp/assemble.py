#!/usr/bin/env python3
"""Assemble translated part files into the chapter/appendix scaffolds.

A part file contains only level-2 sections (`== ...`) plus statements. This
script verifies that the parts together cover every heading of the scaffold
(in the scaffold's order) and then writes the merged chapter file: the
scaffold's comment header + level-1 heading, followed by the parts' sections.

Usage:
  python3 tools/ttfp/assemble.py --check        # only report coverage
  python3 tools/ttfp/assemble.py ch01 ch06      # merge these chapters
  python3 tools/ttfp/assemble.py --all
"""
import argparse
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")


def scaffold_head(path):
    """Comment header + level-1 heading of the scaffold file."""
    try:
        lines = open(path, encoding="utf-8").read().splitlines()
    except FileNotFoundError:
        lines = []
    head = []
    for ln in lines:
        head.append(ln)
        if ln.startswith("= "):
            break
    return "\n".join(head)


def read_part(path):
    """Body of a part file: its sections plus any local helper definitions.

    Helper `#let` definitions that the part needs (e.g. a flag-drawing
    function) sit before its first `== ` heading; they must be carried into
    the merged chapter or its statements stop compiling.
    """
    txt = open(path, encoding="utf-8").read()
    m = re.search(r"^#import\s.*$", txt, re.M)
    start = m.end() if m else 0
    body = txt[start:]
    m2 = re.search(r"^== ", body, re.M)
    if m2:
        # keep the helper definitions that precede the first section (a part
        # may define, say, a flag-drawing `#let`); drop only comments/blanks
        pre = [ln for ln in body[:m2.start()].splitlines()
               if ln.strip() and not ln.lstrip().startswith("//")]
        head = "\n".join(pre).strip()
        body = body[m2.start():]
        if head:
            body = head + "\n\n" + body
    else:
        # a part without level-2 headings (appendix B/D): keep everything
        # after the part's own level-1 heading, if it has one
        m3 = re.search(r"^= .*$", body, re.M)
        if m3:
            body = body[m3.end():]
    body = re.sub(r"^#todo-section\s*$", "", body, flags=re.M)
    return body.strip() + "\n"


def heads_of(txt):
    return [l[3:].strip() for l in txt.splitlines() if l.startswith("== ")]


def parts_of(key, man):
    return sorted(man[key]["parts"], key=lambda p: p["part"])


def report(key, man):
    m = man[key]
    scaffold = os.path.join(ROOT, m["file"])
    want = heads_of(open(scaffold, encoding="utf-8").read())
    have, missing_files = [], []
    for p in parts_of(key, man):
        f = os.path.join(TT, "out", key, f"part{p['part']}.typ")
        if not os.path.exists(f):
            missing_files.append(f"part{p['part']}")
            continue
        have += heads_of(open(f, encoding="utf-8").read())
    miss = [h for h in want if h not in have]
    extra = [h for h in have if h not in want]
    ordered = have == [h for h in want if h in have]
    status = "READY" if (not miss and not extra and ordered and not missing_files) else "INCOMPLETE"
    print(f"{key:6s} {status:11s} headings want={len(want)} have={len(have)}"
          + (f" missing={miss}" if miss else "")
          + (f" extra={extra}" if extra else "")
          + (f" missing_parts={missing_files}" if missing_files else "")
          + ("" if ordered else "  ORDER MISMATCH"))
    return status == "READY"


def merge(key, man):
    m = man[key]
    scaffold = os.path.join(ROOT, m["file"])
    bodies = []
    for p in parts_of(key, man):
        f = os.path.join(TT, "out", key, f"part{p['part']}.typ")
        if not os.path.exists(f):
            print(f"  skip {key}: part{p['part']} not translated yet")
            return False
        bodies.append(read_part(f))
    out = scaffold_head(scaffold) + "\n\n" + "\n".join(bodies)
    out = re.sub(r"\n{3,}", "\n\n", out).rstrip() + "\n"
    open(scaffold, "w", encoding="utf-8").write(out)
    print(f"  merged {key} -> {m['file']} ({len(bodies)} part(s))")
    return True


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("keys", nargs="*")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--all", action="store_true")
    a = ap.parse_args()
    man = json.load(open(os.path.join(TT, "manifest.json")))
    keys = a.keys or list(man)
    if a.check:
        bad = [k for k in keys if not report(k, man)]
        sys.exit(0 if not bad else 1)
    for k in keys:
        if report(k, man):
            merge(k, man)
