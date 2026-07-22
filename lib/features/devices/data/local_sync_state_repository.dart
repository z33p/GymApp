import '../../../core/database/app_database.dart';
import '../domain/fitness_provider.dart';
import '../domain/sync_state.dart';
import '../domain/sync_state_repository.dart';

class LocalSyncStateRepository implements SyncStateRepository {
  LocalSyncStateRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> deleteAll() async {
    final db = await _database.database;
    await db.delete('sync_state');
  }

  @override
  Future<SyncStateRecord?> getSyncState(FitnessProviderType provider) async {
    final db = await _database.database;
    final rows = await db.query(
      'sync_state',
      where: 'provider = ?',
      whereArgs: [provider.value],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SyncStateRecord.fromMap(rows.first);
  }

  @override
  Future<void> saveSyncState(SyncStateRecord state) async {
    final db = await _database.database;
    final existing = await getSyncState(state.provider);
    if (existing == null) {
      await db.insert('sync_state', state.toMap());
    } else {
      await db.update(
        'sync_state',
        state.copyWith(id: existing.id).toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }
}

extension on SyncStateRecord {
  SyncStateRecord copyWith({
    int? id,
    FitnessProviderType? provider,
    String? anchorData,
    DateTime? lastSuccessfulSyncAt,
    DateTime? lastAttemptedSyncAt,
    SyncStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SyncStateRecord(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      anchorData: anchorData ?? this.anchorData,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      lastAttemptedSyncAt: lastAttemptedSyncAt ?? this.lastAttemptedSyncAt,
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
