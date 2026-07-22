import '../../workouts/domain/imported_workout.dart';
import 'fitness_provider.dart';
import 'sync_state.dart';

class FitnessSyncResult {
  const FitnessSyncResult({
    required this.provider,
    required this.importedCount,
    required this.workouts,
    required this.syncState,
  });

  final FitnessProviderType provider;
  final int importedCount;
  final List<ImportedWorkout> workouts;
  final SyncStateRecord syncState;
}

abstract class FitnessImportRepository {
  Future<FitnessSyncResult> sync(FitnessProviderType provider,
      {bool manual = false});
}
