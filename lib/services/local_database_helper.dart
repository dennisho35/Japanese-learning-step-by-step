import 'package:sqflite/sqflite.dart';

/// SQLite 結構化關聯式本機資料庫輔助類別（與 SharedPreferences 雙軌運作）
class LocalDatabaseHelper {
  static final LocalDatabaseHelper instance = LocalDatabaseHelper._init();
  static Database? _database;

  LocalDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('japanese_step_by_step.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$filePath';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE kana_progress (kana_id TEXT PRIMARY KEY, status TEXT NOT NULL, practice_count INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE srs_mistakes (question_id TEXT PRIMARY KEY, wrong_count INTEGER NOT NULL DEFAULT 1, consecutive_correct INTEGER NOT NULL DEFAULT 0, interval_days INTEGER NOT NULL DEFAULT 1, next_review_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE favorites (item_id TEXT PRIMARY KEY, category TEXT NOT NULL, created_at TEXT NOT NULL)',
    );
  }

  Future<void> upsertKanaProgress(String kanaId, String status, int practiceCount) async {
    final db = await instance.database;
    await db.insert(
      'kana_progress',
      {
        'kana_id': kanaId,
        'status': status,
        'practice_count': practiceCount,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
