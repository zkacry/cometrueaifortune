import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'myfortune.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // v2: fortune_summaries テーブル追加
          await db.execute('''
            CREATE TABLE IF NOT EXISTS fortune_summaries (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              uid TEXT NOT NULL,
              monthKey TEXT NOT NULL,
              summary TEXT NOT NULL,
              consultationCount INTEGER NOT NULL,
              generatedAt INTEGER NOT NULL,
              UNIQUE(uid, monthKey)
            )
          ''');
        }
        if (oldVersion < 3) {
          // v3: action_items テーブル追加（ステータス管理付きアクションリスト）
          await db.execute('''
            CREATE TABLE IF NOT EXISTS action_items (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              uid TEXT NOT NULL,
              consultationId INTEGER NOT NULL,
              fortuneType TEXT NOT NULL,
              worry TEXT NOT NULL,
              action TEXT NOT NULL,
              status TEXT NOT NULL DEFAULT 'pending',
              createdAt INTEGER NOT NULL,
              updatedAt INTEGER NOT NULL,
              FOREIGN KEY (consultationId) REFERENCES consultations(id)
            )
          ''');
        }
        if (oldVersion < 4) {
          // v4: consultations テーブルに wasTrueJudgement 列追加（的中判定）
          await db.execute('''
            ALTER TABLE consultations
            ADD COLUMN wasTrueJudgement INTEGER DEFAULT NULL
          ''');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    // 相談履歴
    await db.execute('''
      CREATE TABLE consultations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        worry TEXT NOT NULL,
        fortuneType TEXT NOT NULL,
        cards TEXT DEFAULT '',
        cardReversed TEXT DEFAULT '',
        reading TEXT NOT NULL,
        score INTEGER,
        suggestedActions TEXT DEFAULT '',
        decision TEXT,
        wasTrueJudgement INTEGER DEFAULT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // アクションログ
    await db.execute('''
      CREATE TABLE action_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        consultationId INTEGER NOT NULL,
        action TEXT NOT NULL,
        executedAt INTEGER NOT NULL,
        outcome TEXT,
        feeling INTEGER,
        success INTEGER DEFAULT 0,
        FOREIGN KEY (consultationId) REFERENCES consultations(id)
      )
    ''');

    // 今日の運勢キャッシュ
    await db.execute('''
      CREATE TABLE daily_fortunes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        date TEXT NOT NULL,
        zodiacSign TEXT NOT NULL,
        content TEXT NOT NULL,
        overallScore INTEGER,
        loveScore INTEGER,
        workScore INTEGER,
        moneyScore INTEGER,
        UNIQUE(uid, date)
      )
    ''');

    // 過去占いサマリーキャッシュ
    await db.execute('''
      CREATE TABLE fortune_summaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        monthKey TEXT NOT NULL,
        summary TEXT NOT NULL,
        consultationCount INTEGER NOT NULL,
        generatedAt INTEGER NOT NULL,
        UNIQUE(uid, monthKey)
      )
    ''');

    // アクションリスト（pending/done/failed ステータス管理）
    await db.execute('''
      CREATE TABLE action_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL,
        consultationId INTEGER NOT NULL,
        fortuneType TEXT NOT NULL,
        worry TEXT NOT NULL,
        action TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (consultationId) REFERENCES consultations(id)
      )
    ''');
  }
}
