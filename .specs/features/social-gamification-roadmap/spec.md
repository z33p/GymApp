# Fauna Social & Gamification — Product Roadmap

**Status:** direção de produto aprovada; implementação ainda não iniciada.

## Problema

O GymApp já importa e organiza workouts, mas ainda não transforma consistência em pertencimento, status ou competição. A proposta é criar uma experiência social inclusiva: pessoas com relógio, app fitness ou apenas disposição para publicar uma atividade podem participar sob regras claras definidas pelo próprio grupo.

## Visão

> Treine de verdade, registre ou sincronize sua atividade, evolua na fauna e ajude sua facção.

O produto não exige séries, repetições ou carga manual. O loop principal começa com uma atividade sincronizada ou uma publicação aceita pelo grupo e termina em evolução visual, ranking e conversa social.

## Goals

- Oferecer grupos privados com ranking configurável e regras transparentes.
- Tornar a participação possível sem Apple Watch, Garmin ou outro hardware premium.
- Fazer do animal atual do membro uma identidade visual permanente do app.
- Criar um caminho anual de evolução até Leão ou Dragão, sem transformar ausência temporária em perda completa de conquista.
- Priorizar mural e conversa contextual antes de chat/DM em tempo real.

## Fora de escopo deste roadmap

| Capacidade | Motivo |
| --- | --- |
| Registro de séries, reps, carga ou RPE | O produto prioriza sincronização e check-in de baixa fricção. |
| Chat privado em tempo real | Mural com posts e comentários atende a primeira versão social com menor custo de moderação. |
| Feed público global | Grupos privados são o primeiro ambiente seguro e relevante. |
| Pontuação por fórmula arbitrária escrita pelo usuário | A primeira versão usa modos e limites pré-definidos, compreensíveis e testáveis. |
| Faturamento, anúncios ou assinatura | Decisão posterior, após validar retenção e dinâmica dos grupos. |
| IA de treino ou prescrição médica | Não é necessária para o loop social/gamificado inicial. |

## Decisões e suposições fechadas

| Decisão | Default | Racional | Confirmado |
| --- | --- | --- | --- |
| Elegibilidade sem wearable | O grupo pode aceitar atividade sincronizada, check-in manual ou publicação, conforme regra escolhida. | Evita exclusão por poder aquisitivo ou plataforma. | Sim |
| Modos de ranking | Workouts, minutos, quilômetros ou publicações/check-ins. | Mantém as regras legíveis; cada comunidade escolhe o que valoriza. | Sim |
| Limites de grupo | Dono define mínimo/máximo elegível por evento e máximo creditável diário. | A regra combate spam sem impor uma regra universal. | Sim |
| Tiers | Rato → Lobo → Urso → Rinoceronte → Gorila → Leão/Dragão. | A progressão é memorável e o máximo reforça a facção. | Sim |
| Facções | Bando do Leão e Ordem do Dragão; escolha no ingresso e bloqueio durante a temporada. | Preserva identidade e evita troca oportunista. | Sim |
| Dois progressos | Forma atual usa janela móvel; Legado anual só acumula. | Permite “cair de tier” como motivação sem apagar a conquista anual. | Sim |
| Login/onboarding | Login real entra antes de grupos; onboarding rico e banner de conexão podem vir depois. | Grupos e mensagens precisam de identidade, mas não precisam bloquear o MVP local atual. | Sim |
| Arte do mascote | Assets estáticos por tier e estado na primeira versão. | Dá personalidade sem depender de arte generativa ou avatar customizado. | Sim |

**Open questions:** a escolha do provedor de autenticação/backend e os números exatos de pontos/thresholds ficam para a fase técnica, com telemetry e testes de balanceamento.

## User stories

### P1 — Criar grupo com regra justa

Como dono de uma comunidade, quero configurar a métrica e os limites do ranking para que o desafio represente o que meu grupo considera treino válido.

1. WHEN o dono cria um grupo THEN o sistema SHALL exigir nome, privacidade, timezone e um modo de ranking: `workouts`, `minutes`, `kilometers` ou `posts`.
2. WHEN o dono seleciona minutos ou quilômetros THEN o sistema SHALL exigir mínimo e máximo creditável por atividade.
3. WHEN o dono seleciona workouts ou posts THEN o sistema SHALL exigir máximo de eventos creditáveis por dia.
4. WHEN uma temporada já possui atividade pontuada THEN alterações de regra SHALL criar a próxima temporada, sem recalcular a anterior.

### P1 — Participar sem hardware obrigatório

Como membro, quero registrar minha participação conforme a regra do grupo para competir mesmo sem relógio ou integração fitness.

1. WHEN o grupo aceita sincronização THEN uma atividade importada elegível SHALL gerar a pontuação prevista pela regra.
2. WHEN o grupo aceita check-in/publicação THEN o membro SHALL poder criar uma publicação de atividade sem informar séries, reps ou carga.
3. WHEN uma atividade excede o máximo definido pelo grupo THEN o sistema SHALL registrar a atividade, mas creditar no máximo o limite configurado.
4. WHEN a atividade não alcança o mínimo do grupo THEN o sistema SHALL aparecer no histórico sem gerar pontuação.
5. WHEN o limite diário do membro é atingido THEN novas atividades SHALL permanecer visíveis, mas não aumentar o ranking daquele dia.

### P1 — Evoluir na fauna

Como membro, quero ver meu animal, facção e posição para sentir progresso antes e depois de cada treino.

1. WHEN o perfil ou Home é aberto THEN o sistema SHALL mostrar o mascote do animal atual, tier, facção, posição no grupo e próximo marco.
2. WHEN a pontuação de Forma cruza um threshold THEN o mascote SHALL mudar para o animal correspondente e registrar o evento no histórico.
3. WHEN a Forma diminui pela inatividade THEN o tier atual SHALL poder cair, mas o Legado anual e as conquistas já recebidas SHALL permanecer intactos.
4. WHEN o membro atinge o tier máximo durante a temporada anual THEN o título SHALL ser `Leão` ou `Dragão`, de acordo com sua facção.

### P1 — Consultar ranking de grupo

Como membro, quero acompanhar uma classificação compreensível para saber como contribuir com meu grupo.

1. WHEN o ranking é aberto THEN o sistema SHALL ordenar membros por pontos creditados na temporada ativa, com desempate documentado por atividade mais recente.
2. WHEN o modo é minutos ou quilômetros THEN o ranking SHALL exibir pontos e a métrica bruta usada no cálculo.
3. WHEN o membro não possui atividade elegível THEN o ranking SHALL exibir zero, animal atual e caminho para pontuar.
4. WHEN um membro toca em outro membro THEN o sistema SHALL abrir perfil público limitado ao contexto do grupo.

### P1 — Conversar em mural de grupo

Como membro, quero publicar e comentar no mural do grupo para celebrar treinos e criar accountability.

1. WHEN um treino sincronizado é elegível THEN o membro SHALL poder compartilhá-lo como post pré-preenchido no mural.
2. WHEN um membro cria um post THEN o sistema SHALL aceitar texto e foto opcional, e associar origem como `atividade`, `check-in` ou `conversa`.
3. WHEN um membro abre um post THEN o sistema SHALL exibir comentários em ordem cronológica e reações agregadas.
4. WHEN dono ou moderador fixa uma publicação THEN ela SHALL aparecer antes do feed cronológico.

### P2 — Entrar com identidade e ser guiado

Como novo usuário, quero entender a proposta e conectar uma fonte de treino sem ser obrigado a fazê-lo para explorar o app.

1. WHEN o usuário abre a experiência social pela primeira vez THEN o sistema SHALL oferecer login por Google, Microsoft ou Apple e explicar que a conta protege grupos e ranking.
2. WHEN o usuário ainda não conecta uma fonte THEN o sistema SHALL mostrar banner não bloqueante para conectar Apple Health, Health Connect ou participar por check-in conforme as regras do grupo.
3. WHEN o usuário escolhe facção THEN o sistema SHALL explicar a identidade de Leões e Dragões e confirmar que a escolha fica bloqueada na temporada atual.

### P2 — Completar missões e temporadas

Como membro, quero metas curtas além do ranking para voltar ao app durante a semana.

1. WHEN uma missão semanal é publicada THEN o sistema SHALL mostrar objetivo, período, recompensa visual e progresso individual.
2. WHEN uma atividade elegível cumpre a missão THEN o sistema SHALL atualizar o progresso sem exigir novo input manual.
3. WHEN a temporada encerra THEN o sistema SHALL congelar o ranking, registrar a melhor Forma e atualizar o Legado anual.

## Edge cases e integridade

- WHEN um grupo usa `posts` como métrica THEN o sistema SHALL identificar a pontuação como check-in social, nunca como treino verificado.
- WHEN uma sincronização é repetida THEN o mesmo workout externo SHALL manter deduplicação por origem e ID externo antes de pontuar.
- WHEN duas atividades chegam simultaneamente THEN o servidor SHALL aplicar limites e ranking de forma idempotente.
- WHEN o autor remove um post associado a atividade THEN a visibilidade social SHALL desaparecer, mas a pontuação já creditada seguirá a regra da temporada; moderadores poderão reverter em fase posterior.
- WHEN o grupo não possui posts ou membros ativos THEN o mural e ranking SHALL exibir estados vazios com CTA para convidar ou publicar.
- WHEN um usuário sai do grupo THEN seu histórico da temporada SHALL permanecer atribuído como ex-membro; novas atividades não pontuam.
- WHEN uma ação remota falha THEN o app SHALL manter a última leitura local, mostrar estado de retry e não inventar pontuação offline.

## Roadmap de produto

| Fase | Entrega | Dependência | Resultado de produto |
| --- | --- | --- | --- |
| 0 | Design system Fauna, perfil local, mascote e tiers demonstráveis com dados existentes | Nenhuma | A identidade do GymApp aparece antes da rede social. |
| 1 | Auth, perfil remoto, grupos privados, convites e regras de scoring | Backend + identidade | Comunidades conseguem existir com regras próprias. |
| 2 | Ranking de temporada, Forma/Legado, posts, comentários e moderação básica | Fase 1 | Loop social/gamificado completo. |
| 3 | Health Connect, notificações, banner de conexão e onboarding rico | Fase 2 + integração Android | Participação automática em iOS e Android. |
| 4 | Missões, temporadas de facção e ranking global Leões vs Dragões | Massa crítica de usuários | Competição de longo prazo e retenção. |

## Requirement traceability

| ID | Resultado | Prioridade | Estado |
| --- | --- | --- | --- |
| FAUNA-01 | Regra de ranking configurável por grupo | P1 | Pending |
| FAUNA-02 | Participação sincronizada ou por publicação | P1 | Pending |
| FAUNA-03 | Limites mínimos/máximos e teto diário | P1 | Pending |
| FAUNA-04 | Tiers, facção, Forma e Legado | P1 | Pending |
| FAUNA-05 | Mascote visível no Home, perfil e ranking | P1 | Pending |
| FAUNA-06 | Grupos privados e ranking de temporada | P1 | Pending |
| FAUNA-07 | Mural, posts, reações, comentários e moderação básica | P1 | Pending |
| FAUNA-08 | Login social e banner de conexão não bloqueante | P2 | Pending |
| FAUNA-09 | Missões e encerramento de temporada | P2 | Pending |
| FAUNA-10 | Guerra global entre facções | P3 | Pending |
