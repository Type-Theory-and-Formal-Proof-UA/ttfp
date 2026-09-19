#import "/book.typ": *

// One numbered entry of the reference lists: number aligned with the conclusion,
// each premiss in its own box (the last box's bottom edge acts as the rule).
#let ax(n, concl, prem: (), nota: none, seealso: none) = {
  let head = if seealso == none {
    concl
  } else {
    box[#concl #h(1.2em) #text(size: 9.5pt)[#seealso]]
  }
  let boxed(p) = box(stroke: 0.5pt, inset: (x: 0.55em, y: 0.28em), p)
  align(center)[
    #if prem.len() == 0 {
      grid(
        columns: (2.2em, auto),
        stroke: none,
        align: (right + horizon, center + horizon),
        column-gutter: 0.7em,
        [$ (#n) $],
        head,
      )
    } else {
      grid(
        columns: (2.2em, auto),
        stroke: none,
        align: (right + bottom, center + horizon),
        column-gutter: 0.7em,
        row-gutter: 0.22em,
        grid.cell(rowspan: prem.len() + 1)[$(#n)$],
        ..prem.map(boxed),
        head,
      )
    }
  ]
  if nota != none {
    align(center)[#nota]
  }
  v(0.55em)
}

#ax((1), [$arrow.r.double (A, B) := A arrow.r B : ast_p$], prem: ($A, B : ast_p$,))
#ax((2), [$arrow.r.double "-in"(A, B, u) := u : A arrow.r.double B$], prem: ($u : A -> B$,), seealso: [(див. $(2)^ast$)])
#ax((5), [$bot "-in"(A, u, v) := v u : bot$], prem: ($A : ast_p$, $u : A | v : A arrow.r.double bot$))
#ax((17), [$or "-el"(A, B, C, u, v, w) := u C v w : C$], prem: ($C : ast_p$, $u : A or B | v : A arrow.r.double C | w : B arrow.r.double C$))
