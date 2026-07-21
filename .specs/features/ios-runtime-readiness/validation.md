# Validação — iOS Runtime Readiness

## Windows

- AppIcon: 15 PNGs restaurados do template oficial Flutter; todos têm conteúdo e dimensões de catálogo.
- Xcode: `AppIcon` está referenciado nos perfis de build e o bundle identifier é `com.z33p.gymapp`.
- CocoaPods: `ios/Podfile` adicionado com `flutter_install_all_ios_pods` e deployment target 13.0.
- Permissões: `Info.plist` contém descrições HealthKit e `Runner.entitlements` declara HealthKit.
- VS Code: launch, tasks e recomendações Dart/Flutter adicionados sem dispositivo fixo.

## Gate obrigatório no macOS

```bash
flutter pub get
pod install --project-directory=ios
flutter devices
flutter run -d <device-id>
```

Se o Xcode solicitar assinatura, abra `ios/Runner.xcworkspace`, selecione Runner, defina a Apple Developer Team e confirme um Bundle Identifier disponível. Em caso de cache, execute `flutter clean` e reconstrua.
