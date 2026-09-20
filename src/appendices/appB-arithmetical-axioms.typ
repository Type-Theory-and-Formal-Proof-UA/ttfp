// Appendix B — "Arithmetical axioms, definitions and lemmas" (original p. 397).
#import "/book.typ": *
#set heading(numbering: (..n) => {
  let p = n.pos()
  if p.len() == 1 { "B" } else { "B." + p.slice(1).map(str).join(".") }
})
#counter(heading).update(0)

= Арифметичні аксіоми, означення та леми

Нижче наведено аксіоми, означення та леми, що стосуються арифметики в $ZZ$ та
її підмножині $NN$, як їх сформульовано в розділі 14.

#axiom(label: [])[
  $s$ --- бієкція (ax-int 1).
]

#lemma(label: [])[
  (a) $s$ --- ін'єкція (inj-suc), \
  (b) $s$ --- сюр'єкція (surj-suc).
]

#lemma(label: [])[
  (a) $forall y : ZZ . (s(p y) = y)$ (s-p-ann), \
  (b) $forall y : ZZ . (p(s y) = y)$ (p-s-ann).
]

#axiom(label: [])[
  Для всіх $P : ZZ -> ast_p$,
  $[P 0 and forall x : ZZ . (P x arrow.r.double (P (s x) and P (p x)))] arrow.r.double forall x : ZZ . P x$
  (ax-int 2, симетрична індукція для $ZZ$).
]

#definition(label: [])[
  (a) Для $P : ZZ -> ast_p$, $upright("nat-cond")(P) := P 0 and forall x : ZZ . (P x arrow.r.double P (s x))$, \
  (b) $NN := lambda x : ZZ . Pi P : ZZ -> ast_p . (upright("nat-cond")(P) arrow.r.double P x)$.
]

#lemma(label: [])[
  (a) $0 epsilon NN$ (zero-prop), \
  (b) $forall x : ZZ . (x epsilon NN arrow.r.double s x epsilon NN)$ (clos-prop), \
  (c) $Pi Q : ZZ -> ast_p . (upright("nat-cond")(Q) arrow.r.double (NN subset.eq Q))$ (nat-smallest).
]

#axiom(label: [])[
  $not (p 0 epsilon NN)$ (ax-int 3).
]

#lemma(label: [])[
  (a) $forall x : ZZ . (x epsilon NN arrow.r.double not (s x = 0))$ (nat-prop 1), \
  (b) $forall x, y : ZZ . (x epsilon NN arrow.r.double (y epsilon NN arrow.r.double (s x = s y arrow.r.double x = y)))$ (nat-prop 2).
]

#lemma(label: [])[
  Для всіх $P : ZZ -> ast_p$,
  $[P 0 and forall x : ZZ . (x epsilon NN arrow.r.double (P x arrow.r.double P (s x)))] arrow.r.double forall x : ZZ . (x epsilon NN arrow.r.double P x)$
  (nat-ind, індукція для $NN$).
]

#lemma(label: "14.3.1")[
  $forall x : ZZ . (x epsilon NN arrow.r.double (x = 0 or p x epsilon NN))$.
]

#definition(label: [])[
  Для $x : ZZ$: \
  (a) $upright("pos")(x) := p x epsilon NN$, \
  (b) $upright("neg")(x) := not (x in NN)$.
]

#lemma(label: [])[
  (a) $forall x : ZZ . (x epsilon NN arrow.r.double (x = 0 or p x epsilon NN))$ (nat-split), \
  (b) $forall x : ZZ . (not (x epsilon NN) or x = 0 or p x epsilon NN)$ (nat-split-alt), \
  (c) $forall x : ZZ . (upright("neg")(x) or x = 0 or upright("pos")(x))$ (trip).
]

#lemma(label: "14.3.2")[
  (a) $forall x : ZZ . (upright("pos")(s x) arrow.r.double.long x epsilon NN)$, \
  (b) $forall x : ZZ . (upright("pos")(s x) arrow.r.double.long (x = 0 or upright("pos")(x)))$, \
  (c) $forall x : ZZ . (upright("neg")(p x) arrow.r.double.long (x = 0 or upright("neg")(x)))$.
]

#lemma(label: "14.3.3")[
  (a) $forall x : ZZ . (upright("pos")(x) arrow.r.double.long x eq.not 0 and not upright("neg")(x))$, \
  (b) $forall x : ZZ . (upright("neg")(x) arrow.r.double.long x eq.not 0 and not upright("pos")(x))$, \
  (c) $forall x : ZZ . (x = 0 arrow.r.double.long not upright("pos")(x) and not upright("neg")(x))$.
]

#lemma(label: [])[
  (a) $forall x : ZZ . (x + 0 = x)$ (plus-i), \
  (b) $forall x, y : ZZ . (x + s y = s(x + y))$ (plus-ii), \
  (c) $forall x, y : ZZ . (x + p y = p(x + y))$ (plus-iii).
]

#lemma(label: "14.6.1")[
  (a) $forall x : ZZ . (0 + x = x)$ (plus-i-alt, рис. 14.14), \
  (b) $forall x, y : ZZ . (s x + y = s(x + y))$ (plus-ii-alt, рис. 14.14), \
  (c) $forall x, y : ZZ . (p x + y = p(x + y))$ (plus-iii-alt, рис. 14.14).
]

#lemma(label: "14.6.2")[
  $forall x, y : ZZ . (x + y = y + x)$ (comm-add, рис. 14.14).
]

#lemma(label: "14.6.3")[
  (a) $forall x, y : ZZ . (p x + s y = x + y)$, \
  (b) $forall x, y : ZZ . (s x + p y = x + y)$.
]

#lemma(label: "14.6.4")[
  $forall x, y, z : ZZ . (x + (y + z) = (x + y) + z)$ (assoc-add, рис. 14.14).
]

#lemma(name: "Закони скорочення для додавання", label: [])[
  (a) $forall x, y, z : ZZ . (x + z = y + z arrow.r.double x = y)$ (right-canc-add, рис. 14.14), \
  (b) $forall x, y, z : ZZ . (x + y = x + z arrow.r.double y = z)$ (left-canc-add, рис. 14.14).
]

#lemma(name: "Замкненість ℕ відносно додавання", label: [])[
  $forall x, y : ZZ . ((x epsilon NN and y epsilon NN) arrow.r.double x + y epsilon NN)$ (plus-clos-nat, рис. 14.15).
]

#lemma(name: "Характеризація від'ємних чисел", label: [])[
  $forall x : ZZ . (upright("neg")(x) arrow.r.double.long exists y : ZZ . (upright("pos")(y) and x + y = 0))$.
]

#lemma(name: "Замкненість для від'ємних цілих чисел", label: [])[
  $forall x, y : ZZ . (upright("neg")(x) and upright("neg")(y) arrow.r.double upright("neg")(x + y))$.
]

#lemma(name: "Єдиність різниці", label: [])[
  $forall x, y : ZZ . exists_1 z : ZZ . (z + y = x)$ (uni-dif, рис. 14.16).
]

#lemma(label: "14.8.2")[
  $forall x, y : ZZ . ((x - y) + y = x)$ (subtr-prop 1, рис. 14.16).
]

#lemma(label: "14.8.3")[
  $forall x, y : ZZ . ((x + y) - y = x)$ (subtr-prop 2, рис. 14.16).
]

#lemma(label: "14.8.4")[
  $forall x : ZZ . (x - x = 0)$.
]

#lemma(label: "14.8.5")[
  $forall x : ZZ . (x - 0 = x)$.
]

#lemma(label: "14.8.6")[
  (a) $forall x, y : ZZ . (x - s y = p(x - y))$, \
  (b) $forall x, y : ZZ . (x - p y = s(x - y))$.
]

#lemma(label: "14.8.7")[
  (a) $forall x, y : ZZ . (s x - y = s(x - y))$, \
  (b) $forall x, y : ZZ . (p x - y = p(x - y))$.
]

#lemma(label: "14.8.8")[
  (a) $forall x : ZZ . (x + 1 = s x)$, \
  (b) $forall x : ZZ . (x - 1 = p x)$.
]

#lemma(name: "Закони скорочення для віднімання", label: [])[
  (a) $forall x, y, z : ZZ . (x - z = y - z arrow.r.double x = y)$, \
  (b) $forall x, y, z : ZZ . (x - y = x - z arrow.r.double y = z)$.
]

#lemma(label: "14.8.10")[
  (a) $forall x, y, z : ZZ . (x + (y - z) = (x + y) - z)$, \
  (b) $forall x, y, z : ZZ . (x - (y + z) = (x - y) - z)$, \
  (c) $forall x, y, z : ZZ . (x - (y - z) = (x - y) + z)$.
]

#lemma(label: "14.8.11")[
  $forall x, y : ZZ . (upright("pos")(x - y) arrow.r.double.long upright("neg")(y - x))$.
]

#lemma(label: "14.9.1")[
  (a) $forall x : ZZ . ((-x) + x = 0)$, \
  (b) $forall x, y : ZZ . (x + (-y) = x - y)$, \
  (c) $forall x, y : ZZ . (-(x + y) = (-x) - y)$.
]

#lemma(label: "14.9.2")[
  (a) $-0 = 0$, \
  (b) $forall x : ZZ . (-(-x) = x)$, \
  (c) $forall x : ZZ . (x = 0 arrow.r.double.long -x = 0)$.
]

#lemma(label: "14.9.3")[
  (a) $forall x : ZZ . (-(s x) = p(-x))$, \
  (b) $forall x : ZZ . (-(p x) = s(-x))$.
]

#lemma(label: "14.9.4")[
  (a) $forall x : ZZ . (upright("pos")(x) arrow.r.double.long upright("neg")(-x))$, \
  (b) $forall x : ZZ . (upright("neg")(x) arrow.r.double.long upright("pos")(-x))$.
]

#lemma(label: "14.9.5")[
  (a) $forall x : ZZ . (upright("pos")(x) or upright("pos")(-x) or x = 0)$, \
  (b) $forall x : ZZ . (upright("neg")(x) or upright("neg")(-x) or x = 0)$.
]

#lemma(label: "14.9.6")[
  $forall x : ZZ . (-x epsilon NN arrow.r.double.long (upright("neg")(x) or x = 0))$.
]

#lemma(label: "14.9.7")[
  (a) $forall x : ZZ . (x epsilon NN or -x epsilon NN)$, \
  (b) $forall x : ZZ . ((x epsilon NN and -x epsilon NN) arrow.r.double x = 0)$.
]

#definition(label: [])[
  (a) $lt.eq_ZZ := lambda x : ZZ . lambda y : ZZ . (y - x epsilon NN)$, \
  (b) $lt_ZZ := lambda x : ZZ . lambda y : ZZ . (x lt.eq_ZZ y and x eq.not y)$.
]

#definition(label: [])[
  (a) $gt.eq_ZZ := lambda x : ZZ . lambda y : ZZ . (y lt.eq_ZZ x)$, \
  (b) $gt_ZZ := lambda x : ZZ . lambda y : ZZ . (y lt_ZZ x)$.
]

#lemma(label: "14.10.1")[
  (a) $forall x : ZZ . (x lt.eq x)$, \
  (b) $forall x, y, z : ZZ . ((x lt.eq y and y lt.eq z) arrow.r.double (x lt.eq z))$, \
  (c) $forall x, y, z : ZZ . ((x + z lt.eq y + z) arrow.r.double.long (x lt.eq y))$, \
  (d) $forall x, y, z : ZZ . ((x lt y and y lt.eq z) arrow.r.double (x lt z))$, \
  (e) $forall x, y, z : ZZ . ((x + z lt y + z) arrow.r.double.long (x lt y))$.
]

#lemma(label: "14.10.2")[
  (a) $forall x : ZZ . (upright("pos")(x) arrow.r.double.long x gt 0)$, \
  (b) $forall x : ZZ . (upright("neg")(x) arrow.r.double.long x lt 0)$, \
  (c) $forall x : ZZ . (x lt 0 or x = 0 or x gt 0)$.
]

#lemma(label: "14.10.3")[
  (a) $forall x, y : ZZ . (x lt y arrow.r.double.long -y lt -x)$, \
  (b) $forall x : ZZ . (x lt 0 arrow.r.double.long -x gt 0)$.
]

#lemma(label: [])[
  (a) $forall x : ZZ . (x dot 0 = 0)$ (times-i), \
  (b) $forall x, y : ZZ . (x dot s y = (x dot y) + x)$ (times-ii), \
  (c) $forall x, y : ZZ . (x dot p y = (x dot y) - x)$ (times-iii).
]

#lemma(label: "14.11.1")[
  (a) $forall x : ZZ . (0 dot x = 0)$, \
  (b) $forall x, y : ZZ . (s x dot y = (x dot y) + y)$, \
  (c) $forall x, y : ZZ . (p x dot y = (x dot y) - y)$.
]

#lemma(name: "Праві закони дистрибутивності для множення", label: [])[
  (a) $forall x, y, z : ZZ . (x dot (y + z) = (x dot y) + (x dot z))$, \
  (b) $forall x, y, z : ZZ . (x dot (y - z) = (x dot y) - (x dot z))$.
]

#lemma(label: "14.11.3")[
  (a) $forall x, y : ZZ . (x dot y = y dot x)$, \
  (b) $forall x, y, z : ZZ . ((x dot y) dot z = x dot (y dot z))$.
]

#lemma(label: "14.11.4")[
  $forall x, y : ZZ . (x dot (-y) = -(x dot y))$.
]

#lemma(label: "14.11.5")[
  (a) $forall x, y : ZZ . ((x epsilon NN and y epsilon NN) arrow.r.double x dot y epsilon NN)$, \
  (b) $forall x, y : ZZ . ((x gt 0 and y gt 0) arrow.r.double x dot y gt 0)$, \
  (c) $forall x, y : ZZ . ((x gt 0 and y lt 0) arrow.r.double x dot y lt 0)$, \
  (d) $forall x, y : ZZ . ((x lt 0 and y lt 0) arrow.r.double x dot y gt 0)$.
]

#lemma(label: "14.11.6")[
  $forall x, y : ZZ . (x dot y = 0 arrow.r.double (x = 0 or y = 0))$.
]

#lemma(name: "Правий закон скорочення для множення", label: [])[
  $forall x, y, z : ZZ . ((x dot z = y dot z and z eq.not 0) arrow.r.double x = y)$.
]

#definition(label: [])[
  Для $m, n : ZZ$, \
  $upright("div")(m, n) := exists q : ZZ . (m dot q = n)$ (позначення: $m divides n$).
]

#lemma(label: "14.12.1")[
  (a) $forall m : ZZ . (m divides 0)$, \
  (b) $0 divides 0$, \
  (c) $forall n : ZZ . (0 divides n arrow.r.double n = 0)$.
]

#lemma(label: "14.12.2")[
  (a) $forall l, m : ZZ . (l divides m arrow.r.double.long -l divides m)$, \
  (b) $forall m : ZZ . (1 divides m)$.
]

#lemma(label: "14.12.3")[
  (a) $forall m : ZZ . (m divides m)$, \
  (b) $forall l, m, n : ZZ . ((l divides m and m divides n) arrow.r.double l divides n)$, \
  (c) $forall m, n : ZZ . ((m epsilon NN and n epsilon NN) arrow.r.double ((m divides n and n divides m) arrow.r.double m = n))$.
]

#definition(label: [])[
  Для $k, m, n : ZZ$, \
  (a) $upright("com-div")(k, m, n) := k divides m and k divides n$, \
  (b) $upright("gcd-prop")(k, m, n) := upright("com-div")(k, m, n) and forall l : ZZ . (upright("com-div")(l, m, n) arrow.r.double l lt.eq k)$, \
  (c) $upright("coprime")(m, n) := forall k : ZZ . ((upright("com-div")(k, m, n) and k gt 0) arrow.r.double k = 1)$.
]

#lemma(label: [])[
  Для $m, n : ZZ$, $s : m gt 0$, $t : n gt 0$, \
  $exists_1 k : ZZ . upright("gcd-prop")(k, m, n)$ (gcd-unq).
]

#definition(label: [])[
  Для $m, n : ZZ$, $s : m gt 0$, $t : n gt 0$, \
  $upright("gcd")(m, n, s, t) := iota(ZZ, lambda k : ZZ . upright("gcd-prop")(k, m, n), upright("gcd-unq")(m, n, s, t))$.
]

#lemma(label: [])[
  Для $m, n : ZZ$, $s : m gt 0$, $t : n gt 0$, \
  $upright("gcd")(m, n, s, t) gt 0$ (gcd-pos).
]
