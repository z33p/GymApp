import 'fitness_provider.dart';

enum SyncStatus { idle, syncing, success, failed }

extension SyncStatusX on SyncStatus {
  String get value => switch (this) {
        SyncStatus.idle => 'idle',
        SyncStatus.syncing => 'syncing',
        SyncStatus.success => 'success',
        SyncStatus.failed => 'failed',
      };

  static SyncStatus fromValue(String value) {
    return SyncStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SyncStatus.idle,
    );
  }
}

class SyncStateRecord {
  const SyncStateRecord({
    this.id,
    required this.provider,
    required this.status,
    this.anchorData,
    this.lastSuccessfulSyncAt,
    this.lastAttemptedSyncAt,
    this.errorMessage,
  });

  final int? id;
  final FitnessProviderType provider;
  final String? anchorData;
  final DateTime? lastSuccessfulSyncAt;
  final DateTime? lastAttemptedSyncAt;
  final SyncStatus status;
  final String? errorMessage;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'provider': provider.value,
      'anchor_data': anchorData,
      'last_successful_sync_at': lastSuccessfulSyncAt?.toIso8601String(),
      'last_attempted_sync_at': lastAttemptedSyncAt?.toIso8601String(),
      'status': status.value,
      'error_message': errorMessage,
    };
  }

  factory SyncStateRecord.fromMap(Map<String, Object?> map) {
    final providerValue =
        map['provider'] as String? ?? FitnessProviderType.appleHealth.value;
    return SyncStateRecord(
      id: map['id'] as int?,
      provider: FitnessProviderType.values.firstWhere(
        (provider) => provider.value == providerValue,
        orElse: () => FitnessProviderType.appleHealth,
      ),
      anchorData: map['anchor_data'] as String?,
      lastSuccessfulSyncAt: map['last_successful_sync_at'] == null
          ? null
          : DateTime.parse(map['last_successful_sync_at'] as String),
      lastAttemptedSyncAt: map['last_attempted_sync_at'] == null
          ? null
          : DateTime.parse(map['last_attempted_sync_at'] as String),
      status: SyncStatusX.fromValue(map['status'] as String? ?? 'idle'),
      errorMessage: map['error_message'] as String?,
    );
  }
}
