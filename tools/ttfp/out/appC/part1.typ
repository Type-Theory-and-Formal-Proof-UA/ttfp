#import "/book.typ": *

// Рядок прапорцевого виведення: `#fl(глибина, boxed: true, ...)` обгортає
// вміст у `глибина` прапорців (вертикальних рисок), за потреби — у рамку
// (декларація прапорця).
#let fl(depth, boxed: false, body) = {
  let b = if boxed { box(stroke: 0.5pt, inset: (x: 5pt, y: 2pt), body) } else { body }
  for _ in range(depth) {
    b = box(stroke: (left: 0.6pt), inset: (left: 7pt), width: 100%, b)
  }
  b
}

// Таблиця виведення: ліва колонка — номери рядків, права — рядки з відступами.
#let der(rows) = table(
  columns: (auto, 1fr),
  stroke: none,
  column-gutter: 0.8em,
  row-gutter: 0.35em,
  align: (right + horizon, left + top),
  ..rows,
)

У цьому додатку ми повторюємо два #(ld)-виведення, але тепер із повністю
розробленими «підказками». Ці приклади дають уявлення про те, з чим можна
зустрітися в цьому процесі.

== Замкненість відносно додавання в $NN$

Ми починаємо з повного доведення властивості замкненості додавання в $NN$, яке
відповідає рисунку 14.15. У логічних кроках ми застосовуємо правила
натурального виведення у #(ld)-форматі, підсумовані в додатку A. Ми не
користуємося скороченими версіями об'єктів доведення, як це пояснено в
підрозділах 11.5 і 11.10. Позначальні домовленості, як-от інфіксний запис,
збережено у #(ld)-виведенні, щоб тримати добрий огляд математичного тла.

#der((
  [], [$#fl(1, boxed: true)[$x : Z$]],
  [(1)], [$#fl(1)[$P(x) := lambda y : Z . (x + y epsilon N) : Z -> ast_p$]],
  [], [$#fl(2, boxed: true)[$u : x epsilon N$]],
  [(2)], [$#fl(2)[$"a"_2 (x, u) := "eq-sym"(Z, x + 0, x, "plus-i"(x)) : x = x + 0$]],
  [(3)], [$#fl(2)[$"a"_3 (x, u) := "eq-subs"(Z, N, x, x + 0, "a"_2 (x, u), u) : P(x) 0$]],
  [], [$#fl(3, boxed: true)[$y : Z$]],
  [], [$#fl(4, boxed: true)[$v : y epsilon N$]],
  [], [$#fl(5, boxed: true)[$w : P(x) y$]],
  [(4)], [$#fl(5)[$"a"_4 (x, u, y, v, w) := "clos-prop" (x + y) w : s(x + y) epsilon N$]],
  [(5)], [$#fl(5)[$"a"_5 (x, u, y, v, w) := "eq-sym"(Z, x + s y, s(x + y), "plus-ii"(x, y)) :$ \
      #h(1em) $s(x + y) = x + s y$]],
  [], [$#fl(5)[$dots.v$]],
  [(6)], [$#fl(5)[$"a"_6 (x, u, y, v, w) := "eq-subs"(Z, N, s(x + y), x + s y,$ \
      #h(1em) $"a"_5 (x, u, y, v, w), "a"_4 (x, u, y, v, w)) :$ \
      #h(2em) $P(x) (s y)$]],
  [(6a)], [$#fl(4)[$"a"_(6a) (x, u, y, v) := arrow.r.double "-in"(P(x) y, P(x) (s y),$ \
      #h(1em) $lambda w : P(x) y . "a"_6 (x, u, y, v, w)) :$ \
      #h(2em) $P(x) y arrow.r.double P(x) (s y)$]],
  [(6b)], [$#fl(3)[$"a"_(6b) (x, u, y) := arrow.r.double "-in"(y epsilon N, P(x) y arrow.r.double P(x) (s y),$ \
      #h(1em) $lambda v : y epsilon N . "a"_(6a) (x, u, y, v)) :$ \
      #h(2em) $y epsilon N arrow.r.double (P(x) y arrow.r.double P(x) (s y))$]],
  [(7)], [$#fl(2)[$"a"_7 (x, u) := forall "-in"(Z, lambda y : Z . (y epsilon N arrow.r.double (P(x) y arrow.r.double P(x) (s y))),$ \
      #h(1em) $lambda y : Z . "a"_(6b) (x, u, y)) :$ \
      #h(2em) $forall y : Z . (y epsilon N arrow.r.double (P(x) y arrow.r.double P(x)(s y)))$]],
  [(7a)], [$#fl(2)[$"a"_(7a) (x, u) := and "-in"(P(x) 0, forall y : Z . (y epsilon N arrow.r.double (P(x) y arrow.r.double P(x)(s y))),$ \
      #h(1em) $"a"_3 (x, u), "a"_7 (x, u)) :$ \
      #h(2em) $P(x) 0 and forall y : Z . (y epsilon N arrow.r.double (P(x) y arrow.r.double P(x)(s y)))$]],
  [(8)], [$#fl(2)[$"a"_8 (x, u) := "nat-ind" (P(x)) "a"_(7a) (x, u) :$ \
      #h(2em) $forall y : Z . (y epsilon N arrow.r.double x + y epsilon N)$]],
  [(8a)], [$#fl(1)[$"a"_(8a) (x) := arrow.r.double "-in"(x epsilon N, forall y : Z . (y epsilon N arrow.r.double x + y epsilon N),$ \
      #h(1em) $lambda u : x epsilon N . "a"_8 (x, u)) :$ \
      #h(2em) $x epsilon N arrow.r.double forall y : Z . (y epsilon N arrow.r.double x + y epsilon N)$]],
  [(9)], [$#fl(0)[$"a"_9 := forall "-in"(Z, lambda x : Z . (x epsilon N arrow.r.double forall y : Z . (y epsilon N arrow.r.double x + y epsilon N)),$ \
      #h(1em) $lambda x : Z . "a"_(8a) (x)) :$ \
      #h(2em) $forall x : Z . (x epsilon N arrow.r.double forall y : Z . (y epsilon N arrow.r.double x + y epsilon N))$]],
))

== Теорема про мінімум

Тепер ми даємо повне доведення теореми про мінімум (див. підрозділ 15.7).
Єдині неповноти, які ми дозволяємо, — це обґрунтування «передзнання», з якими
ми вже мали справу раніше в цій книжці: ці результати ми розглядаємо як
доведені факти.

Ми починаємо зі списку в #(ld)-форматі лем і вправ, які використовуються в
доведенні, опускаючи об'єкти доведень. Далі ми даємо розгорнуте доведення
теореми про мінімум як заповнення рисунків 15.16–15.18.

Ми користуємося позначувальними домовленостями, які описали й застосовували
раніше, зокрема вільно вживаючи інфіксні позначення (пор. розділ 12, зокрема
зауваження 12.4.1) і опускаючи незмінені списки параметрів у частині II (пор.
підрозділ 11.7).

У логічних кроках ми застосовуємо правила натурального виведення у #(ld)-форматі,
як описано в розділі 11 і підсумовано в додатку A. Щоб заощадити місце, ми
часто вживаємо «коротшу» версію термів доведення, що супроводжують ці правила,
як згадано в підрозділах 11.5 і 11.10.

=== I. Передзнання: леми та вправи

#der((
  [], [$#fl(1, boxed: true)[$A, B : ast_p$]],
  [(1)], [$#fl(1)[$"Exerc-7.5.(b)"(A, B) := dots.h.c : not (A arrow.r.double B) arrow.r.double (A and not B)$]],
  [], [$#fl(1, boxed: true)[$S : ast_s$]],
  [], [$#fl(2, boxed: true)[$P, Q, R : S -> ast_p$]],
  [(2)], [$#fl(2)[$"Exerc-7.10" (S, P, Q, R) := dots.h.c : (forall x : S . (P x arrow.r.double Q x)) arrow.r.double$ \
      #h(2em) $(forall y : S . (P y arrow.r.double R y)) arrow.r.double forall z : S . (P z arrow.r.double (Q z and R z))$]],
  [], [$#fl(2, boxed: true)[$P, Q : S -> ast_p$]],
  [(3)], [$#fl(2)[$"Exerc-7.13" (S, P, Q) := dots.h.c :$ \
      #h(2em) $(exists x : S . P x) arrow.r.double (forall y : S . (P y arrow.r.double Q y)) arrow.r.double exists z : S . Q z$]],
  [], [$#fl(2, boxed: true)[$P : S -> ast_p$]],
  [(4)], [$#fl(2)[$"Fig-11.29" (S, P) := dots.h.c : (not forall x : S . P x) arrow.r.double (exists y : S . not (P y))$]],
  [(5)], [$#fl(0)[$"Lem-14.8.4" := dots.h.c : forall x : Z . (x - x = 0)$]],
  [(6)], [$#fl(0)[$"Lem-14.8.6.(a)" := dots.h.c : forall x, y : Z . (x - s y = p(x - y))$]],
  [(7)], [$#fl(0)[$"Lem-14.10.1.(b)" := dots.h.c : forall x, y, z : Z . ((x lt.eq y and y lt.eq z) arrow.r.double x lt.eq z)$]],
  [], [$#fl(1, boxed: true)[$P : Z -> ast_p$]],
  [(8)], [$#fl(1)[$"Exerc-14.18" (P) := dots.h.c :$ \
      #h(2em) $((exists l : Z . P l) and forall x : Z . (P x arrow.r.double (P (s x) and P (p x)))) arrow.r.double forall x : Z . P x$]],
  [(9)], [$#fl(0)[$"Exerc-14.23.(b)" := dots.h.c : forall x : Z . (x gt p x)$]],
  [(10)], [$#fl(0)[$"Exerc-14.29.(b)" := dots.h.c : forall x, y : Z . (x lt y arrow.r.double s x lt.eq y)$]],
))

=== II. Повне доведення теореми про мінімум

#der((
  [], [$#fl(1, boxed: true)[$T : "ps"(Z) | u : T eq.not emptyset_Z | v : exists x : Z . "lw-bnd"_Z (T, x)$]],
  [(1)], [$#fl(1)[$"a"_1 := "a"_6^("[рис. 13.8]") (Z, T, u) : exists n : Z . n epsilon T$]],
  [], [$#fl(2, boxed: true)[$l : Z | "ass"_1 : "lw-bnd"_Z (T, l)$]],
  [], [$#fl(3, boxed: true)[$n : Z | "ass"_2 : n epsilon T$]],
  [(2)], [$#fl(3)[$P := lambda x : Z . "lw-bnd"_Z (T, x) : Z -> ast_p$]],
  [(3)], [$#fl(3)[$"a"_3 := exists "-in"(Z, P, l, "ass"_1) : exists x : Z . P x$]],
  [], [$#fl(4, boxed: true)[$"ass"_3 : forall x : Z . (P x arrow.r.double P (s x))$]],
  [], [$#fl(5, boxed: true)[$x : Z | "ass"_4 : P x$]],
  [(4)], [$#fl(5)[$"a"_4 := and "-el"_1 (p x lt.eq x, p x eq.not x, "Exerc-14.23.(b)" x) : p x lt.eq x$]],
  [], [$#fl(6, boxed: true)[$t : Z | "ass"_5 : t epsilon T$]],
  [(5)], [$#fl(6)[$"a"_5 := "ass"_4 t "ass"_5 : x lt.eq t$]],
  [(5a)], [$#fl(6)[$"a"_(5a) := and "-in"(p x lt.eq x, x lt.eq t, "a"_4, "a"_5) := p x lt.eq x and x lt.eq t$]],
  [(6)], [$#fl(6)[$"a"_6 := "Lem-14.10.1.(b)" (p x) x t "a"_(5a) : p x lt.eq t$]],
  [(7)], [$#fl(5)[$"a"_7 := lambda t : Z . lambda "ass"_5 : (t epsilon T) . "a"_6 : P (p x)$]],
  [(8)], [$#fl(4)[$"a"_8 := lambda x : Z . lambda "ass"_4 : P x . "a"_7 : forall x : Z . (P x arrow.r.double P (p x))$]],
  [(9)], [$#fl(4)[$"a"_9 := "Exerc-7.10" (Z, P, lambda x : Z . P (s x), lambda x : Z . P (p x)) "ass"_3 "a"_8 :$ \
      #h(2em) $forall x : Z . (P x arrow.r.double (P (s x) and P (p x)))$]],
  [(9a)], [$#fl(4)[$"a"_(9a) := and "-in"(exists x : Z . P x,$ \
      #h(2em) $forall x : Z . (P x arrow.r.double (P (s x) and P (p x))), "a"_3, "a"_9) :$ \
      #h(4em) $(exists x : Z . P x) and forall x : Z . (P x arrow.r.double (P (s x) and P (p x)))$]],
  [(10)], [$#fl(4)[$"a"_(10) := "Exerc-14.18"(P) "a"_(9a) : forall x : Z . P x$]],
  [(11)], [$#fl(4)[$"a"_(11) := "a"_(10) (s n) : P (s n)$]],
  [(12)], [$#fl(4)[$"a"_(12) := "a"_(11) n "ass"_2 : s n lt.eq n$]],
  [(12a)], [$#fl(4)[$"a"_(12a) := "eq-subs"(Z, lambda x : Z . (x epsilon N), n - s n, p(n - n),$ \
      #h(2em) $"Lem-14.8.6.(a)" n n, "a"_(12)) : p(n - n) epsilon N$]],
  [(12b)], [$#fl(4)[$"a"_(12b) := "eq-subs"(Z, lambda x : Z . (p x epsilon N), n - n, 0,$ \
      #h(2em) $"Lem-14.8.4" n, "a"_(12a)) : p 0 epsilon N$]],
  [(13)], [$#fl(4)[$"a"_(13) := "ax-int"_3 "a"_(12b) : bot$]],
  [(13a)], [$#fl(3)[$"a"_(13a) := lambda "ass"_3 : (forall x : Z . (P x arrow.r.double P (s x))) . "a"_(13) :$ \
      #h(2em) $not forall x : Z . (P x arrow.r.double P (s x))$]],
  [(13b)], [$#fl(3)[$"a"_(13b) := "Fig-11.29" (Z, lambda y : Z . (P y arrow.r.double P (s y))) "a"_(13a) :$ \
      #h(3em) $exists x : Z . not (P x arrow.r.double P (s x))$]],
  [(13c)], [$#fl(3)[$"a"_(13c) := lambda y : Z . "Exerc-7.5.(b)"(P y, P (s y)) :$ \
      #h(3em) $forall y : Z . (not (P y arrow.r.double P (s y)) arrow.r.double (P y and not P (s y)))$]],
  [(14)], [$#fl(3)[$"a"_(14) := "Exerc-7.13" (Z, lambda x : Z . not (P x arrow.r.double P (s x)),$ \
      #h(2em) $lambda z : Z . (P z and not P (s z))) "a"_(13b) "a"_(13c) :$ \
      #h(3em) $exists z : Z . ("lw-bnd"_Z (T, z) and not "lw-bnd"_Z (T, s z))$]],
  [], [$#fl(4, boxed: true)[$z : Z | "ass"_6 : ("lw-bnd"_Z (T, z) and not "lw-bnd"_Z (T, s z))$]],
  [(15)], [$#fl(4)[$"a"_(15) := and "-el"_1 ("lw-bnd"_Z (T, z), not "lw-bnd"_Z (T, s z), "ass"_6) :$ \
      #h(3em) $"lw-bnd"_Z (T, z)$]],
  [(16)], [$#fl(4)[$"a"_(16) := and "-el"_2 ("lw-bnd"_Z (T, z), not "lw-bnd"_Z (T, s z), "ass"_6) :$ \
      #h(3em) $not "lw-bnd"_Z (T, s z)$]],
  [], [$#fl(5, boxed: true)[$"ass"_7 : not (z epsilon T)$]],
  [], [$#fl(6, boxed: true)[$y : Z | "ass"_8 : y epsilon T$]],
  [(17)], [$#fl(6)[$"a"_(17) := "a"_(15) y "ass"_8 : z lt.eq y$]],
  [], [$#fl(7, boxed: true)[$"ass"_9 : z = y$]],
  [(18)], [$#fl(7)[$"a"_(18) := "eq-subs"(Z, lambda x : Z . not (x epsilon T), z, y, "ass"_9, "ass"_7) "ass"_8 :$ \
      #h(4em) $bot$]],
  [(19)], [$#fl(6)[$"a"_(19) := lambda "ass"_9 : (z = y) . "a"_(18) : not (z = y)$]],
  [(20)], [$#fl(6)[$"a"_(20) := and "-in"(z lt.eq y, not (z = y), "a"_(17), "a"_(19)) : z lt y$]],
  [(21)], [$#fl(6)[$"a"_(21) := "Exerc-14.29.(b)" z y "a"_(20) : s z lt.eq y$]],
  [(22)], [$#fl(5)[$"a"_(22) := lambda y : Z . lambda "ass"_8 : (y epsilon T) . "a"_(21) : "lw-bnd"_Z (T, s z)$]],
  [(23)], [$#fl(5)[$"a"_(23) := "a"_(16) "a"_(22) : bot$]],
  [(24)], [$#fl(4)[$"a"_(24) := not not "-el" (z epsilon T, lambda "ass"_7 : not (z epsilon T) . "a"_(23)) : z epsilon T$]],
  [(25)], [$#fl(4)[$"a"_(25) := and "-in"(z epsilon T, "lw-bnd"_Z (T, z), "a"_(24), "a"_(15)) : "least"_Z (T, z)$]],
  [(26)], [$#fl(4)[$"a"_(26) := exists "-in"(Z, lambda y : Z . "least"_Z (T, y), z, "a"_(25)) :$ \
      #h(3em) $exists m : Z . "least"_Z (T, m)$]],
  [(27)], [$#fl(3)[$"a"_(27) := exists "-el" (Z, lambda x : Z . ("lw-bnd"_Z (T, z) and not "lw-bnd"_Z (T, s z)), "a"_(14),$ \
      #h(2em) $exists m : Z . "least"_Z (T, m),$ \
      #h(3em) $lambda z : Z . lambda "ass"_6 : ("lw-bnd"_Z (T, z) and not "lw-bnd"_Z (T, s z)) . "a"_(26)) :$ \
      #h(3em) $exists m : Z . "least"_Z (T, m)$]],
  [(28)], [$#fl(2)[$"a"_(28) := exists "-el" (Z, lambda x : Z . (x epsilon T), "a"_1, exists m : Z . "least"_Z (T, m),$ \
      #h(2em) $lambda n : Z . lambda "ass"_2 : (n epsilon T) . "a"_(27)) :$ \
      #h(3em) $exists m : Z . "least"_Z (T, m)$]],
  [(29)], [$#fl(1)[$"min-the"(T, u, v) := exists "-el" (Z, lambda x : Z . "lw-bnd"_Z (T, x), v,$ \
      #h(2em) $exists m : Z . "least"_Z (T, m), lambda l : Z . lambda "ass"_1 : "lw-bnd"_Z (T, l) . "a"_(28)) :$ \
      #h(3em) $exists m : Z . "least"_Z (T, m)$]],
))
