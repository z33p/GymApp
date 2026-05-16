import 'dart:convert';

enum WorkoutPlatform { appleHealth, healthConnect, garmin, manual, mock }

extension WorkoutPlatformX on WorkoutPlatform {
  String get value => switch (this) {
        WorkoutPlatform.appleHealth => 'apple_health',
        WorkoutPlatform.healthConnect => 'health_connect',
        WorkoutPlatform.garmin => 'garmin',
        WorkoutPlatform.manual => 'manual',
        WorkoutPlatform.mock => 'mock',
      };

  String get label => switch (this) {
        WorkoutPlatform.appleHealth => 'Apple Health',
        WorkoutPlatform.healthConnect => 'Health Connect',
        WorkoutPlatform.garmin => 'Garmin',
        WorkoutPlatform.manual => 'Manual',
        WorkoutPlatform.mock => 'Preview',
      };

  static WorkoutPlatform fromValue(String value) {
    return WorkoutPlatform.values.firstWhere(
      (platform) => platform.value == value,
      orElse: () => WorkoutPlatform.mock,
    );
  }
}

class ImportedWorkout {
  const ImportedWorkout({
    this.id,
    required this.externalId,
    required this.platform,
    required this.activityType,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.importedAt,
    required this.updatedAt,
    this.sourceName,
    this.activeEnergyKcal,
    this.distanceMeters,
    this.averageHeartRate,
    this.maxHeartRate,
    this.notes,
    this.rawPayload,
    this.deletedAt,
  });

  final int? id;
  final String? externalId;
  final WorkoutPlatform platform;
  final String? sourceName;
  final String activityType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final double? activeEnergyKcal;
  final double? distanceMeters;
  final double? averageHeartRate;
  final double? maxHeartRate;
  final String? notes;
  final Map<String, dynamic>? rawPayload;
  final DateTime importedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ImportedWorkout copyWith({
    int? id,
    String? externalId,
    WorkoutPlatform? platform,
    String? sourceName,
    String? activityType,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    double? activeEnergyKcal,
    double? distanceMeters,
    double? averageHeartRate,
    double? maxHeartRate,
    String? notes,
    Map<String, dynamic>? rawPayload,
    DateTime? importedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ImportedWorkout(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      platform: platform ?? this.platform,
      sourceName: sourceName ?? this.sourceName,
      activityType: activityType ?? this.activityType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      activeEnergyKcal: activeEnergyKcal ?? this.activeEnergyKcal,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      notes: notes ?? this.notes,
      rawPayload: rawPayload ?? this.rawPayload,
      importedAt: importedAt ?? this.importedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  String get displaySource => sourceName?.trim().isNotEmpty == true ? sourceName!.trim() : platform.label;

  String get displayActivityType {
    return activityType
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'external_id': externalId,
      'platform': platform.value,
      'source_name': sourceName,
      'activity_type': activityType,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_seconds': durationSeconds,
      'active_energy_kcal': activeEnergyKcal,
      'distance_meters': distanceMeters,
      'average_heart_rate': averageHeartRate,
      'max_heart_rate': maxHeartRate,
      'notes': notes,
      'raw_payload_json': rawPayload == null ? null : jsonEncode(rawPayload),
      'imported_at': importedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory ImportedWorkout.fromMap(Map<String, Object?> map) {
    return ImportedWorkout(
      id: map['id'] as int?,
      externalId: map['external_id'] as String?,
      platform: WorkoutPlatformX.fromValue(map['platform'] as String? ?? 'mock'),
      sourceName: map['source_name'] as String?,
      activityType: map['activity_type'] as String? ?? 'unknown',
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      durationSeconds: map['duration_seconds'] as int? ?? 0,
      activeEnergyKcal: (map['active_energy_kcal'] as num?)?.toDouble(),
      distanceMeters: (map['distance_meters'] as num?)?.toDouble(),
      averageHeartRate: (map['average_heart_rate'] as num?)?.toDouble(),
      maxHeartRate: (map['max_heart_rate'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      rawPayload: map['raw_payload_json'] == null
          ? null
          : Map<String, dynamic>.from(jsonDecode(map['raw_payload_json'] as String) as Map),
      importedAt: DateTime.parse(map['imported_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] == null ? null : DateTime.parse(map['deleted_at'] as String),
    );
  }

  factory ImportedWorkout.fromPlatformPayload({
    required WorkoutPlatform platform,
    required Map<String, dynamic> payload,
  }) {
    final now = DateTime.now().toUtc();
    return ImportedWorkout(
      externalId: payload['externalId'] as String?,
      platform: platform,
      sourceName: payload['sourceName'] as String?,
      activityType: (payload['activityType'] as String? ?? 'unknown').toLowerCase(),
      startTime: DateTime.parse(payload['startTime'] as String).toUtc(),
      endTime: DateTime.parse(payload['endTime'] as String).toUtc(),
      durationSeconds: (payload['durationSeconds'] as num?)?.round() ?? 0,
      activeEnergyKcal: (payload['activeEnergyKcal'] as num?)?.toDouble(),
      distanceMeters: (payload['distanceMeters'] as num?)?.toDouble(),
      averageHeartRate: (payload['averageHeartRate'] as num?)?.toDouble(),
      maxHeartRate: (payload['maxHeartRate'] as num?)?.toDouble(),
      rawPayload: payload['rawPayload'] is Map
          ? Map<String, dynamic>.from(payload['rawPayload'] as Map)
          : payload,
      importedAt: now,
      updatedAt: now,
    );
  }
}
