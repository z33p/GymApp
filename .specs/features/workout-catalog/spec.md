# Workout Catalog Specification

**Product baseline**: `../product-baseline/spec.md`  
**Implementation state**: Implementado com persistência local

## Problem Statement

Depois de importados, workouts precisam ser descobertos rapidamente, filtrados e inspecionados sem depender da plataforma de origem. O catálogo atual oferece um feed limitado, um histórico pesquisável e uma tela de detalhes baseada no registro local.

## Goals

- Mostrar workouts recentes no feed.
- Permitir busca e filtros combináveis no histórico completo.
- Exibir dados essenciais e métricas opcionais persistidas.
- Tratar listas vazias, carregamento, erro e ID inexistente.

## Out of Scope

| Item | Motivo |
| --- | --- |
| Criar, editar ou excluir workout individual | Não há ações/repository de UI para isso |
| Paginação/infinite scroll | Feed usa limite fixo; histórico carrega todos |
| Ordenação selecionável | Ordem é fixa por início descendente |
| Busca em notas/payload | Query atual cobre atividade e `source_name` |
| Exibir heart rate no detalhe | Campos existem no modelo, mas não estão na lista de fatos da UI |

## Modelo exibido

### WorkoutCard

Cada card mostra:

- tipo de atividade formatado em title case;
- badge da plataforma (`Apple Health`, `Health Connect`, `Garmin`, `Manual` ou `Preview`);
- data/hora local de início;
- duração;
- calorias quando não nulas;
- distância quando não nula;
- fonte (`sourceName` ou label da plataforma como fallback).

### Workout Detail

O detalhe mostra atividade, início, fim, duração, calorias opcionais, distância opcional, fonte e data de importação. Em debug, mostra `rawPayload` como JSON indentado e selecionável. `averageHeartRate`, `maxHeartRate` e `notes` não são apresentados atualmente.

## Feed

- Fonte: `WorkoutRepository.getFeedWorkouts()`.
- Filtro invariável: `deleted_at IS NULL`.
- Ordenação: `start_time DESC`.
- Limite default: 50.
- Item com `id` abre `/workouts/:id`; item sem `id` não possui ação.
- Lista vazia orienta conectar Apple Health e informa que workouts aparecerão após sync.

## Histórico, busca e filtros

Os controles são:

1. texto livre `query`;
2. atividade exata;
3. origem exata.

As cláusulas são combinadas com `AND`. A busca textual normaliza trim/lowercase e usa `LIKE` em `LOWER(activity_type)` ou `LOWER(COALESCE(source_name, ''))`. Os filtros de atividade e fonte usam igualdade. Todas as consultas excluem `deleted_at` não nulo e ordenam por início descendente.

As opções dos dropdowns são derivadas do conjunto completo de workouts:

- atividades distintas em ordem alfabética;
- fontes distintas usando `displaySource` em ordem alfabética.

**Limitação conhecida**: se `sourceName` for nulo, a opção mostra a label da plataforma por `displaySource`, mas a query de filtro compara `source_name`; selecionar esse fallback não encontra a linha. Uma correção futura deve alinhar geração de opção e predicado.

## Formatação

| Campo | Regra atual |
| --- | --- |
| Data/hora | timezone local, `EEE, MMM d • h:mm a` |
| Duração >= 1h | `Nh Nm` |
| Duração < 1h | `Nm` |
| Calorias | inteiro arredondado + `kcal` |
| Distância >= 1000m | quilômetros com uma casa decimal |
| Distância < 1000m | metros arredondados |
| Métrica nula | omitida no card/detalhe |

Apesar da preferência `imperial`, os formatadores atuais sempre usam `m/km` e `kcal`.

## Critérios de aceite

### P1 — Feed recente

1. WHEN existem mais de 50 workouts ativos THEN o feed SHALL retornar somente os 50 com maior `start_time`.
2. WHEN existem workouts soft-deleted THEN o feed SHALL excluí-los.
3. WHEN o feed possui dados THEN cada item SHALL mostrar atividade, plataforma, início, duração, fonte e somente as métricas opcionais não nulas.
4. WHEN o feed está vazio THEN a UI SHALL mostrar a orientação de conexão/importação, sem card fictício.
5. WHEN a consulta falha THEN a UI SHALL mostrar `Failed to load feed: <error>`.

### P1 — Histórico pesquisável

1. WHEN nenhuma opção está selecionada THEN o histórico SHALL listar todos os workouts ativos em ordem decrescente de início.
2. WHEN `query` contém espaços laterais e variação de caixa THEN o sistema SHALL aplicar trim e comparação case-insensitive.
3. WHEN `activityType`, `sourceName` e `query` estão preenchidos THEN o sistema SHALL exigir que a linha satisfaça os filtros exatos e ao menos um campo da busca textual.
4. WHEN filtros não encontram resultado THEN a UI SHALL mostrar `No workouts match your current filters.`.
5. WHEN o usuário limpa um dropdown com `All activities` ou `All sources` THEN o estado SHALL remover somente o filtro correspondente.
6. WHEN a consulta falha THEN a UI SHALL mostrar `Failed to load history: <error>`.

### P1 — Detalhe

1. WHEN o usuário toca um card persistido THEN a navegação SHALL abrir `/workouts/<id>`.
2. WHEN o ID existe THEN o detalhe SHALL mostrar os oito fatos definidos, omitindo calorias/distância nulas.
3. WHEN o ID não existe ou o parâmetro não é inteiro THEN a UI SHALL mostrar `Workout not found.`.
4. WHEN a consulta falha THEN a UI SHALL mostrar `Failed to load workout: <error>`.
5. WHEN `kDebugMode` é verdadeiro e `rawPayload` existe THEN a UI SHALL renderizar JSON indentado selecionável.
6. WHEN `kDebugMode` é falso THEN a UI SHALL ocultar o payload bruto.

## Edge Cases e limitações

- Histórico não tem debounce; cada alteração de busca invalida a consulta.
- Histórico não pagina e pode crescer sem limite prático definido.
- Busca não cobre label de plataforma quando `source_name` é nulo.
- `getWorkoutById` não filtra `deleted_at`; um item soft-deleted ainda pode ser aberto diretamente pelo ID.
- `activityType` desconhecido é exibido por transformação de underscore/title case.
- Rota inválida converte o ID para `0`, não produz tela de erro de navegação.

## Evidência e cobertura automatizada

| Comportamento | Evidência | Cobertura atual |
| --- | --- | --- |
| Query do feed/histórico/detalhe | `LocalWorkoutDataSource` | Sem testes dedicados de consulta/filtro |
| Card e estados de tela | `FeedScreen`, `HistoryScreen`, `WorkoutCard` | Sem widget tests |
| Detalhe/debug payload | `WorkoutDetailScreen` | Sem widget tests |
| Formatação | `Formatters` | Sem teste dedicado |
| Mapeamento do workout | `ImportedWorkout` | `workout_mapping_test.dart` cobre parte dos campos |

## Requirement Traceability

| ID | Requisito | Implementação | Estado documental |
| --- | --- | --- | --- |
| WORK-01 | Feed limitado e ordenado | `getFeedWorkouts`, `FeedScreen` | Documented |
| WORK-02 | Busca e filtros combinados | `getWorkouts`, `HistoryScreen` | Documented |
| WORK-03 | Card e métricas opcionais | `WorkoutCard` | Documented |
| WORK-04 | Detalhe e not-found | `WorkoutDetailScreen` | Documented |
| WORK-05 | Payload somente em debug | `WorkoutDetailScreen` | Documented |
| WORK-06 | Formatação atual | `Formatters` | Documented |
| WORK-07 | Limitações/gaps de teste | esta spec | Documented |

**Open questions**: nenhuma para o baseline. Paginação, correção do filtro fallback e exposição de heart rate exigem specs próprias.

