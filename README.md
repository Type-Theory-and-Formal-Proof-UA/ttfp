# Теорія типів і формальне доведення: Вступ (переклад)

Ukrainian translation project for *Type Theory and Formal Proof: An
Introduction* (Rob Nederpelt & Herman Geuvers, Cambridge University Press,
2014), typeset with [Typst](https://typst.app/).

An earlier attempt at this project used mdBook (see the old `foreword.md` /
`preface.md` commits in git history); this setup replaces it with a Typst
build that gives per-chapter numbered theorem/definition/lemma environments
and proper math typesetting for the λ-systems used throughout the book.

## Layout

```
main.typ              entry point — assembles the whole book, builds the PDF
book.typ              shared template: page/heading style, numbered
                       statement environments (definition/theorem/lemma/…),
                       and shorthands for the book's λ-systems (λ→, λ2, λω, …)
src/front/             foreword, preface, acknowledgements, Greek alphabet
src/chapters/           ch01..ch16, one file per chapter of the book
src/appendices/         appA..appD
src/back/                bibliography
GLOSSARY.md            English → Ukrainian term correspondences; keep this
                       up to date so translations stay consistent
```

Each chapter/appendix file mirrors the original book's section structure
(headings only) and marks untranslated sections with `#todo-section`. Delete
that marker as you fill in a section's translation.

## Translation pipeline (`tools/ttfp/`)

The book is translated section by section against the original PDF, in parts
of at most ~9000 words, and the translated parts are merged back into the
chapter scaffolds.

```
tools/ttfp/extract.py    PDF -> tools/ttfp/raw/<chapter>.txt (raw text)
tools/ttfp/negations.py  recover the ≠ / ∉ / ≢ that pdftotext silently drops
tools/ttfp/prepare.py    raw text -> cleaned per-part sources + assignments
tools/ttfp/PROMPT.md     the translation rules (style, Typst conventions,
                         statement environments, glossary)
tools/ttfp/assign/       one assignment per chapter (headings, parts, paths)
tools/ttfp/out/<ch>/     part<N>.typ  — translated parts (the work files)
tools/ttfp/verify.py     per part: statement counts vs. the original,
                         leftover TODOs, Typst compile
tools/ttfp/assemble.py   merge fully translated chapters back into src/
```

### The dropped-negation trap

The book typesets "not equal", "not in" and "not equivalent" by overprinting a
combining solidus (U+0338) on the base relation. `pdftotext` discards that
character, so a naive extraction of the book contains `z = 0` where the page
prints `z ≠ 0` — a different and false statement. There are 97 such places.

`tools/ttfp/negations.py` reads the text layer with PyMuPDF, groups characters
by baseline (PyMuPDF splits visual lines wherever the font changes), matches
each affected line against the `pdftotext` dump and rewrites the base relation
into its negated form. `extract.py` runs it automatically, so `book.txt` and
every `raw/<key>.txt` are correct; `python3 tools/ttfp/negations.py --report`
lists all 97 with their chapter and page.

Anything translated before this fix must be re-checked: the translations in
`src/` were audited and the inverted relations corrected by hand. `verify.py`
now prints the negation counts per part, and `PROMPT.md` warns translators that
`(var)`/`(weak)` require `x in.not Gamma`, `(def)`/`(par)` require
`a in.not Delta`, and substitution/α-conversion require `y in.not FV(M)`.

```sh
make extract   # PDF -> raw text (needs pdftotext)
make jobs      # re-split raw text into parts + assignments
make verify    # check every translated part (counts, TODOs, compile)
make check     # coverage report: which chapters are fully translated
make assemble  # merge ready chapters into src/chapters|appendices/*.typ
make build     # compile the book
```

Neither the original PDF nor the extracted text is committed (see
`.gitignore`); only the tooling and the Ukrainian translation in `src/`.

## Building

Requires the [Typst CLI](https://github.com/typst/typst) (`brew install
typst`).

```sh
make build   # compiles main.typ -> ttfp-uk.pdf
make watch   # recompiles on save
```

## Publishing

`.github/workflows/deploy-pages.yml` builds on every push to `master`: the HTML
edition (`typst compile --features html --format html`, still experimental in
Typst; math is emitted as MathML), which `tools/split_html.py` cuts into one
page per chapter (`index.html` = contents, `ch01.html`…, `appA.html`…), and the
PDF (`ttfp-uk.pdf`); both are deployed to GitHub Pages. One-time setup:
repository **Settings → Pages → Source: GitHub Actions**. The Typst version is
pinned in the workflow's `TYPST_VERSION`. Locally: `make html` → `site/`.

## Writing a chapter

Import the template helpers at the top of a chapter file (already done in
the scaffolded files):

```typst
#import "/book.typ": *
```

Then use the numbered statement environments, which are numbered jointly
per chapter as `Kind <chapter>.<n>` (e.g. `Теорема 3.4`), matching the
convention used in the source book:

```typst
#definition(name: "Редекс")[
  ...
]

#theorem[
  ...
]
#proof[
  ...
]
```

Available: `definition`, `theorem`, `lemma`, `corollary`, `proposition`,
`example`, `remark`, `notation-item`, `convention`, `exercise`, plus
`proof(..)` for QED-terminated proof blocks.

λ-system shorthands: `#lto` (λ→), `#ltwo` (λ2), `#lomega` (λω), `#lp` (λP),
`#lc` (λC), `#ld0` (λD₀), `#ld` (λD) — usable inline or in math mode.

## Source

The original PDF (for reference while translating) lives at
`nederpelt_geuvers__type_theory_and_formal_proof_an_introduction.pdf` in the
repo root. It is not distributed — keep it out of version control if you
push this repo anywhere public (see `.gitignore`).
