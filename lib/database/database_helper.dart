import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mindcare.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // =========================
    // USERS TABLE
    // =========================
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        avatar_emoji TEXT DEFAULT '😊',
        created_at TEXT NOT NULL
      )
    ''');

    // =========================
    // MOOD ENTRIES TABLE
    // =========================
    await db.execute('''
      CREATE TABLE mood_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mood_level INTEGER NOT NULL,
        mood_label TEXT NOT NULL,
        emoji TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL
      )
    ''');

    // =========================
    // JOURNAL ENTRIES TABLE
    // =========================
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // =========================
    // DASS RESULTS TABLE
    // =========================
    await db.execute('''
      CREATE TABLE dass_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stress_score INTEGER NOT NULL,
        anxiety_score INTEGER NOT NULL,
        depression_score INTEGER NOT NULL,
        stress_level TEXT NOT NULL,
        anxiety_level TEXT NOT NULL,
        depression_level TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // =========================
    // CHAT HISTORY TABLE
    // =========================
    await db.execute('''
      CREATE TABLE chat_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // =========================
    // NOTIFICATION SETTINGS
    // =========================
    await db.execute('''
      CREATE TABLE notification_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mood_enabled INTEGER DEFAULT 0,
        journal_enabled INTEGER DEFAULT 0,
        mood_hour INTEGER DEFAULT 8,
        mood_minute INTEGER DEFAULT 0
      )
    ''');

    // default settings
    await db.insert('notification_settings', {
      'mood_enabled': 0,
      'journal_enabled': 0,
      'mood_hour': 8,
      'mood_minute': 0,
    });
  }

  // ======================================================
  // USER METHODS
  // ======================================================

  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('users', row);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // ======================================================
  // MOOD METHODS
  // ======================================================

  Future<int> insertMood(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('mood_entries', row);
  }

  Future<List<Map<String, dynamic>>> getMoodEntries() async {
    final db = await instance.database;

    return await db.query(
      'mood_entries',
      orderBy: 'date DESC',
    );
  }

  // ======================================================
  // JOURNAL METHODS
  // ======================================================

  Future<int> insertJournal(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('journal_entries', row);
  }

  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    final db = await instance.database;

    return await db.query(
      'journal_entries',
      orderBy: 'created_at DESC',
    );
  }

  // ======================================================
  // DASS METHODS
  // ======================================================

  Future<int> insertDassResult(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('dass_results', row);
  }

  Future<List<Map<String, dynamic>>> getDassResults() async {
    final db = await instance.database;

    return await db.query(
      'dass_results',
      orderBy: 'created_at DESC',
    );
  }

  // ======================================================
  // CHAT METHODS
  // ======================================================

  Future<int> insertChat(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('chat_history', row);
  }

  Future<List<Map<String, dynamic>>> getChats() async {
    final db = await instance.database;

    return await db.query(
      'chat_history',
      orderBy: 'created_at ASC',
    );
  }

  // ======================================================
  // NOTIFICATION SETTINGS
  // ======================================================

  Future<Map<String, dynamic>?> getNotificationSettings() async {
    final db = await instance.database;

    final result = await db.query('notification_settings');

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<int> updateNotificationSettings(
      Map<String, dynamic> row) async {
    final db = await instance.database;

    return await db.update(
      'notification_settings',
      row,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ======================================================
  // DELETE ALL DATA
  // ======================================================

  Future<void> clearAllData() async {
    final db = await instance.database;

    await db.delete('mood_entries');
    await db.delete('journal_entries');
    await db.delete('dass_results');
    await db.delete('chat_history');
  }

  // ======================================================
  // CLOSE DATABASE
  // ======================================================

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}