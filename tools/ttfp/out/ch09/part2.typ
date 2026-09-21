#import "/book.typ": *

== Вправи

#exercise[
  Розгляньте середовище $Delta equiv D_1, D_2, D_3, D_4$ з підрозділу 9.6. Опишіть
  залежності між чотирма означеннями та наведіть усі можливі лінеаризації
  відповідного часткового порядку.
]

#exercise[
  Розгляньте такі два означення, $D_i$ і $D_j$:
  $ x : A triangle.r a(x) := K : L, $
  $ y : B triangle.r b(y) := M : N. $

  Нехай $Delta ; Gamma tack.r U : V$ і припустімо, що $D_i$ та $D_j$ є елементами
  списку $Delta$, де $D_i$ передує $D_j$.

  (a) Опишіть точно, де константа $a$ може зустрічатися в $D_i$ та $D_j$.

  (b) Опишіть, де константа $b$ може зустрічатися в $Delta$.
]

#exercise[
  Текст у вправі 8.2 містить вісім нових означень. Нехай $Delta$ — відповідне
  середовище. Перепишіть тип у рядку (8) так, щоб усі означення з $Delta$ було
  розгорнуто.
]

#exercise[
  Див. підрозділ 9.6. Нехай $Delta equiv D_1, dots.h.c, D_4$.

  Наведіть повну діаграму δ-редукції виразу $c(a(u, v), b(w, w))$.
]

#exercise[
  Перевірте, що всі інстанціації параметрів констант, означених і вжитих у
  вправі 8.2, задовольняють вимоги, накладені правилом (inst).
]

#exercise[
  Розгляньте таке середовище $Delta$ із шести означень, у якому ми задля зручності
  вживаємо деякі добре знані формати, як-от $Sigma$- та інфіксні позначення:

  $ D_1 equiv f : NN -> RR, n : NN triangle.r a_1 (f, n) := sum_(i=0)^n (f i) : RR, $

  $ D_2 equiv f : NN -> RR, d : RR triangle.r a_2 (f, d) := forall n : NN (f (n+1) - f n = d) : ast_p, $

  $ D_3 equiv f : NN -> RR, d : RR, u : a_2 (f, d), n : NN triangle.r $
  $ quad a_3 (f, d, u, n) := "formalprf"_3 : f n = f 0 + n dot d, $

  $ D_4 equiv f : NN -> RR, d : RR, u : a_2 (f, d), n : NN triangle.r $
  $ quad a_4 (f, d, u, n) := "formalprf"_4 : a_1 (f, n) = 1/2 dot (n+1) dot (f 0 + f n), $

  $ D_5 equiv f : NN -> RR, d : RR, u : a_2 (f, d), n : NN triangle.r $
  $ quad a_5 (f, d, u, n) := "formalprf"_5 : $
  $ quad quad a_1 (f, n) = (n + 1) dot f 0 + 1/2 dot n dot (n + 1) dot d, $

  $ D_6 equiv emptyset triangle.r a_6 := "formalprf"_6 : sum_(i=0)^100 (i) = 5050. $

  Припустімо, що $"formalprf"_3$ до $"formalprf"_6$ — це метатерми, які стоять
  замість справжніх термів доведень.

  (a) Перепишіть це середовище в прапорцевому форматі.

  (b) Яку назву вживають для $a_2$ у стандартній літературі?

  (c) Знайдіть δ-нормальну форму щодо $Delta$ виразу
      $a_5 (lambda x : NN . 2x, 2, u, 100)$, де $u$ — мешканець
      $a_2 (lambda x : NN . 2x, 2)$.
]

#exercise[
  Ми називаємо означення $D$ *правильним у середовищі* $Delta$, якщо
  $Delta, D ; emptyset tack.r ast : square$. Розгляньте $D_1$ до $D_6$ як у
  вправі 9.6.

  (a) За якої умови можна вивести, що $D_1$ правильне в середовищі $emptyset$?

  (b) Як довести, що $D_2$ правильне в середовищі $D_1$?

  (c) Те саме питання для $D_3$ в середовищі $D_1, D_2$.
]

#exercise[
  Див. вправи 9.6 і 9.7.

  (a) Нехай $Delta equiv D_1, dots.h.c, D_5$. Припустімо, що $D_6$ правильне в
      середовищі $Delta$ і що
      $Delta ; emptyset tack.r (a_1 (lambda x : NN . x, 100) = (lambda x : NN . x)^5050) : ast_p$.
      Виведіть:
      $ Delta ; emptyset tack.r "formalprf"_6 : a_1 (lambda x : NN . x, 100) = (lambda x : NN . x)^5050 . $

  (b) Припустімо, що умови, згадані у вправі 9.7(a), виконано. Який
      найшвидший спосіб довести
      $ D_1 ; f : NN -> RR, n : NN tack.r a_1 (f, n) : RR ? $
]

#exercise[
  Нехай $Gamma equiv A : ast, B : ast, C : ast$. Доведіть, навівши повні виведення
  в #ld0:

  (a) $emptyset ; Gamma tack.r ast : square$,

  (b) $emptyset ; Gamma tack.r A : ast$,

  (c) $emptyset ; Gamma tack.r B : ast$,

  (d) $emptyset ; Gamma tack.r C : ast$.
]

#exercise[
  Нехай $J_1, dots.h.c, J_n$ — судження такі, що, перелічені в цьому порядку, вони
  утворюють виведення. Нехай
  $ J_n equiv Delta_n ; Gamma_n tack.r M_n : N_n | J_n $
  — останнє судження в цьому виведенні, де $J_n$ — його обґрунтування в #ld0.

  Припустімо, що для всіх $i < j$: якщо $J_i equiv Delta_i ; Gamma_i tack.r M_i : N_i$,
  то $Delta_i ; Gamma_i tack.r ast : square$.

  (a) Нехай $J_n$ — випадок застосування правила (weak). Доведіть, що
      $Delta_n ; Gamma_n tack.r ast : square$.

  (b) Те саме, якщо $J_n$ — випадок застосування правила (var).

  (c) Те саме, якщо $J_n$ — випадок застосування правила (def).

  (d) Те саме, якщо $J_n$ — випадок застосування одного з інших правил #ld0, як
      подано на рисунку 9.3.
]
