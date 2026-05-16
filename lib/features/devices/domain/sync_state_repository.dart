import 'fitness_provider.dart';
import 'sync_state.dart';

abstract class SyncStateRepository {
  Future<SyncStateRecord?> getSyncState(FitnessProviderType provider);
  Future<void> saveSyncState(SyncStateRecord state);
  Future<void> deleteAll();
}
