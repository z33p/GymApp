import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/local_auth_repository.dart';
import '../../features/auth/data/mock_auth_data_source.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/devices/data/apple_health/apple_health_data_source.dart';
import '../../features/devices/data/device_integration_repository_impl.dart';
import '../../features/devices/data/fitness_import_repository_impl.dart';
import '../../features/devices/data/local_sync_state_repository.dart';
import '../../features/devices/data/mock/mock_fitness_data_source.dart';
import '../../features/devices/domain/device_integration_repository.dart';
import '../../features/devices/domain/fitness_import_repository.dart';
import '../../features/devices/domain/fitness_provider.dart';
import '../../features/devices/domain/sync_state.dart';
import '../../features/devices/domain/sync_state_repository.dart';
import '../../features/progress/domain/workout_progress_stats.dart';
import '../../features/gamification/domain/fauna_rank.dart';
import '../../features/workouts/data/local_workout_data_source.dart';
import '../../features/workouts/data/local_workout_repository.dart';
import '../../features/workouts/domain/imported_workout.dart';
import '../../features/workouts/domain/workout_filters.dart';
import '../../features/workouts/domain/workout_repository.dart';
import '../../features/workouts/domain/workout_stats_calculator.dart';
import '../database/app_database.dart';
import 'app_settings.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final workoutStatsCalculatorProvider = Provider<WorkoutStatsCalculator>((ref) => const WorkoutStatsCalculator());
final faunaRankCalculatorProvider = Provider<FaunaRankCalculator>((ref) => const FaunaRankCalculator());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthRepository(ref.watch(appDatabaseProvider), const MockAuthDataSource());
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return LocalWorkoutRepository(ref.watch(appDatabaseProvider), const LocalWorkoutDataSource());
});

final syncStateRepositoryProvider = Provider<SyncStateRepository>((ref) {
  return LocalSyncStateRepository(ref.watch(appDatabaseProvider));
});

final appleHealthDataSourceProvider = Provider((ref) => AppleHealthDataSource());
final mockFitnessDataSourceProvider = Provider((ref) => const MockFitnessDataSource());

final deviceIntegrationRepositoryProvider = Provider<DeviceIntegrationRepository>((ref) {
  return DeviceIntegrationRepositoryImpl(
    ref.watch(appleHealthDataSourceProvider),
    ref.watch(mockFitnessDataSourceProvider),
  );
});

final fitnessImportRepositoryProvider = Provider<FitnessImportRepository>((ref) {
  return FitnessImportRepositoryImpl(
    ref.watch(appleHealthDataSourceProvider),
    ref.watch(mockFitnessDataSourceProvider),
    ref.watch(workoutRepositoryProvider),
    ref.watch(syncStateRepositoryProvider),
  );
});

final refreshTickerProvider = StateProvider<int>((ref) => 0);
final historyFiltersProvider = StateProvider<WorkoutFilterState>((ref) => const WorkoutFilterState());
final bootstrapSyncWarningProvider = StateProvider<String?>((ref) => null);

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  ref.watch(refreshTickerProvider);
  return ref.watch(authRepositoryProvider).getCurrentUser();
});

final bootstrapProvider = FutureProvider<void>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  await authRepository.ensureMockUser();
  ref.invalidate(currentUserProvider);
  ref.read(bootstrapSyncWarningProvider.notifier).state = null;
  try {
    await ref.watch(fitnessImportRepositoryProvider).sync(FitnessProviderType.appleHealth);
  } catch (error, stackTrace) {
    debugPrint('Bootstrap sync failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    ref.read(bootstrapSyncWarningProvider.notifier).state =
        'Startup sync could not complete. You can retry from Devices.';
  }
  ref.read(refreshTickerProvider.notifier).state++;
});

final feedWorkoutsProvider = FutureProvider<List<ImportedWorkout>>((ref) async {
  ref.watch(refreshTickerProvider);
  return ref.watch(workoutRepositoryProvider).getFeedWorkouts();
});

final allWorkoutsProvider = FutureProvider<List<ImportedWorkout>>((ref) async {
  ref.watch(refreshTickerProvider);
  return ref.watch(workoutRepositoryProvider).getWorkouts();
});

final historyWorkoutsProvider = FutureProvider<List<ImportedWorkout>>((ref) async {
  ref.watch(refreshTickerProvider);
  final filters = ref.watch(historyFiltersProvider);
  return ref.watch(workoutRepositoryProvider).getWorkouts(filters: filters);
});

final workoutByIdProvider = FutureProvider.family<ImportedWorkout?, int>((ref, id) async {
  ref.watch(refreshTickerProvider);
  return ref.watch(workoutRepositoryProvider).getWorkoutById(id);
});

final syncStateProvider = FutureProvider.family<SyncStateRecord?, FitnessProviderType>((ref, provider) async {
  ref.watch(refreshTickerProvider);
  return ref.watch(syncStateRepositoryProvider).getSyncState(provider);
});

final deviceConnectionProvider = FutureProvider.family<DeviceConnectionInfo, FitnessProviderType>((ref, provider) async {
  ref.watch(refreshTickerProvider);
  return ref.watch(deviceIntegrationRepositoryProvider).getConnectionInfo(provider);
});

final progressStatsProvider = FutureProvider<WorkoutProgressStats>((ref) async {
  final workouts = await ref.watch(allWorkoutsProvider.future);
  return ref.watch(workoutStatsCalculatorProvider).calculate(workouts);
});

final faunaProgressProvider = FutureProvider<FaunaRank>((ref) async {
  final workouts = await ref.watch(allWorkoutsProvider.future);
  return ref.watch(faunaRankCalculatorProvider).calculate(workouts);
});

class SyncController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> connectAppleHealth() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deviceIntegrationRepositoryProvider).connect(FitnessProviderType.appleHealth);
      ref.read(refreshTickerProvider.notifier).state++;
    });
  }

  Future<void> syncAppleHealth({bool manual = true}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(fitnessImportRepositoryProvider).sync(FitnessProviderType.appleHealth, manual: manual);
      ref.read(refreshTickerProvider.notifier).state++;
    });
  }

  Future<void> clearLocalData() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(appDatabaseProvider).clearAllData();
      await ref.read(authRepositoryProvider).ensureMockUser();
      ref.read(refreshTickerProvider.notifier).state++;
    });
  }
}

final syncControllerProvider = AsyncNotifierProvider<SyncController, void>(SyncController.new);

class SettingsController extends AsyncNotifier<AppSettings> {
  static const _themeKey = 'theme_preference';
  static const _unitsKey = 'units_preference';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString(_themeKey) ?? AppThemePreference.system.name;
    final unitsValue = prefs.getString(_unitsKey) ?? AppUnits.metric.name;
    return AppSettings(
      themePreference: AppThemePreference.values.firstWhere(
        (item) => item.name == themeValue,
        orElse: () => AppThemePreference.system,
      ),
      units: AppUnits.values.firstWhere(
        (item) => item.name == unitsValue,
        orElse: () => AppUnits.metric,
      ),
    );
  }

  Future<void> updateTheme(AppThemePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, preference.name);
    state = AsyncData((state.value ?? const AppSettings()).copyWith(themePreference: preference));
  }

  Future<void> updateUnits(AppUnits units) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitsKey, units.name);
    state = AsyncData((state.value ?? const AppSettings()).copyWith(units: units));
  }
}

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);
