#import "/book.typ": *

#let flagcol(depth, body) = {
  let b = body
  for _ in range(depth) {
    b = box(stroke: (left: 0.6pt), inset: (left: 7pt), b)
  }
  b
}

== Вправи

#exercise[
  У підрозділі 8.7 ми дали ім'я $p(m, n, u)$ доведенню твердження

  #align(center)[$ exists x, y : ZZ . (m x + n y = 1) $]

  у контексті $Gamma equiv m : NN^+, n : NN^+, u : "coprime"(m, n)$.

  Припустімо, що ми побудували в контексті $m : NN^+, n : NN^+$ доведення (тобто
  мешканця) $q(m, n)$ твердження

  #align(center)[$ "coprime"(m, n) arrow.r.double "coprime"(n, m) . $]

  Знайдіть мешканця $exists x, y : ZZ . (n x + m y = 1)$ у контексті $Gamma$.
]

#exercise[
  Формальний текст, наведений нижче у прапорцевому форматі, стосується низки добре
  відомих понять аналізу й містить деякі твердження з пропущеними доведеннями.

  // В оригіналі рядок (4) надруковано без закривальної дужки; відтворюємо як в оригіналі.
  #align(center)[
    #text(size: 9pt)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 1.2em,
        row-gutter: 0.6em,
        align: (right + horizon, left),
        [], flagcol(1)[$V : ast_s$],
        [], flagcol(2)[$u : V subset.eq RR$],
        [$(1)$], flagcol(2)[
          #grid(
            columns: 1,
            row-gutter: 0.3em,
            align: left,
            [$"bounded-from-above"(V, u) :=$],
            [$quad exists y : RR . forall x : RR . (x in V arrow.r.double x lt.eq y) : ast_p$],
          )
        ],
        [], flagcol(3)[$s : RR$],
        [$(2)$], flagcol(3)[
          $"upper-bound"(V, u, s) := forall x : RR . (x in V arrow.r.double x lt.eq s) : ast_p$
        ],
        [$(3)$], flagcol(3)[
          #grid(
            columns: 1,
            row-gutter: 0.3em,
            align: left,
            [$"least-upper-bound"(V, u, s) := "upper-bound"(V, u, s) and$],
            [$quad forall x : RR . (x < s arrow.r.double not "upper-bound"(V, u, x)) : ast_p$],
          )
        ],
        [], flagcol(3)[$v : V eq.not emptyset$],
        [], flagcol(4)[$w : "bounded-from-above"(V, u)$],
        [$(4)$], flagcol(4)[
          $p_4(V, u, v, w) := dots.h.c : exists_1 s : RR . ("least-upper-bound"(V, u, s)$
        ],
        [$(5)$], flagcol(1)[
          $S := {x : RR | exists n : RR . (n in NN and x = frac(n, n+1))} : ast_s$
        ],
        [$(6)$], flagcol(1)[$p_6 := dots.h.c : S subset.eq RR$],
        [$(7)$], flagcol(1)[$p_7 := dots.h.c : "bounded-from-above"(S, p_6)$],
        [$(8)$], flagcol(1)[$p_8 := dots.h.c : "least-upper-bound"(S, p_6, 1)$],
      )
    ]
  ]

  #enum(
    numbering: "(a)",
    [Перекладіть текст у звичніший формат, як це могло б бути в підручнику.
      (Зауваження: $exists_1$ виражає єдиність існування; «існує рівно один . . . ».)],
    [Які з восьми рядків є формалізованими означеннями? Які є формалізованими
      математичними твердженнями?],
    [Які константи введено в тексті, а які константи буде введено раніше?],
    [Підкресліть усі інстанціації списків параметрів у формальному тексті та точно
      поясніть, що чим було проінстанційовано і чому це правильно.],
  )
]

#exercise[
  Розгляньте формальний текст із вправи 8.2. Опишіть частковий порядок, який подає
  залежності між означеннями, наведеними в цьому тексті. (Пор. кінець підрозділу 8.5.)
]

#exercise[
  Наведений нижче формальний текст у прапорцевому форматі стосується деяких добре
  відомих понять алгебри, де «op» означає бінарну операцію на $S$ у каррізованій формі
  (пор. зауваження 1.2.6).

  #align(center)[
    #text(size: 9pt)[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 1.2em,
        row-gutter: 0.6em,
        align: (right + horizon, left),
        [], flagcol(1)[$S : ast_s$],
        [], flagcol(2)[$"op" : S arrow.r S arrow.r S$],
        [$(1)$], flagcol(2)[
          #grid(
            columns: 1,
            row-gutter: 0.3em,
            align: left,
            [$"semigroup"(S, "op") :=$],
            [$quad forall x, y, z : S . ("op" x ("op" y z) = "op" ("op" x y) z) : ast_p$],
          )
        ],
        [], flagcol(3)[$u : "semigroup"(S, "op")$],
        [], flagcol(4)[$e : S$],
        [$(2)$], flagcol(4)[
          $"unit"(S, "op", u, e) := forall x : S . ("op" x e = x and "op" e x = x) : ast_p$
        ],
        [$(3)$], flagcol(4)[
          $"monoid"(S, "op", u) := exists e : S . ("unit"(S, "op", u, e)) : ast_p$
        ],
        [], flagcol(4)[$e_1, e_2 : S$],
        [$(4)$], flagcol(4)[
          #grid(
            columns: 1,
            row-gutter: 0.3em,
            align: left,
            [$p_4(S, "op", u, e_1, e_2) :=$],
            [$quad dots.h.c : ("unit"(S, "op", u, e_1) and "unit"(S, "op", u, e_2)) arrow.r.double e_1 = e_2$],
          )
        ],
      )
    ]
  ]

  #enum(
    numbering: "(a)",
    [Перекладіть текст у звичніший формат, як це могло б бути в підручнику. Де доречно,
      скористайтеся інфіксним позначенням.],
    [Підкресліть усі змінні, зв'язані зі зв'язувальною змінною, введеною в тексті.],
    [Перепишіть рядки (1) і (2) у форматі $Gamma tack.r a(dots.h.c) := M : N$, як
      описано в підрозділі 8.5.],
  )
]

#exercise[
  Визначте означення в наведеному нижче тексті та перепишіть текст у формальній формі,
  використовуючи винятково формат означень, як показано на рисунку 8.8. Припустіть, що
  $RR$ — тип. Скористайтеся прапорцевим форматом і позначенням множини
  ${x : RR | P x}$.

  #block(inset: (left: 1.5em))[
    «Дійсне число $r$ є раціональним, якщо існують цілі числа $p$ і $q$ з
    $q eq.not 0$ такі, що $r = p\/q$. Дійсне число, яке не є раціональним, називається
    ірраціональним. Множину всіх раціональних чисел називають $QQ$. Кожне натуральне
    число є раціональним. Число $0.75$ є раціональним, але $sqrt(2)$ — ірраціональне.»
  ]
]

#exercise[
  Розгляньте такий математичний текст:

  #block(inset: (left: 1.5em))[
    «Якщо $k$, $l$ і $m$ — цілі числа, причому $m$ додатне, то кажуть, що $k$
    конгруентне до $l$ за модулем $m$, якщо $m$ ділить $k - l$. Ми пишемо
    $k equiv l ("mod" m)$, щоб указати, що $k$ конгруентне до $l$ за модулем $m$.

    Отже, $-3 equiv 17 ("mod" 5)$, але не $-3 equiv -17 ("mod" 5)$.

    Якщо $k equiv l ("mod" m)$, то також $l equiv k ("mod" m)$.

    $k equiv l ("mod" m)$ тоді й лише тоді, коли існує ціле число $u$ таке, що
    $k = l + u m$.»
  ]

  #enum(
    numbering: "(a)",
    [Перепишіть тексти у формальній формі як список означень. Припустіть, що $ZZ$ — тип.
      Скористайтеся прапорцевим форматом. Формалізуйте $k equiv l ("mod" m)$ як
      $"eqv"(k, l, m, u)$, де $u$ — доведення того, що $m$ додатне.],
    [Укажіть області дії всіх змінних і констант, введених у формальному тексті.],
    [Визначте всі інстанціації списків параметрів, уведених у формальному тексті, і
      перевірте, чи дотримано умов типізації.],
  )
]
