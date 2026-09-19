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

## Building

Requires the [Typst CLI](https://github.com/typst/typst) (`brew install
typst`).

```sh
make build   # compiles main.typ -> ttfp-uk.pdf
make watch   # recompiles on save
```

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
