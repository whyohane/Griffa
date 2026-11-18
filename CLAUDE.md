# Griffa

App iOS de leitura em UIKit, com interface 100% programática (sem storyboards). Três abas: Summary, Books e Quotes. No primeiro acesso, o app abre pelo onboarding.

## Build

- Projeto: `Griffa.xcodeproj`, scheme `Griffa`. Deployment target: iOS 27.
- Dentro do Xcode, compilar com a ferramenta `BuildProject` do MCP `xcode-tools` e checar erros rápidos com `XcodeRefreshCodeIssuesInFile`.
- Os arquivos ficam em `Griffa/` (pasta sincronizada com o Xcode). Não é preciso editar o `.pbxproj` ao criar ou mover arquivos.
- Fontes novas precisam entrar em `UIAppFonts` no `App/Info.plist` (nome do arquivo `.ttf`) e ser usadas pelo nome PostScript.

## Arquitetura

MVVM com UIKit.

- **View** (`UIView`): só monta a UI e as constraints. Não conhece ViewModel nem Store. Expõe closures (`onContinue`, `onNameChange`) e métodos simples (`setContinueEnabled(_:)`, `setGreeting(_:)`).
- **ViewController**: dono da navegação. Recebe o ViewModel pelo `init` e liga View ↔ ViewModel. Usa `loadView() { view = xxxView }`. Avisa o fluxo externo com closures (`onFinish`).
- **ViewModel**: lógica e validação. Recebe dependências pelo `init` (ex.: `UserProfileStore`). Não importa UIKit.
- **Persistência**: protocolo + implementação, para poder trocar por mock em testes. `UserProfileStore` → `UserDefaultsProfileStore` (nome do usuário). `BooksStore` → `SwiftDataBooksStore` (biblioteca de livros, com SwiftData; `SwiftDataBooksStore.inMemory()` para previews e testes). O SwiftData não vaza para ViewModels e telas: eles só conhecem o protocolo.
- **Services**: tudo que fala com API externa fica em `Services/`, atrás de um protocolo (ver "API de livros").
- **Injeção de dependências**: o `SceneDelegate` cria o `profileStore`, o `booksService` e o `ModelContainer` do SwiftData (com `Book` e `Quote`), de onde sai o `booksStore`, e os passa para o `MainTabBarController`. Ele repassa o `profileStore` ao `SummaryViewModel` e o `booksService` e o `booksStore` ao `BooksViewController`, que cria o `AddBookViewModel(service:store:)`, que por sua vez cria o `BookDetailViewModel` do livro escolhido. Dependências sempre pelo `init`, sem valor padrão que crie a implementação real dentro do ViewModel.
- **Fluxo inicial**: o `SceneDelegate` decide a tela raiz. Se `profileStore.profile == nil`, é o primeiro acesso e abre o onboarding. Senão, abre o `MainTabBarController`. O `onFinish` do onboarding troca o root para o `MainTabBarController`.
- Sem Combine. Preferir async/await quando houver código assíncrono.

## Estrutura de pastas

```
Griffa/
├── App/            AppDelegate, SceneDelegate, MainTabBarController, Info.plist
├── Features/       uma pasta por tela, cada uma com View + ViewController + ViewModel
│   ├── Onboarding/
│   ├── Summary/
│   ├── AddBook/   sheet de busca de livros (+ BookResultsCard)
│   ├── BookDetail/   "parte 2": detalhes do livro escolhido e botão de adicionar
│   ├── Books/
│   └── Quotes/
├── Models/         UserProfile, Book (@Model), Quote (@Model), ReadingStatus
├── Persistence/    UserProfileStore, BooksStore (protocolo), SwiftDataBooksStore
├── Services/       BooksService (protocolo), GoogleBooksService, APIConfig, ImageLoader
├── Resources/      Assets.xcassets, Fonts (ElmsSans, Quicksand, Source_Serif_4)
└── Shared/
    ├── Components/    GriffaButton, GriffaTextField, QuoteCard, ReadingBookCard, BookRow, BookCard, LabeledDivider, GriffaSearchField
    ├── DesignSystem/  Fonts
    └── Extensions/    UIViewController+GriffaNavigationBar
```

## Convenções de código

- 4 espaços de indentação. Tipos em PascalCase, propriedades e métodos em camelCase.
- Classes `final` por padrão.
- Views e componentes de UIKit não usam `init?(coder:)`:
  ```swift
  @available(*, unavailable)
  required init?(coder: NSCoder) {
      fatalError("init(coder:) não é usado")
  }
  ```
- Componentes reutilizáveis (`GriffaButton`, `GriffaTextField`) configuram a si mesmos no `init` (incluindo `translatesAutoresizingMaskIntoConstraints = false` e altura mínima de 50). Quem os usa define só as constraints de posição.
- Largura é decidida por quem contém a view (leading/trailing), nunca fixa no componente. Margem lateral padrão: 20pt. Trailing usa `-20` (valor positivo empurra para fora da tela).
- Posição relativa: `item.anchor.constraint(equalTo: referencia.anchor, constant: x)`. Quem leva as constraints é o item que se move, não a referência.
- Abaixo da barra de navegação: ancorar em `safeAreaLayoutGuide.topAnchor`.
- Cada elemento do layout tem um método `setupXxx()`, chamado em ordem no `init` da view. A ordem importa para o z-order e para as dependências entre constraints (usar `addSubview`; só o background do onboarding usa `insertSubview(at: 0)`).
- Comentários em português, só onde a lógica não é óbvia.
- Fontes sempre pelo enum `Fonts`, com Dynamic Type. Não usar `UIFont.systemFont`. Famílias: ElmsSans (texto e botões), Quicksand Bold (títulos), Source Serif 4 SemiBold Italic (`Fonts.quote()`, 16pt).
- Imagens e cores pelos símbolos gerados: `UIImage(resource: .catinho)`, `UIColor(resource: .primaryPurple)`.
- Testes: Swift Testing para unitários, XCUIAutomation para UI.

## Design system

- Cores: `primaryPurple` (principal), `backgroundPurple` (fundo da Summary), `strokeTextField` (borda de campo).
- `GriffaButton`: cápsula, roxo. Dois estilos: `.filled` (padrão) e `.outlined` (só borda roxa, texto roxo). Estado desabilitado (mesma cor com 40% de opacidade), controlado por `isEnabled`.
- `GriffaTextField`: selecionado (em foco: borda roxa de 2pt) e não selecionado (borda `strokeTextField` de 1pt). Tipo de teclado pelo `init(label:keyboardType:)`.
- `QuoteCard`: card com título, quote, divisor, livro e autor/página. Hoje recebe todos os dados no `init`; precisará de um `configure(...)` para ser atualizado.
- Fundos adaptam ao tema com `.systemBackground` e `.label`. Evitar `.white` e `.black` fixos.

## Barra de navegação

- `setupGriffaNavigationBar(onAdd:)` (extension de `UIViewController`) monta a barra padrão: catinho com borda à esquerda (`customView`, sem ação, `hidesSharedBackground = true`), nome do app no centro (`titleView`, sem ação) e botão `plus` à direita (`.prominent`, tint `primaryPurple`) que chama `onAdd`.
- Usada por Summary, Books e Quotes. O botão add abre um modal (sheet) placeholder.
- Alturas das imagens são fixas por constraint (as variantes clara e escura dos SVGs têm dimensões diferentes). A barra tem altura limitada (cerca de 44pt), então aumentar demais o catinho pode não ter efeito (dedução, não confirmada no simulador).
- A barra só existe dentro de um `UINavigationController` e é configurada no ViewController, não na View.

## Dark mode

Imagens com versão escura usam um único imageset com a variante `appearances: luminosity = dark` no `Contents.json`, com `preserves-vector-representation` ligado. Não criar um imageset separado para o modo escuro: `UIImage(resource:)` já troca sozinho.

## Onboarding

- Coleta só o nome. `UserProfile` tem apenas `name`.
- O botão "Continue" começa desabilitado e só habilita com nome não vazio (espaços não contam).
- Toque fora do campo ou arrastar a tela fecha o teclado (gestos com `cancelsTouchesInView = false`).

## Summary

- Mostra saudação com o nome salvo ("Hello, Nome!"), a data de hoje em inglês e maiúsculas (`WEDNESDAY, NOVEMBER 11`, formatada no `SummaryViewModel` com `.formatted(.dateTime...locale(en_US))`), o `QuoteCard` e o label "Reading now".
- O `QuoteCard` da Summary ainda usa dados de exemplo fixos.
- **"Reading now":** abaixo do label ficam os `ReadingBookCard` dos livros com status `.reading` (capa, título, autor, barra de progresso, "N% completed", "p. X of Y"), numa scroll view com stack vertical. O `SummaryViewModel(store:booksStore:)` monta os `ReadingBookContent` (`readingBooks()`) e o controller recarrega em `viewWillAppear`, para refletir livros adicionados na aba Books. Sem livros, o label "Reading now" some. O card calcula progresso e porcentagem a partir de `currentPage` e `pages`; a altura dele é definida pelo texto.
- Quote do dia (planejado): uma por dia, estável durante o dia. Plano: salvar `{ data, idDaQuote }` no `UserDefaults`; se a data salva for hoje, reutilizar; senão sortear nova evitando repetir a de ontem. Retorno opcional (sem livros = sem quote).

## Adicionar livro (AddBook)

- Aberta pelo "+" da aba Books: `BooksViewController` apresenta `AddBookViewController` dentro de um `UINavigationController` (os detents da sheet ficam no navigation). Barra com botão de texto "Cancel" (fecha a sheet) e título "Add book". Não há botão Salvar: o livro é adicionado na tela de detalhes (parte 2).
- **Busca a cada pausa na digitação** (debounce de 400 ms, cada busca cancela a anterior). Lógica no `AddBookViewModel`, que expõe um `State` (`idle`, `loading`, `loaded([Book])`, `empty`, `failed(String)`) e `onStateChange`. O controller mapeia o `State` para `AddBookView.Content` e chama `showContent(_:)`. A View não conhece o ViewModel.
- Com resultados na tela, uma nova busca não volta para `loading` (evita piscar).
- UI: scroll view (com `keyboardLayoutGuide` e `keyboardDismissMode = .onDrag`) com título, `GriffaSearchField` (`UISearchTextField` de 48pt com fundo de Liquid Glass: `UIGlassEffect` com tint `backgroundTextField`, e borda roxa de 2pt quando em foco; não usar fundo sólido, que esconde o glass), "N results", `BookResultsCard`, `LabeledDivider` ("Can't find your book?") e botão `.outlined` "Add it manually". A área de resultados começa escondida e "expande" (animação) ao digitar. Cada resultado é uma `BookRow` (tocável, com a setinha `chevron.right` à direita via `showsDisclosureIndicator: true`) dentro do card, com separadores.
- **Navegação (parte 2):** tocar em um livro faz `push` de `BookDetailViewController` (+ `BookDetailViewModel` e `BookDetailView`) dentro do mesmo navigation controller da sheet, como um NavigationLink. O botão de voltar nativo mostra "‹ Search" porque o `AddBookViewController` define `navigationItem.backButtonTitle = "Search"`. 

## Detalhes do livro (BookDetail)

- **Sem rolagem:** a tela cabe na altura visível porque a **capa é o item flexível**: prefere 300pt de altura (prioridade 700) e encolhe até 80pt em telas curtas, mantendo a proporção 197:300. Uma constraint de prioridade 999 limita o conteúdo à altura visível (não é obrigatória, para a rolagem voltar em casos extremos, como texto muito grande). Medido: sheet de 792pt → capa 177×270; 700pt → 117×178; 600pt → 52×80; sem rolagem nas três. A scroll view continua existindo só como rede de segurança.
- **A `UIImageView` da capa precisa de prioridades 1 (hugging e compression resistance) nos dois eixos.** A imagem baixada tem tamanho intrínseco grande (575×845) e, com a prioridade padrão, empurrava a capa para cima e espremia "ADD TO" e o seletor até altura 0.
- **Qualidade da capa:** o Google devolve a miniatura com `zoom=1` (128px de largura) e `edge=curl` (efeito de página dobrada). O `GoogleBooksService` reescreve a URL para `zoom=3` (~575×845px, ~100KB) e remove o `edge=curl`. Medido em 4 livros reais: zoom 2 = 300px, zoom 3 = 575px, zoom 4 = 800px, zoom 0/6 = a maior disponível (pode passar de 1500px e 600KB). A mesma URL serve para a lista e para os detalhes, então a imagem baixada na busca já está no cache ao abrir os detalhes, e o `coverData` salvo no livro é essa imagem nítida.
- Layout (scroll view + botão fixo embaixo): capa centralizada (cantos de 8pt), lista nativa **inset grouped** com Title, Author e Pages (`UICollectionView` com `UICollectionLayoutListConfiguration(appearance: .insetGrouped)` e `UIListContentConfiguration.subtitleCell()`: rótulo cinza em cima, valor embaixo), "ADD TO" com um `UISegmentedControl` das estantes (`ReadingStatus`: Want to read, Reading, Read; selecionado em `primaryPurple`) e o botão "Add to my books".
- A lista está dentro de uma scroll view, então usa `SelfSizingCollectionView`: a altura vem do `contentSize`. **A altura intrínseca precisa ter no mínimo 1pt**: com 0 o layout da lista não calcula as células e a lista fica invisível.
- O item da lista (`BookInfoItem`) é `nonisolated ... Sendable`, porque o diffable data source exige identificador `Sendable` e o projeto isola tudo no MainActor por padrão.
- **Adicionar:** `BookDetailViewModel.add()` baixa a capa (`CoverDataLoading`, implementado pelo `ImageLoader`) se houver URL e chama `BooksStore.add(_:status:coverData:)`. Se a capa não baixar, o livro entra sem ela. O `SwiftDataBooksStore` recusa duplicados pelo `googleID` (`BooksStoreError.alreadyAdded`, mostrado em alerta), grava o `status` e o `coverData` (`@Attribute(.externalStorage)`), insere no contexto e salva. Ao terminar, o controller chama `onAdded` e a sheet inteira fecha. Durante a adição o botão mostra um indicador (`GriffaButton.setLoading`).
- Verificado em código com store em memória e serviço de capas falso (status, capa gravada, duplicado, sem capa, capa que falha). Os livros salvos aparecem na aba Books (seção abaixo).
- Estados sem resultado, carregando e erro aparecem como mensagem dentro do mesmo card.
- Capas: `ImageLoader.shared` (cache `NSCache`) baixa a imagem da URL; é um singleton de propósito (exceção à regra de injeção, como um cache de imagens).
- **Ainda mockado/pendente:** "Add it manually" abrirá outra sheet com formulário (o botão não faz nada).
- **Gotcha de preview:** um tipo aninhado declarado **antes** do `init` na classe da View faz o preview do Xcode falhar ("initializer chaining ('super.init') cannot be nested in another expression"). Por isso `AddBookView.Content` fica numa `extension` no fim do arquivo. Views de tela cheia precisam ser previewadas dentro de um `UIViewController` (`controller.view = view`), senão colapsam com altura 0.

## Aba Books

- O estilo fino do segmented control (trilho `backgroundStatusBar`, segmento selecionado branco no light e roxo no dark) é compartilhado: `UISegmentedControl.applyGriffaStyle()` em `Shared/Extensions`, usado no filtro da Books e no seletor "ADD TO" dos detalhes do livro.
- Tela: título "Books", filtro (`UISegmentedControl` nativo e fino: trilho com a cor `backgroundStatusBar`, que já tem variante escura; segmento selecionado branco no light mode e `primaryPurple` no dark mode) com **All / Reading / To read / Finished** e, abaixo, uma **estante por status** (cabeçalho em maiúsculas + lista horizontal de cards). Com um filtro escolhido, só aquela estante aparece. Estantes vazias não aparecem; sem nada a mostrar, aparece uma mensagem centralizada.
- **`BookCard`** (`Shared/Components`) é o card reutilizável: capa 75×107 centralizada (cantos de 4pt), título, autor, "N% completed" e "p. X of Y", tudo centralizado, fundo `backgroundCard`, borda de 1pt `tertiaryPurple`, cantos de 8pt, largura 130 (`BookCard.width`). Recebe um `BookCardContent` (struct `nonisolated Sendable`, sem os bytes da capa na comparação). Usa `coverData` se o livro já tiver a capa salva; senão baixa pela URL (`ImageLoader`). Tem `prepareForReuse()` para uma capa antiga não aparecer em célula reaproveitada.
- A tela é uma `UICollectionView` com layout composicional: cada seção usa `orthogonalScrollingBehavior = .continuous` (lista horizontal dentro de uma lista vertical), com cabeçalho de seção (`ShelfHeaderView`, sem margem própria: o recuo de 20pt já vem da seção) e `contentInset.top = 16` abaixo do filtro. Células: `BookCardCell` embrulha o `BookCard`. Data source diffable com seção `String` (status) e item `BookCardContent`.
- `BooksViewModel(store:)` busca os livros (`BooksStore.allBooks()`, mais novos primeiro), monta as estantes (`Shelf`) conforme o filtro e expõe `emptyText`. **Progresso:** `currentPage` do livro; livros "Finished" contam como 100% (`p. N of N`); sem total de páginas mostra "Pages unknown".
- **Atualização automática:** o `SwiftDataBooksStore` publica `Notification.Name.booksDidChange` depois de salvar, e o `BooksViewModel` recarrega. O observador é registrado **de forma síncrona no `init`** (`addObserver(forName:queue:)` + `MainActor.assumeIsolated`). Com `NotificationCenter.notifications(named:)` dentro de um `Task` a primeira notificação podia se perder: o `Task` ainda não tinha começado a observar (medido).
- `ReadingStatus.read` agora se chama **"Finished"** (era "Read"), seguindo o design; vale para o seletor da tela de detalhes também. `Book` ganhou `currentPage` e `addedAt`.
- Ainda não há ação ao tocar em um card (detalhes do livro da biblioteca) nem forma de atualizar a página atual (`currentPage` só é 0 ou, em "Finished", o total).
- Verificado: lógica do ViewModel em código (estantes, filtros, textos de progresso, ordem, refresh ao adicionar) e o desenho renderizado com capas reais baixadas. Para renderizar uma tela de verdade: `RunCodeSnippet` + `view.drawHierarchy(in:afterScreenUpdates: true)` salvando um PNG (funciona com collection views; `layer.render(in:)` saiu em branco aqui).

## API de livros (Google Books)

**Status (16/11/26):** a camada de rede está implementada e o mapeamento JSON → `Book` foi verificado com JSON fixo (título, autores unidos, páginas, capa convertida para `https`, campos ausentes e resposta sem `items`). Uma busca real ("alice in wonderland") com a chave e o header de bundle ID retornou 20 livros com título, autor, páginas e capa `https` (testada fora do app, lendo a chave do arquivo). A chave chega ao `Info.plist` do app via xcconfig (verificado no build). O service é usado pelo `AddBookViewModel` (busca da sheet AddBook). Verificado com um serviço falso: debounce, cancelamento, vazio, erro 429 e limpar o campo. Arquivos: `Services/BooksService.swift` (protocolo + `BooksServiceError`), `Services/GoogleBooksService.swift` (implementação + DTOs privados + `GoogleBooksService.books(from:)` testável), `Services/APIConfig.swift` (lê a chave do `Info.plist`). `Book` ganhou `coverURL: URL?`.

**Chave de API:** fica em `Config/Secrets.xcconfig` (ignorado pelo Git; não há arquivo de exemplo, foi removido de propósito), com uma linha `GOOGLE_BOOKS_API_KEY = <chave>` sem aspas. O `Info.plist` expõe a variável como `GoogleBooksAPIKey`. Quem clonar o projeto precisa criar esse arquivo com a própria chave (Google Cloud Console → Books API → chave de API restrita a apps iOS, bundle ID `Personal.Griffa`). A pasta `Config/` fica **fora** de `Griffa/` de propósito, para o arquivo não ser copiado para dentro do app, e já está associada às configurações Debug e Release do projeto (sem isso a chave chega vazia e o service lança `missingAPIKey`). Verificado: o `Info.plist` do build para dispositivo recebe a chave (39 caracteres). Nunca colar a chave em chat, commit ou código.

Notas e decisões anteriores:

Conceito: o app faz uma requisição HTTP `GET` para uma URL, o servidor responde com JSON, o app decodifica o JSON (`Codable`) e converte para os models do app.

- Endpoint de busca: `GET https://www.googleapis.com/books/v1/volumes?q=<texto>&printType=books&maxResults=20`. Montar a URL com `URLComponents`/`URLQueryItem`, nunca concatenando string.
- **Não exige autenticação** para buscar dados públicos. API key é opcional (cota própria; sem ela, cota compartilhada e possíveis erros `429`). OAuth só seria necessário para as estantes pessoais do usuário no Google, fora do escopo.
- **Ocorrido (16/11/26):** a busca sem chave devolveu `429 RESOURCE_EXHAUSTED` com `quota_limit_value: "0"` e `quota_limit: defaultPerDayPerProject` para um projeto que não é necessariamente o nosso. Um limite 0 significa que aquele projeto não tem cota alguma, não que a cota diária foi gasta. Conclusão: na prática é preciso **criar um projeto próprio no Google Cloud, ativar a Books API e usar uma API key** (parâmetro `&key=`). O número de ~1.000 consultas/dia que citei antes não vale para o caso sem chave. O service deve tratar o `429` com mensagem clara para o usuário.
- **Ocorrido (16/11/26), chave criada:** com a chave nova (restrita a apps iOS), a busca pelo navegador devolveu `403 API_KEY_IOS_APP_BLOCKED` com `iosBundleId: <empty>`. Significa que a chave e a cota funcionam, mas a restrição "aplicativos iOS" exige o bundle ID na requisição, e o navegador não o envia. O `URLSession` também **não** envia sozinho: o service deve mandar o header `X-Ios-Bundle-Identifier` com `Bundle.main.bundleIdentifier` (bundle ID atual: `Personal.Griffa`). Para testar a chave com a restrição ligada: `curl -H "X-Ios-Bundle-Identifier: Personal.Griffa" "<url>&key=<chave>"`.
- Plano B se a cota do Google continuar bloqueada: Open Library (`https://openlibrary.org/search.json?q=...`), que não exige chave. Campos a confirmar na doc: `title`, `author_name`, `number_of_pages_median`, `cover_i` (capa em `https://covers.openlibrary.org/b/id/<cover_i>-M.jpg`). Como o service está atrás do protocolo `BooksService`, trocar a fonte não afeta as telas.
- Se usar API key: restringir por bundle ID no Google Cloud Console, guardar em `.xcconfig` ignorado pelo Git e nunca commitar a chave. Uma chave dentro do app nunca é segredo de verdade.
- Dados necessários: capa, título, autor e número de páginas (sem descrição). O JSON traz `volumeInfo.title`, `volumeInfo.authors` (lista, opcional), `volumeInfo.pageCount` (opcional) e `volumeInfo.imageLinks.thumbnail` (opcional, é só a URL da imagem).
- Estrutura em `Services/`:
  - `BooksService.swift`: protocolo `BooksService` (`searchBooks(matching:) async throws -> [Book]`) e `BooksServiceError`.
  - `GoogleBooksService.swift`: implementação com `URLSession` async/await. Checar o status HTTP (o `URLSession` não lança erro para 403/429). DTOs privados que imitam o JSON, separados do `Book`.
- `Book` precisará de um campo novo para a capa (`coverURL: URL?`). `author` vira a lista de autores unida por vírgula, com fallback "Unknown author"; `numberOfPages` com fallback 0.
- A capa é uma segunda requisição: a API devolve só a URL; a imagem é baixada à parte (`URLSession` + `UIImage(data:)`), com cache (`NSCache`) e cuidado com reuso de célula.
- O Google às vezes devolve a capa em `http://`. O iOS bloqueia (ATS), então trocar para `https://` antes de baixar.
- Campos opcionais no DTO: muitos livros vêm sem autor, páginas ou capa. Sem isso, um livro incompleto quebra a lista inteira. `items` também falta quando não há resultados.
- Busca enquanto digita: usar debounce (~400 ms) e cancelar a busca anterior (`Task.cancel()`), para não estourar a cota.
- O ViewModel recebe o `BooksService` pelo `init`. Nos testes, usar um mock do protocolo.
- Dica de aprendizado: colar a URL de busca no navegador mostra o JSON real da resposta.

## Git

- Branch principal: `main`. Trabalho em branches `feature/...` (PR de `feature/*` para `develop`).
- Mensagens no estilo Conventional Commits, em inglês: `feat:`, `fix:`, `refactor:`, `chore:`, `style:`, `docs:`.
- `.gitignore` já ignora `xcuserdata/`, `DerivedData/`, `.build/` e `.claude/settings.local.json`.

## Pendências e decisões em aberto

- `OnboardingViewController.title` ainda está como `"Read Books Page"` (resto de outra tela).
- Trailing com `+20` (empurra para fora da tela; o correto é `-20`) em: `titleLabelView` no `OnboardingView`, `welcomeLabelView` e `dateLabelView` no `SummaryView`.
- `QuotesView`, `ReadingBookCard` e `QuotesViewModel` são placeholders vazios.
- `Book` e `Quote` são classes SwiftData (`@Model`) e o `ModelContainer` já existe (criado no `SceneDelegate`). Pendente: `@Relationship(deleteRule: .cascade, inverse:)` entre `Book.quotes` e `Quote.book` (hoje o inverso não está declarado).
- A capa só foi testada com download falso; o download real (`ImageLoader.coverData(for:)`) e o app rodando de ponta a ponta ainda não foram vistos no simulador.
- Previews do Xcode: nesta versão falham de forma intermitente com "initializer chaining ('super.init') cannot be nested in another expression", mesmo em arquivos que não mudaram. O app compila normalmente. Para conferir layout, `RunCodeSnippet` renderizando a view para um PNG funciona (`drawHierarchy` para collection views; `layer.render(in:)` para telas simples). Views com Liquid Glass não aparecem assim.
- Se o clear button (x) do campo de busca dispara `.editingChanged` (e, portanto, volta para `idle`) não foi verificado.
- `Quote` não tem a página, que o `QuoteCard` exige. Decidir onde a página mora.
- O SVG do catinho tem nome `Frame 364.svg` (renomear).
- A pasta `Resources/Fonts/Source_Serif_4` tem ~70 arquivos e só `SourceSerif4-SemiBoldItalic` é usado. Todos são copiados para o app; considerar apagar os demais (manter `OFL.txt`).
