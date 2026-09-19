#import "/book.typ": *
#let fpA(depth, boxed: false, body) = {
  let b = if boxed { box(stroke: 0.6pt, inset: (x: 4pt, y: 2pt), body) } else { body }
  for _ in range(depth) { b = box(stroke: (left: 0.7pt), inset: (left: 9pt), width: 100%, b) }
  b
}
#let fpB(depth, boxed: false, body) = {
  let b = if boxed { box(stroke: 0.6pt, inset: (x: 4pt, y: 2pt), body) } else { body }
  for _ in range(depth) { b = box(stroke: (left: 0.7pt), inset: (left: 9pt), b) }
  b
}
#table(columns: (2.4em, 1fr, auto), stroke: none, align: (right+horizon, left+horizon, left+horizon), column-gutter: 0.7em, row-gutter: 0pt,
  [(a)], [#fpA(0, boxed: true)[$A, B : ast_p$]], [],
  [(b)], [#fpA(1, boxed: true)[$x : A or B$]], [],
  [(c)], [#fpA(2, boxed: true)[$y : not A$]], [],
  [(1)], [#fpA(3)[$a_1 (A, B, x, y, u) := not"-el"(A, y, u) : bot$]], [$(not"-el")$],
  [(3)], [#fpA(2)[$a_3 (A, B, x, y) := arrow.r.double"-in"(A, B, lambda u : A . a_2) : A arrow.r.double B$]], [$(arrow.r.double"-in")$],
)
#v(1em)
#table(columns: (2.4em, auto, auto), stroke: none, align: (right+horizon, left+horizon, left+horizon), column-gutter: 0.7em, row-gutter: 0pt,
  [(a)], [#fpB(0, boxed: true)[$A, B : ast_p$]], [],
  [(b)], [#fpB(1, boxed: true)[$x : A or B$]], [],
  [(c)], [#fpB(2, boxed: true)[$y : not A$]], [],
  [(1)], [#fpB(3)[$a_1 (A, B, x, y, u) := not"-el"(A, y, u) : bot$]], [$(not"-el")$],
  [(3)], [#fpB(2)[$a_3 (A, B, x, y) := arrow.r.double"-in"(A, B, lambda u : A . a_2) : A arrow.r.double B$]], [$(arrow.r.double"-in")$],
)
