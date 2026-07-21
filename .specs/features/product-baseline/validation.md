# Product Baseline Validation

**Date**: 2026-07-21  
**Spec**: `.specs/features/product-baseline/spec.md`  
**Diff range**: `e5ca178..e96104f`  
**Verifier**: segundo Verifier independente (author != verifier)  
**Scope**: baseline canônico, seis specs funcionais e `.specs/README.md`

## Verdict

**Overall**: PASS — Ready

Os claims, estados de entrega, links e discrimination sensor são consistentes. Não foi encontrada contradição real entre a documentação e a implementação inspecionada.

A cobertura automatizada permanece estreita, mas essa limitação está declarada nas specs e no índice. Para este baseline documental, evidência direta de código foi aceita separadamente de cobertura por teste.

## Task Completion

| Task | Status | Evidence |
| --- | --- | --- |
| T1 — Baseline e arquitetura | Done | `product-baseline/{spec,design,tasks}.md` |
| T2 — Importação e sync | Done | `workout-import-sync/spec.md` |
| T3 — Catálogo | Done | `workout-catalog/spec.md` |
| T4 — Progresso | Done | `progress-insights/spec.md` |
| T5 — Dispositivos | Done | `device-integrations/spec.md` |
| T6 — Perfil/configurações | Done | `local-profile-settings/spec.md` |
| T7 — Dados/privacidade | Done | `local-data-lifecycle/spec.md` |
| T8 — Índice/rastreabilidade | Done | `.specs/README.md`; 11 links, 0 inválidos |

## Spec-Anchored Requirements

| Requirement | Spec-defined outcome | Evidence | Result |
| --- | --- | --- | --- |
| PROD-01 | Visão, usuário e problema local-first | `product-baseline/spec.md:7`, `:11` | PASS |
| PROD-02 | Capability map distingue implementado, parcial, preview, planejado e fora do MVP | `product-baseline/spec.md:23-40`; estados confrontados com código | PASS |
| PROD-03 | Bootstrap, resume, HealthKit, preview, upsert e falha recuperável | `app_providers.dart:72-85`; `main.dart:37-40`; `AppDelegate.swift:49`, `:120-124`; `mock_fitness_data_source.dart:8-46`; `fitness_import_repository_impl.dart:23-70`; `local_workout_data_source.dart:52-80` | PASS |
| PROD-04 | Feed, histórico e detalhe refletem filtros, soft delete, limite, not-found e payload debug | `local_workout_data_source.dart:9-49`; `workout_detail_screen.dart:23`, `:25-34`, `:62-67` | PASS |
| PROD-05 | Seis métricas e streak seguem limites e resultados documentados | `workout_stats_calculator.dart:9-41`; `workout_stats_calculator_test.dart:37-42` | PASS |
| PROD-06 | Apple Health/preview entregues; Health Connect/Garmin planejados | `AppDelegate.swift:82`, `:189-191`; `devices_screen.dart:23-40`, `:199`; `device_integration_repository_impl.dart:16-24`, `:55-63` | PASS |
| PROD-07 | Perfil mock, tema/unidades persistem; conversão imperial não é alegada | `mock_auth_data_source.dart:14-28`; `app_providers.dart:157-186`; `app_settings.dart:3-20`; `formatters.dart:22-28`; `app_providers.dart:144-150` | PASS |
| PROD-08 | Schema, índices, unicidade, limpeza e separação de preferências corretos | `app_database.dart:12-17`, `:19-74`, `:81-88`; `local_workout_data_source.dart:52-80` | PASS |
| PROD-09 | Índice cobre baseline, seis domínios e baseline técnico | `.specs/README.md:7-25`; checker 11/11 | PASS |

**Status**: 9/9 requisitos correspondem ao resultado definido; 0 spec-precision gaps.

## Selective Domain Verification

### Importação e sincronização

- Bootstrap garante usuário mock e tenta sync sem bloquear navegação após falha.
- Resume chama sync com `manual: false`.
- Bridge usa lookback de 90 dias na query ancorada.
- Fallback produz exatamente dois workouts de preview.
- Estado percorre `syncing -> success|failed`; falha preserva anchor/último sucesso e relança.
- Upsert preserva `id` e `importedAt` e atualiza métricas/`updatedAt`.

Coverage boundary: mapping e upsert possuem testes parciais; estado, bridge e triggers não possuem assertions dedicadas. A limitação está declarada.

### Catálogo

- Feed aplica `deleted_at IS NULL`, `start_time DESC` e limite 50.
- Histórico combina atividade, fonte e busca textual com `AND`.
- Detalhe apresenta not-found e payload JSON somente sob `kDebugMode`.
- Exceção do detalhe por ID não filtrar soft delete está documentada.

Coverage boundary: consultas, UI e formatadores não têm testes dedicados; declarado na spec.

### Progresso

- Semana inicia segunda UTC; mês inicia no primeiro dia UTC.
- Métricas nulas somam zero.
- Streak exige workout hoje, usa dias distintos e limita a 365.
- Teste confere `2`, `2`, `5400`, `750`, `27000` e `2`.

Coverage boundary: fronteiras, vazios, nulos, limite e widget estão listados como não testados.

### Dispositivos

- Apple Health aparece somente em iOS.
- Autorização usa `toShare: nil`.
- Heart rate é solicitado para leitura, mas média/máxima permanecem nulas.
- Health Connect e Garmin retornam `connected: false`/`coming_soon` e cards planejados.

Coverage boundary: UI, repository, MethodChannel e bridge não possuem testes dedicados.

### Perfil, preferências e dados

- Perfil padrão é idempotente.
- Tema e unidades persistem; `AppUnits` não participa dos formatadores.
- Limpeza apaga o banco, recria perfil mock e não toca SharedPreferences.
- Schema v1 contém quatro tabelas, constraint de unicidade e dois índices.
- `check_ins` está corretamente classificado como schema inativo.

Coverage boundary: preferências, soft delete, sync state e privacidade dependem de inspeção estática, conforme declarado.

## Automated Test Evidence

| Test | Assertions | Spec match |
| --- | --- | --- |
| `workout_mapping_test.dart` | linhas 21-26: ID, plataforma, duração, energia, distância e fonte | Exact |
| `workout_stats_calculator_test.dart` | linhas 37-42: seis resultados numéricos | Exact |
| `local_workout_upsert_test.dart` | linhas 43-45: uma linha e métricas atualizadas | Exact para dedup/update |

Nenhum teste foi apresentado como cobrindo mais do que suas assertions demonstram.

## Gate Check

- **Commands**: `flutter analyze`; `flutter test`
- **Analyzer**: exit 0, no issues
- **Tests**: 3 passed, 0 failed, 0 skipped
- **Before/after count**: 3 -> 3, delta 0 esperado para documentação
- **Link checker**: 11 links, 0 inválidos

**Result**: PASS

## Discrimination Sensor

| Mutation | Target | Description | Result |
| --- | --- | --- | --- |
| 1 | cópia temporária de `device-integrations/spec.md` | `Health Connect | Android | Planejado` -> `Implementado` | Killed |

O checker confrontou a mutação com `permissionStatus: 'coming_soon'`, `connected: false`, mensagem `planned for a future release` e card `Coming soon`.

- **Sensor depth**: lightweight, proporcional a feature documental
- **Scratch cleanup**: removido; árvore real intocada
- **Result**: 1/1 killed — PASS

## Code Quality

| Principle | Status |
| --- | --- |
| Nenhuma capacidade além do baseline foi alegada | PASS |
| Estados parciais, preview e planejados permanecem distintos | PASS |
| Estrutura por domínio corresponde ao design | PASS |
| Claims estão ancorados em código existente | PASS |
| Testes e evidência estática estão separados | PASS |
| Lacunas de cobertura são explícitas | PASS |
| Requisitos e links têm rastreabilidade | PASS |

## Known Coverage Debt

- UI, filtros e estados de tela sem widget tests.
- Estado de sync e falhas sem testes dedicados.
- Bridge HealthKit sem XCTest.
- Preferências e limpeza integral sem testes dedicados.
- Edge cases do calculador de progresso sem cobertura.

Essas ausências são dívida conhecida e explicitamente declarada; não contradizem o snapshot documental.

## Requirement Traceability Outcome

| Requirement | Previous | Outcome |
| --- | --- | --- |
| PROD-01 | Implementing | Verified |
| PROD-02 | Implementing | Verified |
| PROD-03 | Implementing | Verified |
| PROD-04 | Implementing | Verified |
| PROD-05 | Implementing | Verified |
| PROD-06 | Implementing | Verified |
| PROD-07 | Implementing | Verified |
| PROD-08 | Implementing | Verified |
| PROD-09 | Implementing | Verified |

## Summary

- **Spec-anchored check**: 9/9; 0 precision gaps
- **Gate**: analyzer limpo; 3/3 testes
- **Links**: 11/11 válidos
- **Sensor**: 1/1 mutant killed; scratch removido
- **Contradições reais**: nenhuma
- **Lessons**: nenhuma — PASS limpo, sem sinal grounded

