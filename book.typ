// book.typ — shared template and helpers for the Ukrainian translation of
// "Type Theory and Formal Proof: An Introduction" (Nederpelt & Geuvers).
//
// Import this from main.typ and from any chapter/appendix file that needs
// the statement environments or the λ-system shorthands.

// ---------------------------------------------------------------------------
// Chapter-scoped numbering helpers
// ---------------------------------------------------------------------------

// Current chapter number (the nearest level-1 heading), as an integer.
#let chapter-num() = counter(heading).get().first()

// Current section number: the level-2 part of "chapter.section".  The source
// book numbers every statement as chapter.section.n, resetting n at each new
// section (Remark 11.3.1, 11.3.2, then 11.4.1 again) -- so a flat chapter-wide
// counter would print numbers that none of the text's cross-references match.
#let section-num() = {
  let h = counter(heading).get()
  if h.len() > 1 { h.at(1) } else { 0 }
}

// Shared counter for every "statement" kind (definition, theorem, lemma, …),
// mirroring the source book's convention of numbering these jointly within
// a section. Reset by the level-1 and level-2 heading show rules.
#let statement-counter = counter("statement")

// Builds a labelled, numbered block: kind + "chapter.section.n" (+ optional
// name).  Usage: #definition(name: "Редекс")[ ...body... ]
//
// `label:` overrides the auto-number with a literal one (appendix B restates
// the arithmetical lemmas with the numbers they carry in chapter 14, so there
// the printed number is content, not a fresh count).  `label: []` prints no
// number at all, for the entries the source book itself leaves unnumbered and
// identifies only by the figure they come from.
#let statement(kind: "Твердження") = (name: none, label: auto, body) => {
  if label == auto { statement-counter.step() }
  block(above: 1.2em, below: 1.2em, breakable: true)[
    #context {
      let num = if label == auto {
        let n = statement-counter.get().first()
        [#chapter-num().#section-num().#n]
      } else { label }
      let labelled = if label == auto or label != [] { [#num] } else { [] }
      let head = if name == none {
        if labelled == [] { [*#kind.*] } else { [*#kind #labelled.*] }
      } else {
        [*#kind #labelled* (#name).]
      }
      head
    }
    #body
  ]
}

#let definition = statement(kind: "Означення")
#let theorem = statement(kind: "Теорема")
#let lemma = statement(kind: "Лема")
#let corollary = statement(kind: "Наслідок")
#let proposition = statement(kind: "Твердження")
#let example = statement(kind: "Приклад")
#let remark = statement(kind: "Зауваження")
#let notation-item = statement(kind: "Позначення")
#let convention = statement(kind: "Домовленість")
#let exercise = statement(kind: "Вправа")
#let axiom = statement(kind: "Аксіома")

// Placeholder marker for a section whose translation has not been written
// yet. Drop `#todo-section` right under a heading; remove it once the
// section has real content.
#let todo-section = text(style: "italic", fill: gray)[TODO: переклад ще не виконано.]

// A proof block, closed with a QED square instead of a numbered label.
#let proof(body) = block(above: 1em, below: 1.2em, breakable: true)[
  _Доведення._ #body #h(1fr) $square$
]

// ---------------------------------------------------------------------------
// Derivation rules
// ---------------------------------------------------------------------------
// Renders a rule in premiss-conclusion format (premisses above a horizontal
// line, rule label in the left margin, side condition in the right margin):
//
//   #rule(label: "appl", prem: $Gamma tack.r M : Pi x : A . B$,
//         conc: $Gamma tack.r M N : B[x := N]$)
//
// For a multi-premiss rule, join the premisses in one math string with
// `quad` (see e.g. ch05's (weak)/(conv) rules); use `prem: none` for an
// axiom. `side-by-side` below is a helper for that same horizontal joining
// when the premisses are built up as separate content blocks rather than
// written inline — deliberately NOT named `stack`, which would silently
// shadow Typst's built-in block-stacking function for anyone who imports
// this file with `*` and calls `stack(dir: ttb, ..)` expecting the builtin.
#let side-by-side(..rules) = {
  let r = rules.pos()
  math.display($#r.join($space space space space$)$)
}
#let rule(label: none, prem: none, conc: none, side: none) = block(
  above: 1.1em,
  below: 1.1em,
  breakable: false,
)[
  #grid(
    columns: (4.5em, 1fr, auto),
    align: (left + horizon, center + horizon, right + horizon),
    column-gutter: 0.6em,
    row-gutter: 0.35em,
    text(size: 9pt, if label == none { [~] } else { label }),
    if prem == none { [#none] } else { prem },
    if side == none { [#none] } else { text(size: 9pt, side) },
    [], line(length: 100%, stroke: 0.5pt), [],
    [], conc, [],
  )
]

// ---------------------------------------------------------------------------
// λ-system shorthands used throughout the book
// ---------------------------------------------------------------------------

#let lto = $lambda^(arrow)$ // λ→  — simply typed lambda calculus
#let ltwo = $lambda 2$ // λ2  — second order typed lambda calculus
#let lomega = $lambda omega$ // λω  — types dependent on types
#let lp = $lambda P$ // λP  — types dependent on terms
#let lc = $lambda C$ // λC  — the Calculus of Constructions
#let ld0 = $lambda D_0$ // λD₀ — λC extended with definitions
#let ld = $lambda D$ // λD  — full system with definitions

// Judgement/derivation shorthand.
#let vdash = $tack.r$
#let defeq = $:=$

// ---------------------------------------------------------------------------
// Page / text setup
// ---------------------------------------------------------------------------

#let book-template(
  title: none,
  subtitle: none,
  authors: (),
  translator: none,
  body,
) = {
  set document(title: title, author: authors)
  set text(lang: "uk", region: "UA", font: "New Computer Modern", size: 11pt)
  set page(
    paper: "a4",
    margin: (inside: 3.2cm, outside: 2.5cm, top: 3cm, bottom: 3cm),
    numbering: "1",
  )
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")
  set math.equation(numbering: n => context {
    numbering("(1.1)", chapter-num(), n)
  })

  show heading.where(level: 1): it => {
    statement-counter.update(0)
    counter(math.equation).update(0)
    pagebreak(weak: true)
    v(2cm)
    block(text(size: 24pt, weight: "bold", it))
    v(1.5cm)
  }
  // Every level-2 section restarts the statement counter: the source book
  // numbers statements per section (14.8.1 … 14.8.11, then 14.9.1 again).
  show heading.where(level: 2): it => {
    statement-counter.update(0)
    text(size: 15pt, it)
  }
  show heading.where(level: 3): set text(size: 12.5pt)

  // HTML export (experimental) has no layout engine: grids, stacks and
  // absolutely positioned boxes would come out empty. Typeset those through
  // `html.frame`, which lays the content out as usual and embeds it as an
  // inline SVG. (Inside a frame `target()` is "paged", so this cannot recurse.)
  // A frame has no page to take a width from, so `1fr` columns would collapse;
  // give them the width of the PDF's text block (a4 minus margins ≈ 39em).
  show grid: it => context if target() == "html" {
    html.elem("div", attrs: (style: "margin: 1.1em 0"), html.frame(block(width: 39em, it)))
  } else { it }
  // Tables here are almost all layout (rules, flag proofs, side-by-side
  // figures) with cell borders and nested grids that native <table> cannot
  // express, so they get the same treatment, centred like the book's own.
  show table: it => context if target() == "html" {
    html.elem("div", attrs: (style: "margin: 1.1em 0"), html.frame(block(width: 39em, align(center, it))))
  } else { it }
  show stack: it => context if target() == "html" {
    html.elem("div", attrs: (style: "margin: 1.1em 0"), html.frame(block(width: 39em, it)))
  } else { it }
  // Boxes that take a percentage of the available width (the flag-style
  // proofs' nested poles) need a concrete width to be a percentage of.
  show box: it => context if target() == "html" and (it.width != auto or it.height != auto) {
    if type(it.width) in (ratio, relative) {
      html.frame(block(width: 33em, it))
    } else {
      html.frame(it)
    }
  } else { it }
  show align: it => context if target() == "html" {
    let x = it.alignment.x
    let css = if x == center { "center" } else if x == right or x == end { "right" } else { "left" }
    html.elem("div", attrs: (class: "al", style: "text-align: " + css), it.body)
  } else { it }
  show line: it => context if target() == "html" {
    html.elem("div", attrs: (style: "border-top: 0.5pt solid currentColor; margin: 0.2em auto; width: calc(" + repr(it.length.ratio) + " + " + repr(it.length.length) + ")"))
  } else { it }
  show pad: it => context if target() == "html" {
    html.elem("blockquote", it.body)
  } else { it }
  show math.overline: it => context if target() == "html" {
    math.accent(it.body, math.macron)
  } else { it }

  body
}
