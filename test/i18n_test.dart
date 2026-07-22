import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations tests', () {
    test('English localizations loaded correctly', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10n.homeTitle, equals('Home'));
      expect(l10n.settingsTitle, equals('Settings'));
      expect(l10n.workoutHistoryTitle, equals('Workout History'));
    });

    test('Portuguese (pt) localizations loaded correctly', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('pt'));
      expect(l10n.homeTitle, equals('Início'));
      expect(l10n.settingsTitle, equals('Configurações'));
      expect(l10n.workoutHistoryTitle, equals('Histórico de Treinos'));
    });

    test('Spanish (es) localizations loaded correctly', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      expect(l10n.homeTitle, equals('Inicio'));
      expect(l10n.settingsTitle, equals('Ajustes'));
      expect(l10n.workoutHistoryTitle, equals('Historial de Entrenamientos'));
    });
  });
}
