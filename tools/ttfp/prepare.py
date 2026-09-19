#!/usr/bin/env python3
"""Prepare per-part translation jobs for the Ukrainian TTFP translation.

Splits the extracted original text into parts of at most WORDS_PER_PART words
and writes, per chapter/appendix:

  tools/ttfp/out/<key>/src-part<N>.txt   the original text of that part
  tools/ttfp/assign/<key>.md             the assignment (headings, paths)

Sections are located using tools/ttfp/sections.json (built from the book's
table of contents by contents.py), so every part records which original
sections it covers and which Ukrainian headings they map to.

Usage: python3 tools/ttfp/prepare.py [--raw tools/ttfp/raw/book.txt]
"""
import argparse
import json
import os
import re
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")
WORDS_PER_PART = 9000
FIRST_CONTENT_PAGE = 29  # raw 0-based index of the chapter-opening page of
# printed page 1 (see extract.py)
RAW = os.path.join(TT, "raw")

CTRL_MAP = {
    "\x10": "⊢",   # turnstile: judgements, "Γ ⊢ M : N"
    "\x05": "▷",   # the definition-format separator, "Γ ▷ a(x) := M : N".
    #   The book introduces it explicitly ("We introduce the symbol '▷' here
    #   as a separator between the context and the rest", section 8.5) and it
    #   is NOT the turnstile: a definition and a judgement are different
    #   things.  Mapping both to ⊢ silently turns every definition in
    #   chapters 8-12 into a judgement.
    "\x04": "□",   # the sort □
    "\x03": "→",
    "\x07": "→",
    "\x02": "⟶",   # zero-or-more-step reduction arrow (ch09)
    "\x06": "↦",   # maplet: the "translates to" arrow in a convention
    "\x19": "⟨",   # left angle bracket: opens a pair <a, q>
    "\x1a": "⟩",   # right angle bracket: closes it
    "\x01": "",    # figure/rule art (book-level dump only)
    "\x08": "",    # figure art
    "\x1b": "",    # figure art
    "\x18": "",    # figure art (X/XXXX marks in a ch09 figure)
}

# Every control character below 0x20 that the extraction actually produces
# must appear in CTRL_MAP; an unmapped one is dropped by clean_pages, which
# loses a symbol without a trace.  Asserted at import so the next glyph the
# PDF mangles fails loudly instead of quietly deleting text.
EXPECTED_CTRL = set(CTRL_MAP)


def clean_pages(pages, en_title):
    """Drop running heads and printed page numbers; keep everything else."""
    out = []
    num_pat = re.compile(r"^\s*\d{1,3}\s*$")
    title_tail = en_title.split(":")[0].strip()
    seen_ctrl = set()
    for p in pages:
        lines = p.splitlines()
        # the first non-empty line of a page is the running head (or a section
        # heading merged with it) — never content
        for i, ln in enumerate(lines):
            if ln.strip():
                del lines[i]
                break
        for ln in lines:
            s = ln.strip()
            if not s or num_pat.match(ln):
                continue
            if title_tail and title_tail in ln and len(s) < len(title_tail) + 30:
                continue
            for c in ln:
                if ord(c) < 32 and c != "\t":
                    seen_ctrl.add(c)
            ln = "".join(CTRL_MAP.get(c, "" if ord(c) < 32 else c) for c in ln)
            if ln.strip():
                out.append(ln.rstrip())
    unmapped = seen_ctrl - EXPECTED_CTRL
    if unmapped:
        raise SystemExit(
            "prepare: unmapped control character(s) in the extracted text: "
            + ", ".join(f"U+{ord(c):04X}" for c in sorted(unmapped))
            + " -- add them to CTRL_MAP (a dropped one loses a symbol "
              "silently; see chapter 8's definition separator)."
        )
    return out


def fold(s):
    """Loose comparison key: ligatures, accents and spacing removed."""
    s = unicodedata.normalize("NFKD", s)
    s = (s.replace("\ufb01", "fi").replace("\ufb02", "fl").replace("\ufb00", "ff")
          .replace("\ufb03", "ffi").replace("\ufb04", "ffl"))
    s = re.sub(r"[\u2018\u2019\u02bc]", "'", s)
    s = re.sub(r"[\s]+", " ", s)
    return s.lower().strip()


def find_sections(lines, sections, chapter, prefix=None):
    """Locate the start line of every section listed in sections.json."""
    starts, pos = [], 0
    for sec in sections:
        num, en = sec["num"], sec["en"]
        found = None
        if num is None:  # the Exercises block
            for i in range(pos, len(lines)):
                if re.match(r"^\s*Exercises\s*$", lines[i]):
                    found = i
                    break
        else:
            key = fold(en)[:32]
            for i in range(pos, len(lines)):
                ln = lines[i]
                m = re.match(rf"^\s*{re.escape(num)}\s+(\S.*)$", ln)
                if not m:
                    continue
                if fold(m.group(1))[:32] == key:
                    found = i
                    break
            if found is None:  # fall back to the number alone
                for i in range(pos, len(lines)):
                    if re.match(rf"^\s*{re.escape(num)}\s+\S", lines[i]):
                        found = i
                        break
        if found is None:
            raise SystemExit(f"{chapter}: cannot locate section {num} {en!r}")
        starts.append(found)
        pos = found + 1
    return starts


def build(raw_path):
    os.makedirs(os.path.join(TT, "assign"), exist_ok=True)
    os.makedirs(os.path.join(TT, "out"), exist_ok=True)
    pages = open(raw_path, encoding="utf-8", errors="replace").read().split("\f")
    ch = json.load(open(os.path.join(TT, "chapters.json")))
    ranges = json.load(open(os.path.join(TT, "pageranges.json")))
    sections = json.load(open(os.path.join(TT, "sections.json")))
    man = {}
    for key, meta in ch.items():
        lo, hi = ranges[key]
        lines = clean_pages(pages[FIRST_CONTENT_PAGE + lo - 1: FIRST_CONTENT_PAGE + hi],
                            meta["en_title"])
        secs = sections.get(key, [])
        if secs:
            starts = find_sections(lines, secs, key, meta.get("prefix"))
        else:
            starts = [0]
            secs = [{"num": None, "en": meta["en_title"], "uk": None}]
        # section -> line span
        spans = []
        for i, s in enumerate(secs):
            end = starts[i + 1] if i + 1 < len(starts) else len(lines)
            spans.append((starts[i], end, s))
        text_path = os.path.join(TT, "src", f"{key}.txt")
        open(text_path, "w", encoding="utf-8").write("\n".join(lines) + "\n")

        # group sections into parts
        parts, cur, cur_words = [], [], 0
        for (a, b, s) in spans:
            w = sum(len(l.split()) for l in lines[a:b])
            if cur and cur_words + w > WORDS_PER_PART:
                parts.append(cur)
                cur, cur_words = [], 0
            cur.append((a, b, s))
            cur_words += w
        if cur:
            parts.append(cur)

        part_files = []
        for i, part in enumerate(parts, 1):
            d = os.path.join(TT, "out", key)
            os.makedirs(d, exist_ok=True)
            src_out = os.path.join(d, f"src-part{i}.txt")
            with open(src_out, "w", encoding="utf-8") as fh:
                for (a, b, _s) in part:
                    fh.write("\n".join(lines[a:b]).rstrip() + "\n\n")
            part_files.append({
                "part": i,
                "source": os.path.relpath(src_out, ROOT),
                "words": sum(sum(len(l.split()) for l in lines[a:b]) for (a, b, _s) in part),
                "sections": [{"num": s["num"], "en": s["en"], "uk": s["uk"]}
                             for (_a, _b, s) in part],
            })
        man[key] = {"file": meta["file"], "chapter": meta.get("prefix") or str(meta["chapter"]),
                    "scaffold_headings": [s["uk"] for s in secs if s.get("uk")],
                    "parts": part_files}

        md = [f"# {key} — {meta['file']}", "",
              f"Розділ/додаток: **{man[key]['chapter']}**. "
              f"Файл-каркас: `{meta['file']}`.",
              "Загальні правила перекладу: `tools/ttfp/PROMPT.md` — прочитай його.", ""]
        md += [f"Усього частин: {len(part_files)}.", ""]
        for pf in part_files:
            md += [f"## Частина {pf['part']}", "",
                   f"- Текст оригіналу: `{pf['source']}` (~{pf['words']} слів)",
                   f"- Результат: `tools/ttfp/out/{key}/part{pf['part']}.typ`",
                   "- Підрозділи цієї частини (заголовок рівня 2, який треба "
                   "вставити дослівно — українською, і відповідний підрозділ "
                   "оригіналу):", ""]
            for s in pf["sections"]:
                head = s["uk"] or f"({s['en']})"
                md.append(f"    - `== {head}`  ←  {s['num'] + ' ' if s['num'] else ''}{s['en']}")
            md += ["", "Переклади всі ці підрозділи повністю — без скорочень і "
                   "переказу, з усіма твердженнями, доведеннями, прикладами, "
                   "таблицями та вправами.", ""]
        open(os.path.join(TT, "assign", f"{key}.md"), "w", encoding="utf-8").write(
            "\n".join(md) + "\n")
    json.dump(man, open(os.path.join(TT, "manifest.json"), "w"), indent=1,
              ensure_ascii=False)
    for key, m in man.items():
        print(f"{key:6s} ch{m['chapter']:<3} parts={len(m['parts'])} "
              f"words={[p['words'] for p in m['parts']]}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--raw", default=os.path.join(RAW, "book.txt"))
    build(ap.parse_args().raw)
