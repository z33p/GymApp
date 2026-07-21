# Especificação da Baseline de Desenvolvimento

## Problem Statement

O GymApp não possuía uma baseline reproduzível de dependências nem um registro persistente da stack, das limitações de plataforma e dos comandos de verificação. Em uma máquina Windows limpa, o projeto precisava ser preparado para desenvolvimento Flutter/Android sem introduzir novas funcionalidades.

## Goals

- [x] Disponibilizar uma toolchain Flutter/Android compatível com o projeto.
- [x] Fixar as dependências resolvidas do aplicativo em `pubspec.lock`.
- [x] Garantir que analyzer, testes automatizados e build Android debug passem.
- [x] Registrar a arquitetura atual e as restrições que devem orientar as próximas features.

## Out of Scope

| Item | Razão |
| --- | --- |
| Atualizar Gradle, Android Gradle Plugin ou Kotlin | O build atual passa; os avisos indicam compatibilidade futura e exigem uma migração própria. |
| Implementar Health Connect ou Garmin | São integrações futuras, explicitamente marcadas como `coming_soon` no código. |
| Alterar comportamento ou interface do produto | Esta entrega estabelece somente a baseline de desenvolvimento. |
| Compilar ou validar HealthKit no Windows | Builds iOS e testes reais de HealthKit exigem macOS, Xcode e dispositivo compatível. |
| Preparar Web ou Windows Desktop | O repositório contém somente os alvos Android e iOS. |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default | Rationale | Confirmed? |
| --- | --- | --- | --- |
| Canal Flutter | Stable 3.44.7 | O `pubspec.yaml` aceita Dart `>=3.5.0 <4.0.0` e não fixa outra versão. | Sim |
| Java para Android | Temurin JDK 17 LTS | O projeto define Java/Kotlin JVM 17 e o Flutter 3.44 aceita essa baseline. | Sim |
| Alvo verificável no Windows | Android API 36 | É o alvo mobile suportado localmente; iOS permanece dependente de macOS. | Sim |
| Dependências com majors mais novos | Manter constraints atuais | Atualizações de Riverpod, `go_router` e demais pacotes podem exigir mudanças comportamentais. | Sim |
| Avisos futuros do Gradle/AGP/Kotlin | Registrar, não migrar agora | São warnings; analyzer, testes e APK debug passam na baseline atual. | Sim |

**Open questions:** nenhuma — as decisões necessárias para esta baseline estão registradas acima.

---

## Stack e Arquitetura Atual

| Área | Tecnologia / padrão | Evidência no projeto |
| --- | --- | --- |
| Aplicativo | Flutter 3.44.7 / Dart 3.12.2 | `pubspec.yaml`, `lib/main.dart` |
| Estado e injeção | Riverpod 2 (`Provider`, `FutureProvider`, `AsyncNotifier`) | `lib/core/config/app_providers.dart` |
| Navegação | `go_router` com `ShellRoute` e cinco abas | `lib/core/router/app_router.dart` |
| Persistência | SQLite via `sqflite`; testes via `sqflite_common_ffi` | `lib/core/database/app_database.dart` |
| Preferências | `shared_preferences` para tema e unidades | `lib/core/config/app_providers.dart` |
| Organização | Feature-first, separada em `domain`, `data` e `presentation` | `lib/features/` |
| Integração iOS | Swift + HealthKit via MethodChannel `com.gymapp.health/apple_health` | `ios/Runner/AppDelegate.swift` |
| Fallback | Dados locais de preview quando HealthKit não está disponível | `lib/features/devices/data/mock/` |
| Android | Kotlin/JVM 17, Gradle 8.10.2, AGP 8.7.3, API 36 | `android/` |
| Qualidade | `flutter_lints`, `flutter_test`, `mocktail`, três testes existentes | `analysis_options.yaml`, `test/` |

### Fluxo funcional principal

1. O bootstrap cria um usuário mock local e tenta sincronizar Apple Health.
2. Em iOS compatível, o MethodChannel consulta o HealthKit com anchor incremental.
3. Fora do iOS, o repositório usa workouts de preview.
4. Workouts e estado de sincronização são persistidos em SQLite com upsert por plataforma e `external_id`.
5. Feed, histórico, detalhe, progresso, dispositivos e configurações consomem os providers Riverpod.

---

## User Stories

### P1: Ambiente reproduzível ⭐ MVP

**User Story**: Como pessoa desenvolvedora, quero abrir o GymApp em uma máquina Windows preparada para poder analisar, testar e compilar o aplicativo Android.

**Why P1**: Nenhuma feature pode ser desenvolvida com segurança sem uma toolchain verificável.

**Acceptance Criteria**:

1. QUANDO a versão do Flutter for consultada ENTÃO o ambiente DEVERÁ reportar Flutter 3.44.7 stable e Dart 3.12.2.
2. QUANDO `flutter doctor -v` for executado ENTÃO a seção Android toolchain DEVERÁ passar com Android SDK 36.0.0, Java 17 e licenças aceitas.
3. QUANDO `flutter pub get` for executado ENTÃO as dependências DEVERÃO ser resolvidas e registradas em `pubspec.lock`.

**Independent Test**: Executar `flutter doctor -v` e `flutter pub get` em `C:\Users\rapha\Development\GymApp`.

### P1: Baseline verificável ⭐ MVP

**User Story**: Como pessoa desenvolvedora, quero gates verdes para detectar regressões antes de trabalhar em novas features.

**Why P1**: Uma baseline vermelha torna resultados futuros ambíguos.

**Acceptance Criteria**:

1. QUANDO `flutter analyze` for executado ENTÃO deverá terminar com exit code 0 e `No issues found`.
2. QUANDO `flutter test` for executado ENTÃO os 3 testes existentes DEVERÃO passar, sem falhas ou skips.
3. QUANDO `flutter build apk --debug` for executado ENTÃO deverá terminar com exit code 0 e gerar `build/app/outputs/flutter-apk/app-debug.apk`.
4. QUANDO `AppDatabase` receber uma `DatabaseFactory` injetada ENTÃO deverá obter o diretório do banco pela mesma factory, permitindo o teste FFI sem estado global.

**Independent Test**: Executar os três comandos de gate e confirmar o APK e a contagem de testes.

### P2: Contexto persistente do projeto

**User Story**: Como colaborador futuro, quero entender rapidamente a stack, os limites de plataforma e as decisões vigentes para especificar novas features sem redescobrir o projeto.

**Why P2**: Reduz retrabalho e evita decisões incompatíveis com a arquitetura existente.

**Acceptance Criteria**:

1. QUANDO uma nova feature for iniciada ENTÃO `.specs/STATE.md` DEVERÁ identificar as decisões ativas e indicar que o próximo passo é especificar a solicitação do usuário.
2. QUANDO esta especificação for lida ENTÃO DEVERÁ identificar stack, camadas, fluxo de sincronização, persistência, gates e limitações iOS/Windows.

**Independent Test**: Ler esta especificação e `.specs/STATE.md` sem depender do histórico da conversa.

---

## Edge Cases

- QUANDO o projeto for trabalhado no Windows ENTÃO a ausência de Xcode DEVERÁ ser tratada como limitação conhecida, não como falha da baseline Android.
- QUANDO `flutter doctor` reportar ausência de Chrome ou Visual Studio ENTÃO esses itens DEVERÃO ser ignorados enquanto Web e Windows Desktop permanecerem fora do escopo.
- QUANDO o Flutter alertar sobre suporte futuro a Gradle 8.10.2, AGP 8.7.3 ou Kotlin 2.0.21 ENTÃO o warning DEVERÁ ser registrado como dívida técnica sem mascarar o resultado atual do build.
- QUANDO uma factory SQLite de teste for injetada ENTÃO nenhuma chamada de caminho DEVERÁ depender da factory global do `sqflite`.

---

## Requirement Traceability

| Requirement ID | Story | Evidence / gate | Status |
| --- | --- | --- | --- |
| ENV-01 | P1: Ambiente reproduzível | `flutter --version` | Implementing |
| ENV-02 | P1: Ambiente reproduzível | `flutter doctor -v` | Implementing |
| ENV-03 | P1: Ambiente reproduzível | `flutter pub get`, `pubspec.lock` | Implementing |
| ENV-04 | P1: Baseline verificável | `flutter analyze` | Implementing |
| ENV-05 | P1: Baseline verificável | `flutter test` | Implementing |
| ENV-06 | P1: Baseline verificável | `flutter build apk --debug` | Implementing |
| ENV-07 | P1: Baseline verificável | `test/local_workout_upsert_test.dart` | Implementing |
| ENV-08 | P2: Contexto persistente | `.specs/STATE.md`, esta especificação | Implementing |

**Coverage:** 8 requisitos, 8 mapeados a evidências, 0 não mapeados.

---

## Success Criteria

- [x] Flutter/Dart/JDK/Android SDK instalados e reconhecidos.
- [x] Dependências resolvidas com lockfile versionado.
- [x] Analyzer com zero issues.
- [x] 3 testes aprovados, 0 falhas, 0 skips.
- [x] APK debug Android gerado.
- [x] Stack, decisões e limitações persistidas para a próxima feature.
