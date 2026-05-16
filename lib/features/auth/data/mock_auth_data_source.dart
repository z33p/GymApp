import 'package:sqflite/sqflite.dart';

import '../../auth/domain/app_user.dart';

class MockAuthDataSource {
  const MockAuthDataSource();

  Future<AppUser?> getCurrentUser(Database db) async {
    final rows = await db.query('app_user', limit: 1);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser> ensureUser(Database db) async {
    final existing = await getCurrentUser(db);
    if (existing != null) return existing;

    final now = DateTime.now().toUtc();
    const user = AppUser(
      id: 'local-user-1',
      displayName: 'Alex GymApp',
      username: 'alexgym',
      avatarUrl: null,
      createdAt: DateTime.utc(2024, 1, 1),
      updatedAt: DateTime.utc(2024, 1, 1),
    );
    final newUser = AppUser(
      id: user.id,
      displayName: user.displayName,
      username: user.username,
      avatarUrl: user.avatarUrl,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('app_user', newUser.toMap());
    return newUser;
  }
}
