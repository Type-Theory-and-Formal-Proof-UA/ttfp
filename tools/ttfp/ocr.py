#!/usr/bin/env python3
"""OCR the original book PDF as a cross-check against pdftotext extraction.

`extract.py` pulls text straight out of the PDF's embedded text layer, which
is normally exact but has known gaps: pdftotext drops some combining glyphs
(see negations.py) and there is no text layer at all for labels baked into
vector diagrams (e.g. chapter 16's figures). Rasterising each page and
running tesseract over the image recovers those as an independent reading to
diff against tools/ttfp/raw/<key>.txt.

Requires `pdftoppm` (poppler) and `tesseract` (with the `eng` language data):
    brew install poppler tesseract

Usage:
    python3 tools/ttfp/ocr.py --key ch16
    python3 tools/ttfp/ocr.py --key front-foreword
    python3 tools/ttfp/ocr.py --all            # every chapter + appendix
    python3 tools/ttfp/ocr.py --pages 379-390   # raw printed-page range

Writes tools/ttfp/ocr/<key>.txt (page-break-separated with \\f, matching the
layout of tools/ttfp/raw/book.txt). That directory is git-ignored — same
copyright boundary as tools/ttfp/raw/, see .gitignore.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")
OCR_DIR = os.path.join(TT, "ocr")
PDF_DEFAULT = "nederpelt_geuvers__type_theory_and_formal_proof_an_introduction.pdf"

sys.path.insert(0, TT)
from extract import FIRST_CONTENT_PAGE, FRONT, REFERENCES  # noqa: E402


def require(tool):
    if shutil.which(tool) is None:
        sys.exit(f"error: `{tool}` not found — try `brew install poppler tesseract`")


def printed_range(key):
    """(lo, hi) 1-based PDF page numbers (as `pdftoppm -f/-l` expects) for `key`."""
    front_key = key.removeprefix("front-")
    if front_key in FRONT:
        lo, hi = FRONT[front_key]
        return lo + 1, hi + 1  # FRONT stores 0-based raw indices
    if key == "references":
        lo, hi = REFERENCES
        return FIRST_CONTENT_PAGE + lo, FIRST_CONTENT_PAGE + hi + 1
    ranges = json.load(open(os.path.join(TT, "pageranges.json")))
    lo, hi = ranges[key]
    return FIRST_CONTENT_PAGE + lo, FIRST_CONTENT_PAGE + hi + 1


def ocr_range(pdf, lo, hi, lang, dpi, psm, keep_images):
    """OCR PDF pages [lo, hi] (1-based, inclusive). Returns \\f-joined text."""
    with tempfile.TemporaryDirectory() as tmp:
        prefix = os.path.join(tmp, "page")
        subprocess.run(
            ["pdftoppm", "-f", str(lo), "-l", str(hi), "-r", str(dpi), "-png", pdf, prefix],
            check=True,
        )
        pages = []
        images = sorted(f for f in os.listdir(tmp) if f.endswith(".png"))
        for img in images:
            img_path = os.path.join(tmp, img)
            result = subprocess.run(
                ["tesseract", img_path, "stdout", "--psm", str(psm), "-l", lang],
                capture_output=True, text=True, check=True,
            )
            pages.append(result.stdout)
            if keep_images:
                dest_dir = os.path.join(OCR_DIR, "pages")
                os.makedirs(dest_dir, exist_ok=True)
                shutil.copy(img_path, os.path.join(dest_dir, img))
        return "\f".join(pages)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--pdf", default=PDF_DEFAULT)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--key", help="chapter/appendix key, e.g. ch16, appA, front-foreword, references")
    g.add_argument("--all", action="store_true", help="OCR every chapter + appendix (slow: ~390 pages)")
    g.add_argument("--pages", help="raw printed-page range, e.g. 379-390")
    ap.add_argument("--lang", default="eng", help="tesseract language(s), default eng")
    ap.add_argument("--dpi", type=int, default=300)
    ap.add_argument("--psm", type=int, default=3, help="tesseract page segmentation mode")
    ap.add_argument("--keep-images", action="store_true", help="keep the rasterised pages in tools/ttfp/ocr/pages/")
    a = ap.parse_args()

    require("pdftoppm")
    require("tesseract")
    os.makedirs(OCR_DIR, exist_ok=True)
    pdf = a.pdf if os.path.isabs(a.pdf) else os.path.join(ROOT, a.pdf)
    if not os.path.exists(pdf):
        sys.exit(f"error: PDF not found: {pdf}")

    if a.pages:
        lo, hi = (int(x) for x in a.pages.split("-"))
        keys = [(f"pages-{lo}-{hi}", lo, hi)]
    elif a.key:
        lo, hi = printed_range(a.key)
        keys = [(a.key, lo, hi)]
    else:
        ranges = json.load(open(os.path.join(TT, "pageranges.json")))
        keys = []
        for key in ranges:
            lo, hi = printed_range(key)
            keys.append((key, lo, hi))

    for key, lo, hi in keys:
        print(f"OCR {key}: pages {lo}-{hi} ...", end=" ", flush=True)
        text = ocr_range(pdf, lo, hi, a.lang, a.dpi, a.psm, a.keep_images)
        out_path = os.path.join(OCR_DIR, f"{key}.txt")
        open(out_path, "w", encoding="utf-8").write(text)
        print(f"-> {os.path.relpath(out_path, ROOT)} ({len(text)} chars)")

    print(f"\ndone. cross-check with e.g.:\n  diff tools/ttfp/raw/{keys[0][0]}.txt tools/ttfp/ocr/{keys[0][0]}.txt")


if __name__ == "__main__":
    main()
