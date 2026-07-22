import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/database/app_database.dart';
import 'package:gym_app/features/workouts/data/local_workout_data_source.dart';
import 'package:gym_app/features/workouts/data/local_workout_repository.dart';
import 'package:gym_app/features/workouts/domain/imported_workout.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late LocalWorkoutRepository repository;

  setUp(() async {
    sqfliteFfiInit();
    database = AppDatabase(factory: databaseFactoryFfi);
    repository =
        LocalWorkoutRepository(database, const LocalWorkoutDataSource());
    await database.database;
    await database.clearAllData();
  });

  test('upsert updates existing workout without duplicating rows', () async {
    final base = DateTime.utc(2026, 5, 1, 10);
    final original = ImportedWorkout(
      externalId: 'dup-1',
      platform: WorkoutPlatform.appleHealth,
      sourceName: 'Apple Watch',
      activityType: 'running',
      startTime: base,
      endTime: base.add(const Duration(minutes: 30)),
      durationSeconds: 1800,
      activeEnergyKcal: 200,
      distanceMeters: 3000,
      importedAt: base,
      updatedAt: base,
    );
    final updated =
        original.copyWith(activeEnergyKcal: 250, distanceMeters: 3600);

    await repository.upsertWorkouts([original]);
    await repository.upsertWorkouts([updated]);

    final workouts = await repository.getWorkouts();
    expect(workouts, hasLength(1));
    expect(workouts.single.activeEnergyKcal, 250);
    expect(workouts.single.distanceMeters, 3600);
  });
}
