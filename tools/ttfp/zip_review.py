#!/usr/bin/env python3
"""Zip up the local side-by-side review pages for easy local sharing.

Regenerates tools/ttfp/review/ (via review.py) and packs it into
tools/ttfp/review.zip, so it can be copied off this machine by hand (AirDrop,
a USB drive, an attachment to a private message) without touching git.

    python3 tools/ttfp/zip_review.py

The zip embeds the same copyrighted original text as the review pages
themselves, so tools/ttfp/review.zip is git-ignored, same boundary as
tools/ttfp/review/ and tools/ttfp/raw/ — never commit or push it.
"""
import os
import subprocess
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")
REVIEW = os.path.join(TT, "review")
ZIP_PATH = os.path.join(TT, "review.zip")


def main():
    subprocess.run([sys.executable, os.path.join(TT, "review.py")], check=True)

    if os.path.exists(ZIP_PATH):
        os.remove(ZIP_PATH)
    with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as zf:
        for dirpath, _dirnames, filenames in os.walk(REVIEW):
            for name in filenames:
                full = os.path.join(dirpath, name)
                zf.write(full, arcname=os.path.relpath(full, REVIEW))

    size_kb = os.path.getsize(ZIP_PATH) / 1024
    print(f"wrote {os.path.relpath(ZIP_PATH, ROOT)} ({size_kb:.0f} KiB)")


if __name__ == "__main__":
    main()
