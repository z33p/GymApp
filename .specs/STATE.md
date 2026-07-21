# STATE

## Decisions

### AD-001
- **Decision**: Usar Flutter stable 3.44.7 com Dart 3.12.2 como baseline local validada.
- **Reason**: O projeto aceita Dart 3.x, não fixa outra versão e os gates passam nesta release stable.
- **Trade-off**: Uma futura atualização do Flutter deve repetir analyzer, testes e builds de plataforma.
- **Scope**: Todo o aplicativo Flutter e suas ferramentas locais.
- **Date**: 2026-07-21
- **Status**: active

### AD-002
- **Decision**: Usar Temurin JDK 17 e Android SDK/API 36 para desenvolvimento Android.
- **Reason**: O projeto compila Java e Kotlin para JVM 17 e o Flutter 3.44 usa API 36 como baseline.
- **Trade-off**: Java 21 não será adotado até uma migração intencional e verificada da cadeia Android.
- **Scope**: Builds, testes e tooling Android.
- **Date**: 2026-07-21
- **Status**: active

### AD-003
- **Decision**: Preservar a arquitetura feature-first com camadas `domain`, `data` e `presentation`, Riverpod para estado/injeção e SQLite como persistência local.
- **Reason**: É o padrão consistente já utilizado por auth, devices, workouts, progress e settings.
- **Trade-off**: Novas features devem respeitar as fronteiras existentes ou registrar explicitamente uma decisão que as substitua.
- **Scope**: Todas as novas features e refatorações de aplicação.
- **Date**: 2026-07-21
- **Status**: active

### AD-004
- **Decision**: Manter HealthKit como integração nativa iOS via MethodChannel e usar dados de preview em plataformas sem HealthKit até que integrações próprias sejam especificadas.
- **Reason**: Esse é o fluxo vertical existente e permite desenvolvimento Android/Windows sem simular disponibilidade real do HealthKit.
- **Trade-off**: Validação completa do HealthKit continua exigindo macOS, Xcode e dispositivo iOS compatível.
- **Scope**: Sincronização de dispositivos e importação de workouts.
- **Date**: 2026-07-21
- **Status**: active

### AD-005
- **Decision**: Manter uma spec canônica de produto e specs separadas por domínio funcional, com estados explícitos para implementado, parcial, preview, planejado e fora do MVP.
- **Reason**: A estrutura preserva a rastreabilidade do baseline sem confundir placeholders ou intenção de roadmap com capacidades entregues.
- **Trade-off**: Mudanças de comportamento devem atualizar a spec do domínio e o índice, além da implementação.
- **Scope**: Toda evolução funcional e documentação de produto em `.specs/`.
- **Date**: 2026-07-21
- **Status**: active

### AD-006
- **Decision**: Evoluir o GymApp de local-first para offline-first quando grupos e gamificação social forem implementados: dados pessoais de treino continuam locais, enquanto identidade, grupos, ranking e mural exigem sincronização remota.
- **Reason**: O produto precisa de ranking e comunidade consistentes entre aparelhos, sem perder o valor do histórico individual quando estiver offline.
- **Trade-off**: A próxima fase exigirá escolha explícita de backend, autenticação, regras de autorização e estratégia de conflito; nenhuma dessas decisões é inferida neste roadmap.
- **Scope**: Features futuras de identidade, grupos, ranking, facções e social.
- **Date**: 2026-07-21
- **Status**: active

## Handoff

- **Feature**: Product baseline / `.specs/features/product-baseline/spec.md`
- **Phase / Task**: Complete — segunda validação independente PASS
- **Completed**: PROD-01 a PROD-09; visão canônica, seis specs funcionais, índice, gates, links e sensor
- **In-progress** (file:line): nenhum
- **Next step**: usar `.specs/README.md` e a spec do domínio como ponto de partida da próxima feature
- **Blockers**: nenhum
- **iOS readiness**: AppIcon vazio corrigido; Podfile, atalhos VS Code e gate macOS documentados.
- **Product roadmap**: Fauna Social & Gamification desenhado; aguarda autorização para plano técnico e implementação.
- **Uncommitted files**: nenhum após o commit final de validação
- **Branch**: master
