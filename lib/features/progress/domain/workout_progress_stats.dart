class WorkoutProgressStats {
  const WorkoutProgressStats({
    required this.workoutsThisWeek,
    required this.workoutsThisMonth,
    required this.totalDurationThisWeekSeconds,
    required this.totalCaloriesThisWeek,
    required this.totalDistanceThisWeekMeters,
    required this.currentStreakDays,
  });

  final int workoutsThisWeek;
  final int workoutsThisMonth;
  final int totalDurationThisWeekSeconds;
  final double totalCaloriesThisWeek;
  final double totalDistanceThisWeekMeters;
  final int currentStreakDays;
}
