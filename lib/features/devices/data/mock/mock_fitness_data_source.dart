import '../../../workouts/domain/imported_workout.dart';
import '../../domain/fitness_provider.dart';
import '../apple_health/apple_health_data_source.dart';

class MockFitnessDataSource {
  const MockFitnessDataSource();

  Future<AppleHealthSyncPayload> syncPreviewWorkouts() async {
    final now = DateTime.now().toUtc();
    final workouts = [
      ImportedWorkout(
        externalId: 'mock-workout-1',
        platform: WorkoutPlatform.mock,
        sourceName: 'Apple Watch Preview',
        activityType: 'traditional_strength_training',
        startTime: now.subtract(const Duration(days: 1, hours: 2)),
        endTime: now.subtract(const Duration(days: 1, hours: 1, minutes: 12)),
        durationSeconds: 48 * 60,
        activeEnergyKcal: 466,
        distanceMeters: null,
        averageHeartRate: null,
        maxHeartRate: null,
        notes: 'Preview workout imported from the local mock data source.',
        rawPayload: const {'mode': 'preview', 'source': 'mock'},
        importedAt: now,
        updatedAt: now,
      ),
      ImportedWorkout(
        externalId: 'mock-workout-2',
        platform: WorkoutPlatform.mock,
        sourceName: 'Preview Run',
        activityType: 'running',
        startTime: now.subtract(const Duration(days: 3, hours: 3)),
        endTime: now.subtract(const Duration(days: 3, hours: 2, minutes: 20)),
        durationSeconds: 40 * 60,
        activeEnergyKcal: 388,
        distanceMeters: 6200,
        averageHeartRate: 148,
        maxHeartRate: 172,
        notes: null,
        rawPayload: const {'mode': 'preview', 'source': 'mock'},
        importedAt: now,
        updatedAt: now,
      ),
    ];
    return AppleHealthSyncPayload(workouts: workouts, anchorData: 'mock-anchor-${now.millisecondsSinceEpoch}');
  }

  Future<String> getAuthorizationStatus() async => 'preview';

  Future<bool> requestAuthorization() async => true;

  Future<bool> isAvailable() async => true;

  FitnessProviderType get provider => FitnessProviderType.mock;
}
