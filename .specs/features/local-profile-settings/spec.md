# Local Profile & Settings Specification

**Product baseline**: `../product-baseline/spec.md`  
**Implementation state**: Perfil mock e tema implementados; unidades parcialmente implementadas

## Problem Statement

O MVP precisa de uma identidade local mínima e preferências de aparência sem introduzir autenticação remota. Também precisa explicar que os dados são locais e oferecer uma ação de limpeza.

## Goals

- Garantir um perfil de demonstração idempotente.
- Mostrar identidade local na tela Settings.
- Persistir preferência de tema e unidades.
- Aplicar tema imediatamente.
- Permitir limpeza das tabelas locais e recriação do perfil mock.

## Out of Scope

| Item | Motivo |
| --- | --- |
| Login, cadastro, logout e token | Não existe backend/auth remota |
| Editar nome, username ou avatar | Perfil é fixo e somente leitura |
| Múltiplos usuários | `getCurrentUser` retorna a primeira linha e bootstrap usa ID fixo |
| Backup/sync das preferências | SharedPreferences é local |
| Conversão imperial efetiva | Preferência é salva, mas não consumida pelos formatadores |

## Perfil local

No bootstrap, `LocalAuthRepository.ensureMockUser()` consulta `app_user`. Se existir um registro, retorna-o sem alteração. Se estiver vazio, cria:

| Campo | Valor inicial |
| --- | --- |
| `id` | `local-user-1` |
| `displayName` | `Alex GymApp` |
| `username` | `alexgym` |
| `avatarUrl` | null |
| timestamps | UTC no momento da criação |

Settings mostra um avatar genérico, display name e `@username`. Durante ausência/loading do provider usa `Local athlete` e `@gymapp` como fallback visual.

## Preferências

### Tema

Valores: `system`, `light`, `dark`. Default: `system`. A escolha é salva na chave `theme_preference` e convertida em `ThemeMode`, consumido pelo `MaterialApp.router`.

### Unidades

Valores: `metric`, `imperial`. Default: `metric`. A escolha é salva em `units_preference` e reaparece no dropdown.

**Limitação funcional**: `AppUnits` não é passado a `Formatters`, `WorkoutCard`, `WorkoutDetailScreen` ou `ProgressScreen`. Portanto selecionar `imperial` não altera metros/quilômetros nem qualquer outro valor exibido. O estado correto é “preferência persistida”, não “conversão implementada”.

Valores persistidos desconhecidos caem no default correspondente por `firstWhere(..., orElse:)`.

## Limpeza local

`Clear local data` chama `AppDatabase.clearAllData()` em uma transação:

1. apaga `check_ins`;
2. apaga `imported_workouts`;
3. apaga `sync_state`;
4. apaga `app_user`;
5. recria o perfil mock;
6. incrementa o ticker para atualizar providers.

A limpeza não remove `theme_preference` nem `units_preference`, pois SharedPreferences não participa da transação.

## Critérios de aceite

### P1 — Identidade mock

1. WHEN o banco não possui usuário THEN o bootstrap SHALL inserir exatamente o perfil padrão definido nesta spec.
2. WHEN o banco já possui usuário THEN `ensureMockUser` SHALL retornar o registro existente sem criar duplicata.
3. WHEN Settings recebe usuário THEN a UI SHALL mostrar `displayName` e username prefixado por `@`.
4. WHEN o provider ainda não possui valor THEN a UI SHALL usar `Local athlete` e `@gymapp`.

### P1 — Tema

1. WHEN não existe preferência THEN o sistema SHALL usar `ThemeMode.system`.
2. WHEN o usuário seleciona `light` ou `dark` THEN o sistema SHALL persistir o enum pelo nome e aplicar o `ThemeMode` correspondente.
3. WHEN o app reinicia THEN o controller SHALL restaurar a preferência persistida.
4. WHEN o valor salvo é inválido THEN o sistema SHALL retornar ao default `system`.

### P2 — Unidades

1. WHEN não existe preferência THEN o dropdown SHALL selecionar `metric`.
2. WHEN o usuário seleciona `imperial` THEN o sistema SHALL persistir e restaurar `imperial` no dropdown.
3. WHEN `imperial` está selecionado no baseline THEN os formatadores SHALL continuar métricos; a aplicação não SHALL alegar conversão implementada.
4. WHEN o valor salvo é inválido THEN o sistema SHALL retornar ao default `metric`.

### P1 — Limpeza

1. WHEN o usuário toca `Clear local data` THEN o botão SHALL ficar desabilitado enquanto o controller está loading.
2. WHEN a transação conclui THEN workouts, sync state e check-ins SHALL estar vazios e o perfil mock SHALL existir novamente.
3. WHEN a limpeza conclui THEN a UI SHALL mostrar `Local data cleared.`.
4. WHEN a limpeza ocorre THEN tema e unidades SHALL permanecer inalterados em SharedPreferences.

## Edge Cases e limitações

- Não há diálogo de confirmação antes da limpeza destrutiva.
- O snackbar de sucesso é executado após o `AsyncValue.guard`; como o método não relança, ele pode aparecer mesmo se a limpeza falhar.
- Settings não renderiza `syncController.hasError` para a ação de limpeza.
- Não há constraint explícita de username único no schema.
- `getCurrentUser(limit: 1)` não define ordenação; múltiplas linhas seriam comportamento não especificado.
- Preferências e banco têm ciclos de vida diferentes.

## Evidência e cobertura automatizada

| Área | Evidência | Cobertura atual |
| --- | --- | --- |
| Bootstrap/perfil | `MockAuthDataSource`, `LocalAuthRepository`, `bootstrapProvider` | Sem teste dedicado |
| Tema/unidades | `SettingsController`, `AppSettings`, `GymApp.build` | Sem teste dedicado |
| UI Settings | `SettingsScreen` | Sem widget test |
| Limpeza | `AppDatabase.clearAllData`, `SyncController.clearLocalData` | Setup do teste de upsert usa `clearAllData`, mas não valida todas as tabelas |

## Requirement Traceability

| ID | Requisito | Implementação | Estado documental |
| --- | --- | --- | --- |
| SET-01 | Perfil mock idempotente | `MockAuthDataSource.ensureUser` | Documented |
| SET-02 | Perfil somente leitura na UI | `SettingsScreen` | Documented |
| SET-03 | Tema persistido e aplicado | `SettingsController`, `GymApp` | Documented |
| SET-04 | Unidade persistida, conversão não entregue | `SettingsController`, `Formatters` | Documented |
| SET-05 | Limpeza transacional e recriação | `AppDatabase`, `SyncController` | Documented |
| SET-06 | Limitações de UX/erro explícitas | esta spec | Documented |

**Open questions**: nenhuma para o baseline. Confirmação de limpeza, conversão imperial e autenticação real requerem novas decisões/specs.

