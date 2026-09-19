#!/usr/bin/env python3
"""Extract the raw text of the original book into per-chapter source files.

Requires the original PDF (see README) and `pdftotext` (poppler).

  python3 tools/ttfp/extract.py
  # or, with an explicit PDF path:
  python3 tools/ttfp/extract.py --pdf nederpelt_geuvers__....pdf

Writes, into tools/ttfp/raw/:
  book.txt        full `pdftotext -layout` dump (page = \\f-separated)
  <key>.txt       untouched text of every chapter/appendix (printed pages)
  front.txt       foreword, preface, acknowledgements, greek alphabet
  references.txt  bibliography
and then runs prepare.py to build the cleaned per-part jobs.

GLYPH FIXES
-----------
`pdftotext` silently drops the combining solidus (U+0338) that this book uses
to write the *negated* relations.  Without a fix the extraction contains
"z = 0" where the book prints "z ≠ 0" -- a mathematically false statement.
The affected characters are:

    U+0338 followed by  =   ->  !=
    U+0338 followed by  in  ->  notin
    U+0338 followed by  ==  ->  !=  (strict non-equivalence)

They are invisible to pdftotext, so they are recovered from the PDF text layer
with PyMuPDF (see negations.py) and patched back by line number.  Run
`python3 tools/ttfp/negations.py --report` to see them.
"""
import argparse
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")
PDF_DEFAULT = "nederpelt_geuvers__type_theory_and_formal_proof_an_introduction.pdf"
FIRST_CONTENT_PAGE = 29  # 0-based pdf page index of the *chapter opening* page
# of printed page 1 (the page carrying the printed folio "1" is one later, so
# printed page n starts at raw index FIRST_CONTENT_PAGE + n - 1)
# front matter: raw 0-based pdf page indices (inclusive), taken from the
# contents pages of the original
FRONT = {"foreword": (12, 13), "preface": (14, 25), "acknowledgements": (26, 26),
         "greek-alphabet": (27, 27)}
# bibliography: printed page range (printed 1 == FIRST_CONTENT_PAGE)
REFERENCES = (411, 417)


def patch_negations(book_path, pdf_path):
    """Re-insert the negations pdftotext dropped (see module docstring)."""
    from negations import apply_to_book

    return apply_to_book(pdf_path, book_path)


def main():
    import json
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf", default=PDF_DEFAULT)
    ap.add_argument("--no-prepare", action="store_true")
    a = ap.parse_args()
    raw = os.path.join(TT, "raw")
    os.makedirs(raw, exist_ok=True)
    book = os.path.join(raw, "book.txt")
    # book.txt is always re-made from the PDF: re-applying the negation patch
    # to an already-patched dump would count each of them twice and place the
    # second copy one character past the relation.
    subprocess.run(["pdftotext", "-layout", a.pdf, book], cwd=ROOT, check=True)
    from negations import apply_to_book

    n = apply_to_book(os.path.join(ROOT, a.pdf), book)
    print(f"patched {n} negations dropped by pdftotext")
    pages = open(book, encoding="utf-8", errors="replace").read().split("\f")
    ranges = json.load(open(os.path.join(TT, "pageranges.json")))
    for key, (lo, hi) in ranges.items():
        txt = "".join(pages[FIRST_CONTENT_PAGE + lo - 1 : FIRST_CONTENT_PAGE + hi])
        open(os.path.join(raw, f"{key}.txt"), "w", encoding="utf-8").write(txt)
    for key, (lo, hi) in FRONT.items():
        open(os.path.join(raw, f"front-{key}.txt"), "w", encoding="utf-8").write(
            "".join(pages[lo : hi + 1])
        )
    lo, hi = REFERENCES
    open(os.path.join(raw, "references.txt"), "w", encoding="utf-8").write(
        "".join(pages[FIRST_CONTENT_PAGE + lo - 1 : FIRST_CONTENT_PAGE + hi])
    )
    print("extracted", len(ranges), "chapters + front + references into tools/ttfp/raw/")
    if not a.no_prepare:
        subprocess.run([sys.executable, os.path.join(TT, "prepare.py")], check=True)


if __name__ == "__main__":
    main()
