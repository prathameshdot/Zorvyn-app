import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseService {
  static Database? _db;

  static Future<void> initialize() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'zorvyn_cache.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE api_cache (
            cache_key TEXT PRIMARY KEY,
            response TEXT NOT NULL,
            cached_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_writes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            method TEXT NOT NULL,
            path TEXT NOT NULL,
            body TEXT,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> cacheResponse(String key, Map<String, dynamic> data) async {
    if (_db == null) return;
    await _db!.insert(
      'api_cache',
      {
        'cache_key': key,
        'response': jsonEncode(data),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getCachedResponse(String key) async {
    if (_db == null) return null;
    final results = await _db!.query(
      'api_cache',
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (results.isEmpty) return null;
    final row = results.first;
    // Cache valid for 24 hours
    final cachedAt = row['cached_at'] as int;
    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    if (age > 86400000) {
      await _db!.delete('api_cache', where: 'cache_key = ?', whereArgs: [key]);
      return null;
    }
    return jsonDecode(row['response'] as String) as Map<String, dynamic>;
  }

  static Future<void> queueWrite(String method, String path, Map<String, dynamic>? body) async {
    if (_db == null) return;
    await _db!.insert('pending_writes', {
      'method': method,
      'path': path,
      'body': body != null ? jsonEncode(body) : null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<List<Map<String, dynamic>>> getPendingWrites() async {
    if (_db == null) return [];
    return _db!.query('pending_writes', orderBy: 'created_at ASC');
  }

  static Future<void> removePendingWrite(int id) async {
    if (_db == null) return;
    await _db!.delete('pending_writes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearCache() async {
    if (_db == null) return;
    await _db!.delete('api_cache');
  }

  static Future<void> clearAll() async {
    if (_db == null) return;
    await _db!.delete('api_cache');
    await _db!.delete('pending_writes');
  }
}
