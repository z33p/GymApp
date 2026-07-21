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

## Handoff

- **Feature**: Baseline de desenvolvimento / `.specs/features/development-environment/spec.md`
- **Phase / Task**: Execute — validação independente pendente
- **Completed**: configuração Flutter/JDK/Android, dependências, correções de compatibilidade, analyzer, testes, build APK, spec
- **In-progress** (file:line): nenhum
- **Next step**: executar o Verifier, persistir `validation.md` e então aguardar a próxima feature solicitada pelo usuário
- **Blockers**: nenhum
- **Uncommitted files**: `pubspec.lock`, quatro arquivos Dart, `.specs/STATE.md`, `.specs/features/development-environment/spec.md`
- **Branch**: master
