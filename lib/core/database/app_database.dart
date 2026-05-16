import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({DatabaseFactory? factory}) : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = p.join(await getDatabasesPath(), 'gym_app.db');
    _database = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE app_user (
              id TEXT PRIMARY KEY,
              display_name TEXT NOT NULL,
              username TEXT NOT NULL,
              avatar_url TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE imported_workouts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              external_id TEXT,
              platform TEXT NOT NULL,
              source_name TEXT,
              activity_type TEXT NOT NULL,
              start_time TEXT NOT NULL,
              end_time TEXT NOT NULL,
              duration_seconds INTEGER NOT NULL,
              active_energy_kcal REAL,
              distance_meters REAL,
              average_heart_rate REAL,
              max_heart_rate REAL,
              notes TEXT,
              raw_payload_json TEXT,
              imported_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              deleted_at TEXT,
              UNIQUE(platform, external_id)
            )
          ''');
          await db.execute('''
            CREATE TABLE sync_state (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              provider TEXT NOT NULL UNIQUE,
              anchor_data TEXT,
              last_successful_sync_at TEXT,
              last_attempted_sync_at TEXT,
              status TEXT NOT NULL,
              error_message TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE check_ins (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              workout_id INTEGER NOT NULL,
              user_id TEXT NOT NULL,
              caption TEXT,
              visibility TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              FOREIGN KEY(workout_id) REFERENCES imported_workouts(id)
            )
          ''');
          await db.execute('CREATE INDEX idx_workouts_start_time ON imported_workouts(start_time DESC)');
          await db.execute('CREATE INDEX idx_workouts_platform_external_id ON imported_workouts(platform, external_id)');
        },
      ),
    );
    return _database!;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('check_ins');
      await txn.delete('imported_workouts');
      await txn.delete('sync_state');
      await txn.delete('app_user');
    });
  }
}
