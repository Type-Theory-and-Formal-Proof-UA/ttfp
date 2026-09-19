#!/usr/bin/env python3
"""Build a local, side-by-side review page: original text vs. translation.

Reads every tools/ttfp/out/<key>/part<N>.typ that has a matching
src-part<N>.txt next to it, and renders one HTML page per chapter/appendix
plus an index, so a human can scroll the original and the Ukrainian
translation together and check the translation against the source.

    python3 tools/ttfp/review.py
    open tools/ttfp/review/index.html

Output goes to tools/ttfp/review/, which is git-ignored: these pages embed
the copyrighted original text (same boundary as tools/ttfp/raw/ and
tools/ttfp/out/*/src-part*.txt — see .gitignore), so they must stay local
and are never committed or pushed.
"""
import glob
import html
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")
OUT = os.path.join(TT, "out")
REVIEW = os.path.join(TT, "review")

STYLE = """
:root { color-scheme: light dark; }
* { box-sizing: border-box; }
body { margin: 0; font: 14px/1.5 -apple-system, system-ui, sans-serif; }
header {
  position: sticky; top: 0; z-index: 1; display: flex; align-items: center;
  gap: 1rem; padding: 0.6rem 1rem; background: Canvas; border-bottom: 1px solid GrayText;
}
header h1 { font-size: 1rem; margin: 0; flex: 1; }
header nav a { margin-right: 0.75rem; }
.part { border-top: 3px solid GrayText; }
.part h2 {
  margin: 0; padding: 0.5rem 1rem; font-size: 0.9rem; background: Canvas;
  position: sticky; top: 2.6rem; z-index: 1;
}
.cols { display: flex; align-items: flex-start; }
.col { flex: 1 1 50%; min-width: 0; padding: 0.75rem 1rem; overflow-x: auto; }
.col.src { border-right: 1px solid GrayText; }
.col h3 { margin: 0 0 0.5rem; font-size: 0.75rem; text-transform: uppercase; opacity: 0.6; }
pre {
  white-space: pre-wrap; word-wrap: break-word; margin: 0;
  font: 12.5px/1.5 ui-monospace, "SF Mono", Menlo, monospace;
}
.index li { margin: 0.15rem 0; }
.index code { opacity: 0.6; }
@media (max-width: 800px) { .cols { flex-direction: column; } .col.src { border-right: none; border-bottom: 1px solid GrayText; } }
"""

SYNC_SCROLL_JS = """
document.querySelectorAll('.cols').forEach(row => {
  const [a, b] = row.querySelectorAll('.col');
  let syncing = null;
  const link = (from, to) => from.addEventListener('scroll', () => {
    if (syncing) return;
    syncing = from;
    const frac = from.scrollTop / (from.scrollHeight - from.clientHeight || 1);
    to.scrollTop = frac * (to.scrollHeight - to.clientHeight);
    syncing = null;
  });
  link(a, b); link(b, a);
});
"""


def page(title, body, nav=""):
    return f"""<!doctype html>
<html lang="uk"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<style>{STYLE}</style>
</head><body>
<header><h1>{html.escape(title)}</h1><nav>{nav}</nav></header>
{body}
<script>{SYNC_SCROLL_JS}</script>
</body></html>"""


def find_pairs(key):
    """[(n, src_text, typ_text), ...] for every part of `key`, in order."""
    pairs = []
    for src_path in sorted(glob.glob(os.path.join(OUT, key, "src-part*.txt"))):
        n = int(re.search(r"src-part(\d+)\.txt$", src_path).group(1))
        typ_path = os.path.join(OUT, key, f"part{n}.typ")
        if not os.path.exists(typ_path):
            continue
        src = open(src_path, encoding="utf-8", errors="replace").read()
        typ = open(typ_path, encoding="utf-8", errors="replace").read()
        pairs.append((n, src, typ))
    return pairs


def chapter_page(key, pairs):
    parts_html = []
    for n, src, typ in pairs:
        parts_html.append(f"""
<section class="part" id="part{n}">
  <h2>Частина {n}</h2>
  <div class="cols">
    <div class="col src"><h3>Оригінал</h3><pre>{html.escape(src)}</pre></div>
    <div class="col"><h3>Переклад ({key}/part{n}.typ)</h3><pre>{html.escape(typ)}</pre></div>
  </div>
</section>""")
    nav = " ".join(f'<a href="#part{n}">ч.{n}</a>' for n, *_ in pairs)
    nav += ' <a href="index.html">← зміст</a>'
    return page(f"Рецензія — {key}", "\n".join(parts_html), nav=nav)


def main():
    os.makedirs(REVIEW, exist_ok=True)
    keys = sorted(
        os.path.basename(d) for d in glob.glob(os.path.join(OUT, "*")) if os.path.isdir(d)
    )
    index_rows = []
    n_pairs_total = 0
    for key in keys:
        pairs = find_pairs(key)
        if not pairs:
            continue
        n_pairs_total += len(pairs)
        open(os.path.join(REVIEW, f"{key}.html"), "w", encoding="utf-8").write(
            chapter_page(key, pairs)
        )
        index_rows.append(
            f'<li><a href="{key}.html">{key}</a> '
            f"<code>({len(pairs)} " + ("частина" if len(pairs) == 1 else "частин(и)") + ")</code></li>"
        )
    index_body = f"<ul class='index'>{''.join(index_rows)}</ul>" if index_rows else (
        "<p>Немає пар <code>src-part*.txt</code> / <code>part*.typ</code> — "
        "запусти <code>python3 tools/ttfp/extract.py</code> та "
        "<code>python3 tools/ttfp/prepare.py</code> спочатку.</p>"
    )
    open(os.path.join(REVIEW, "index.html"), "w", encoding="utf-8").write(
        page("Рецензія перекладу — зміст", index_body)
    )
    print(f"wrote {len(index_rows)} chapter page(s), {n_pairs_total} part(s), to {REVIEW}/")
    print(f"open {os.path.join(REVIEW, 'index.html')}")


if __name__ == "__main__":
    main()
