#import "/book.typ": *

== Probe2

$ arrow.b quad arrow.b.dashed quad arrow.r.dashed quad arrow.r.se quad arrow.l quad arrow.r quad arrow.squiggly quad arrow.r.long quad arrow.b.long $

$ "gcd"^(arrow.r)(m, n) quad T^(arrow.r) quad "gcd-prop"^(arrow.r)(k, m, n) quad upright("Min")(S) quad a_1^dagger quad a_(12)^("Рис.13.8") quad exists^(lt.eq 1) quad iota $

$ forall a b exists d (0 lt.eq d and d divides a and d divides b and exists x y (d = a x + b y)) $

$ forall m, n : upright("nat") (m > 0 or n > 0 arrow.r.double exists i, i_1 : ZZ (i m + i_1 n = "gcd"^(arrow.r)(m, n))) $

$ forall a, b, d : ZZ ("gcd-prop"^(arrow.r)(d, a, b) arrow.r.double exists u, v : ZZ (u a + v b = d)) $

$ forall m, n (0 < m and 0 < n arrow.r.double
   exists a, b (b n lt.eq a m and "gcd"(m, n) = a m - b n) or
   exists a, b (a m lt.eq b n and "gcd"(m, n) = b n - a m)) $

$ =_(ZZ) quad =_(NN) quad beta Delta $
