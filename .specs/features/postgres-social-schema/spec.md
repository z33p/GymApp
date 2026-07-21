# PostgreSQL Social Schema Specification

**Status:** Implementing

## Problem statement

Grupos, ranking, identidade e mural precisam ser compartilhados entre aparelhos e não podem depender do SQLite local. O projeto precisa de um schema PostgreSQL versionado, repetível e seguro que preserve o histórico pessoal offline e prepare o MVP social.

## Goals

- [x] Disponibilizar migrations PostgreSQL ordenadas para toda informação remota do MVP social.
- [x] Modelar login externo, grupos privados, temporadas, regras, claims, ranking, fauna e mural.
- [x] Fornecer scripts de aplicação e smoke test para Windows, macOS e Linux.

## Out of scope

| Capability | Reason |
| --- | --- |
| Escolha ou provisionamento de Supabase/Firebase/servidor | Requer decisão e credenciais do produto. |
| Migração do SQLite pessoal para a nuvem | O histórico de treino permanece local/offline-first. |
| OAuth, upload de mídia, push notification e API Flutter | Dependem do provedor remoto e são próximos incrementos. |
| Chat/DM em tempo real | Fora do MVP social aprovado. |

## Assumptions & open questions

| Decision | Default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Autenticação | O backend mapeia `provider + subject` para `user_profiles.id`; providers Google, Microsoft e Apple são suportados. | Evita acoplamento a um fornecedor antes da escolha. | No — implementação segura padrão |
| Autorização | A camada de API define `app.user_id` por transação; RLS usa esse valor. | Mantém o banco seguro e independente de JWT específico. | No — implementação segura padrão |
| Pontuação | Claims são imutáveis depois de criados; regra da temporada não muda após o primeiro claim. | Garante ranking auditável e previsível. | Yes — direção de produto |
| Mídia | O banco guarda apenas referência de storage e metadados. | Binários não pertencem ao PostgreSQL neste MVP. | No — implementação segura padrão |

**Open questions:** provedor de auth/storage e política final de retenção/exclusão serão definidos antes de expor a API pública.

## User stories

### P1: Base social remota

As a membro, quero que minha identidade, meus grupos e meu ranking sobrevivam a aparelhos diferentes, para participar de uma comunidade sem perder o histórico local.

1. WHEN uma migration é aplicada em um PostgreSQL vazio THEN o sistema SHALL criar o schema remoto em ordem determinística.
2. WHEN uma identidade externa é cadastrada THEN o sistema SHALL impedir duplicidade do mesmo provider e subject.
3. WHEN uma pessoa não é membro ativo THEN o sistema SHALL não permitir que ela gere claim ou leia conteúdo privado pelo papel de cliente.

### P1: Ranking transparente

As a dono de grupo, quero definir métrica, mínimo, máximo, teto diário e fontes aceitas por temporada, para evitar spam e explicar o placar.

1. WHEN uma claim elegível excede o máximo por evento THEN o sistema SHALL creditar exatamente o máximo configurado e preservar o valor bruto.
2. WHEN uma claim fica abaixo do mínimo ou ultrapassa o teto diário THEN o sistema SHALL armazená-la com status explícito e zero ponto.
3. WHEN a temporada já possui claim THEN o sistema SHALL bloquear alteração dos campos de regra que afetariam o placar.

### P1: Mural privado

As a membro ativo, quero publicar, comentar e reagir no mural do meu grupo, para criar accountability sem chat privado.

1. WHEN um post, comentário ou reação é criado THEN o sistema SHALL vinculá-lo a membro e grupo válidos.
2. WHEN conteúdo é removido THEN o sistema SHALL manter registro de moderação e ocultar o conteúdo em leituras do cliente.

## Edge cases

- WHEN uma requisição de sincronização é repetida com a mesma fonte e referência externa THEN o sistema SHALL rejeitar a duplicata.
- WHEN a origem não é aceita pela temporada THEN o sistema SHALL registrar claim sem pontos e status `source_not_allowed`.
- WHEN não há identidade de sessão THEN as políticas RLS SHALL não expor dados de grupos.

## Requirement traceability

| ID | Requirement | Task | Status |
| --- | --- | --- | --- |
| PG-01 | Migrations reproduzíveis e contrato local/remoto | T1, T5 | Verified static |
| PG-02 | Identidade, grupos, membros e temporadas | T2 | Verified static |
| PG-03 | Claims idempotentes e regras de score | T3 | Verified static |
| PG-04 | Ranking e estado remoto de fauna | T3 | Verified static |
| PG-05 | Mural e moderação privados | T4 | Verified static |
| PG-06 | RLS por sessão e scripts verificáveis | T4, T5 | Verified static |
