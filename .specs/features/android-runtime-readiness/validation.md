# Validação — Android Runtime Readiness

## Auditoria estática

- `android/app/build.gradle.kts`: namespace/applicationId `com.z33p.gymapp`; Java/Kotlin JVM 17; SDKs fornecidos pelo Flutter.
- Gradle wrapper: 8.10.2; Android Gradle Plugin: 8.7.3; Kotlin: 2.0.21.
- Manifesto: Flutter embedding v2, launcher activity exportada e ícone mipmap válido.
- Ícones: mipmap `ic_launcher.png` presente nos cinco density buckets.
- VS Code: tasks já fornecem análise/testes; o script Windows prepara e gera o APK.

## Gate executado no Windows

Executado nesta máquina Windows com `scripts/setup_android_windows.ps1 -Clean`:

- Flutter 3.44.7, Dart 3.12.2, JDK Temurin 17.0.19 e Android SDK 36 detectados.
- `flutter analyze`: PASS, sem issues.
- `flutter test`: PASS, 3 testes.
- `flutter build apk --debug`: PASS; APK gerado em `build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter doctor`: toolchain Android e licenças OK; Chrome e Visual Studio ausentes, sem impacto no Android.
- Gradle 8.10.2, AGP 8.7.3 e Kotlin 2.0.21 geram avisos de compatibilidade futura, mas compilam atualmente.

Reprodução:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.scriptssetup_android_windows.ps1 -Clean
```

Para rodar em um aparelho/emulador conectado:

```powershell
flutter devices
.scriptssetup_android_windows.ps1 -Device <device-id>
```
