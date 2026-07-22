import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/gamification/domain/fauna_rank.dart';
import 'package:gym_app/features/workouts/domain/imported_workout.dart';

ImportedWorkout workout(String id, DateTime start, {DateTime? deletedAt}) {
  return ImportedWorkout(
    externalId: id,
    platform: WorkoutPlatform.mock,
    activityType: 'running',
    startTime: start,
    endTime: start.add(const Duration(minutes: 30)),
    durationSeconds: 1800,
    importedAt: start,
    updatedAt: start,
    deletedAt: deletedAt,
  );
}

void main() {
  const calculator = FaunaRankCalculator();
  final now = DateTime.utc(2026, 7, 21, 12);

  test('empty history starts at Rato with zero Forma', () {
    final rank = calculator.calculate(const [], now: now);

    expect(rank.tier, FaunaTier.rat);
    expect(rank.formPoints, 0);
    expect(rank.legacyPoints, 0);
    expect(rank.nextTier, FaunaTier.wolf);
    expect(rank.pointsToNext, 1);
  });

  test('Forma crosses the documented animal thresholds', () {
    final workouts = List.generate(
      12,
      (index) => workout('w$index', now.subtract(Duration(days: index))),
    );

    expect(calculator.calculate(workouts.take(1).toList(), now: now).tier,
        FaunaTier.wolf);
    expect(calculator.calculate(workouts.take(2).toList(), now: now).tier,
        FaunaTier.bear);
    expect(calculator.calculate(workouts.take(4).toList(), now: now).tier,
        FaunaTier.rhino);
    expect(calculator.calculate(workouts.take(7).toList(), now: now).tier,
        FaunaTier.gorilla);
    expect(calculator.calculate(workouts, now: now).tier, FaunaTier.apex);
  });

  test('Forma uses 28 days while Legado keeps current-year history', () {
    final recent = workout('recent', now.subtract(const Duration(days: 2)));
    final old = workout('old', now.subtract(const Duration(days: 40)));
    final rank = calculator.calculate([recent, old], now: now);

    expect(rank.formPoints, 1);
    expect(rank.legacyPoints, 2);
    expect(rank.tier, FaunaTier.wolf);
  });

  test('deleted workouts do not contribute to Forma or Legado', () {
    final deleted = workout('deleted', now, deletedAt: now);
    final rank = calculator.calculate([deleted], now: now);

    expect(rank.formPoints, 0);
    expect(rank.legacyPoints, 0);
    expect(rank.tier, FaunaTier.rat);
  });
}
