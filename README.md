# GymApp

GymApp is a Flutter mobile MVP focused on automatically importing workouts that were recorded elsewhere, especially workouts written into Apple Health by Apple Watch.

## Vertical slice included
- Local mock user bootstrap
- Riverpod + go_router app shell with bottom navigation
- Local SQLite persistence for workouts, sync state, check-ins, and app user
- Devices screen with Apple Health connect/sync flow and preview fallback
- Manual sync plus startup/resume sync orchestration
- Activity feed, history list, workout detail, progress dashboard, and settings
- Native iOS MethodChannel HealthKit integration scaffold

## Notes
- iOS reads from Apple Health through `com.gymapp.health/apple_health`.
- Unsupported platforms and iOS simulator fall back to preview workout data.
- Android is structured for future Health Connect and Garmin integrations.

## Preparar iOS no macOS

Depois de clonar o repositório, execute:

```bash
cd GymApp
chmod +x scripts/setup_ios_macos.sh
./scripts/setup_ios_macos.sh --open
```

O script verifica Flutter, Xcode Command Line Tools e CocoaPods, executa `flutter pub get`, instala os pods e valida o workspace. Use `--clean` para limpar o build antes da preparação. O desenvolvimento pode continuar no VS Code; o Xcode só precisa estar instalado para fornecer o toolchain e o simulador.

## Preparar Android no Windows

No PowerShell, após clonar:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup_android_windows.ps1 -Clean
```

O script detecta Flutter, JDK 17 e Android SDK, executa `flutter pub get`, análise, testes e gera `build\app\outputs\flutter-apk\app-debug.apk`. Para executar diretamente em um emulador ou aparelho conectado, informe o device:

```powershell
flutter devices
.\scripts\setup_android_windows.ps1 -Device <device-id>
```
