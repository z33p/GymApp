# Fauna Foundation — Tasks

**Spec:** `.specs/features/social-gamification-roadmap/spec.md`
**Design:** `.specs/features/social-gamification-roadmap/design.md`
**Status:** Done — Fase 0

## Execution result

- T1: complete — rank calculator and 4 unit tests.
- T2: complete — mascot widget and 2 widget tests.
- T3: complete — Habitat route, provider and 2 widget tests.
- T4: complete — analyzer, 13 tests and debug APK gate passed.

## Test Coverage Matrix

> Guideline: `tlc-spec-driven`; strong defaults applied to domain and widget layers.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
| --- | --- | --- | --- | --- |
| Domain rank calculator | unit | Every tier boundary, rolling Forma, annual Legado and empty state | `test/*fauna*test.dart` | `flutter test` |
| Mascot widget | widget | Each rendered tier label/emoji and accessible semantics | `test/*fauna*test.dart` | `flutter test` |
| Habitat screen/provider | widget | Loading, populated state and no-workout state | `test/*habitat*test.dart` | `flutter test` |
| Config/routing | none | Analyzer/build gate | `lib/core/router`, `lib/core/config` | `flutter analyze` |

## Gate Check Commands

| Gate Level | When to Use | Command |
| --- | --- | --- |
| Quick | Domain or widget task | `flutter test` |
| Build | Last task of Fase 0 | `flutter analyze; flutter test; flutter build apk --debug` |

## Execution Plan

```text
T1 → T2 → T3 → T4
```

### T1: Fauna rank calculator

**What:** Criar o modelo determinístico de Forma, Legado e tiers com thresholds locais provisórios.
**Where:** `lib/features/gamification/domain/fauna_rank.dart`, `test/fauna_rank_calculator_test.dart`
**Depends on:** None
**Requirement:** FAUNA-04
**Done when:**

- [x] Estado vazio começa em Rato com Forma zero.
- [x] Limites de Rato/Lobo/Urso/Rinoceronte/Gorila são testados.
- [x] Forma considera somente workouts da janela móvel de 28 dias.
- [x] Legado anual permanece contando workouts do ano mesmo quando antigos para Forma.
- [x] `flutter test` passa com os testes novos e existentes.

**Tests:** unit
**Gate:** quick
**Commit:** `feat(gamification): add fauna rank calculator`

### T2: Mascote Fauna

**What:** Criar widget reutilizável que mostra emoji, nome, tier e descrição do animal atual.
**Where:** `lib/features/gamification/presentation/fauna_mascot.dart`, `test/fauna_mascot_test.dart`
**Depends on:** T1
**Requirement:** FAUNA-05
**Done when:**

- [x] Cada tier renderiza nome e mascote correspondente.
- [x] O widget expõe semântica legível para acessibilidade.
- [x] Estado de facção não selecionada não afirma Leão ou Dragão.
- [x] `flutter test` passa.

**Tests:** widget
**Gate:** quick
**Commit:** `feat(gamification): add fauna mascot widget`

### T3: Habitat/Home

**What:** Adicionar provider de progresso Fauna, tela Habitat e rota/tab inicial substituindo Feed como entrada principal.
**Where:** `lib/core/config/app_providers.dart`, `lib/core/router/app_router.dart`, `lib/core/widgets/app_shell.dart`, `lib/features/gamification/presentation/habitat_screen.dart`, `test/habitat_screen_test.dart`
**Depends on:** T1, T2
**Requirement:** FAUNA-04, FAUNA-05
**Done when:**

- [x] Home mostra mascote, tier, Forma, Legado e progresso para o próximo tier.
- [x] Home mostra CTA `Sincronizar agora` e resumo dos workouts recentes.
- [x] Estado sem workouts mostra Rato e orientação para sincronizar.
- [x] Tab inicial é `Habitat`; Feed continua acessível por rota existente.
- [x] Widget test cobre estado populado, vazio e loading.
- [x] `flutter test` passa.

**Tests:** widget
**Gate:** quick
**Commit:** `feat(gamification): add habitat home`

### T4: Validação da Fase 0

**What:** Atualizar rastreabilidade/validação da Fase 0 e executar todos os gates com APK debug.
**Where:** `.specs/features/social-gamification-roadmap/spec.md`, `.specs/features/social-gamification-roadmap/validation.md`, `.specs/STATE.md`
**Depends on:** T3
**Requirement:** FAUNA-04, FAUNA-05
**Done when:**

- [x] Requisitos FAUNA-04/05 apontam para implementação real.
- [x] `flutter analyze` passa sem issues.
- [x] `flutter test` passa sem reduzir a contagem existente.
- [x] `flutter build apk --debug` passa.
- [x] Verificação independente é executada após o último commit.

**Tests:** none — documentação e gate de build
**Gate:** build
**Commit:** `docs(gamification): validate fauna foundation`
