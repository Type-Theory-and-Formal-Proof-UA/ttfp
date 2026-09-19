#!/usr/bin/env python3
"""Recover the negated relations that `pdftotext` silently drops.

The original book typesets "not equal", "not in" and "not equivalent" by
overprinting a combining solidus (U+0338) on the base relation.  poppler's
text layer keeps the slash as its own character, but `pdftotext -layout`
discards it -- so "z != 0" comes out as "z = 0", which is a different and
false statement.  The same happens for "not in" and "not equivalent".

This module reads the PDF text layer with PyMuPDF, finds every U+0338, and
rewrites the base relation into its negated form in the pdftotext dump.

  python3 tools/ttfp/negations.py --report   # list them, grouped by chapter
  python3 tools/ttfp/negations.py --json     # machine-readable
  python3 tools/ttfp/negations.py --apply    # patch tools/ttfp/raw/book.txt
"""
import argparse
import difflib
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")
PDF_DEFAULT = os.path.join(
    ROOT, "nederpelt_geuvers__type_theory_and_formal_proof_an_introduction.pdf"
)
FIRST_CONTENT_PAGE = 29

SLASH = "\u0338"
# U+0338 negates the relation printed underneath it.
NEGATED = {
    "=": "\u2260",        # not equal
    "\u2208": "\u2209",   # not an element of
    "\u2261": "\u2262",   # not equivalent
}
FOLD = {"\ufb01": "fi", "\ufb02": "fl", "\ufb00": "ff", "\ufb03": "ffi",
        "\ufb04": "ffl"}


def _lines(pdf_path):
    """[(page_idx, line_idx, [(char, x0), ...])] from the PDF text layer.

    PyMuPDF splits a visual line into several "lines" when the typesetting
    changes font or block, which breaks line-by-line matching against the
    pdftotext dump.  So the characters are regrouped here by their baseline
    y-coordinate (and then ordered by x), which reproduces the visual lines
    that `pdftotext -layout` emits.
    """
    import fitz

    doc = fitz.open(pdf_path)
    for page_idx, page in enumerate(doc):
        chars = []
        for block in page.get_text("rawdict")["blocks"]:
            for line in block.get("lines", []):
                for span in line["spans"]:
                    for c in span["chars"]:
                        chars.append((round(c["bbox"][1], 1), c["bbox"][0], c["c"]))
        chars.sort(key=lambda t: (t[0], t[1]))
        lines, cur, cur_y = [], [], None
        for y, x, c in chars:
            if cur_y is None or abs(y - cur_y) <= 2.0:
                cur.append((c, x))
                cur_y = y if cur_y is None else cur_y
            else:
                cur.sort(key=lambda t: t[1])
                lines.append(cur)
                cur, cur_y = [(c, x)], y
        if cur:
            cur.sort(key=lambda t: t[1])
            lines.append(cur)
        for line_idx, ln in enumerate(lines):
            yield page_idx, line_idx, ln


def find_negations(pdf_path=PDF_DEFAULT):
    """Every dropped negation as (page_idx, line_idx, ordinal, char).

    `ordinal` is the 1-based occurrence count of the base relation within the
    visible text of that line, which is what the pdftotext dump can be matched
    on without any offset alignment.
    """
    out = []
    for page_idx, line_idx, chars in _lines(pdf_path):
        if not any(c == SLASH for c, _ in chars):
            continue
        seen = {}  # base char -> how many times it has appeared so far
        pending = False
        for k, (c, _) in enumerate(chars):
            if c == SLASH:
                nxt = chars[k + 1][0] if k + 1 < len(chars) else None
                pending = nxt in NEGATED
                continue
            if pending:
                # this visible char is the negated relation
                out.append((page_idx, line_idx, seen.get(c, 0) + 1, NEGATED[c]))
                pending = False
            seen[c] = seen.get(c, 0) + 1
    return out


def _compact(s):
    for a, b in FOLD.items():
        s = s.replace(a, b)
    return "".join(s.split())


def _compact_positions(s):
    """Compact text plus, for each compact index, its index in `s`."""
    chars, back = [], []
    for pos, c in enumerate(s):
        f = FOLD.get(c, c)
        for ch in f:
            chars.append(ch)
            back.append(pos)
    return "".join(chars), back


def apply_to_book(pdf_path=PDF_DEFAULT, book_path=None):
    """Insert the dropped negations into the pdftotext dump; returns the count.

    Each affected PDF line is matched to the pdftotext line with the highest
    text similarity, and the base relation is then *replaced* by its negated
    form at the same occurrence index -- so no global offset alignment is
    needed and neighbouring lines cannot shift the result.
    """
    book_path = book_path or os.path.join(TT, "raw", "book.txt")
    text = open(book_path, encoding="utf-8", errors="replace").read()
    pages = text.split("\f")

    by_page = {}
    for page_idx, line_idx, nth, ch in find_negations(pdf_path):
        by_page.setdefault(page_idx, {}).setdefault(line_idx, []).append((nth, ch))

    pdf_lines = {}
    for page_idx, line_idx, chars in _lines(pdf_path):
        pdf_lines[(page_idx, line_idx)] = "".join(c for c, _ in chars)

    applied = 0
    for page_idx, lines in by_page.items():
        if page_idx >= len(pages):
            continue
        dlines = pages[page_idx].split("\n")
        dcache = [_compact(l) for l in dlines]
        for line_idx, marks in lines.items():
            src = pdf_lines.get((page_idx, line_idx))
            if src is None:
                continue
            src_c = _compact(src.replace(SLASH, ""))
            best, best_r = None, 0.0
            for i, dc in enumerate(dcache):
                if not dc:
                    continue
                r = difflib.SequenceMatcher(None, src_c, dc).ratio()
                if r > best_r:
                    best, best_r = i, r
            if best is None or best_r < 0.6:
                continue
            _dc, back = _compact_positions(dlines[best])
            # resolve every mark against the *original* line first: mutating
            # the line as we go would shift the occurrence indices of the
            # remaining marks (a second "=" on the same line would be lost)
            plan = []
            for nth, ch in marks:
                base = {v: k for k, v in NEGATED.items()}[ch]
                positions = [j for j, c in enumerate(_dc) if c == base]
                if nth - 1 >= len(positions):
                    continue
                real = back[positions[nth - 1]]
                if dlines[best][real] == base:
                    plan.append((real, ch))
            for real, ch in sorted(plan, reverse=True):
                dlines[best] = (dlines[best][:real] + ch
                                + dlines[best][real + 1:])
                applied += 1
        pages[page_idx] = "\n".join(dlines)

    open(book_path, "w", encoding="utf-8").write("\f".join(pages))
    return applied


def report(pdf_path=PDF_DEFAULT):
    ranges = json.load(open(os.path.join(TT, "pageranges.json")))

    def key_for(printed):
        for k, (lo, hi) in ranges.items():
            if lo <= printed <= hi:
                return k
        return "front/other"

    per = {}
    for page_idx, line_idx, chars in _lines(pdf_path):
        txt = "".join(c for c, _ in chars)
        if SLASH not in txt:
            continue
        for k, (c, _) in enumerate(chars):
            if c != SLASH:
                continue
            nxt = chars[k + 1][0] if k + 1 < len(chars) else None
            if nxt not in NEGATED:
                continue
            printed = page_idx + 1 - FIRST_CONTENT_PAGE
            per.setdefault(key_for(printed), []).append(
                (printed, NEGATED[nxt], _compact(txt)[:86])
            )
    total = sum(len(v) for v in per.values())
    print(f"{total} negations dropped by pdftotext:\n")
    for k in sorted(per):
        print(f"== {k} ({len(per[k])})")
        for printed, ch, line in per[k]:
            print(f"   p.{printed} {ch!r}  {line}")
    return per


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf", default=PDF_DEFAULT)
    ap.add_argument("--report", action="store_true")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--apply", action="store_true")
    a = ap.parse_args()
    if a.json:
        print(json.dumps(find_negations(a.pdf), ensure_ascii=False, indent=1))
    elif a.apply:
        print("patched", apply_to_book(a.pdf), "negations")
    else:
        report(a.pdf)
