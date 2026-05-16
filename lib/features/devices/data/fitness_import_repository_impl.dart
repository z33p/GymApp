import '../domain/fitness_import_repository.dart';
import '../domain/fitness_provider.dart';
import '../domain/sync_state.dart';
import '../domain/sync_state_repository.dart';
import '../../workouts/domain/workout_repository.dart';
import 'apple_health/apple_health_data_source.dart';
import 'mock/mock_fitness_data_source.dart';

class FitnessImportRepositoryImpl implements FitnessImportRepository {
  FitnessImportRepositoryImpl(
    this._appleHealthDataSource,
    this._mockDataSource,
    this._workoutRepository,
    this._syncStateRepository,
  );

  final AppleHealthDataSource _appleHealthDataSource;
  final MockFitnessDataSource _mockDataSource;
  final WorkoutRepository _workoutRepository;
  final SyncStateRepository _syncStateRepository;

  @override
  Future<FitnessSyncResult> sync(FitnessProviderType provider, {bool manual = false}) async {
    final previousState = await _syncStateRepository.getSyncState(provider);
    final attemptTime = DateTime.now().toUtc();
    await _syncStateRepository.saveSyncState(
      SyncStateRecord(
        id: previousState?.id,
        provider: provider,
        anchorData: previousState?.anchorData,
        lastSuccessfulSyncAt: previousState?.lastSuccessfulSyncAt,
        lastAttemptedSyncAt: attemptTime,
        status: SyncStatus.syncing,
        errorMessage: null,
      ),
    );

    try {
      final payload = provider == FitnessProviderType.appleHealth && await _appleHealthDataSource.isAvailable()
          ? await _appleHealthDataSource.syncWorkouts(anchorData: previousState?.anchorData)
          : await _mockDataSource.syncPreviewWorkouts();
      await _workoutRepository.upsertWorkouts(payload.workouts);
      final newState = SyncStateRecord(
        id: previousState?.id,
        provider: provider,
        anchorData: payload.anchorData ?? previousState?.anchorData,
        lastSuccessfulSyncAt: attemptTime,
        lastAttemptedSyncAt: attemptTime,
        status: SyncStatus.success,
        errorMessage: null,
      );
      await _syncStateRepository.saveSyncState(newState);
      return FitnessSyncResult(
        provider: provider,
        importedCount: payload.workouts.length,
        workouts: payload.workouts,
        syncState: newState,
      );
    } catch (error) {
      final failedState = SyncStateRecord(
        id: previousState?.id,
        provider: provider,
        anchorData: previousState?.anchorData,
        lastSuccessfulSyncAt: previousState?.lastSuccessfulSyncAt,
        lastAttemptedSyncAt: attemptTime,
        status: SyncStatus.failed,
        errorMessage: error.toString(),
      );
      await _syncStateRepository.saveSyncState(failedState);
      rethrow;
    }
  }
}
