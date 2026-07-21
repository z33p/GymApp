# GymApp Product Baseline Specification

**Status**: Baseline atual em documentação  
**Baseline de código**: `master` em `e5ca178`  
**Escopo**: comportamento existente do MVP, não roadmap comprometido

## Visão do produto

O GymApp é um aplicativo mobile local-first para reunir treinos registrados por dispositivos e aplicativos fitness. O vertical slice atual prioriza treinos gravados no Apple Health, especialmente por Apple Watch, e permite importar, consultar e resumir esses treinos sem depender de conta real ou backend.

## Usuário e problema

O usuário-alvo do MVP é uma pessoa fisicamente ativa que já registra exercícios em outra plataforma e quer consultar uma visão única do histórico e do progresso. O problema central é evitar cadastro manual duplicado e transformar registros externos em informação local útil.

## Princípios do produto atual

1. **Local-first**: workouts, perfil de demonstração e estado de sincronização ficam no SQLite do aparelho.
2. **Importar antes de editar**: o MVP consome workouts externos; não oferece criação ou edição manual.
3. **Funcionar fora do iOS**: quando HealthKit não está disponível, dados de preview mantêm o vertical slice demonstrável.
4. **Distinguir realidade de intenção**: Health Connect e Garmin aparecem como planejados, não como integrações funcionais.
5. **Falhar de forma recuperável**: falhas de sync não apagam o último estado bem-sucedido e podem ser repetidas manualmente.

## Matriz de capacidades

| Área | Capacidade | Estado atual | Evidência principal |
| --- | --- | --- | --- |
| Inicialização | Criar perfil local de demonstração | Implementado | `bootstrapProvider`, `MockAuthDataSource.ensureUser` |
| Sincronização | Importar workouts do Apple Health | Implementado no iOS | `AppleHealthDataSource`, `ios/Runner/AppDelegate.swift` |
| Sincronização | Usar workouts de preview sem HealthKit | Implementado | `MockFitnessDataSource` |
| Sincronização | Executar sync no startup, resume e sob demanda | Implementado | `bootstrapProvider`, `GymApp.didChangeAppLifecycleState`, `SyncController` |
| Persistência | Fazer upsert por plataforma + ID externo | Implementado | `LocalWorkoutDataSource.upsertWorkouts` |
| Feed | Listar até 50 workouts ativos, mais recentes primeiro | Implementado | `getFeedWorkouts(limit: 50)` |
| Histórico | Buscar e filtrar por atividade e origem | Implementado | `HistoryScreen`, `LocalWorkoutDataSource.getWorkouts` |
| Detalhes | Exibir fatos do workout e payload bruto em debug | Implementado | `WorkoutDetailScreen` |
| Progresso | Calcular totais semanais/mensais e streak | Implementado | `WorkoutStatsCalculator` |
| Preferências | Persistir tema e unidade escolhida | Implementado parcialmente | `SettingsController`; a unidade ainda não altera os formatadores |
| Dados locais | Limpar banco e recriar perfil mock | Implementado | `SyncController.clearLocalData` |
| Android | Importar via Health Connect | Planejado; somente placeholder | `DevicesScreen`, `DeviceIntegrationRepositoryImpl` |
| Garmin | Autorizar e importar workouts | Planejado; somente placeholder | `DevicesScreen`, `DeviceIntegrationRepositoryImpl` |
| Autenticação | Conta real e sessão remota | Fora do MVP | somente `LocalAuthRepository` e usuário mock |
| Nuvem/social | Backend, sync entre aparelhos e check-ins publicados | Fora do MVP | não há cliente de backend; tabela `check_ins` não possui fluxo de UI |

## Navegação e superfícies

| Rota | Superfície | Resultado observável |
| --- | --- | --- |
| `/feed` | Activity Feed | Lista workouts recentes ou orienta conectar/importar |
| `/history` | Workout History | Busca textual, filtros de atividade/origem e lista completa |
| `/progress` | Progress | Seis indicadores agregados do histórico local |
| `/devices` | Connect Devices | Estado do Apple Health/preview, sync manual e placeholders futuros |
| `/settings` | Settings | Perfil mock, tema, unidade e limpeza local |
| `/workouts/:id` | Workout Detail | Fatos do workout, estado não encontrado e payload em debug |

## Fluxo funcional principal

```mermaid
flowchart LR
    A[App inicia ou volta ao foreground] --> B[Bootstrap garante usuário mock]
    B --> C{HealthKit disponível?}
    C -->|Sim| D[HealthKit via MethodChannel]
    C -->|Não| E[Preview local]
    D --> F[Mapear payload para ImportedWorkout]
    E --> F
    F --> G[Upsert SQLite por platform + externalId]
    G --> H[Salvar estado/anchor da sincronização]
    H --> I[Atualizar Feed, History e Progress]
```

## Modelo funcional de workout

Cada workout importado possui identidade local e externa opcionais, plataforma, fonte, tipo de atividade, início, fim, duração, métricas opcionais, notas, payload bruto e timestamps de importação/atualização/exclusão lógica.

No HealthKit atual, calorias e distância são importadas quando disponíveis. Frequência cardíaca média e máxima estão presentes no modelo, porém sua agregação nativa está explicitamente adiada.

## Histórias e critérios de aceite do baseline

### P1 — Importar workouts automaticamente

**User Story**: Como atleta, quero que meus workouts externos sejam importados para não cadastrá-los novamente.

1. WHEN o app conclui o bootstrap THEN o sistema SHALL garantir o perfil mock local e tentar uma sincronização Apple Health.
2. WHEN o app volta ao estado `resumed` THEN o sistema SHALL iniciar uma sincronização não manual.
3. WHEN HealthKit está disponível THEN o sistema SHALL ler workouts por query ancorada com lookback inicial de 90 dias.
4. WHEN HealthKit não está disponível THEN o sistema SHALL importar os dois workouts determinísticos de preview.
5. WHEN o mesmo par `platform + externalId` é recebido novamente THEN o sistema SHALL atualizar a linha existente sem duplicá-la e preservar `importedAt`.
6. WHEN uma sincronização falha THEN o sistema SHALL persistir estado `failed`, manter o último sucesso/anchor e propagar o erro para recuperação.

### P1 — Consultar workouts

**User Story**: Como atleta, quero localizar e inspecionar meus workouts importados.

1. WHEN o feed é aberto THEN o sistema SHALL mostrar no máximo 50 workouts não excluídos em ordem decrescente de início.
2. WHEN busca, atividade e origem são combinadas no histórico THEN o sistema SHALL aplicar todos os filtros simultaneamente aos workouts não excluídos.
3. WHEN um workout existente é aberto THEN o sistema SHALL exibir atividade, início, fim, duração, origem, importação e métricas opcionais disponíveis.
4. WHEN um ID inexistente é aberto THEN o sistema SHALL exibir `Workout not found.`.
5. WHEN o build é debug e existe payload bruto THEN o sistema SHALL exibi-lo como JSON selecionável; builds não debug SHALL ocultá-lo.

### P1 — Acompanhar progresso

**User Story**: Como atleta, quero visualizar agregados do meu histórico local.

1. WHEN a tela de progresso é aberta THEN o sistema SHALL calcular workouts da semana corrente, workouts do mês corrente, duração, calorias e distância da semana.
2. WHEN existe workout no dia de referência e nos dias imediatamente anteriores THEN o sistema SHALL contar a sequência consecutiva, limitada a 365 dias.
3. WHEN não existe workout no dia de referência THEN o sistema SHALL retornar streak zero.

### P2 — Controlar integração e dados locais

**User Story**: Como usuário do MVP, quero entender a origem dos dados e controlar preferências locais.

1. WHEN Apple Health é conectado em iOS compatível THEN o sistema SHALL solicitar somente leitura de workout, energia ativa, distâncias e frequência cardíaca.
2. WHEN o usuário seleciona tema ou unidades THEN o sistema SHALL persistir a seleção em SharedPreferences.
3. WHEN o usuário limpa dados locais THEN o sistema SHALL apagar `check_ins`, workouts, sync state e usuário, depois recriar o perfil mock.
4. WHEN Health Connect ou Garmin são apresentados THEN o sistema SHALL identificá-los como `Coming soon`, sem alegar conexão funcional.

## Requisitos não funcionais

- O banco local SHALL manter unicidade de `(platform, external_id)` quando existe ID externo.
- Datas recebidas de plataformas SHALL ser normalizadas para UTC; apresentação SHALL usar horário local.
- O aplicativo SHALL continuar navegável após falha de sincronização de bootstrap, exibindo aviso recuperável.
- Falha estrutural do bootstrap SHALL exibir erro e ação `Retry`.
- O app não SHALL enviar workouts, perfil ou preferências a backend, pois não existe backend no baseline.

## Dimensões de requisitos implícitos

| Dimensão | Resolução no baseline |
| --- | --- |
| Validação e limites | IDs de rota inválidos viram `0` e resultam em não encontrado; streak é limitado a 365; feed é limitado a 50. Validação adicional de payload não está implementada. |
| Falha parcial | Falha de sync preserva último sucesso/anchor e registra mensagem; falha do bootstrap pode ser repetida. |
| Idempotência/duplicatas | Upsert usa `(platform, externalId)`; itens sem `externalId` não possuem deduplicação garantida. |
| Autorização/rate limit | HealthKit usa consentimento do sistema. Rate limit é N/A porque não há API remota. |
| Concorrência/ordenação | Ordenação é `start_time DESC`; não há lock explícito contra syncs concorrentes. |
| Ciclo de vida | Limpeza é destrutiva e local; soft delete existe no schema, mas não há exclusão individual. |
| Observabilidade | `debugPrint` registra falha de bootstrap; não existem métricas ou tracing remotos. |
| Dependência externa | HealthKit indisponível ativa preview; exceções de sync são persistidas e reapresentadas. |
| Transições de estado | Sync percorre `syncing -> success|failed`; último estado é persistido por provider. |

## Fora de escopo do baseline

| Capacidade | Motivo |
| --- | --- |
| Login/cadastro real | MVP usa identidade local fixa |
| Backend e sincronização em nuvem | Nenhum serviço remoto existe |
| Criação/edição manual de workout | Vertical slice é orientado a importação |
| Health Connect real | Placeholder planejado |
| Garmin real | Placeholder planejado |
| Agregação de heart rate no HealthKit | Adiada explicitamente no bridge nativo |
| Social/check-ins publicados | Existe somente schema sem experiência funcional |
| Conversão efetiva para unidades imperiais | Preferência é persistida, mas formatadores permanecem métricos |

## Assumptions & Open Questions

| Decisão | Default adotado | Racional | Confirmado? |
| --- | --- | --- | --- |
| Natureza desta spec | Snapshot descritivo da `master`, não promessa de roadmap | O pedido é documentar bem o projeto existente | Sim, derivado do pedido |
| Preview | Modo demonstrativo, não integração Apple Health real | Evita representar mock como produção | Sim, comprovado no código |
| Unidade imperial | Implementação parcial | Preferência é salva, mas não consumida nos formatadores | Sim, comprovado no código |
| `check_ins` | Schema inativo | Não existem repository, provider, rota ou UI correspondentes | Sim, comprovado no código |

**Open questions**: nenhuma para registrar o baseline atual. Decisões futuras de produto devem gerar novas specs.

## Rastreabilidade

| ID | Resultado documentado | Spec detalhada | Status da documentação |
| --- | --- | --- | --- |
| PROD-01 | Visão, usuário e problema | esta spec | Implementing |
| PROD-02 | Capability map com estados reais | esta spec | Implementing |
| PROD-03 | Importação e sync | `../workout-import-sync/spec.md` | Implementing |
| PROD-04 | Feed, histórico e detalhe | `../workout-catalog/spec.md` | Implementing |
| PROD-05 | Métricas de progresso | `../progress-insights/spec.md` | Implementing |
| PROD-06 | Dispositivos e integrações | `../device-integrations/spec.md` | Implementing |
| PROD-07 | Perfil e preferências | `../local-profile-settings/spec.md` | Implementing |
| PROD-08 | Dados, privacidade e ciclo de vida | `../local-data-lifecycle/spec.md` | Implementing |
| PROD-09 | Índice navegável de specs | `.specs/README.md` | Implementing |

**Coverage**: 9 requisitos, 9 mapeados, 0 sem destino.
