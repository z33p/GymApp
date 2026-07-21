# iOS Runtime Readiness

## Objetivo

Permitir que o GymApp seja preparado e executado em um Mac com Xcode, simulador ou dispositivo iOS, sem depender da máquina Windows de desenvolvimento.

## Requisitos

- **IOS-01 — Catálogo de assets válido:** `AppIcon` e `LaunchImage` referenciam PNGs existentes, não vazios e com assinatura válida; os ícones têm dimensões `size × scale`, e o marketing icon é 1024×1024 sem transparência.
- **IOS-02 — Asset catalog ligado:** Debug, Profile e Release usam `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`.
- **IOS-03 — CocoaPods:** `ios/Podfile` usa os modos Flutter Debug/Profile/Release e instala os pods Flutter com deployment target iOS 13.
- **IOS-04 — Identidade e permissões:** `Info.plist` define GymApp, bundle identifier por build setting e mensagens HealthKit; entitlements declara HealthKit.
- **IOS-05 — VS Code:** `launch.json` oferece Debug/Profile sem fixar device; `tasks.json` oferece pub get, análise, testes, CocoaPods e abertura do workspace.
- **IOS-06 — Gate Mac:** após `flutter pub get`, `pod install` e seleção de equipe de assinatura no Xcode, o workspace deve compilar no macOS. Assinatura Apple e HealthKit real não são verificáveis no Windows.

## Critérios de aceite

1. Nenhum PNG referenciado pelo AppIcon é vazio ou ausente.
2. `flutter analyze` e `flutter test` passam no baseline Windows.
3. Atalhos VS Code e Podfile não contêm device, certificado ou caminho local.
4. A validação final em macOS está documentada como gate de ambiente.
