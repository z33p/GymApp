import 'package:sqflite/sqflite.dart';

import '../domain/imported_workout.dart';
import '../domain/workout_filters.dart';

class LocalWorkoutDataSource {
  const LocalWorkoutDataSource();

  Future<List<ImportedWorkout>> getFeedWorkouts(Database db, {int limit = 50}) async {
    final rows = await db.query(
      'imported_workouts',
      where: 'deleted_at IS NULL',
      orderBy: 'start_time DESC',
      limit: limit,
    );
    return rows.map(ImportedWorkout.fromMap).toList();
  }

  Future<List<ImportedWorkout>> getWorkouts(Database db, {WorkoutFilterState? filters}) async {
    final whereClauses = <String>['deleted_at IS NULL'];
    final args = <Object?>[];
    if (filters != null) {
      if (filters.activityType != null && filters.activityType!.isNotEmpty) {
        whereClauses.add('activity_type = ?');
        args.add(filters.activityType);
      }
      if (filters.sourceName != null && filters.sourceName!.isNotEmpty) {
        whereClauses.add('source_name = ?');
        args.add(filters.sourceName);
      }
      if (filters.query.trim().isNotEmpty) {
        final query = '%${filters.query.trim().toLowerCase()}%';
        whereClauses.add("(LOWER(activity_type) LIKE ? OR LOWER(COALESCE(source_name, '')) LIKE ?)");
        args.addAll([query, query]);
      }
    }
    final rows = await db.query(
      'imported_workouts',
      where: whereClauses.join(' AND '),
      whereArgs: args,
      orderBy: 'start_time DESC',
    );
    return rows.map(ImportedWorkout.fromMap).toList();
  }

  Future<ImportedWorkout?> getWorkoutById(Database db, int id) async {
    final rows = await db.query('imported_workouts', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return ImportedWorkout.fromMap(rows.first);
  }

  Future<void> upsertWorkouts(Database db, List<ImportedWorkout> workouts) async {
    await db.transaction((txn) async {
      for (final workout in workouts) {
        if (workout.externalId != null) {
          final existing = await txn.query(
            'imported_workouts',
            where: 'platform = ? AND external_id = ?',
            whereArgs: [workout.platform.value, workout.externalId],
            limit: 1,
          );
          if (existing.isNotEmpty) {
            final existingWorkout = ImportedWorkout.fromMap(existing.first);
            await txn.update(
              'imported_workouts',
              workout
                  .copyWith(
                    id: existingWorkout.id,
                    importedAt: existingWorkout.importedAt,
                    updatedAt: DateTime.now().toUtc(),
                  )
                  .toMap(),
              where: 'id = ?',
              whereArgs: [existingWorkout.id],
            );
            continue;
          }
        }
        await txn.insert('imported_workouts', workout.toMap());
      }
    });
  }

  Future<void> deleteAll(Database db) async {
    await db.delete('imported_workouts');
  }
}
