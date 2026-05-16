import 'package:flutter/material.dart';

enum AppUnits { metric, imperial }

enum AppThemePreference { system, light, dark }

class AppSettings {
  const AppSettings({
    this.units = AppUnits.metric,
    this.themePreference = AppThemePreference.system,
  });

  final AppUnits units;
  final AppThemePreference themePreference;

  ThemeMode get themeMode => switch (themePreference) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      };

  AppSettings copyWith({AppUnits? units, AppThemePreference? themePreference}) {
    return AppSettings(
      units: units ?? this.units,
      themePreference: themePreference ?? this.themePreference,
    );
  }
}
