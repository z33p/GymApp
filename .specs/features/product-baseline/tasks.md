# Product Baseline Documentation Tasks

## Execution Protocol

Executar com `tlc-spec-driven`, uma tarefa por vez, gate obrigatório e commit atômico. Esta feature possui 8 tarefas e cabe em um único batch inline.

**Design**: `.specs/features/product-baseline/design.md`  
**Status**: In Progress

## Test Coverage Matrix

> Gerada a partir de `README.md`, `analysis_options.yaml`, `pubspec.yaml` e dos três testes existentes. Não há guideline adicional; strong defaults foram adaptados ao escopo documental.

| Camada | Tipo exigido | Expectativa | Padrão | Comando |
| --- | --- | --- | --- | --- |
| Markdown/spec | revisão estrutural + evidência | Seções, IDs, links, estados e claims consistentes com o código | `.specs/**/*.md` | `git diff --check` + buscas estruturais |
| Domain/data existente | testes existentes | Nenhum teste removido ou enfraquecido | `test/*_test.dart` | `flutter test` |
| Flutter app | analyzer | Nenhum erro ou lint introduzido | `lib/**`, `test/**` | `flutter analyze` |

## Gate Check Commands

| Gate | Quando | Comando |
| --- | --- | --- |
| Quick | Após cada spec | `git diff --check` e conferência de headings/IDs/links do arquivo |
| Full | Após índice e rastreabilidade | revisão de links + `flutter analyze` + `flutter test` |
| Build | Fechamento | `flutter analyze` + `flutter test` |

## Execution Plan

```text
T1 -> T2 -> T3 -> T4 -> T5 -> T6 -> T7 -> T8
```

## Task Breakdown

### T1 — Definir baseline e arquitetura documental

**What**: Criar a visão canônica, o design da documentação e este plano.  
**Where**: `.specs/features/product-baseline/{spec,design,tasks}.md`  
**Depends on**: none  
**Requirements**: PROD-01, PROD-02  
**Tests**: revisão documental  
**Gate**: Quick  
**Done when**: visão, capability map, estados, ACs, riscos, topologia e tarefas estão completos e sem contradição conhecida.

### T2 — Especificar importação e sincronização

**What**: Documentar autorização, sync incremental/preview, estados, falhas e idempotência.  
**Where**: `.specs/features/workout-import-sync/spec.md`  
**Depends on**: T1  
**Requirement**: PROD-03  
**Tests**: revisão documental  
**Gate**: Quick

### T3 — Especificar catálogo de workouts

**What**: Documentar feed, histórico, busca, filtros, cards e detalhe.  
**Where**: `.specs/features/workout-catalog/spec.md`  
**Depends on**: T2  
**Requirement**: PROD-04  
**Tests**: revisão documental  
**Gate**: Quick

### T4 — Especificar progresso

**What**: Documentar fórmulas, limites temporais, métricas e estados da tela.  
**Where**: `.specs/features/progress-insights/spec.md`  
**Depends on**: T3  
**Requirement**: PROD-05  
**Tests**: revisão documental + correspondência com `workout_stats_calculator_test.dart`  
**Gate**: Quick

### T5 — Especificar dispositivos e integrações

**What**: Separar Apple Health real, preview, Health Connect e Garmin planejados.  
**Where**: `.specs/features/device-integrations/spec.md`  
**Depends on**: T4  
**Requirement**: PROD-06  
**Tests**: revisão documental  
**Gate**: Quick

### T6 — Especificar perfil e configurações

**What**: Documentar usuário mock, tema, unidades e limitações observáveis.  
**Where**: `.specs/features/local-profile-settings/spec.md`  
**Depends on**: T5  
**Requirement**: PROD-07  
**Tests**: revisão documental  
**Gate**: Quick

### T7 — Especificar dados e privacidade local

**What**: Documentar schema ativo/inativo, retenção, limpeza e ausência de backend.  
**Where**: `.specs/features/local-data-lifecycle/spec.md`  
**Depends on**: T6  
**Requirement**: PROD-08  
**Tests**: revisão documental  
**Gate**: Quick

### T8 — Criar índice navegável e fechar rastreabilidade

**What**: Criar o catálogo de specs e conferir links/estados.  
**Where**: `.specs/README.md`  
**Depends on**: T7  
**Requirement**: PROD-09  
**Tests**: revisão documental + gates Flutter existentes  
**Gate**: Full

## Diagram-Definition Cross-Check

| Task | Depends on | Diagrama | Status |
| --- | --- | --- | --- |
| T1 | none | início | Match |
| T2 | T1 | T1 -> T2 | Match |
| T3 | T2 | T2 -> T3 | Match |
| T4 | T3 | T3 -> T4 | Match |
| T5 | T4 | T4 -> T5 | Match |
| T6 | T5 | T5 -> T6 | Match |
| T7 | T6 | T6 -> T7 | Match |
| T8 | T7 | T7 -> T8 | Match |

## Test Co-location Validation

| Task | Camada alterada | Matrix requer | Task diz | Status |
| --- | --- | --- | --- | --- |
| T1–T8 | Markdown/spec | revisão estrutural + evidência | revisão documental | OK |
| T4 | Domínio coberto por teste | correspondência com teste existente | revisão + correspondência | OK |
| T8 | Integração do catálogo | full gate | revisão + Flutter gates | OK |

## Task Granularity Check

| Task | Entrega | Status |
| --- | --- | --- |
| T1 | pacote coeso de Specify/Design/Tasks | Granular para planejamento |
| T2–T7 | uma spec funcional por tarefa | Granular |
| T8 | um índice e fechamento de links | Granular |

