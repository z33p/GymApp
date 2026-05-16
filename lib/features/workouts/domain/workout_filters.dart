class WorkoutFilterState {
  const WorkoutFilterState({
    this.query = '',
    this.activityType,
    this.sourceName,
  });

  final String query;
  final String? activityType;
  final String? sourceName;

  WorkoutFilterState copyWith({
    String? query,
    String? activityType,
    String? sourceName,
    bool clearActivityType = false,
    bool clearSourceName = false,
  }) {
    return WorkoutFilterState(
      query: query ?? this.query,
      activityType: clearActivityType ? null : activityType ?? this.activityType,
      sourceName: clearSourceName ? null : sourceName ?? this.sourceName,
    );
  }
}
