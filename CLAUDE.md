# Griffa

App iOS de leitura em UIKit, com interface 100% programática (sem storyboards). Três abas: Summary, Books e Quotes. No primeiro acesso, o app abre pelo onboarding.

## Build

- Projeto: `Griffa.xcodeproj`, scheme `Griffa`.
- Dentro do Xcode, compilar com a ferramenta `BuildProject` do MCP `xcode-tools` e checar erros rápidos com `XcodeRefreshCodeIssuesInFile`.
- Os arquivos ficam em `Griffa/` (pasta sincronizada com o Xcode). Não é preciso editar o `.pbxproj` ao criar ou mover arquivos.

## Arquitetura

MVVM com UIKit.

- **View** (`UIView`): só monta a UI e as constraints. Não conhece ViewModel nem Store. Expõe closures (`onContinue`, `onNameChange`) e métodos simples (`setContinueEnabled(_:)`).
- **ViewController**: dono da navegação. Recebe o ViewModel pelo `init` e liga View ↔ ViewModel (`bindView()`). Avisa o fluxo externo com closures (`onFinish`).
- **ViewModel**: lógica e validação. Recebe dependências pelo `init` (ex.: `UserProfileStore`). Não importa UIKit.
- **Persistência**: protocolo (`UserProfileStore`) + implementação (`UserDefaultsProfileStore`), para poder trocar por mock em testes.
- **Fluxo inicial**: o `SceneDelegate` decide a tela raiz. Se `profileStore.profile == nil`, é o primeiro acesso e abre o onboarding. Senão, abre o `MainTabBarController`. O `onFinish` do onboarding troca o root para o `MainTabBarController`.
- Sem Combine. Preferir async/await quando houver código assíncrono.

## Estrutura de pastas

```
Griffa/
├── App/            AppDelegate, SceneDelegate, MainTabBarController
├── Features/       uma pasta por tela (Onboarding, Books, Quotes, Summary)
│   └── Onboarding/ OnboardingViewController, OnboardingViewModel, Views/OnboardingView
├── Models/         UserProfile
├── Persistence/    UserProfileStore
├── Resources/      Assets.xcassets, Fonts (ElmsSans, Quicksand)
└── Shared/
    ├── Components/    GriffaButton, GriffaTextField
    └── DesignSystem/  Fonts
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
- Largura é decidida por quem contém a view (leading/trailing), nunca fixa no componente. Margem lateral padrão da tela de onboarding: 20pt.
- Cada elemento do layout tem um método `setupXxx()`, chamado em ordem no `init` da view. A ordem importa para o z-order (usar `addSubview`; só o background usa `insertSubview(at: 0)`).
- Comentários em português, só onde a lógica não é óbvia.
- Fontes sempre pelo enum `Fonts` (`Fonts.body()`, `Fonts.bodyMedium()`, `Fonts.button()`...), que usa ElmsSans com Dynamic Type. Não usar `UIFont.systemFont`.
- Imagens e cores pelos símbolos gerados: `UIImage(resource: .catinho)`, `UIColor(resource: .primaryPurple)`.
- Testes: Swift Testing para unitários, XCUIAutomation para UI.

## Design system

- Cor principal: `primaryPurple`. Borda de campo: `strokeTextField`.
- `GriffaButton`: cápsula, roxo. Tem estado desabilitado (mesma cor com 40% de opacidade), controlado por `isEnabled`.
- `GriffaTextField`: dois estados, selecionado (em foco: borda roxa de 2pt) e não selecionado (borda `strokeTextField` de 1pt). O tipo de teclado vem do `init(label:keyboardType:)`.
- Fundos adaptam ao tema com `.systemBackground` e `.label`. Evitar `.white` e `.black` fixos.

## Dark mode

Imagens com versão escura usam um único imageset com a variante `appearances: luminosity = dark` no `Contents.json`, com `preserves-vector-representation` ligado. Não criar um imageset separado para o modo escuro: `UIImage(resource:)` já troca sozinho.

## Onboarding

- Coleta só o nome. `UserProfile` tem apenas `name`.
- O botão "Continue" começa desabilitado e só habilita com nome não vazio (espaços não contam).
- Toque fora do campo ou arrastar a tela fecha o teclado (gestos com `cancelsTouchesInView = false`).

## Git

- Branch principal: `main`. Trabalho em branches `feature/...`.
- Mensagens no estilo Conventional Commits, em inglês: `feat:`, `fix:`, `refactor:`, `chore:`, `style:`.

## Pendências e decisões em aberto

- `OnboardingViewController.title` ainda está como `"Read Books Page"` (resto de outra tela).
- No `OnboardingView`, o label do título usa `trailingAnchor` com `+20`, o que o empurra para fora da tela. O correto é `-20`.
- Falta `.gitignore` (`xcuserdata/` aparece como não rastreado).
- Os SVGs do mascote ficaram com nomes `Frame 364.svg` e `Frame 365.svg`. Considerar renomear.
