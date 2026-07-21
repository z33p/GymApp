import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/config/app_providers.dart';
import 'package:gym_app/features/gamification/domain/fauna_rank.dart';
import 'package:gym_app/features/gamification/presentation/habitat_screen.dart';
import 'package:gym_app/features/workouts/domain/imported_workout.dart';

ImportedWorkout workout() {
  final start = DateTime.utc(2026, 7, 21, 8);
  return ImportedWorkout(
    externalId: 'habitat-1',
    platform: WorkoutPlatform.appleHealth,
    sourceName: 'Apple Watch',
    activityType: 'running',
    startTime: start,
    endTime: start.add(const Duration(minutes: 30)),
    durationSeconds: 1800,
    importedAt: start,
    updatedAt: start,
  );
}

void main() {
  testWidgets('shows mascot, progression and recent activity', (tester) async {
    const rank = FaunaRank(
      tier: FaunaTier.bear,
      formPoints: 3,
      legacyPoints: 8,
      nextTier: FaunaTier.rhino,
      nextTierPoints: 4,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          faunaProgressProvider.overrideWith((ref) async => rank),
          feedWorkoutsProvider.overrideWith((ref) async => [workout()]),
        ],
        child: const MaterialApp(home: HabitatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Habitat'), findsOneWidget);
    expect(find.text('Urso'), findsOneWidget);
    expect(find.text('1 treinos para Rinoceronte'), findsOneWidget);
    expect(find.text('Sincronizar agora'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Apple Watch'), findsOneWidget);
  });

  testWidgets('shows a clear empty state for a new Rato', (tester) async {
    const rank = FaunaRank(
      tier: FaunaTier.rat,
      formPoints: 0,
      legacyPoints: 0,
      nextTier: FaunaTier.wolf,
      nextTierPoints: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          faunaProgressProvider.overrideWith((ref) async => rank),
          feedWorkoutsProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: HabitatScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rato'), findsOneWidget);
    expect(find.text('Seu Habitat começa com o próximo treino. Sincronize uma fonte para evoluir de Rato.'), findsOneWidget);
  });
}
