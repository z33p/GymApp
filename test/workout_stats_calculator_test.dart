import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/workouts/domain/imported_workout.dart';
import 'package:gym_app/features/workouts/domain/workout_stats_calculator.dart';

void main() {
  test('calculates weekly and monthly workout stats', () {
    const calculator = WorkoutStatsCalculator();
    final workouts = [
      ImportedWorkout(
        externalId: '1',
        platform: WorkoutPlatform.mock,
        activityType: 'running',
        startTime: DateTime.utc(2026, 5, 11, 8),
        endTime: DateTime.utc(2026, 5, 11, 8, 30),
        durationSeconds: 1800,
        activeEnergyKcal: 300,
        distanceMeters: 5000,
        importedAt: DateTime.utc(2026, 5, 11, 9),
        updatedAt: DateTime.utc(2026, 5, 11, 9),
      ),
      ImportedWorkout(
        externalId: '2',
        platform: WorkoutPlatform.mock,
        activityType: 'cycling',
        startTime: DateTime.utc(2026, 5, 12, 8),
        endTime: DateTime.utc(2026, 5, 12, 9),
        durationSeconds: 3600,
        activeEnergyKcal: 450,
        distanceMeters: 22000,
        importedAt: DateTime.utc(2026, 5, 12, 9),
        updatedAt: DateTime.utc(2026, 5, 12, 9),
      ),
    ];

    final stats =
        calculator.calculate(workouts, now: DateTime.utc(2026, 5, 12, 10));

    expect(stats.workoutsThisWeek, 2);
    expect(stats.workoutsThisMonth, 2);
    expect(stats.totalDurationThisWeekSeconds, 5400);
    expect(stats.totalCaloriesThisWeek, 750);
    expect(stats.totalDistanceThisWeekMeters, 27000);
    expect(stats.currentStreakDays, 2);
  });
}
