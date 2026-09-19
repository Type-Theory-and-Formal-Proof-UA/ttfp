#!/usr/bin/env python3
"""Verify a translated part against the original English text of that part.

For each part it reports
  * per section: how many words the original text has vs. the translation
    (a translation that silently drops or paraphrases whole passages shows up
    as a low ratio), plus the heading used;
  * how many statements of each kind the original section text contains
    (Definition/Lemma/... labels) vs. how many statement macros the
    translation uses — these should match;
  * the exercises found in the source vs. #exercise macros;
  * leftover `#todo-section`/TODO markers and untranslated English leftovers;
  * whether the file compiles with typst.

Usage: python3 tools/ttfp/verify.py [ch06 ch07 ...]
"""
import collections
import json
import os
import re
import subprocess
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")

KINDS = {
    "definition": "Definitions?",
    "theorem": "Theorems?",
    "lemma": "Lemmas?",
    "corollary": "Corollar(?:y|ies)",
    "proposition": "Propositions?",
    "example": "Examples?",
    "remark": "Remarks?",
    "notation-item": "Notation",
    "convention": "Conventions?",
}

# the original PDF is typeset with f-ligatures and curly quotes
LIGATURES = {"\ufb01": "fi", "\ufb02": "fl", "\ufb00": "ff", "\ufb03": "ffi",
             "\ufb04": "ffl", "\u2019": "'", "\u2018": "'", "\u201c": '"',
             "\u201d": '"', "\u2212": "-"}

CYRILLIC = re.compile("[\u0400-\u04ff]")
# English function words that must not survive a full translation
EN_WORDS = re.compile(
    r"\b(the|and|of|with|which|this|that|from|then|such|have|been|are|is|"
    r"for|not|when|where|proof|lemma|definition|exercise)\b", re.I)
TEXTCONF = re.compile(r"#text(?:\.|[(])|#raw|#emph|#strong")


def norm(t):
    for k, v in LIGATURES.items():
        t = t.replace(k, v)
    return t


def fold(s):
    s = unicodedata.normalize("NFKD", norm(s))
    s = re.sub(r"[\s]+", " ", s)
    return s.lower().strip()


def orig_counts(src_text, chapter):
    """Statement labels per kind + exercise count in the original part text.

    In the layout dump a statement always starts its own line, while
    cross-references occur mid-sentence — anchoring on line starts keeps the
    counts free of references to statements in other sections.
    """
    t = norm(src_text)
    counts = {}
    for macro, word in KINDS.items():
        pat = re.compile(
            rf"(?m)^\s{{0,40}}(?:{word})\s+{chapter}\.(\d{{1,2}})\.(\d{{1,3}})"
            rf"(?=\s|$)(.*)$"
        )
        found = set()
        for m in pat.finditer(t):
            # A label at line start may be a wrapped cross-reference rather
            # than a header: the dump breaks lines mid-sentence, so
            # ``Lemma 14.11.4, hence ...`` and ``Lemma 14.3.2 (b) implies ...``
            # look like headers.  A header opens a title in parentheses
            # (``(Closure ...)``) or a formula (``∀x, y ...``); a reference
            # resumes with lowercase prose or punctuation.
            rest = re.sub(r"^\s*\((?:[a-z]|\d+)\)", "", m.group(3)).strip()
            if rest and re.match(r"[a-z,;)\]]", rest):
                continue
            found.add((m.group(1), m.group(2)))
        counts[macro] = len(found)
    ex = 0
    m = re.search(r"^\s*Exercises\s*$", t, re.M)
    if m:
        ex = len(re.findall(rf"^\s*{chapter}\.(\d{{1,2}})\s+\S", t[m.end():], re.M))
    return counts, ex


def macro_counts(path):
    txt = open(path, encoding="utf-8").read()
    c = collections.Counter()
    for m in re.finditer(r"#([a-z][a-z-]*)\s*[\[(]", txt):
        c[m.group(1)] += 1
    return c, txt


def section_spans(src_text, secs, chapter):
    """Span of the original text for each section of this part."""
    spans = []
    for i, s in enumerate(secs):
        num = s["num"]
        if num is None:
            m = re.search(r"^\s*Exercises\s*$", src_text, re.M)
        else:
            m = re.search(rf"^\s*{re.escape(num)}\s+\S", src_text, re.M)
        spans.append(m.start() if m else None)
    out = []
    for i, s in enumerate(secs):
        a = spans[i]
        b = next((x for x in spans[i + 1:] if x is not None), len(src_text))
        out.append((s, a, b))
    return out


def english_leftovers(txt):
    """Lines that still look like original English prose."""
    bad = []
    for ln in txt.splitlines():
        s = ln.strip()
        if not s or s.startswith("//") or s.startswith("=="):
            continue
        # Typst function calls, imports and options are code, not prose
        if re.match(r"^#[a-zA-Z]", s) or s.startswith("stroke:") or s.startswith("fill:"):
            continue
        if s.endswith("=>") or re.match(r"^\w+:\s*\(", s):
            continue
        # strip inline math and code-ish content
        s2 = re.sub(r"\$[^$]*\$", " ", s)
        s2 = re.sub(r"#[a-zA-Z][a-zA-Z0-9._-]*(\[[^\]]*\])?", " ", s2)
        s2 = re.sub(r"https?://\S+", " ", s2)
        s2 = re.sub(r"\(([A-Z][a-z]+(?: & [A-Z][a-z]+)?),? \d{4}[a-z]?\)", " ", s2)
        if CYRILLIC.search(s2):
            continue
        if len(EN_WORDS.findall(s2)) >= 4 and len(s2.split()) >= 6:
            bad.append(s)
    return bad


def negation_check(src_text, txt):
    """Negated relations in the source vs. the translation -- a warning only.

    `pdftotext` silently drops the combining solidus the book uses for
    "not equal" / "not in" / "not equivalent" (see tools/ttfp/negations.py), so
    anyone translating from a stale dump writes the *positive* relation exactly
    where the book has the negated one -- turning a true statement into a false
    one.  This reports the counts so a drop is visible while reviewing.

    It is deliberately a warning, not a failure: Ukrainian renders some
    negations as prose (e.g. several "=alpha doesn't hold" lines collapse into
    one sentence), so a lower count is not by itself an error.  What matters is
    never *asserting* the positive relation where the source has a negation.
    """
    src = re.findall(r"[\u2260\u2209\u2262]", src_text)
    tr = re.findall(
        r"in\.not|eq\.not|equiv\.not|=\.not|!=|\bnotin\b|\bneq\b|[≠∉≢]|"
        r"\bnot\b\s*(?:in|=)|не (?:належить|дорівнює|є елементом)|не виконується",
        txt)
    warn = ""
    if len(src) and len(tr) < len(src):
        warn = (f"negations: source has {len(src)} (\u2260\u2209\u2262), "
                f"translation expresses {len(tr)} -- check none is inverted")
    return warn, len(src), len(tr)


def prose_words(seg):
    """Words of prose in a source or translation segment, notation excluded.

    Drops the lines of a formal derivation/figure -- the numbered proof terms
    (``(23) a23 := ...``) and formula-only lines -- which are reproduced as
    tables in the translation and have no prose counterpart.  Counting them
    makes a fully translated section look like it lost text.
    """
    out = []
    for ln in seg.splitlines():
        s = ln.strip()
        if not s:
            continue
        # a numbered line of a figure, or a line that is one long formula
        if re.match(r"^\(\d{1,3}\)\s", s) or re.match(r"^a_\d+\s*:=", s):
            continue
        if re.match(r"^\$$", s) or re.match(r"^\[\(?\d{1,3}\)?\]", s):
            continue
        # a line that is mostly symbols and digits, not letters
        letters = len(re.findall(r"[A-Za-zА-Яа-яЇїІіЄєҐґ]", s))
        if letters < len(s) * 0.4:
            continue
        out.append(s)
    return re.findall(r"\S+", " ".join(out))


def check(key, part, man, secs_by_key):
    chapter = str(man[key]["chapter"]).lstrip("ABCD") or man[key]["chapter"]
    src = os.path.join(TT, "out", key, f"src-part{part}.txt")
    p = os.path.join(TT, "out", key, f"part{part}.typ")
    print(f"==== {key} part{part} ====")
    if not os.path.exists(p):
        print("  MISSING (not translated yet)")
        return False
    ok = True
    macros, txt = macro_counts(p)
    heads = [l[3:].strip() for l in txt.splitlines() if l.startswith("== ")]
    if "#todo-section" in txt or re.search(r"\bTODO\b", txt):
        print("  !! leftover TODO marker")
        ok = False
    sec = man[key]["parts"][part - 1]["sections"]
    # appendices B and D are flat reference lists: their single manifest entry
    # is the appendix title itself, and the files have no level-2 headings
    flat = not heads and (
        not sec or all(s["num"] is None and s["uk"] is None for s in sec)
        and len(sec) == 1)

    # headings must be exactly the scaffold headings of these sections
    want_heads = [s["uk"] or s["en"] for s in sec]
    if flat:
        print("  headings: n/a (flat appendix, no sections)")
    elif heads == want_heads:
        print(f"  headings: OK ({len(heads)})")
    else:
        print(f"  headings: {len(heads)} found, expected {len(want_heads)}")
        for h in heads:
            mark = "  " if h in want_heads else "?? "
            print(f"    {mark}== {h}")
        ok = False

    if os.path.exists(src) and not flat:
        src_text = norm(open(src, encoding="utf-8").read())
        # per-section word counts, original vs translation
        ttxt = txt
        tpos = []
        for s in sec:
            uh = s["uk"] or s["en"]
            m = re.search(rf"^==\s*{re.escape(uh)}\s*$", ttxt, re.M)
            tpos.append(m.start() if m else None)
        print("  section words (original -> translation):")
        for i, (s, a, b) in enumerate(section_spans(src_text, sec, chapter)):
            # Compare prose only.  A section may have a formal figure
            # interleaved (39 numbered proof-term lines, in one case); that
            # notation is reproduced as a table and has no prose counterpart,
            # so counting it makes a complete section look short.
            ow = len(prose_words(src_text[a:b] if a is not None else ""))
            tw_s = tpos[i]
            te = next((x for x in tpos[i + 1:] if x is not None), len(ttxt))
            tw = len(prose_words(ttxt[tw_s:te] if tw_s is not None else ""))
            ratio = tw / ow if ow else 0
            flag = ""
            if ow and ratio < 0.7:
                flag = "  <-- short?"
                ok = False
            elif ow and ratio > 2.2:
                flag = "  <-- long?"
            label = s["num"] or "вправи"
            print(f"    {label:7s} {ow:5d} -> {tw:5d} ({ratio:4.2f}){flag}")
        want, want_ex = orig_counts(src_text, chapter)
        row = []
        for macro in KINDS:
            o, t = want.get(macro, 0), macros.get(macro, 0)
            if o or t:
                row.append(f"{macro}={o}/{t}" + ("" if o == t else "!!"))
                if o != t:
                    ok = False
        got_ex = macros.get("exercise", 0)
        row.append(f"exercise={want_ex}/{got_ex}" + ("" if want_ex == got_ex else "!!"))
        if want_ex != got_ex:
            ok = False
        print("  statements original/translation: " + "  ".join(row))
        if macros.get("proof"):
            print(f"  proof blocks: {macros['proof']}")
        warn, n_src, n_tr = negation_check(src_text, txt)
        if n_src:
            print(f"  negations (≠/∉/≢) source/translation: {n_src}/{n_tr}")
        if warn:
            print(f"  ?? {warn}")
    left = english_leftovers(txt)
    if left:
        print(f"  !! {len(left)} line(s) still look English:")
        for ln in left[:6]:
            print("     " + ln[:110])
        ok = False
    # `#ld-текст`: Typst parses the hyphen as minus and dies on an unknown
    # variable, so a hash macro glued by `-` to a Cyrillic word is always a
    # bug (the fix is `#(ld)-текст`).  A hyphen between ASCII words may be a
    # legitimate macro name (`#notation-item`), so require non-ASCII after it.
    bad = re.findall(r"#[a-zA-Z][a-zA-Z0-9.]*-[^\s\d,.);:\]}#]*[^\x00-\x7f][^\s]*", txt)
    if bad:
        print(f"  !! {len(bad)} hash macro(s) followed by a hyphen (parsed as "
              f"minus): {', '.join(sorted(set(bad))[:5])}")
        ok = False
    r = subprocess.run(
        ["typst", "compile", "--root", ".", os.path.relpath(p, ROOT),
         f"/tmp/verify-{key}-{part}.pdf"],
        cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
    )
    print(f"  typst: {'OK' if r.returncode == 0 else 'FAILED'}")
    if r.returncode != 0:
        print("   ", (r.stdout or "").strip()[:500])
        ok = False
    print(f"  -> {'OK' if ok else 'PROBLEMS'}")
    return ok


if __name__ == "__main__":
    man = json.load(open(os.path.join(TT, "manifest.json")))
    secs = json.load(open(os.path.join(TT, "sections.json")))
    keys = sys.argv[1:] or list(man)
    results = {}
    for key in keys:
        for part in man[key]["parts"]:
            results[(key, part["part"])] = check(key, part["part"], man, secs)
    print(f"\n{sum(results.values())}/{len(results)} parts OK")
