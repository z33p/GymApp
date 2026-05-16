import '../../../core/database/app_database.dart';
import '../domain/imported_workout.dart';
import '../domain/workout_filters.dart';
import '../domain/workout_repository.dart';
import 'local_workout_data_source.dart';

class LocalWorkoutRepository implements WorkoutRepository {
  LocalWorkoutRepository(this._database, this._dataSource);

  final AppDatabase _database;
  final LocalWorkoutDataSource _dataSource;

  @override
  Future<void> deleteAll() async {
    final db = await _database.database;
    await _dataSource.deleteAll(db);
  }

  @override
  Future<List<ImportedWorkout>> getFeedWorkouts({int limit = 50}) async {
    final db = await _database.database;
    return _dataSource.getFeedWorkouts(db, limit: limit);
  }

  @override
  Future<ImportedWorkout?> getWorkoutById(int id) async {
    final db = await _database.database;
    return _dataSource.getWorkoutById(db, id);
  }

  @override
  Future<List<ImportedWorkout>> getWorkouts({WorkoutFilterState? filters}) async {
    final db = await _database.database;
    return _dataSource.getWorkouts(db, filters: filters);
  }

  @override
  Future<void> upsertWorkouts(List<ImportedWorkout> workouts) async {
    final db = await _database.database;
    await _dataSource.upsertWorkouts(db, workouts);
  }
}
