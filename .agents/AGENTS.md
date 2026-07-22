# GymApp Project Rules & Standards

## 1. Design System (DS)
- **Widgets**: DO NOT use raw Flutter Material widgets like `Card`, `ElevatedButton`, `TextButton`, or `OutlinedButton` directly in presentation screens when a Design System component exists. Use `DsCard`, `DsButton`, `DsGap`, etc.
- **Spacing**: DO NOT hardcode static spacing pixel offsets (`SizedBox(height: 16)`). Use `DsGap.s(context)`, `DsGap.m(context)`, `DsGap.l(context)`, or `context.dsSpacing`.
- **Theming**: Use `context.dsColors` and `context.dsTypography` from `DsTheme` instead of arbitrary colors or default `Theme.of(context)` styles where applicable.

## 2. Internationalization (i18n)
- **No Hardcoded UI Strings**: DO NOT use hardcoded string literals inside user-facing UI widgets (`Text('Hardcoded string')`).
- **AppLocalizations**: Always wrap UI text with `AppLocalizations.of(context)!.yourKey` (or helper `l10n`).
- **ARB Sync**: Whenever adding a new UI string key, ensure it is added to `app_en.arb`, `app_pt.arb`, and `app_es.arb` in `lib/l10n/`.

## 3. Code Formatting & Linting
- **Dart Format**: Ensure code adheres to standard Dart formatting (`dart format`).
- **Static Analysis**: Clean build with zero warnings or errors from `flutter analyze`.
- **Verification**: Run `flutter test` after making modifications to verify zero regressions.
