# Android Runtime Readiness

## Objetivo

Permitir que o GymApp seja baixado em uma máquina Windows, preparado por script e executado em um emulador ou dispositivo Android usando Flutter/VS Code.

## Requisitos

- **ANDROID-01 — Toolchain detectável:** o script encontra Flutter, JDK 17 e Android SDK/ADB sem caminhos específicos do usuário.
- **ANDROID-02 — Build configurado:** namespace e applicationId são `com.z33p.gymapp`; compilação usa Java/Kotlin 17, Flutter compile/target SDK e Gradle compatível.
- **ANDROID-03 — Manifest funcional:** embedding Flutter v2, activity exportada/launcher, ícone `@mipmap/ic_launcher` e permissão de internet nos perfis de desenvolvimento.
- **ANDROID-04 — Setup reproduzível:** script opcionalmente limpa, executa `flutter pub get`, análise, testes e gera APK debug.
- **ANDROID-05 — Execução local:** sem device fixo no repositório; o script aceita `-Device` ou orienta `flutter devices`/`flutter run`.

## Critérios de aceite

1. `flutter analyze`, `flutter test` e `flutter build apk --debug` passam na máquina Windows configurada.
2. O script falha com instrução clara quando Flutter, JDK 17 ou Android SDK/ADB estão ausentes.
3. Nenhum segredo, keystore ou caminho absoluto de usuário é versionado.
