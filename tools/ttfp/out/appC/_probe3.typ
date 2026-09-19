#import "/book.typ": *

$ {x : S | B} quad {emptyset, {emptyset}, {{emptyset}}, dots.h.c} $

$ T eq.not emptyset_Z quad x in.not Gamma quad a in.not Delta quad M equiv.not N $

$ V union emptyset_S = V quad V inter W quad V \\ W quad V^c quad full-set(S) $

$ G compose F quad union.big_(z : T) (F z) quad lr(angle.l a, q angle.r) quad Sigma x : S . P x $

$ pi_1 K quad pi_2 K quad "ps"(S) := S -> ast_p : square quad "lw-bnd"_Z (T, x) quad "least"_Z(T,z) $

$ and "-in"(A, B, u, v) quad arrow.r.double "-in"(A, B, u) quad not not "-el"(A, u) quad exists "-el"(S, P, u, A, v) $

$ a_6^("[рис. 13.8]") (Z, T, u) quad "Exerc-7.5.(b)"(A,B) quad "Lem-14.8.4" quad dots.h.c $

$ forall x : S . ((x epsilon V^c) arrow.r.double.long not (x epsilon V)) quad P_S (T) quad "P"_S(T) $

Test $union.big$ symbol and $sect$ and $subset.eq$ and $lt.eq$ and $gt.eq$ and $:=$.

#rule(
  label: $("Sigma"-"form")$,
  prem: $Delta ; Gamma tack.r S : ast_s quad Delta ; Gamma, x : S tack.r B : ast_p$,
  conc: $Delta ; Gamma tack.r Sigma x : S . B : ast_s$,
)

#rule(
  label: $(upright("PVS"))$,
  prem: $M : S quad N : B[x := N]$,
  conc: $M : {x : S | B}$,
)

#exercise[
  Нехай $S : ast_s$ і $V : "ps"(S)$. Доведіть у #ld: $V union V^c = "full-set"(S)$.
]
