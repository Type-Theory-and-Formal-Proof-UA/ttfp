// Appendix A — "Logic in λD" (original pp. 391–396).
#import "/book.typ": *

#set heading(numbering: (..n) => {
  let p = n.pos()
  if p.len() == 1 { "A" } else { "A." + p.slice(1).map(str).join(".") }
})
#counter(heading).update(0)

= Логіка в #ld

#let dblbot = $bot #h(-0.12em) bot$
#let ax(n, concl, prem: (), nota: none, seealso: none) = {
  let boxed(p) = box(stroke: 0.5pt, inset: (x: 0.55em, y: 0.28em), p)
  let note = box(text(size: 9.5pt)[#(
    if seealso == none { [] } else { seealso }
  )])
  let nprem = prem.len()
  let cells = ()
  cells.push(grid.cell(rowspan: if nprem > 0 { nprem + 1 } else { 1 }, align: right + bottom)[$(#n)$])
  for p in prem {
    cells.push(grid.cell(colspan: 2, align: center + horizon)[#boxed(p)])
  }
  cells.push(grid.cell(align: center + horizon)[#concl])
  cells.push(grid.cell(align: left + horizon)[#note])
  align(center)[
    #grid(
      columns: (2.2em, auto, auto),
      stroke: none,
      column-gutter: 0.7em,
      row-gutter: 0.22em,
      ..cells,
    )
  ]
  if nota != none {
    align(center)[#nota]
  }
  v(0.55em)
}
#let ln(i, body, boxed: false) = align(left)[
  #box(inset: (left: i * 1.4em), if boxed {
    box(stroke: 0.5pt, inset: (x: 0.5em, y: 0.25em), body)
  } else { body })
]
#let dots2(i) = align(left)[#box(inset: (left: i * 1.4em), $..$)]
#let dots1(i) = align(left)[#box(inset: (left: i * 1.4em + 0.35em), $.$)]

== Конструктивна логіка висловлювань

*Імплікація (пор. рис. 11.5)*

#ax(
  (1),
  [$arrow.r.double (A, B) := A arrow.r B : ast_p$],
  prem: ($A, B : ast_p$,),
  nota: [Позначення: $A arrow.r.double B$ замість $arrow.r.double (A, B)$],
)

#ax(
  (2),
  [$arrow.r.double "-in"(A, B, u) := u : A arrow.r.double B$],
  prem: ($u : A -> B$,),
  seealso: [(див. $(2)^ast$)],
)

#ax(
  (3),
  [$arrow.r.double "-el"(A, B, u, v) := u v : B$],
  prem: ($u : A arrow.r.double B | v : A$,),
)

Стратегія $(2)^ast$ для $arrow.r.double$-введення:

#grid(
  columns: (auto,),
  stroke: none,
  row-gutter: 0.25em,
  dots2(1),
  dots1(2),
  ln(4, [$x : A$], boxed: true),
  dots2(5),
  dots1(6),
  ln(4, [$a(dots.h.c, x) := dots.h.c : B$]),
  ln(1, [$b(dots.h.c) := lambda x : A . a(dots.h.c, x) : A arrow.r.double B$]),
)

*Абсурдність (пор. рис. 11.6)*

#ax(
  (4),
  [$bot := Pi A : ast_p . A : ast$],
)

#ax(
  (5),
  [$bot "-in"(A, u, v) := v u : bot$],
  prem: ($A : ast_p$, $u : A | v : A arrow.r.double bot$),
)

#ax(
  (6),
  [$bot "-el"(A, u) := u A : A$],
  prem: ($u : bot$,),
)

*Заперечення (пор. рис. 11.7)*

#ax(
  (7),
  [$not (A) := A arrow.r.double bot : ast_p$],
  prem: ($A : ast_p$,),
  nota: [Позначення: $not A$ замість $not (A)$],
)

#ax(
  (8),
  [$not "-in"(A, u) := u : not A$],
  prem: ($u : A -> bot$,),
)

#ax(
  (9),
  [$not "-el"(A, u, v) := u v : bot$],
  prem: ($u : not A | v : A$,),
)

*Кон'юнкція (пор. рис. 11.10)*

#ax(
  (10),
  [$and (A, B) := Pi C : ast_p . (A arrow.r.double B arrow.r.double C) arrow.r.double C : ast_p$],
  prem: ($A, B : ast_p$,),
  nota: [Позначення: $A and B$ замість $and (A, B)$],
)

#ax(
  (11),
  [$and "-in"(A, B, u, v) := lambda C : ast_p . lambda w : A arrow.r.double B arrow.r.double C . w u v : A and B$],
  prem: ($u : A | v : B$,),
)

#ax(
  (12),
  [$and "-el"_1 (A, B, u) := u A (lambda v : A . lambda w : B . v) : A$],
  prem: ($u : A and B$,),
)

#ax(
  (13),
  [$and "-el"_2 (A, B, u) := u B (lambda v : A . lambda w : B . w) : B$],
  prem: ($u : A and B$,),
)

*Диз'юнкція (пор. рис. 11.11)*

#ax(
  (14),
  [$or (A, B) := Pi C : ast . (A arrow.r.double C) arrow.r.double (B arrow.r.double C) arrow.r.double C : ast_p$],
  prem: ($A, B : ast_p$,),
  nota: [Позначення: $A or B$ замість $or (A, B)$],
)

#ax(
  (15),
  [$or "-in"_1 (A, B, u) := lambda C : ast_p . lambda v : A arrow.r.double C . lambda w : B arrow.r.double C . v u : A or B$],
  prem: ($u : A$,),
)

#ax(
  (16),
  [$or "-in"_2 (A, B, u) := lambda C : ast_p . lambda v : A arrow.r.double C . lambda w : B arrow.r.double C . w u : A or B$],
  prem: ($u : B$,),
)

#ax(
  (17),
  [$or "-el"(A, B, C, u, v, w) := u C v w : C$],
  prem: ($C : ast_p$, $u : A or B | v : A arrow.r.double C | w : B arrow.r.double C$),
)

*Біімплікація (пор. рис. 11.12)*

#ax(
  (18),
  [$arrow.l.r.double (A, B) := (A arrow.r.double B) and (B arrow.r.double A) : ast_p$],
  prem: ($A, B : ast_p$,),
  nota: [Позначення: $A arrow.l.r.double B$ замість $arrow.l.r.double (A, B)$],
)

#ax(
  (19),
  [$arrow.l.r.double "-in"(A, B, u, v) := and "-in"(A arrow.r.double B, B arrow.r.double A, u, v) : A arrow.l.r.double B$],
  prem: ($u : A arrow.r.double B | v : B arrow.r.double A$,),
)

#ax(
  (20),
  [$arrow.l.r.double "-el"_1 (A, B, u) := and "-el"_1 (A arrow.r.double B, B arrow.r.double A, u) : A arrow.r.double B$],
  prem: ($u : A arrow.l.r.double B$,),
)

#ax(
  (21),
  [$arrow.l.r.double "-el"_2 (A, B, u) := and "-el"_2 (A arrow.r.double B, B arrow.r.double A, u) : B arrow.r.double A$],
  prem: ($u : A arrow.l.r.double B$,),
)

== Класична логіка висловлювань

*Аксіома виключеного третього (пор. рис. 11.16)*

#ax(
  (22),
  [$"exc-thrd"(A) := #dblbot : A or not A$],
  prem: ($A : ast_p$,),
)

*Подвійне заперечення (пор. рис. 11.17)*

#ax(
  (23),
  [$not not "-in"(A, u) := lambda v : not A . v u : not not A$],
  prem: ($A : ast_p$, $u : A$),
)

#ax(
  (24),
  [$"doub-neg"(A) := dots.h.c quad "див. рис." 11.16 quad dots.h.c : not not A arrow.r.double A$],
)

#ax(
  (25),
  [$not not "-el"(A, u) := "doub-neg"(A) u : A$],
  prem: ($u : not not A$,),
)

*Альтернативи для диз'юнкції (пор. рис. 11.19)*

#ax(
  (26),
  [$or "-in-alt"_1 (A, B, u) := a_10 ["Рис." 11.18] (A, B, u) : A or B$],
  prem: ($A, B : ast_p$, $u : not A arrow.r.double B$),
  seealso: [(див. $(26)^ast$)],
)

#ax(
  (27),
  [$or "-in-alt"_2 (A, B, v) := dots.h.c quad "див. рис." 11.19 quad dots.h.c : A or B$],
  prem: ($v : not B arrow.r.double A$,),
)

#ax(
  (28),
  [$or "-el-alt"_1 (A, B, u, v) := a_5 ["Рис." 11.13] (A, B, u, v) : B$],
  prem: ($u : A or B$, $v : not A$),
)

#ax(
  (29),
  [$or "-el-alt"_2 (A, B, u, w) := dots.h.c quad "див. рис." 11.19 quad dots.h.c : A$],
  prem: ($w : not B$,),
)

Стратегія $(26)^ast$ для альтернативного $or$-введення, перша версія:

#grid(
  columns: (auto,),
  stroke: none,
  row-gutter: 0.25em,
  dots2(1),
  dots1(2),
  ln(4, [$x : not A$], boxed: true),
  dots2(5),
  dots1(6),
  ln(4, [$a(dots.h.c, x) := dots.h.c : B$]),
  ln(1, [$b(dots.h.c) := or "-in-alt"_1 (A, B, lambda x : not A . a(dots.h.c, x)) : A or B$]),
)

== Конструктивна логіка предикатів

*Універсальне квантифікування (пор. рис. 11.22)*

#ax(
  (30),
  [$forall (S, P) := Pi x : S . P x : ast_p$],
  prem: ($S : ast_s | P : S -> ast_p$,),
  nota: [Позначення: $forall x : S . P x$ замість $forall (S, P)$],
)

#ax(
  (31),
  [$forall "-in"(S, P, u) := u : forall x : S . P x$],
  prem: ($u : Pi x : S . P x$,),
  seealso: [(див. $(31)^ast$)],
)

#ax(
  (32),
  [$forall "-el"(S, P, u, v) := u v : P v$],
  prem: ($u : forall x : S . P x | v : S$,),
)

Стратегія $(31)^ast$ для $forall$-введення:

#grid(
  columns: (auto,),
  stroke: none,
  row-gutter: 0.25em,
  dots2(1),
  dots1(2),
  ln(4, [$x : S$], boxed: true),
  dots2(5),
  dots1(6),
  ln(4, [$a(dots.h.c, x) := dots.h.c : P x$]),
  ln(1, [$b(dots.h.c) := lambda x : S . a(dots.h.c, x) : forall x : S . P x$]),
)

*Екзистенціальне квантифікування (пор. рис. 11.23)*

#ax(
  (33),
  [$exists (S, P) := Pi A : ast_p . ((forall x : S . (P x arrow.r.double A)) arrow.r.double A) : ast_p$],
  prem: ($S : ast_s | P : S -> ast_p$,),
  nota: [Позначення: $exists x : S . P x$ замість $exists (S, P)$],
)

#ax(
  (34),
  [$exists "-in"(S, P, u, v) := lambda A : ast_p . lambda w : (forall x : S . (P x arrow.r.double A)) . w u v : exists x : S . P x$],
  prem: ($u : S | v : P u$,),
)

#ax(
  (35),
  [$exists "-el"(S, P, u, A, v) := u A v : A$],
  prem: ($u : exists x : S . P x | A : ast_p | v : forall x : S . (P x arrow.r.double A)$,),
  seealso: [(див. $(35)^ast$)],
)

Стратегія $(35)^ast$ для $exists$-вилучення:

#grid(
  columns: (auto,),
  stroke: none,
  row-gutter: 0.25em,
  dots2(2),
  dots1(3),
  ln(4, [$a(dots.h.c) := dots.h.c : exists x : S . P x$]),
  ln(6, [$x : S$], boxed: true),
  ln(6, [$u : P x$], boxed: true),
  dots2(7),
  dots1(8),
  ln(7, [$b(dots.h.c, x, u) := dots.h.c : A$]),
  ln(5, [$c(dots.h.c, x) := lambda u : P x . b(dots.h.c, x, u) : P x arrow.r.double A$]),
  ln(2, [$d(dots.h.c) := lambda x : S . c(dots.h.c, x) : forall x : S . (P x arrow.r.double A)$]),
  ln(2, [$e(dots.h.c) := exists "-el"(S, P, a(dots.h.c), A, d(dots.h.c)) : A$]),
)

== Класична логіка предикатів

*Альтернативи для екзистенціального квантифікування (пор. рис. 11.28)*

#ax(
  (36),
  [$exists "-in-alt"(S, P, u) := a_4 ["Рис." 11.27] (S, P, u) : exists x : S . P x$],
  prem: ($S : ast_s | P : S -> ast_p$, $u : not forall x : S . not (P x)$),
)

#ax(
  (37),
  [$exists "-el-alt"(S, P, u) := a_2 ["Рис." 11.25] (S, P, u) : not forall x : S . not (P x)$],
  prem: ($u : exists x : S . P x$,),
)
