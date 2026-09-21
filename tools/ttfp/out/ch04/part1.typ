#import "/book.typ": *

== Конструктори типів

У попередньому розділі ми ввели можливість конструювати узагальнені терми, абстрагуючи терм від змінної типу. Наприклад, терм $lambda x : sigma . x$ (тотожність на фіксованому типі $sigma$) можна узагальнити до терма $lambda alpha : ast . lambda x : alpha . x$ («поліморфна» тотожність, тобто тотожність на змінному типі $alpha$, абстрагована від цього $alpha$).

Подібно до цього природно бажати конструювати узагальнені типи. Наприклад, типи $beta arrow.r beta$, $gamma arrow.r gamma$, $(gamma arrow.r beta) arrow.r (gamma arrow.r beta)$, … усі мають загальну структуру $diamond arrow.r diamond$, де з обох боків стрілки стоїть той самий тип. Абстрагування від $diamond$ дає змогу описати всю родину типів із такою структурою.

Щоб це охопити, ми вводимо узагальнений вираз, який утілює суть цієї структури: $lambda alpha : ast . alpha arrow.r alpha$. Сам він не є типом, а є функцією, значенням якої є тип. Тому його називають _конструктором типів_. Лише коли ми його «нагодуємо», скажімо, $beta$, $gamma$ чи $(gamma arrow.r beta)$, ми отримуємо типи:

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (left, center, left),
  column-gutter: 1.2em,
  [$(lambda alpha : ast . alpha arrow.r alpha) beta$], [$arrow.r_beta$], [$beta arrow.r beta$],
  [$(lambda alpha : ast . alpha arrow.r alpha) gamma$], [$arrow.r_beta$], [$gamma arrow.r gamma$],
  [$(lambda alpha : ast . alpha arrow.r alpha) (gamma arrow.r beta)$], [$arrow.r_beta$], [$(gamma arrow.r beta) arrow.r (gamma arrow.r beta)$],
)

Конструктор типів $lambda alpha : ast . alpha arrow.r alpha$ ми отримуємо, абстрагуючи тип $alpha arrow.r alpha$ від типу $alpha$. Подібним чином можна утворювати складніші конструктори типів, наприклад $lambda alpha : ast . lambda beta : ast . alpha arrow.r beta$.

Очевидне питання: які типи мають ці конструктори типів? Ми вже знаємо, що $alpha arrow.r alpha$ є типом. Отже, $lambda alpha : ast . alpha arrow.r alpha$ можна розглядати як функцію, що відображає тип $alpha$ у тип $alpha arrow.r alpha$. Оскільки $alpha : ast$ і $alpha arrow.r alpha : ast$, ми отримуємо:

$ lambda alpha : ast . alpha arrow.r alpha : ast arrow.r ast . $

Тому поряд із $ast$ нам потрібен новий «надтип», а саме $ast arrow.r ast$.

Аналогічно можемо зробити висновок:

$ lambda alpha : ast . lambda beta : ast . alpha arrow.r beta : ast arrow.r (ast arrow.r ast) . $

Коли ми додаємо як нові надтипи такі речі, як $ast arrow.r ast$ і $ast arrow.r (ast arrow.r ast)$, природно також дозволити змінні, що належать цим надтипам.

#example[
  (1) Припустімо, що ми маємо змінну $alpha : ast arrow.r ast$; тоді для $gamma : ast$ маємо:

  $ alpha gamma : ast. $

  Тоді також природно абстрагувати від цієї змінної $alpha$ і отримати:

  $ lambda alpha : ast arrow.r ast . alpha gamma : (ast arrow.r ast) arrow.r ast. $

  І ми можемо застосувати цей конструктор типів до тотожності на типах $lambda beta : ast . beta$, оскільки $lambda beta : ast . beta$ має тип $ast arrow.r ast$:

  $ (lambda alpha : ast arrow.r ast . alpha gamma)(lambda beta : ast . beta) : ast. $

  (2) Ми також можемо абстрагувати від $alpha$ типу $ast arrow.r ast$ і вивести:

  $ lambda alpha : ast arrow.r ast . alpha : (ast arrow.r ast) arrow.r (ast arrow.r ast) . $
]

Описані вище розширення можна підсумувати як додавання типів, залежних від типів, що приведе до системи #lomega, яку буде описано в цьому розділі.

#remark[
  Використовуючи такого роду загальні пояснювальні вирази, як «терми, залежні від типів» або «типи, залежні від типів», ми тепер мусимо розширити значення слова «тип», оскільки маємо справу як зі звичайними типами, так і з конструкторами типів. Подібне стосується й виразів на кшталт «абстрагування терма від типу».
]

Вище нам трапилися такі приклади типів (точніше: конструкторів типів), залежних від типу, яким тут у всіх випадках є $alpha$:

#list(
  [$lambda alpha : ast . alpha arrow.r alpha$],
  [$lambda alpha : ast . lambda beta : ast . alpha arrow.r beta$],
  [$lambda alpha : ast arrow.r ast . alpha$],
  [$lambda alpha : ast arrow.r ast . alpha gamma$],
)

«Надтипи», які ми бачили вище, — ті, що складаються з самого $ast$ та з символів $ast$ зі стрілками між ними, — називаються _родами_. Абстрактний синтаксис для множини $K$ усіх родів такий:

$ K = ast | (K arrow.r K) . $

#notation-item[
  Ми використовуємо подібні домовленості про пропуск дужок, як і для простих типів. Отже, зовнішні дужки можна пропускати, а роди записуються правоасоціативно. (Пор. позначення 2.2.2.)
]

Приклади родів:

$ast, ast arrow.r ast, ast arrow.r ast arrow.r ast, (ast arrow.r ast) arrow.r ast, (ast arrow.r ast) arrow.r ast arrow.r ast, ast arrow.r (ast arrow.r ast) arrow.r ast$.

Ми вводимо новий символ для типу всіх родів, а саме $square$, який, так би мовити, є єдиним і неповторним «над-надтипом». Тепер ми маємо, наприклад, що $ast : square$, але також $ast arrow.r ast : square$, тощо. Якщо $kappa$ — рід, то кожен $M$ «типу» $kappa$ (розмовно це позначення $M : kappa$) часто називають _конструктором типів_, або просто _конструктором_. Тоді всі «старі» типи — як $alpha$ чи $alpha arrow.r alpha$ — теж називають конструкторами, хоч у цих випадках «конструювати нічого». Отже, $lambda alpha : ast . alpha arrow.r alpha$ є конструктором роду $ast arrow.r ast$, а «старий» тип $alpha arrow.r alpha$ сам є конструктором роду $ast$.

Для конструкторів, які не є типами, уживаємо термін _власний конструктор_. Таким чином, множина конструкторів розпадається на («старі») типи та власні конструктори.

Нарешті, слово _сорт_ позначає $ast$ або $square$, отже:

#definition(name: "Конструктор, власний конструктор, сорт")[
  (1) Якщо $kappa : square$ і $M : kappa$, то $M$ є _конструктором_. Якщо $kappa equiv.not ast$, то $M$ — _власний конструктор_.

  (2) Множина сортів — це ${ast, square}$.
]

#notation-item[
  Відтепер ми залишаємо символ $s$ як метазмінну для сорту (отже, $s$ позначає або $ast$, або $square$).
]

Із додаванням $square$ у нашому синтаксисі тепер чотири рівні:

#definition(name: "Рівні")[
  *Рівень 1*: тут розташовані терми;

  *рівень 2*: тут містяться конструктори (тобто типи плюс власні конструктори);

  *рівень 3*: рівень родів;

  *рівень 4*: складається лише з $square$.
]

Зчіплюючи все докупи, ми неформально записуємо такі ланцюжки суджень, як $t : sigma : ast arrow.r ast$, або навіть $t : sigma : ast arrow.r ast : square$, що виражають $t : sigma$, $sigma : ast arrow.r ast$ і $ast arrow.r ast : square$. В останньому прикладі ми маємо рівні від 1 до 4, об'єднані в один ланцюжок суджень.

Коли $sigma$ є власним конструктором, то він не може бути населеним, тому ми мусимо опустити $t$ з ланцюжка. Тоді ми отримуємо коротший ланцюжок суджень $sigma : kappa : square$, де, наприклад, $kappa equiv ast arrow.r ast$. Але знову ж таки в цьому ланцюжку спостерігаємо кілька рівнів, а саме рівні від 2 до 4.

#remark[
  Варто зауважити, що багатший вибір рівнів впливає також на твердження $A : B$. Оскільки рівень $B$ мусить бути на одиницю вищим за рівень $A$, ми маємо:

  Якщо $A$ має рівень 1, то $A$ мусить бути термом, а $B$ — типом.

  У #ltwo $A$ може також мати рівень 2. Тоді $A$ є типом, а $B equiv ast$. У #lomega $A$ може також бути конструктором типів, і тому $B$ може бути складнішим родом, як-от $ast arrow.r ast$.

  У #lomega можливо, що $A$ має рівень 3; тоді $A$ є родом, а $B equiv square$.

  Отже, ролі суб'єкта й типу в твердженні теж охоплюють кілька рівнів. Ці ролі (а тому й їхні конструкції) дедалі більше переплітаються між собою, що стане істотною рисою систем типів, які розглядаються в цьому та наступних розділах.
]

== Правило сортів і правило змінної в #lomega

Система, яку ми розглядаємо в цьому розділі, називається #lomega. Це ще одне розширення #lto:

#list(
  [#ltwo = #lto плюс терми, залежні від типів,],
  [#lomega = #lto плюс типи, залежні від типів.],
)

Тепер перейдімо до опису конкретних правил виведення #lomega. Спершу формалізуймо той факт, що надтип $ast$ має тип $square$. (Те, що всі інші роди також мають тип $square$, випливає з підрозділу 4.4.) Це правило називається правилом сортів:

#definition(name: "Правило сортів")[
  #table(
    columns: (auto, auto),
    stroke: none,
    align: (right, center),
    column-gutter: 1.5em,
    [(sort)], [$emptyset tack.r ast : square$],
  )
]

Далі ми хочемо мати правило, яке встановлює, що всі декларації, які трапляються в контексті, вивідні в цьому контексті. У #lto та #ltwo ми використовували для цієї мети правило (var) (див. означення 2.4.5 і рисунок 3.1 відповідно). У #lomega ми застосовуємо дещо інший підхід: ми акуратно поєднуємо вивідність декларацій контексту з побудовою самого контексту.

Причина цього — у тому, що типи в #lomega складніші, тож ми мусимо подбати, щоб типи були коректно побудовані. У #lto, де множина допустимих типів була задана наперед, жодної проблеми не було. У #ltwo справи були трохи складніші, тому нам довелося встановити, що таке (власний) #(ltwo)-контекст (див. означення 3.4.4), що, зокрема, привело до вимог щодо типів, уживаних у таких контекстах. Отже, допустимість типів, які трапляються в судженні, уже не могла визначатися посиланням на зовнішню множину, а мала залежати від огляду самого судження, включно з його контекстом.

У цій системі вимоги, що накладаються на типи, ще суворіші: допустимість типу, який трапляється в судженні, тепер випливає лише з того, що ми можемо формально його вивести.

Наш новий підхід такий: ми розширюємо контекст декларацією $x : A$ лише тоді, коли сам тип $A$ уже є «допустимим». А «допустимі типи» твердження належать до рівня 2 або 3, а отже, є типом або родом.

Ці речі можна виразити таким правилом:

#definition(name: "Правило змінної")[
  #table(
    columns: (auto, auto, auto),
    stroke: none,
    align: (right, center, left),
    column-gutter: 1.2em,
    [(var)],
    table(
      columns: 1,
      stroke: none,
      align: center,
      [$Gamma tack.r A : s$],
      table.cell(stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma, x : A tack.r x : A$],
    ),
    [якщо $x in.not Gamma$.],
  )
]

Нагадаємо, що $s$ пробігає множину сортів (пор. позначення 4.1.5). Отже, засновок цього правила (var), $Gamma tack.r A : s$, вимагає, щоб сам $A$ був або типом (коли $s equiv ast$), або родом (коли $s equiv square$). Тож літера «$x$» може позначати як термову змінну, так і змінну типу. Правило (var) дає змогу розширити контекст $Gamma$ декларацією $x : A$ і вивести ту саму декларацію як твердження в розширеному контексті.

Обмеження $x in.not Gamma$ гарантує, що змінна $x$ є «свіжою», тобто $x$ не трапляється в $Gamma$. Звідси випливає, що всі змінні, декларовані в контексті, різні, що знову ж таки є природною вимогою: контекст слугує для типізації змінних, які можуть бути вільними у твердженні, і вочевидь зайве декларувати ту саму змінну в контексті більше ніж один раз (і навіть заплутує, якщо відповідні типи випадково різні).

Наголосимо, що це правило (var) відіграє подвійну роль завдяки двом можливостям для $s$. Оскільки $s$ може бути або $ast$ (рівня 3), або $square$ (рівня 4), правило як ціле охоплює два рівні. Покажемо це в наступному прикладі, навівши кілька реалізацій тверджень $A : s$ і $x : A$, які трапляються в означенні 4.2.2:

#example[
  #table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    stroke: none,
    align: (right, center, center, auto, center, center, auto),
    column-gutter: 0.7em,
    [], [$s equiv square$], [], [], [], [$s equiv ast$], [],
    [$A : s$], [$ast : square$], [$ast arrow.r ast : square$], [], [$alpha : ast$], [$alpha arrow.r beta : ast$], [],
    [$x : A$], [$alpha : ast$], [$beta : ast arrow.r ast$], [], [$x : alpha$], [$y : alpha arrow.r beta$], [],
  )
]

Тепер ми можемо розпочати виведення за допомогою правил (sort) і (var), наведених вище. Наведемо приклад у деревоподібному форматі, який наочно демонструє, як працюють ці правила.

#table(
  columns: (auto, auto),
  stroke: none,
  align: (center, left),
  column-gutter: 1em,
  [$"(1)" emptyset tack.r ast : square$], [],
  table.cell(stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(2)" alpha : ast tack.r alpha : ast$], [(var)],
  table.cell(stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(3)" alpha : ast, x : alpha tack.r x : alpha$], [(var)],
)

Правило (sort) дає рядок (1). Правило (var) використано в обох його ролях: з $s equiv square$ у рядку (2) і з $s equiv ast$ у рядку (3).

Звісно, подібне виведення можна зробити й для типу $beta$.

У підрозділі 2.5 ми згадували, що в цій книжці ми віддаємо перевагу прапорцевому формату над деревоподібним. Тому наведімо це виведення ще раз у прапорцевому форматі:

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (left, left, left),
  column-gutter: 1.2em,
  [$"(1)"$], [$ast : square$], [(sort)],
  [], [$#h(2.2em)alpha : ast$], [],
  [$"(2)"$], [$#h(2.2em)alpha : ast$], [(var) на (1)],
  [], [$#h(4.4em)x : alpha$], [],
  [$"(3)"$], [$#h(4.4em)x : alpha$], [(var) на (2)],
)

З цього прикладу також стає ясно, що правило (var), уведене в цьому розділі, менш загальне, ніж, скажімо, у системі #lto (див. означення 2.4.5), оскільки теперішнє правило (var) дозволяє виводити лише останню, щойно додану декларацію $x : A$ контексту. Див. рядки (2) і (3) у виведенні. Однак у #lto будь-яка декларація $x : sigma$, що трапляється в $Gamma$, є вивідною щодо цього $Gamma$.

Природно бажати, щоб у нашій системі #lomega ми могли робити не менше, ніж у #lto. Так, наприклад, ми хочемо вміти виводити не лише $alpha : ast, x : alpha tack.r x : alpha$, а й:

$ (?1) space alpha : ast, x : alpha tack.r alpha : ast , $

що неможливо з теперішніми правилами. Інше судження, яке ми поки не можемо отримати, таке:

$ (?2) space alpha : ast, beta : ast tack.r alpha : ast . $

Якщо добре подумати, навіть виведення

$ (?3) space alpha : ast, beta : ast tack.r beta : ast $

неможливе, хоч $beta : ast$ і є останньою декларацією контексту $alpha : ast, beta : ast$. Причина в тому, що ми поки не можемо отримати засновок

$ (?4) space alpha : ast tack.r ast : square , $

який потрібен, щоб вивести (?3) за правилом (var).

Усе це буде виправлено в наступному підрозділі додаванням так званого «правила ослаблення».

== Правило ослаблення в #lomega

Розв'язком описаної раніше проблеми є додавання нового правила. Це правило, яке називають ослабленням, дає змогу «ослабити» контекст судження, додавши нові декларації, за умови, що «типи» нових декларацій є «коректно побудованими». Спершу сформулюймо правило, а потім його обговоримо:

#definition(name: "Правило ослаблення")[
  #table(
    columns: (auto, auto, auto),
    stroke: none,
    align: (right, center, left),
    column-gutter: 1.2em,
    [(weak)],
    table(
      columns: 2,
      stroke: none,
      align: center,
      column-gutter: 1.8em,
      [$Gamma tack.r A : B$], [$Gamma tack.r C : s$],
      table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma, x : C tack.r A : B$],
    ),
    [якщо $x in.not Gamma$.],
  )
]

Основний ефект цього правила можна описати так. Якщо ми вивели судження $Gamma tack.r A : B$ (перший засновок), то можемо «ослабити» контекст $Gamma$, додавши довільну декларацію в кінці. Отже, отриманий висновок — це $Gamma, x : C tack.r A : B$, тобто $A : B$ теж вивідне в розширеному контексті.

Є одна умова: тип $C$ доданої декларації сам має бути коректно побудованим. Це виражено у вимозі, поданій у другому засновку: має виконуватися $Gamma tack.r C : s$, тобто сам $C$ вивідний у тому самому контексті $Gamma$ як дещо, що стоїть на рівні 2, коли $s equiv ast$, або на рівні 3, коли $s equiv square$.

Те, що розширення контексту в правилі (weak) дозволено лише в кінці, легко виразити, і цього виявляється достатньо. Можна довести, що будь-яке розширення контексту коректно побудованою декларацією є допустимим; це випливає з леми про потовщення, яка теж виконується для #lomega (пор. леми 2.10.5 (1) і 3.6.4).

#remark[
  У теорії типів для загального процесу вставляння нової декларації у заданий список декларацій у довільному місці віддають перевагу слову «потовщення». «Ослаблення» ж радше вживають для розширення такого списку лише в кінці. В обох ситуаціях додаються нові припущення, і це справді «послаблює» (або «потовщує») те, що ми виражаємо.
]

Тепер ми можемо вивести пропущені судження (?1)–(?4), згадані в кінці попереднього підрозділу. Спершу наведімо деревоподібні версії виведень, щоб зберегти тісну відповідність до формату правил.

*(?1)* Це судження (4), отримане в наступному виведенні, у якому важливу роль відіграє правило (weak).

#table(
  columns: (auto, auto),
  stroke: none,
  align: (center, left),
  column-gutter: 1.2em,
  table(
    columns: 3,
    stroke: none,
    align: (center, center, auto),
    column-gutter: 1.6em,
    table(
      columns: (auto, auto),
      stroke: none,
      align: (center, left),
      column-gutter: 1em,
      [$"(1)" emptyset tack.r ast : square$], [],
      table.cell(stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(2)" alpha : ast tack.r alpha : ast$], [(var)],
    ),
    table(
      columns: (auto, auto),
      stroke: none,
      align: (center, left),
      column-gutter: 1em,
      [$"(1)" emptyset tack.r ast : square$], [],
      table.cell(stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(2)" alpha : ast tack.r alpha : ast$], [(var)],
    ),
    [],
    table.cell(colspan: 3, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(4)" alpha : ast, x : alpha tack.r alpha : ast$],
  ),
  [(weak)],
)

Цікаво побачити, як тут дві копії рядка (2) використано як перший і другий засновки правила (weak), щоб отримати рядок (4) як висновок. Беремо $s equiv ast$. Уважно простежте, що тут відбувається.

*(?2) і (?4)* У наступному виведенні остаточний висновок (рядок (6)) розв'язує питання (?2). Як побічний результат ми також отримуємо відповідь на питання (?4): див. рядок (5), для якого знову ж таки використано дві копії того самого судження як лівий і правий засновки.

#table(
  columns: (auto, auto),
  stroke: none,
  align: (center, bottom),
  column-gutter: 1.2em,
  table(
    columns: 3,
    stroke: none,
    align: (center, center, auto),
    column-gutter: 1.6em,
    table(
      columns: (auto, auto),
      stroke: none,
      align: (center, left),
      column-gutter: 1em,
      [$"(1)" emptyset tack.r ast : square$], [],
      table.cell(stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(2)" alpha : ast tack.r alpha : ast$], [(var)],
    ),
    table(
      columns: 3,
      stroke: none,
      align: (center, center, auto),
      column-gutter: 1.6em,
      [$"(1)" emptyset tack.r ast : square$], [$"(1)" emptyset tack.r ast : square$], [],
      table.cell(colspan: 3, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(5)" alpha : ast tack.r ast : square$], [(weak)],
    ),
    [],
    table.cell(colspan: 3, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(6)" alpha : ast, beta : ast tack.r alpha : ast$],
  ),
  [(weak)],
)

Обидва застосування (weak) тут ґрунтуються на $s equiv square$.

*(?3)* Останнє питання розв'язано в рядку (7) нижче.

#table(
  columns: (auto, auto),
  stroke: none,
  align: (center, left),
  column-gutter: 1em,
  table(
    columns: (auto, auto),
    stroke: none,
    align: (center, bottom),
    column-gutter: 1em,
    table(
      columns: 3,
      stroke: none,
      align: (center, center, auto),
      column-gutter: 1.6em,
      [$"(1)" emptyset tack.r ast : square$], [$"(1)" emptyset tack.r ast : square$], [],
      table.cell(colspan: 3, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(5)" alpha : ast tack.r ast : square$], [(weak)],
    ),
    [(var)],
    table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(7)" alpha : ast, beta : ast tack.r beta : ast$],
  ),
)

Нарешті зведімо всі деревоподібні виведення, наведені в цьому та попередньому підрозділі, в одне прапорцеве виведення:

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (left, left, left),
  column-gutter: 1.2em,
  [$"(1)"$], [$ast : square$], [(sort)],
  [], [$#h(2.2em)alpha : ast$], [],
  [$"(2)"$], [$#h(2.2em)alpha : ast$], [(var) на (1)],
  [], [$#h(4.4em)x : alpha$], [],
  [$"(3)"$], [$#h(4.4em)x : alpha$], [(var) на (2)],
  [$"(4)"$], [$#h(4.4em)alpha : ast$], [(weak) на (2) і (2)],
  [$"(5)"$], [$#h(2.2em)ast : square$], [(weak) на (1) і (1)],
  [], [$#h(4.4em)beta : ast$], [],
  [$"(6)"$], [$#h(4.4em)alpha : ast$], [(weak) на (2) і (5)],
  [$"(7)"$], [$#h(4.4em)beta : ast$], [(var) на (5)],
)

#remark[
  Хоча деревоподібні виведення й відображають правила виведення правильно, читати їх не завжди легко, як ми вже згадували в підрозділі 2.5. По-перше, деревоподібні виведення швидко стають незручно великими й складними. По-друге, у деревоподібних виведеннях зазвичай багато повторень суджень, а також піддерев. Див., наприклад, дерева вище, де рядок (1) написано сім разів. Дерево, що складається з рядків (1) і (2), повторено тричі.

  Лінійне подання, як-от прапорцевий формат, стоїть далі від правил виведення в тому вигляді, як вони подані. Однак воно дає покрокове уявлення про розвиток виведення. Більше того, прапорцеві виведення значно компактніші, як демонструє наведений вище приклад. Зокрема, повторення, властиві деревоподібному виведенню, більше не потрібні, оскільки кожен рядок у прапорцевому виведенні можна використовувати як завгодно часто. Див., наприклад, прапорцеве виведення вище, де рядок (2) подано лише один раз, але на нього посилалися чотири рази.
]

== Правило утворення в #lomega

У #ltwo ми мали правило утворення (form) для побудови типізаційних тверджень у контексті. Це правило ґрунтувалося на множині $T_2$ #(ltwo)-типів (див. початок підрозділу 3.4). Як уже зазначено в підрозділі 4.2, типи в #lomega складніші. Тому ми вводимо «справжнє» правило виведення — із засновками та висновком — для утворення типів.

Більше того, у #lomega ми маємо також роди. Але завдяки можливості «подвійних ролей» у #lomega все виявляється простіше, ніж очікувалося. Нове правило (form), яке дає змогу утворювати типи й роди, виглядає так:

#definition(name: "Правило утворення")[
  #table(
    columns: (auto, auto),
    stroke: none,
    align: (center, auto),
    column-gutter: 1.2em,
    [(form)],
    table(
      columns: 2,
      stroke: none,
      align: center,
      column-gutter: 1.8em,
      [$Gamma tack.r A : s$], [$Gamma tack.r B : s$],
      table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma tack.r A arrow.r B : s$],
    ),
  )
]

Це охоплює всі типи й роди, які нам потрібні. (Зауважте, що в #lomega немає термів, залежних від типів, а тому в #lomega немає й Π-типів.)

Наведемо два приклади цього правила; перший — із $s equiv ast$. Пропущені піддерева над рядками (6) і (7) можна знайти в попередньому підрозділі.

#table(
  columns: (auto, auto),
  stroke: none,
  align: (center, left),
  column-gutter: 1.2em,
  table(
    columns: 3,
    stroke: none,
    align: (center, center, auto),
    column-gutter: 1.6em,
    [......], [......], [],
    [$"(6)" alpha : ast, beta : ast tack.r alpha : ast$], [$"(7)" alpha : ast, beta : ast tack.r beta : ast$], [],
    table.cell(colspan: 3, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(8)" alpha : ast, beta : ast tack.r alpha arrow.r beta : ast$],
  ),
  [(form)],
)

У другому прикладі $s equiv square$:

#table(
  columns: (auto, auto),
  stroke: none,
  align: (center, left),
  column-gutter: 1.2em,
  table(
    columns: 3,
    stroke: none,
    align: (center, center, auto),
    column-gutter: 1.6em,
    [......], [......], [],
    [$"(5)" alpha : ast tack.r ast : square$], [$"(5)" alpha : ast tack.r ast : square$], [],
    table.cell(colspan: 3, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(9)" alpha : ast tack.r ast arrow.r ast : square$],
  ),
  [(form)],
)

Ці результати можна також подати у прапорцевому форматі, продовживши прапорцеве виведення з попереднього підрозділу ще двома рядками:

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (left, left, left),
  column-gutter: 1.2em,
  [..], [], [],
  [.], [], [],
  [$"(8)"$], [$#h(2.2em)alpha arrow.r beta : ast$], [(form) на (6) і (7)],
  [$"(9)"$], [$#h(2.2em)ast arrow.r ast : square$], [(form) на (5) і (5)],
)

== Правила застосування та абстракції в #lomega

Залишилися правила (appl) і (abst). Наводимо їх нижче.

Ці правила трохи відрізняються від правил у розділі 3 (див. рисунок 3.1). По-перше, назви метазмінних для типів інші ($A$ замість $sigma$, тощо), бо типи в #lomega загальніші. А по-друге, у правилі (abst) ми мусимо бути певні, що $A arrow.r B$ є коректно побудованим типом. (Нагадаємо, що в #lomega немає Π-типів.) Це виражено другим засновком цього правила, подібно до того, як ми робили раніше в цьому розділі.

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (right, center, left),
  column-gutter: 1.2em,
  [(appl)],
  table(
    columns: 2,
    stroke: none,
    align: center,
    column-gutter: 1.8em,
    [$Gamma tack.r M : A arrow.r B$], [$Gamma tack.r N : A$],
    table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma tack.r M N : B$],
  ),
  [],
  [(abst)],
  table(
    columns: 2,
    stroke: none,
    align: center,
    column-gutter: 1.8em,
    [$Gamma, x : A tack.r M : B$], [$Gamma tack.r A arrow.r B : s$],
    table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma tack.r lambda x : A . M : A arrow.r B$],
  ),
  [],
)

Зауважте, що обидва знову мають подвійну роль, оскільки $s in {ast, square}$. Отже, тип $A arrow.r B$, який трапляється і в (appl), і в (abst), може бути типом другого рівня, як-от $(alpha arrow.r beta) arrow.r gamma$, коли $s equiv ast$. Але $A arrow.r B$ може бути також типом третього рівня, або родом, як-от $(ast arrow.r ast) arrow.r ast$, коли $s equiv square$.

Ми досі точно не пояснили, як поширити β-редукцію та β-конверсію на #lomega. Це природно зробити. Справжнє означення ми відкладемо, а щодо прикладів, які показують, як це працює, відсилаємо до початку підрозділу 4.1.

Один із цих прикладів такий:

$ (lambda alpha : ast . alpha arrow.r alpha) beta arrow.r_beta beta arrow.r beta . $

Як невелику вправу обчислімо типи обох виразів. Почнімо з лівого боку, $(lambda alpha : ast . alpha arrow.r alpha) beta$, і виведімо його тип у прапорцевому форматі, знову як продовження попереднього прапорцевого виведення, але починаючи з порожнього контексту.

У виведенні використано і (abst), і (appl): див. рядки (14) і (16). Щоб графічно продемонструвати, як ці правила реалізовано, ми наведемо також відповідну частину деревоподібного виведення.

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (left, left, left),
  column-gutter: 1.2em,
  [..], [], [],
  [.], [], [],
  [], [$#h(2.2em)beta : ast$], [],
  [$"(10)"$], [$#h(2.2em)ast : square$], [(weak) на (1) і (1)],
  [], [$#h(4.4em)alpha : ast$], [],
  [$"(11)"$], [$#h(4.4em)alpha : ast$], [(var) на (10)],
  [$"(12)"$], [$#h(4.4em)alpha arrow.r alpha : ast$], [(form) на (11) і (11)],
  [$"(13)"$], [$#h(2.2em)ast arrow.r ast : square$], [(form) на (10) і (10)],
  [$"(14)"$], [$#h(2.2em)lambda alpha : ast . alpha arrow.r alpha : ast arrow.r ast$], [(abst) на (12) і (13)],
  [$"(15)"$], [$#h(2.2em)beta : ast$], [(var) на (1)],
  [$"(16)"$], [#h(2.2em)$(lambda alpha : ast . alpha arrow.r alpha) beta : ast$], [(appl) на (14) і (15)],
)

#table(
  columns: (auto, auto),
  stroke: none,
  align: (center, left),
  column-gutter: 1em,
  table(
    columns: 3,
    stroke: none,
    align: (center, center, auto),
    column-gutter: 1.6em,
    table(
      columns: 3,
      stroke: none,
      align: (center, center, auto),
      column-gutter: 1.6em,
      [$"(12)" beta : ast, alpha : ast tack.r alpha arrow.r alpha : ast$], [$"(13)" beta : ast tack.r ast arrow.r ast : square$], [],
      table.cell(colspan: 3, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(14)" beta : ast tack.r lambda alpha : ast . alpha arrow.r alpha : ast arrow.r ast$], [(abst)],
    ),
    [$"(15)" beta : ast tack.r beta : ast$], [],
    table.cell(colspan: 3, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(16)" beta : ast tack.r (lambda alpha : ast . alpha arrow.r alpha) beta : ast$],
  ),
  [(appl)],
)

Виведення, яке відповідає правому боку, $beta arrow.r beta$, просте; для цього нам потрібен лише рядок (15):

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (left, left, left),
  column-gutter: 1.2em,
  [..], [], [],
  [.], [], [],
  [$"(17)"$], [$#h(2.2em)beta arrow.r beta : ast$], [(form) на (15) і (15)],
)

Судження (16) і (17) демонструють, що лівий і правий боки прикладу β-редукції мають однакові типи, що відповідають тим самим контекстам. Це, як і очікувалося: пор. лему про редукцію підмета 2.11.5.

== Скорочені виведення

Виведення на кшталт наведених у попередніх підрозділах, які ведуть до судження в #lomega, мають як цікаві, так і нецікаві складники. Наприклад, судження

$ (8) quad alpha : ast, beta : ast tack.r alpha arrow.r beta : ast $

побудовано із суджень (6) і (7) за допомогою правила (form). Ці судження, своєю чергою, залежать від (1), (2) і (5), що можна встановити, оглянувши або дерева, або прапорцеві виведення.

Нижче ми перелічуємо ці судження:

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (left, left, left),
  column-gutter: 1.2em,
  [$"(1)"$], [$emptyset tack.r ast : square$], [(sort),],
  [$"(2)"$], [$alpha : ast tack.r alpha : ast$], [(var),],
  [$"(5)"$], [$alpha : ast tack.r ast : square$], [(weak),],
  [$"(6)"$], [$alpha : ast, beta : ast tack.r alpha : ast$], [(weak),],
  [$"(7)"$], [$alpha : ast, beta : ast tack.r beta : ast$], [(var).],
)

Щоб встановити (8), потрібно щонайменше п'ять суджень. Однак усі згадані судження, включно з (8), виглядають цілком очевидними.

Такі не надто цікаві кроки трапляються, зокрема, у трьох випадках:

#enum(numbering: "(i)",
  [коли використовуються правила (sort), (var) і (weak),],
  [коли використовується (form), і],
  [коли встановлюється справедливість другого засновку правила (abst).],
)

Зауважте, що випадок (i) стосується всіх п'яти суджень, ужитих у виведенні (8). Усі вони «очевидно» коректно побудовані судження. Випадок (ii) стосується (8). Випадки (ii) і (iii) — це саме ті випадки, коли ми хочемо переконатися, що щось є коректно побудованим типом.

Ми хочемо зосередити увагу на справді цікавих кроках, як у розділах 2 і 3 (див., наприклад, скорочене виведення в підрозділі 2.5). Тому ми дозволимо собі пропускати всі судження, які очевидні самі по собі або потрібні лише для встановлення того, що щось є коректно побудованим типом.

#remark[
  Це, звісно, спірне рішення, адже ми вже не такі точні, як насправді мали б бути. Але люди схильні помилятися, коли втрачають зосередженість, а це легко трапляється, коли робиш нецікаві кроки. Більше того, оскільки наша система цілком формальна, ми можемо залишити остаточну перевірку комп'ютерній програмі, яка без проблем заповнить пропущені судження. Тому ми вважаємо, що в решті цієї книжки дозволено пропускати «нецікаві» кроки.
]

Як наслідок, відтепер до правила (form) звертатимуться рідко, а (sort), (var) і (weak) уживатимуть мінімально.

Щоб показати, який виграш дає ця домовленість, наведімо скорочену версію прапорцевого виведення (16) з попереднього підрозділу:

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (left, left, left),
  column-gutter: 1.2em,
  [], [$"(a)"#h(1.2em)beta : ast$], [],
  [], [$"(b)"#h(2.4em)alpha : ast$], [],
  [$"(12)"$], [$#h(2.4em)alpha arrow.r alpha : ast$], [(form) на (b) і (b)],
  [$"(14)"$], [$#h(1.2em)lambda alpha : ast . alpha arrow.r alpha : ast arrow.r ast$], [(abst) на (12)],
  [$"(16)"$], [#h(1.2em)$(lambda alpha : ast . alpha arrow.r alpha) beta : ast$], [(appl) на (14) і (a)],
)

Порівнюючи ці два виведення, можна помітити таке:

#list(
  [Друге виведення компактне й безпосередньо зрозуміле, зокрема коли читати його в напрямку від мети (знизу вгору).],
  [Ми можемо одразу посилатися на те, що міститься в прапорцях: порівняйте дві версії (12) і (16).],
  [Правило (form) у скороченій версії пропущено, але судження (12) мусить залишитися, оскільки воно потрібне для (14).],
  [Ми дозволяємо використовувати (abst) із посиланням лише на перший засновок, нехтуючи другим: див. нове (14).],
)

== Правило конверсії

У цьому підрозділі ми повертаємося до β-редукції та β-конверсії в #lomega та їхніх наслідків для типізації. Нагадаємо такий приклад β-редукції в #lomega, обговорений у підрозділах 4.1 і 4.5:

$ (lambda alpha : ast . alpha arrow.r alpha) beta arrow.r_beta beta arrow.r beta . $

У попередньому підрозділі ми вивели тип $ast$ для лівого боку в контексті $beta : ast$ (див. рядок (16)). Тоді за правилом (var) випливає:

$ beta : ast, x : (lambda alpha : ast . alpha arrow.r alpha) beta tack.r x : (lambda alpha : ast . alpha arrow.r alpha) beta. $

Природно хотіти, щоб також

$ beta : ast, x : (lambda alpha : ast . alpha arrow.r alpha) beta tack.r x : beta arrow.r beta, $

оскільки β-конвертні типи навмисне вважають «тим самим» типом.

Однак (і це може здивувати) останнє судження вивести не можна: наша система виведення занадто слабка для такого висновку. Перехід від типу $(lambda alpha : ast . alpha arrow.r alpha) beta$ до типу $beta arrow.r beta$ є випадком загальнішої β-конверсії. Очевидно, ми хочемо такого:

Якщо $M$ має тип $B$ і $B =_(beta) B'$, то $M$ має також тип $B'$ (за умови, що і $B$, і $B'$ є коректно побудованими типами або родами).

Оскільки ми поки не можемо вивести це в нашій системі #lomega, нам потрібне додаткове правило виведення. Це правило, яке називають правилом конверсії, виражається так:

#definition(name: "Правило конверсії")[
  #table(
    columns: (auto, auto, auto),
    stroke: none,
    align: (right, center, left),
    column-gutter: 1.2em,
    [(conv)],
    table(
      columns: 2,
      stroke: none,
      align: center,
      column-gutter: 1.8em,
      [$Gamma tack.r A : B$], [$Gamma tack.r B' : s$],
      table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma tack.r A : B'$],
    ),
    [якщо $B =_(beta) B'$.],
  )
]

Зауважте, що в наведеному правилі $B$ уже є коректно побудованим, оскільки він виступає як тип у судженні $Gamma tack.r A : B$. Щоб гарантувати, що $B'$ теж коректно побудований, ми додаємо другий засновок: $Gamma tack.r B' : s$. (Отже, коли $s equiv ast$, ми маємо, що $B'$ є коректно побудованим типом, а коли $s equiv square$, ми маємо, що $B'$ є коректно побудованим родом.)

#remark[
  Можна замислитися, чи справді потрібен другий засновок у правилі конверсії: перший засновок передбачає, що $B$ коректно побудований; чи не буде тоді $B'$ автоматично також коректно побудованим, оскільки $B =_(beta) B'$?

  Відповідь: ні. Наприклад, виконується $beta arrow.r gamma =_(beta) (lambda alpha : ast . beta arrow.r gamma) M$ для довільного терма $M$. Лівий бік $beta arrow.r gamma$ є коректно побудованим типом, але правий бік $(lambda alpha : ast . beta arrow.r gamma) M$ може легко виявитися «неправильним» — наприклад, коли $M$ не має типу $ast$.
]

Як приклад зобразимо ключову частину деревоподібного виведення, що відповідає наведеним вище судженням. Нехай $Gamma equiv beta : ast, x : (lambda alpha : ast . alpha arrow.r alpha) beta$.

#table(
  columns: (auto, auto),
  stroke: none,
  align: (center, left),
  column-gutter: 1.2em,
  table(
    columns: 3,
    stroke: none,
    align: (center, center, auto),
    column-gutter: 1.6em,
    [$"(18)" Gamma tack.r x : (lambda alpha : ast . alpha arrow.r alpha) beta$], [$"(19)" Gamma tack.r beta arrow.r beta : ast$], [],
    table.cell(colspan: 3, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$"(20)" Gamma tack.r x : beta arrow.r beta$],
  ),
  [(conv)],
)

Попри сказане в зауваженні 4.7.2, у скороченому виведенні ми дозволяємо опускати другий засновок правила конверсії, щойно стає безпосередньо ясно, що відповідний $B'$ є коректно побудованим типом. Це узгоджується з нашою домовленістю з попереднього підрозділу.

Як приклад подамо частину наведеного вище дерева у вигляді прапорцевого скороченого виведення; отже, ми опускаємо другий засновок (conv), а саме рядок (19).

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (left, left, left),
  column-gutter: 1.2em,
  [..], [], [],
  [.], [], [],
  [], [$#h(4.4em)x : (lambda alpha : ast . alpha arrow.r alpha) beta$], [],
  [$"(18)"$], [$#h(4.4em)x : (lambda alpha : ast . alpha arrow.r alpha) beta$], [(var) на (16)],
  [$"(20)"$], [$#h(4.4em)x : beta arrow.r beta$], [(conv) на (18)],
)

Щоб цілком ясно показати, у чому різниця між редукцією підмета та правилом конверсії, наведімо таку схему:

#table(
  columns: (auto, auto, auto),
  stroke: none,
  align: (center, center, center),
  column-gutter: 2em,
  [$Gamma tack.r A : B$], [$Gamma tack.r A : B$], [$Gamma tack.r A : B$],
  [$arrow.b_beta$], [$arrow.b_beta$], [$=_(beta)$],
  [$A'$], [$B'$], [$B'$],
  [$Gamma tack.r A' : B$], [$Gamma tack.r A : B'$], [$Gamma tack.r A : B'$],
  [], [якщо $Gamma tack.r B' : s$], [якщо $Gamma tack.r B' : s$],
  [Редукція підмета], [Редукція типу], [Конверсія],
  [(теорема)], [(окремий випадок (conv))], [(правило (conv))],
)

Редукція підмета стверджує, що якщо ми редукуємо суб'єкт судження, залишаючи тип таким, як він є, то отримуємо судження, яке знову є вивідним. Її можна довести в #lomega без правила конверсії.

Редукція типу стверджує, що якщо ми редукуємо тип судження, то знову отримуємо вивідне судження. Але цього не можна довести в #lomega без правила конверсії. Зауважте, що редукція типу є окремим випадком правила конверсії.

Для зручності завершимо цей підрозділ переліком усіх #(lomega)-правил (див. рисунок 4.1).

#figure(
  table(
    columns: (auto, auto, auto),
    stroke: none,
    align: (right, center, left),
    column-gutter: 1.2em,
    row-gutter: 0.6em,
    [(sort)], [$emptyset tack.r ast : square$], [],
    [(var)],
    table(
      columns: 1,
      stroke: none,
      align: center,
      [$Gamma tack.r A : s$],
      table.cell(stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma, x : A tack.r x : A$],
    ),
    [якщо $x in.not Gamma$],
    [(weak)],
    table(
      columns: 2,
      stroke: none,
      align: center,
      column-gutter: 1.8em,
      [$Gamma tack.r A : B$], [$Gamma tack.r C : s$],
      table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma, x : C tack.r A : B$],
    ),
    [якщо $x in.not Gamma$],
    [(form)],
    table(
      columns: 2,
      stroke: none,
      align: center,
      column-gutter: 1.8em,
      [$Gamma tack.r A : s$], [$Gamma tack.r B : s$],
      table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma tack.r A arrow.r B : s$],
    ),
    [],
    [(appl)],
    table(
      columns: 2,
      stroke: none,
      align: center,
      column-gutter: 1.8em,
      [$Gamma tack.r M : A arrow.r B$], [$Gamma tack.r N : A$],
      table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma tack.r M N : B$],
    ),
    [],
    [(abst)],
    table(
      columns: 2,
      stroke: none,
      align: center,
      column-gutter: 1.8em,
      [$Gamma, x : A tack.r M : B$], [$Gamma tack.r A arrow.r B : s$],
      table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma tack.r lambda x : A . M : A arrow.r B$],
    ),
    [],
    [(conv)],
    table(
      columns: 2,
      stroke: none,
      align: center,
      column-gutter: 1.8em,
      [$Gamma tack.r A : B$], [$Gamma tack.r B' : s$],
      table.cell(colspan: 2, stroke: (top: 0.6pt), inset: (y: 4pt), align: center)[$Gamma tack.r A : B'$],
    ),
    [якщо $B =_(beta) B'$],
  ),
  numbering: none,
  caption: [Рисунок 4.1 Правила виведення для #lomega],
)

== Властивості #lomega

Система #lomega задовольняє більшість гарних властивостей попередніх систем (див. підрозділи 2.10, 2.11 і 3.6).

Однак правило конверсії вимагає невеликої видозміни леми про єдиність типів: типи вже не обов'язково буквально збігаються, але вони збігаються з точністю до конверсії:

#lemma(name: "Єдиність типів з точністю до конверсії")[
  Якщо $Gamma tack.r A : B_1$ і $Gamma tack.r A : B_2$, то $B_1 =_(beta) B_2$.
]

Доведення цієї леми ми не наводимо.

== Висновки

Ми вивчили узагальнені типи, які самі також залежать від типів. Деякі з отриманих конструкцій є (власними) конструкторами типів, тобто функціями, які не є типами, але дають типи, коли їх застосувати до належних аргументів. Розширюючи нашу множину типів, ми мусили також розширити свою одноелементну множину надтипів: самого $ast$ не досить, ми отримуємо роди, побудовані з $ast$ та $arrow.r$. Ми також додали до вже отриманих трьох рівнів четвертий — рівень над-надтипу $square$. Система, що виникає з цих розширень, — це #lomega.

Щодо правил виведення для #lomega, ми маємо правило (sort), яке стверджує, що $ast$ має тип $square$. Крім того, нам потрібне нове правило (var) для змінних і правило ослаблення (weak) для контекстів суджень. Щоб утворювати типи всередині системи виведення, ми ввели правило утворення (form).

Правило застосування (appl) і правило абстракції (abst) у #lomega більш-менш такі, як і очікувалося. Це окремі, прості правила, які не потрібно дублювати, як у #ltwo. Одна з причин цього — те, що в #lomega немає Π-типів. Інша причина — важлива подвійна роль більшості правил у #lomega, зокрема (appl) і (abst).

Коли ми робимо справжні виведення в #lomega, виявляється, що багато кроків не дуже цікаві. Щоб дати собі з цим раду, ми дозволили скорочені виведення, у яких деякі потрібні перевірки навмисне опущено. Хоч це й спірне рішення, воно робить виведення коротшими й зручнішими для людини.

Нарешті, ми додали правило конверсії (conv), яке дає змогу замінювати тип на («коректно побудований») конвертний тип.

Система #lomega задовольняє багато гарних властивостей попередніх систем (#lto, #ltwo). Але щоб мати справу з конвертними типами, які походять від правила конверсії, лему про єдиність типів довелося пристосувати.

== Додаткова література

J.-Y. Girard першим дослідив явище «типів, залежних від типів», у своїй докторській дисертації (Girard, 1972) як розширення своєї системи F (див. підрозділ 3.8) до системи Fω. Його метою було вивчити клас функцій, тотальність яких можна довести в арифметиці вищого порядку. Виявляється, що цей клас точно збігається з функціями, які можна означити в Fω.

Властивість «типи, залежні від типів» зазвичай вивчають не окремо, а в поєднанні з поліморфізмом, уведеним у розділі 3 (див. приклади 3.1.1 (2)). Система #lomega по суті означена лише як перехід до Fω або числення конструкцій (див. розділ 6).

У сучасних функціональних мовах, наприклад у Haskell (Peyton Jones et al., 1998), «типи, залежні від типів» постають у формі конструкторів типів: якщо $"List"_sigma$ — це тип списків над типом-носієм $sigma$ (отже, $l : "List"_sigma$ — це список, що складається з термів типу $sigma$), то хотілося б абстрагувати від носія. Тоді ми розглядаємо $"List" : ast arrow.r ast$ як «конструктор типів», який переводить тип $sigma$ у тип списків над $sigma$. Функції $"length"$ тоді можна надати поліморфний тип $Pi alpha : ast . "List" alpha arrow.r "nat"$, який «позичено» з #ltwo.

== Вправи

#exercise[
  Наведіть діаграму дерева, що відповідає повному деревоподібному виведенню рядка (16) з підрозділу 4.5.
]

#exercise[
  Наведіть повні #(lomega)-виведення, спершу в деревоподібному форматі, а потім у прапорцевому форматі (не скорочені), таких суджень:

  (a) $emptyset tack.r (ast arrow.r ast) arrow.r ast : square$,

  (b) $alpha : ast, beta : ast tack.r (alpha arrow.r beta) arrow.r alpha : ast$.
]

#exercise[
  (a) Наведіть повне (тобто не скорочене) #(lomega)-виведення у прапорцевому форматі для

  $quad alpha, beta : ast, x : alpha, y : alpha arrow.r beta tack.r y x : beta$.

  (b) Наведіть скорочене #(lomega)-виведення у прапорцевому форматі для

  $quad alpha, beta : ast, x : alpha, y : alpha arrow.r beta, z : beta arrow.r alpha tack.r z(y x) : alpha$.
]

#exercise[
  Наведіть скорочені #(lomega)-виведення у прапорцевому форматі таких суджень:

  (a) $alpha : ast, beta : ast arrow.r ast tack.r beta(beta alpha) : ast$,

  (b) $alpha : ast, beta : ast arrow.r ast, x : beta(beta alpha) tack.r lambda y : alpha . x : alpha arrow.r beta(beta alpha)$,

  (c) $emptyset tack.r lambda alpha : ast . lambda beta : ast arrow.r ast . beta(beta alpha) : ast arrow.r (ast arrow.r ast) arrow.r ast$,

  (d) $emptyset tack.r (lambda alpha : ast . lambda beta : ast arrow.r ast . beta(beta alpha)) "nat" (lambda gamma : ast . gamma) : ast$, якщо припустити, що $"nat"$ є константою типу $ast$.
]

#exercise[
  Наведіть скорочене #(lomega)-виведення у прапорцевому форматі такого судження:

  $quad alpha : ast, x : alpha tack.r lambda y : alpha . x : (lambda beta : ast . beta arrow.r beta) alpha$.
]

#exercise[
  (a) Доведіть, що не існує таких $Gamma$ і $N$ у #lomega, щоб $Gamma tack.r square : N$ було вивідним.

  (b) Доведіть, що не існує таких $Gamma$, $M$ і $N$ у #lomega, щоб $Gamma tack.r M arrow.r square : N$ було вивідним.
]

#exercise[
  (a) Наведіть #(lomega)-означення понять «легальний терм», «твердження», «#(lomega)-контекст» та «область визначення».

  (b) Сформулюйте для #lomega такі теореми: лема про вільні змінні, лема про потовщення, лема про підстановку.
]
