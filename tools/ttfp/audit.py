#!/usr/bin/env python3
"""Audit the Ukrainian translation: Russianisms, calques and broken Typst.

Deliberately HIGH PRECISION. A checker that flags correct Ukrainian costs more
than it saves: it buries the real defects and sends a reviewer to "fix" good
text. Every rule here is either an unambiguous Russianism (a form that is
simply not Ukrainian) or a Typst syntax trap.

Constructions that are correct in modern Ukrainian -- при цьому, на основі,
по суті, починаючи з, в області, інакше кажучи, з другого боку, таким чином,
в першу чергу, в результаті, як правило, те що, для того щоб -- are NOT
flagged. They were ruled out deliberately: an earlier, looser version flagged
them and every hit was correct Ukrainian.

Usage:
    python3 tools/ttfp/audit.py                 # whole book, prose + syntax
    python3 tools/ttfp/audit.py ch01 ch02       # selected keys
    python3 tools/ttfp/audit.py --prose
    python3 tools/ttfp/audit.py --syntax
"""
import argparse
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")

# Cyrillic letters, for a negative lookbehind that distinguishes a bare Russian
# "являється" from the correct Ukrainian "з'являється" / "виявляється" (the
# apostrophe is a regex word boundary, so \b alone cannot tell them apart).
CYR = "а-яіїєґА-ЯІЇЄҐ"

# ---------------------------------------------------------------------------
# prose: unambiguous Russianisms and Russian calques
# ---------------------------------------------------------------------------
PROSE = [
    (rf"(?<![{CYR}\u2019'])(являється|являються|являвся|являлася)\b",
     "росіянізм", "«являється» → «є» / «становить»"),
    (rf"(?<![{CYR}\u2019'])являє\s+собою\b",
     "калька", "«являє собою» → «становить»"),
    (r"\bслідуюч\w+", "росіянізм", "«слідуючий» → «наступний»"),
    (r"\bполуча\w+|\bполучи\w+|\bполучен\w+",
     "росіянізм", "«получати» → «отримувати»"),
    (r"\bвитікає\b|\bвитікають\b|\bвитікало\b",
     "росіянізм", "«витікає» → «випливає»"),
    (r"\bна\s+протязі\b", "росіянізм", "«на протязі» → «протягом»"),
    (r"\bв\s+якості\b", "росіянізм", "«в якості» → «як»"),
    (r"\bприйма\w+\s+участь\b", "росіянізм", "«приймати участь» → «брати участь»"),
    (r"\bіз-за\b", "росіянізм", "«із-за» → «через»"),
    (r"\bв\s+залежності\s+від\b", "росіянізм", "→ «залежно від»"),
    (r"\bв\s+кінці\s+кінців\b", "росіянізм", "→ «зрештою»"),
    (r"\bтак\s+як\b", "росіянізм", "«так як» → «оскільки»"),
    (r"\bу\s+відповідності\s+(?:до|з)\b", "росіянізм", "→ «відповідно до»"),
    (r"\bв\s+силу\s+того\b", "росіянізм", "→ «через те»"),
    (r"\bпри\s+допомозі\b", "росіянізм", "«при допомозі» → «за допомогою»"),
    (r"\bпри\s+наявності\b", "росіянізм", "→ «за наявності»"),
    (r"\bне\s+дивлячись\s+на\s+те\s+що\b", "росіянізм", "→ «попри те що»"),
    (r"\bв\s+течії\b", "росіянізм", "«в течії» → «протягом»"),
    (r"\bприводе\w*", "росіянізм", "→ «призводить»"),
    (r"\bпредставляє\w*", "росіянізм", "«представляє» → «становить» / «є»"),
    # NB: "існуючий" is a valid Ukrainian participle (існувати → існуючий,
    # "існуючий порядок"): do NOT flag it. "наступуючий"/"слідуючий" are the
    # Russianisms, because Ukrainian has "наступний".
    (r"\bнаступуюч\w+|\bслідуюч\w*",
     "росіянізм", "рос. «следующий» → «наступний»"),
    # Russian-style superlative "самий важливий"; "той самий" is fine, so only
    # flag it when an adjective follows.
    (r"\bсамий\s+(важлив\w+|цікав\w+|прост\w+|складн\w+|загальн\w+|типов\w+|поширен\w+)",
     "калька", "«самий важливий» → «найважливіший»"),
    (r"\bсама\s+(важлив\w+|цікав\w+|прост\w+)",
     "калька", "«сама важлива» → «найважливіша»"),
    # --- mechanical generation faults ---------------------------------------
    # A word repeated across a heading boundary is a section title ending in
    # the same word ("== Частина II доведення" then "Доведення леми ..."),
    # which is correct style -- so require the repeat to sit on ONE line.
    (r"\b(підстановк\w+|означенн\w+|доведенн\w+)[ \t]+\1\b",
     "дубль", "повтор того самого слова (збій генерації)"),
]

# ---------------------------------------------------------------------------
# syntax: Typst structure
# ---------------------------------------------------------------------------
SYNTAX = [
    # A hash macro glued to a Cyrillic word with a hyphen parses as subtraction.
    (r"#[a-zA-Z][a-zA-Z0-9.]*-[^\s\d,.);:\]}#]*[^\x00-\x7f][^\s]*",
     "дефіс після #макроса (Typst читає як мінус)"),
    (r"\bTODO\b|#todo-section", "залишковий маркер TODO"),
]


def prose_hits(text):
    out = []
    for pat, name, why in PROSE:
        for m in re.finditer(pat, text, re.IGNORECASE):
            line = text.count("\n", 0, m.start()) + 1
            out.append((line, name, m.group(0), why))
    return out


def syntax_hits(text):
    body = re.sub(r"(?m)^#import.*$", "", text)
    out = []
    for pat, why in SYNTAX:
        for m in re.finditer(pat, body):
            line = body.count("\n", 0, m.start()) + 1
            out.append((line, why, m.group(0)[:70]))
    if len(re.findall(r"(?<!\\)\$", body)) % 2:
        out.append((0, "непарна кількість $ (незакрита формула)", ""))
    return out


def parts():
    man = json.load(open(os.path.join(TT, "manifest.json")))
    for key in sorted(man):
        for p in sorted(man[key]["parts"], key=lambda x: x["part"]):
            yield key, p["part"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("keys", nargs="*")
    ap.add_argument("--prose", action="store_true")
    ap.add_argument("--syntax", action="store_true")
    a = ap.parse_args()
    do_prose = a.prose or not a.syntax
    do_syntax = a.syntax or not a.prose

    tp = ts = 0
    for key, part in parts():
        if a.keys and key not in a.keys:
            continue
        f = os.path.join(TT, "out", key, f"part{part}.typ")
        if not os.path.exists(f):
            continue
        text = open(f, encoding="utf-8").read()
        ph = prose_hits(text) if do_prose else []
        sh = syntax_hits(text) if do_syntax else []
        if not ph and not sh:
            continue
        print(f"\n=== {key}/part{part} ===")
        for line, name, frag, why in ph:
            print(f"  prose  L{line:<5} {name:<12} {frag[:40]!r}")
            print(f"         → {why}")
        for line, why, frag in sh:
            print(f"  syntax L{line:<5} {why}  {frag!r}")
        tp += len(ph)
        ts += len(sh)
    print(f"\ntotal: {tp} prose hit(s), {ts} syntax hit(s)")


if __name__ == "__main__":
    main()
