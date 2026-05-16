import 'dart:io';

import 'package:flutter/services.dart';

import '../../../workouts/domain/imported_workout.dart';
import '../../domain/fitness_provider.dart';

class AppleHealthSyncPayload {
  const AppleHealthSyncPayload({
    required this.workouts,
    required this.anchorData,
  });

  final List<ImportedWorkout> workouts;
  final String? anchorData;
}

class AppleHealthDataSource {
  static const String statusUnsupported = 'unsupported';
  static const String statusUnavailable = 'unavailable';
  static const String statusNotDetermined = 'notDetermined';

  AppleHealthDataSource() : _channel = const MethodChannel('com.gymapp.health/apple_health');

  final MethodChannel _channel;

  bool get isSupportedPlatform => Platform.isIOS;

  Future<bool> isAvailable() async {
    if (!isSupportedPlatform) return false;
    try {
      return (await _channel.invokeMethod<bool>('isHealthDataAvailable')) ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<String> getAuthorizationStatus() async {
    if (!isSupportedPlatform) return statusUnsupported;
    try {
      return (await _channel.invokeMethod<String>('getAuthorizationStatus')) ?? statusNotDetermined;
    } on PlatformException {
      return statusUnavailable;
    }
  }

  Future<bool> requestAuthorization() async {
    if (!isSupportedPlatform) return false;
    try {
      return (await _channel.invokeMethod<bool>('requestAuthorization')) ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<AppleHealthSyncPayload> syncWorkouts({String? anchorData}) async {
    if (!isSupportedPlatform) {
      return const AppleHealthSyncPayload(workouts: [], anchorData: null);
    }
    final method = anchorData == null || anchorData.isEmpty ? 'syncWorkouts' : 'syncWorkoutsSince';
    final response = await _channel.invokeMapMethod<String, dynamic>(
          method,
          anchorData == null || anchorData.isEmpty ? null : {'anchorData': anchorData},
        ) ??
        <String, dynamic>{};
    final rawWorkouts = (response['workouts'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<dynamic, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .map((payload) => ImportedWorkout.fromPlatformPayload(
              platform: FitnessProviderType.appleHealth.toWorkoutPlatform(),
              payload: payload,
            ))
        .toList();
    return AppleHealthSyncPayload(
      workouts: rawWorkouts,
      anchorData: response['anchorData'] as String?,
    );
  }
}

extension on FitnessProviderType {
  WorkoutPlatform toWorkoutPlatform() {
    return switch (this) {
      FitnessProviderType.appleHealth => WorkoutPlatform.appleHealth,
      FitnessProviderType.healthConnect => WorkoutPlatform.healthConnect,
      FitnessProviderType.garmin => WorkoutPlatform.garmin,
      FitnessProviderType.mock => WorkoutPlatform.mock,
    };
  }
}
