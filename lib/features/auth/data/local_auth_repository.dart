import '../../../core/database/app_database.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'mock_auth_data_source.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._database, this._dataSource);

  final AppDatabase _database;
  final MockAuthDataSource _dataSource;

  @override
  Future<void> clearUser() async {
    final db = await _database.database;
    await db.delete('app_user');
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final db = await _database.database;
    return _dataSource.getCurrentUser(db);
  }

  @override
  Future<AppUser> signInDebug() async {
    final db = await _database.database;
    return _dataSource.ensureUser(db);
  }

  @override
  Future<void> signInWith(AuthProvider provider) async {
    throw AuthProviderNotConfiguredException(provider);
  }
}
