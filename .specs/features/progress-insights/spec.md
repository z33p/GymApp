# Progress Insights Specification

**Product baseline**: `../product-baseline/spec.md`  
**Implementation state**: Implementado sobre workouts locais

## Problem Statement

O histórico bruto não responde rapidamente quanto o usuário treinou no período atual. A feature agrega workouts locais em seis indicadores simples, sem backend, metas ou séries históricas.

## Goals

- Calcular contagens semanais e mensais.
- Somar duração, calorias e distância da semana.
- Calcular streak diário consecutivo a partir do dia atual.
- Mostrar loading e erro enquanto os dados locais são resolvidos.

## Out of Scope

| Item | Motivo |
| --- | --- |
| Gráficos e comparação entre períodos | A UI atual contém somente cards |
| Metas, PRs e recomendações | Não existem modelos/regras correspondentes |
| Conversão imperial | `Formatters.distanceMeters` permanece métrico |
| Estatísticas por tipo de atividade | Calculator agrega todos os workouts |
| Streak que termina ontem | Regra atual exige treino no dia de referência |

## Fonte de dados

`progressStatsProvider` aguarda `allWorkoutsProvider`, que consulta workouts com `deleted_at IS NULL`, e passa a lista ao `WorkoutStatsCalculator`. Qualquer mudança no `refreshTickerProvider` invalida a fonte e recalcula a tela.

## Regras de cálculo

O relógio de referência é convertido para UTC.

| Indicador | Regra precisa |
| --- | --- |
| Workouts this week | quantidade com `startTime >= segunda-feira 00:00 UTC` da semana de referência |
| Workouts this month | quantidade com `startTime >= primeiro dia 00:00 UTC` do mês de referência |
| Duration this week | soma de `durationSeconds` dos workouts da semana |
| Calories this week | soma de `activeEnergyKcal ?? 0` dos workouts da semana |
| Distance this week | soma de `distanceMeters ?? 0` dos workouts da semana |
| Current streak | dias UTC distintos e consecutivos iniciando no dia de referência, máximo 365 |

Datas duplicadas contam uma única vez para streak, mas cada workout conta e soma normalmente nos demais indicadores.

## Apresentação

A rota `/progress` usa grid de duas colunas com seis `StatCard`s. Duração usa `Formatters.duration`; distância usa métrico e cai para `0 m`; calorias são arredondadas e exibidas como inteiro `kcal`; streak usa `<N> days`.

## Critérios de aceite

### P1 — Totais do período

1. WHEN um workout começa exatamente na segunda-feira 00:00 UTC THEN o sistema SHALL incluí-lo na semana.
2. WHEN um workout começa antes da segunda-feira 00:00 UTC THEN o sistema SHALL excluí-lo de todos os totais semanais.
3. WHEN um workout começa no primeiro instante do mês THEN o sistema SHALL incluí-lo na contagem mensal.
4. WHEN métricas opcionais são nulas THEN as somas de calorias e distância SHALL adicionar zero para esses campos.
5. WHEN não existem workouts THEN todos os valores numéricos SHALL ser zero e os cards SHALL mostrar `0`, `0m`, `0 kcal`, `0 m` e `0 days` conforme seu tipo.

### P1 — Streak

1. WHEN existem workouts hoje e em cada dia UTC imediatamente anterior THEN o sistema SHALL contar a sequência até o primeiro dia ausente.
2. WHEN existem múltiplos workouts no mesmo dia THEN esse dia SHALL incrementar a streak somente uma vez.
3. WHEN não existe workout no dia de referência THEN `currentStreakDays` SHALL ser zero, ainda que ontem tenha workout.
4. WHEN a sequência excede 365 dias THEN `currentStreakDays` SHALL ser 365.

### P1 — Estados da tela

1. WHEN o provider está carregando THEN a UI SHALL mostrar `CircularProgressIndicator`.
2. WHEN o cálculo conclui THEN a UI SHALL renderizar exatamente seis cards com os indicadores definidos.
3. WHEN a consulta/cálculo falha THEN a UI SHALL mostrar `Failed to load progress: <error>`.

## Edge Cases e limitações

- Os filtros de semana e mês possuem limite inferior, mas não limite superior; workouts com data futura também entram nas contagens atuais.
- O cálculo usa limites UTC, enquanto datas são exibidas em timezone local; perto da meia-noite a percepção do dia pode divergir.
- Duração negativa ou métricas negativas não são validadas antes da soma.
- A streak só representa uma sequência que inclui hoje, não a última sequência encerrada.
- `maxStreakDays = 365` limita custo e resultado mesmo com histórico maior.
- Não há persistência de agregados; tudo é recalculado em memória.

## Evidência e cobertura automatizada

`test/workout_stats_calculator_test.dart` cobre um cenário com dois dias consecutivos na mesma semana/mês e verifica exatamente:

- 2 workouts semanais;
- 2 mensais;
- 5.400 segundos;
- 750 kcal;
- 27.000 metros;
- streak 2.

Não existem testes dedicados para lista vazia, fronteiras semana/mês, nulos, ausência de workout hoje, duplicidade diária, limite 365, datas futuras ou estados do widget.

## Requirement Traceability

| ID | Requisito | Implementação | Estado documental |
| --- | --- | --- | --- |
| PROG-01 | Semana iniciando segunda UTC | `WorkoutStatsCalculator.calculate` | Documented |
| PROG-02 | Mês iniciando no primeiro dia UTC | `WorkoutStatsCalculator.calculate` | Documented |
| PROG-03 | Somas com nulos tratados como zero | `WorkoutStatsCalculator.calculate` | Documented |
| PROG-04 | Streak distinta, a partir de hoje, limitada a 365 | `WorkoutStatsCalculator.calculate` | Documented |
| PROG-05 | Seis cards e estados async | `ProgressScreen` | Documented |
| PROG-06 | Limitações temporais e cobertura explícitas | esta spec | Documented |

**Open questions**: nenhuma para o baseline. Limite superior do período, timezone de negócio e definição alternativa de streak precisam de decisão de produto antes de mudança.

