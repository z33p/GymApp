import '../../workouts/domain/imported_workout.dart';

enum FaunaTier {
  rat('Rato', '🐀', 0),
  wolf('Lobo', '🐺', 1),
  bear('Urso', '🐻', 2),
  rhino('Rinoceronte', '🦏', 4),
  gorilla('Gorila', '🦍', 7),
  apex('Leão ou Dragão', '🦁🐉', 12);

  const FaunaTier(this.label, this.mascot, this.minimumPoints);

  final String label;
  final String mascot;
  final int minimumPoints;
}

class FaunaRank {
  const FaunaRank({
    required this.tier,
    required this.formPoints,
    required this.legacyPoints,
    required this.nextTier,
    required this.nextTierPoints,
  });

  final FaunaTier tier;
  final int formPoints;
  final int legacyPoints;
  final FaunaTier? nextTier;
  final int? nextTierPoints;

  bool get isAtApex => nextTier == null;

  int get pointsToNext {
    if (nextTierPoints == null) return 0;
    return (nextTierPoints! - formPoints).clamp(0, nextTierPoints!);
  }
}

class FaunaRankCalculator {
  const FaunaRankCalculator();

  static const formWindow = Duration(days: 28);

  FaunaRank calculate(List<ImportedWorkout> workouts, {DateTime? now}) {
    final reference = (now ?? DateTime.now()).toUtc();
    final formStart = reference.subtract(formWindow);
    final validWorkouts = workouts.where((workout) => workout.deletedAt == null);
    final formPoints = validWorkouts
        .where((workout) => !workout.startTime.isBefore(formStart) && !workout.startTime.isAfter(reference))
        .length;
    final legacyPoints = validWorkouts.where((workout) {
      final start = workout.startTime.toUtc();
      return start.year == reference.year;
    }).length;

    final tier = FaunaTier.values.lastWhere((item) => formPoints >= item.minimumPoints);
    final tierIndex = FaunaTier.values.indexOf(tier);
    final nextTier = tierIndex == FaunaTier.values.length - 1 ? null : FaunaTier.values[tierIndex + 1];

    return FaunaRank(
      tier: tier,
      formPoints: formPoints,
      legacyPoints: legacyPoints,
      nextTier: nextTier,
      nextTierPoints: nextTier?.minimumPoints,
    );
  }
}
