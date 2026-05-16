import 'imported_workout.dart';
import 'workout_filters.dart';

abstract class WorkoutRepository {
  Future<List<ImportedWorkout>> getFeedWorkouts({int limit = 50});
  Future<List<ImportedWorkout>> getWorkouts({WorkoutFilterState? filters});
  Future<ImportedWorkout?> getWorkoutById(int id);
  Future<void> upsertWorkouts(List<ImportedWorkout> workouts);
  Future<void> deleteAll();
}
