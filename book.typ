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

// Shared counter for every "statement" kind (definition, theorem, lemma, …),
// mirroring the source book's convention of numbering these jointly within
// a chapter. Reset to 0 by the level-1 heading show rule in book-template.
#let statement-counter = counter("statement")

// Builds a labelled, numbered block: kind + "chapter.n" (+ optional name).
// Usage: #definition(name: "Редекс")[ ...body... ]
#let statement(kind: "Твердження") = (name: none, body) => {
  statement-counter.step()
  block(above: 1.2em, below: 1.2em, breakable: true)[
    #context {
      let n = statement-counter.get().first()
      let head = if name == none {
        [*#kind #chapter-num().#n.*]
      } else {
        [*#kind #chapter-num().#n* (#name).]
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
// Use `#stack` for a multi-premiss rule and `prem: none` for an axiom.
#let stack(..rules) = {
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
  show heading.where(level: 2): set text(size: 15pt)
  show heading.where(level: 3): set text(size: 12.5pt)

  body
}
