# Auth Login & Debug Mode Specification

**Status:** Implemented locally; external providers pending

## Problem

O app possui apenas um usuário mock criado automaticamente, o que impede validar a primeira experiência de login e mistura bootstrap local com autenticação. Precisamos de uma tela visual pronta para receber Google, Microsoft e Apple, mantendo uma entrada explícita para desenvolvimento enquanto o backend não existe.

## Goals

- [x] Exibir uma tela de login com identidade visual GymApp e provedores externos preparados.
- [x] Permitir entrada local explícita em modo debug sem alegar autenticação externa.
- [x] Não bloquear instalações existentes que já possuem usuário local.
- [x] Manter o contrato de autenticação independente do provedor escolhido.

## Out of scope

| Capability | Reason |
| --- | --- |
| OAuth real, tokens, refresh e deep links | Dependem do provedor/backend que ainda será escolhido. |
| Cadastro de senha e recuperação de conta | Não faz parte do fluxo social aprovado. |
| Persistência de credenciais externas em SQLite | Identidades remotas pertencem ao backend PostgreSQL. |

## Acceptance criteria

1. WHEN não existe usuário local THEN o app SHALL exibir a tela de login antes do Habitat.
2. WHEN o usuário toca `Entrar em modo desenvolvimento` THEN o app SHALL criar/reutilizar o perfil local debug e abrir o Habitat.
3. WHEN o usuário toca Google, Microsoft ou Apple sem adaptador configurado THEN o app SHALL manter a tela aberta e explicar que o provedor ainda será conectado.
4. WHEN já existe usuário local THEN o app SHALL abrir o app normalmente sem exigir login novamente.
5. WHEN o bootstrap é executado sem sessão THEN o app SHALL não criar usuário silenciosamente nem iniciar sync social em nome de uma conta inexistente.

## Traceability

| ID | Requirement | Status |
| --- | --- | --- |
| AUTH-01 | Login visual e gate de sessão | Implemented |
| AUTH-02 | Debug login local explícito | Implemented |
| AUTH-03 | Contrato para Google/Microsoft/Apple | Implemented — adapters pending |
| AUTH-04 | Bootstrap sem auto-login silencioso | Implemented |
