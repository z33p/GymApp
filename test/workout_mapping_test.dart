import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/workouts/domain/imported_workout.dart';

void main() {
  test('maps platform payload into imported workout', () {
    final workout = ImportedWorkout.fromPlatformPayload(
      platform: WorkoutPlatform.appleHealth,
      payload: {
        'externalId': 'hk-1',
        'activityType': 'running',
        'startTime': '2026-05-01T10:00:00Z',
        'endTime': '2026-05-01T10:30:00Z',
        'durationSeconds': 1800,
        'activeEnergyKcal': 320.5,
        'distanceMeters': 5200.0,
        'sourceName': 'Apple Watch',
        'rawPayload': {'uuid': 'hk-1'},
      },
    );

    expect(workout.externalId, 'hk-1');
    expect(workout.platform, WorkoutPlatform.appleHealth);
    expect(workout.durationSeconds, 1800);
    expect(workout.activeEnergyKcal, 320.5);
    expect(workout.distanceMeters, 5200.0);
    expect(workout.displaySource, 'Apple Watch');
  });
}
