# Auth Login & Debug Mode Design

## Architecture

- `AuthRepository` será o contrato único consumido pela UI.
- `LocalAuthRepository` persiste somente o perfil local de debug até o backend existir.
- `signInWith(AuthProvider)` será o ponto de substituição para OAuth; nesta fase lança uma falha tipada de configuração.
- `AuthGate` ficará no shell do app, depois do bootstrap técnico, e decide entre `LoginScreen` e a rota atual.
- O bootstrap consulta a sessão, mas não cria usuário. A sincronização pessoal só roda quando há uma sessão local.

## Provider boundary

```text
LoginScreen -> AuthRepository -> provider adapter futuro
                           \-> LocalAuthRepository -> SQLite app_user (debug)
```

O modo debug é visível somente em builds `kDebugMode`, evitando que a porta de desenvolvimento vire uma opção de produção.

## Risks and mitigations

| Risk | Mitigation |
| --- | --- |
| Login visual parecer autenticação real | Mensagem e estado explícitos de `modo desenvolvimento`; externos mostram `não configurado`. |
| Bootstrap recriar usuário | `bootstrapProvider` apenas lê sessão e retorna sem sync quando nula. |
| Provedor futuro acoplar a tela | Enum/contrato no domínio, sem SDK na apresentação. |
