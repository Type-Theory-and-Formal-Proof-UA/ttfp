// main.typ — entry point. Build with:
//   typst compile main.typ ttfp-uk.pdf
// or `make` / `just build` (see Makefile / justfile).

#import "book.typ": book-template

#show: book-template.with(
  title: "Теорія типів і формальне доведення: Вступ",
  subtitle: "Переклад українською",
  authors: ("Роб Недерпелт", "Херман Геверс"),
  translator: none, // TODO: fill in translator name
)

#include "src/front/titlepage.typ"

#set page(numbering: "i")
#counter(page).update(1)

#include "src/front/foreword.typ"
#include "src/front/preface.typ"
#include "src/front/acknowledgements.typ"
#include "src/front/greek-alphabet.typ"

#outline(title: [Зміст])

#set page(numbering: "1")
#counter(page).update(1)
#counter(heading).update(0)

#include "src/chapters/ch01-untyped-lambda-calculus.typ"
#include "src/chapters/ch02-simply-typed-lambda-calculus.typ"
#include "src/chapters/ch03-second-order-typed-lambda-calculus.typ"
#include "src/chapters/ch04-types-dependent-on-types.typ"
#include "src/chapters/ch05-types-dependent-on-terms.typ"
#include "src/chapters/ch06-calculus-of-constructions.typ"
#include "src/chapters/ch07-encoding-logical-notions.typ"
#include "src/chapters/ch08-definitions.typ"
#include "src/chapters/ch09-extension-of-lc-with-definitions.typ"
#include "src/chapters/ch10-rules-and-properties-of-ld.typ"
#include "src/chapters/ch11-flag-style-natural-deduction.typ"
#include "src/chapters/ch12-mathematics-in-ld-first-attempt.typ"
#include "src/chapters/ch13-sets-and-subsets.typ"
#include "src/chapters/ch14-numbers-and-arithmetic.typ"
#include "src/chapters/ch15-elaborated-example.typ"
#include "src/chapters/ch16-further-perspectives.typ"

#include "src/appendices/appA-logic-in-ld.typ"
#include "src/appendices/appB-arithmetical-axioms.typ"
#include "src/appendices/appC-two-example-proofs.typ"
#include "src/appendices/appD-derivation-rules.typ"

#include "src/back/references.typ"
