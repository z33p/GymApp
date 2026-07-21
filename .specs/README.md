# GymApp Specifications

Este diretório é a fonte de verdade para comportamento, decisões e validação do GymApp. O baseline descreve o que a `master` realmente entrega e separa explicitamente implementação, preview, planejamento e fora de escopo.

## Comece aqui

1. [Product baseline](features/product-baseline/spec.md) — visão, usuário, capability map, navegação e critérios globais.
2. [Product documentation design](features/product-baseline/design.md) — topologia, convenções, riscos e fontes de evidência.
3. [Project decisions and handoff](STATE.md) — decisões arquiteturais vigentes e último estado de trabalho.

## Specs funcionais

| Domínio | Spec | O que cobre | Estado do produto |
| --- | --- | --- | --- |
| Importação e sincronização | [Workout Import & Synchronization](features/workout-import-sync/spec.md) | HealthKit, preview, triggers, anchor, upsert, estados e falhas | Apple Health iOS + preview implementados |
| Catálogo de workouts | [Workout Catalog](features/workout-catalog/spec.md) | Feed, histórico, busca, filtros, cards, detalhe e formatação | Implementado |
| Progresso | [Progress Insights](features/progress-insights/spec.md) | Totais semanais/mensais, duração, calorias, distância e streak | Implementado |
| Dispositivos | [Device Integrations](features/device-integrations/spec.md) | Apple Health, preview, permissões, Health Connect e Garmin | Apple Health/preview implementados; demais planejados |
| Perfil e preferências | [Local Profile & Settings](features/local-profile-settings/spec.md) | Usuário mock, tema, unidade e limpeza | Parcial: conversão imperial não implementada |
| Dados e privacidade | [Local Data Lifecycle & Privacy](features/local-data-lifecycle/spec.md) | SQLite, SharedPreferences, retenção, schema inativo e local-only | Implementado conforme baseline |

## Baseline técnico

- [Development Environment](features/development-environment/spec.md)
- [Development Environment Validation](features/development-environment/validation.md)

Ambiente validado: Flutter 3.44.7, Dart 3.12.2, Temurin JDK 17 e Android SDK/API 36.

## Roadmap de produto planejado

- [Fauna Social & Gamification](features/social-gamification-roadmap/spec.md) — grupos privados, regras de score, fauna, facções, ranking e mural; Fase 0 local entregue, social remoto pendente.
- [Product Design](features/social-gamification-roadmap/design.md) — fluxo, telas, funções, contratos e riscos da experiência proposta.

## Estados usados

| Estado | Significado |
| --- | --- |
| Implementado | Fluxo funcional existe no código atual |
| Implementado parcialmente | Parte observável existe, mas o resultado completo não é entregue |
| Preview | Dados simulados e identificados como demonstração |
| Planejado | Placeholder/TODO sem integração funcional |
| Fora do MVP | Não há fluxo funcional no baseline |
| Schema inativo | Estrutura de dados existe sem domínio, repository/provider e UI completos |

## Capability snapshot

### Entregue

- Bootstrap com perfil mock local.
- Apple Health no iOS por MethodChannel/HealthKit.
- Preview cross-platform.
- Sync no startup, resume e manual.
- Persistência/upsert SQLite.
- Feed, histórico, filtros e detalhe.
- Seis métricas de progresso.
- Tema persistente e limpeza local.

### Parcial ou limitado

- Unidade imperial é salva, mas não aplicada.
- Heart rate existe no modelo/permissão, mas não é agregado no bridge nem exibido no detalhe.
- Soft delete existe no schema, mas não há ação de exclusão individual.
- `check_ins` é somente schema reservado.
- Cobertura automatizada possui três testes e não cobre UI, sync state ou bridge nativo.

### Planejado, não entregue

- Health Connect.
- Garmin.
- Autenticação real/backend.
- Sincronização em nuvem.
- Criação manual de workouts.
- Experiência social/check-ins.

## Como evoluir uma feature

1. Leia esta página, o product baseline e a spec do domínio afetado.
2. Leia as decisões ativas em `STATE.md`.
3. Crie uma nova pasta em `features/<feature>/` usando `tlc-spec-driven`.
4. Declare quais requisitos do baseline serão preservados, alterados ou superseded.
5. Não mude `Planejado` para `Implementado` sem código, gate e validação independentes.
6. Atualize este índice somente quando uma spec nova se tornar fonte de verdade.

## Qualidade e evidência

Specs registram duas formas de evidência separadas:

- **Implementação**: arquivo/símbolo que produz o comportamento atual.
- **Cobertura automatizada**: teste e assertions existentes.

Ausência de teste não é mascarada como cobertura. O baseline pode documentar comportamento comprovado por leitura de código e, ao mesmo tempo, registrar a lacuna que uma feature futura deverá fechar.
