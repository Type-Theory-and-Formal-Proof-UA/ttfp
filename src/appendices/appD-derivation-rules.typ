// Appendix D — "Derivation rules for λD" (original pp. 409–410).
#import "/book.typ": *

#set heading(numbering: (..n) => {
  let p = n.pos()
  if p.len() == 1 { "D" } else { "D." + p.slice(1).map(str).join(".") }
})
#counter(heading).update(0)

= Правила виведення для #ld

// ⊥⊥ — у друкованому оригіналі означник примітивного означення набрано двома
// символами ⊥; відтворюємо це як у оригіналі (пор. розділ 10).
#let dblbot = $bot #h(-0.12em) bot$

#rule(
  label: "(sort)",
  prem: none,
  conc: $emptyset ; emptyset tack.r ast : square$,
)

#rule(
  label: "(var)",
  prem: $Delta ; Gamma tack.r A : s$,
  conc: $Delta ; Gamma, x : A tack.r x : A$,
  side: [якщо $x in.not Gamma$],
)

#rule(
  label: "(weak)",
  prem: $Delta ; Gamma tack.r A : B quad Delta ; Gamma tack.r C : s$,
  conc: $Delta ; Gamma, x : C tack.r A : B$,
  side: [якщо $x in.not Gamma$],
)

#rule(
  label: "(form)",
  prem: $Delta ; Gamma tack.r A : s_1 quad Delta ; Gamma, x : A tack.r B : s_2$,
  conc: $Delta ; Gamma tack.r Pi x : A . B : s_2$,
)

#rule(
  label: "(appl)",
  prem: $Delta ; Gamma tack.r M : Pi x : A . B quad Delta ; Gamma tack.r N : A$,
  conc: $Delta ; Gamma tack.r M N : B[x := N]$,
)

#rule(
  label: "(abst)",
  prem: $Delta ; Gamma, x : A tack.r M : B quad Delta ; Gamma tack.r Pi x : A . B : s$,
  conc: $Delta ; Gamma tack.r lambda x : A . M : Pi x : A . B$,
)

#rule(
  label: "(conv)",
  prem: $Delta ; Gamma tack.r A : B quad Delta ; Gamma tack.r B' : s$,
  conc: $Delta ; Gamma tack.r A : B'$,
  side: [якщо $B =_(beta) B'$],
)

#rule(
  label: "(def)",
  prem: $Delta ; Gamma tack.r K : L quad Delta ; x : A tack.r M : N$,
  conc: $Delta , x : A triangle.r a(x) := M : N ; Gamma tack.r K : L$,
  side: [якщо $a in.not Delta$],
)

#rule(
  label: "(def-prim)",
  prem: $Delta ; Gamma tack.r K : L quad Delta ; x : A tack.r N : s$,
  conc: $Delta , x : A triangle.r a(x) := #dblbot : N ; Gamma tack.r K : L$,
  side: [якщо $a in.not Delta$],
)

#rule(
  label: "(inst)",
  prem: $Delta ; Gamma tack.r ast : square quad Delta ; Gamma tack.r U : A[x := U]$,
  conc: $Delta ; Gamma tack.r a(U) : N[x := U]$,
  side: [якщо $x : A triangle.r a(x) := M : N in Delta$],
)

#rule(
  label: "(inst-prim)",
  prem: $Delta ; Gamma tack.r ast : square quad Delta ; Gamma tack.r U : A[x := U]$,
  conc: $Delta ; Gamma tack.r a(U) : N[x := U]$,
  side: [якщо $x : A triangle.r a(x) := #dblbot : N in Delta$],
)

_Виведене правило:_

#rule(
  label: "(par)",
  prem: $Delta ; x : A tack.r M : N$,
  conc: $Delta, D ; x : A tack.r a(x) : N$,
  side: [якщо $D equiv x : A triangle.r a(x) := M : N$ і $a in.not Delta$],
)
