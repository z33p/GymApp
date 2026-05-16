import 'package:collection/collection.dart';

import '../../progress/domain/workout_progress_stats.dart';
import 'imported_workout.dart';

class WorkoutStatsCalculator {
  const WorkoutStatsCalculator();

  static const int maxStreakDays = 365;

  WorkoutProgressStats calculate(List<ImportedWorkout> workouts, {DateTime? now}) {
    final reference = (now ?? DateTime.now()).toUtc();
    final startOfWeek = DateTime.utc(reference.year, reference.month, reference.day)
        .subtract(Duration(days: reference.weekday - 1));
    final startOfMonth = DateTime.utc(reference.year, reference.month);

    final thisWeek = workouts.where((workout) => !workout.startTime.isBefore(startOfWeek)).toList();
    final thisMonth = workouts.where((workout) => !workout.startTime.isBefore(startOfMonth)).toList();

    final distinctWorkoutDays = workouts
        .map((workout) => DateTime.utc(workout.startTime.year, workout.startTime.month, workout.startTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    var streak = 0;
    var cursor = DateTime.utc(reference.year, reference.month, reference.day);
    if (distinctWorkoutDays.contains(cursor)) {
      while (streak < maxStreakDays && distinctWorkoutDays.contains(cursor)) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      }
    }

    return WorkoutProgressStats(
      workoutsThisWeek: thisWeek.length,
      workoutsThisMonth: thisMonth.length,
      totalDurationThisWeekSeconds: thisWeek.fold(0, (sum, workout) => sum + workout.durationSeconds),
      totalCaloriesThisWeek: thisWeek.fold(0.0, (sum, workout) => sum + (workout.activeEnergyKcal ?? 0)),
      totalDistanceThisWeekMeters: thisWeek.fold(0.0, (sum, workout) => sum + (workout.distanceMeters ?? 0)),
      currentStreakDays: streak,
    );
  }

  List<String> distinctActivities(List<ImportedWorkout> workouts) {
    return workouts.map((workout) => workout.activityType).toSet().sorted();
  }

  List<String> distinctSources(List<ImportedWorkout> workouts) {
    return workouts.map((workout) => workout.displaySource).toSet().sorted();
  }
}
