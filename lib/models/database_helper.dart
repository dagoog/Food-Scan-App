import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'avoid_list_item.dart';

/// SQLite database helper for local data persistence
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB('food_scanner.db');
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

  Future<void> _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';

    // Avoid list table
    await db.execute('''
    CREATE TABLE avoid_list (
      id TEXT PRIMARY KEY,
      ingredient_name $textType,
      description TEXT,
      category TEXT,
      created_at $textType,
      last_used TEXT,
      usage_count INTEGER DEFAULT 0,
      user_notes TEXT
    )
    ''');

    // Cached products table
    await db.execute('''
    CREATE TABLE cached_products (
      barcode TEXT PRIMARY KEY,
      product_data $textType,
      cached_at $textType,
      access_count INTEGER DEFAULT 0
    )
    ''');

    // Scan history table
    await db.execute('''
    CREATE TABLE scan_history (
      id TEXT PRIMARY KEY,
      barcode $textType,
      scan_time $textType,
      scan_method TEXT,
      confidence REAL,
      matched_items TEXT
    )
    ''');

    // User preferences table
    await db.execute('''
    CREATE TABLE preferences (
      key TEXT PRIMARY KEY,
      value $textType
    )
    ''');
  }

  // === Avoid List Operations ===

  Future<void> insertAvoidItem(AvoidListItem item) async {
    final db = await database;
    await db.insert('avoid_list', item.toJson());
  }

  Future<List<AvoidListItem>> getAllAvoidItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('avoid_list', orderBy: 'ingredient_name ASC');
    return maps.map((map) => AvoidListItem.fromJson(map)).toList();
  }

  Future<AvoidListItem?> getAvoidItem(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'avoid_list',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AvoidListItem.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateAvoidItem(AvoidListItem item) async {
    final db = await database;
    await db.update(
      'avoid_list',
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteAvoidItem(String id) async {
    final db = await database;
    await db.delete(
      'avoid_list',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> searchAvoidItems(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'avoid_list',
      where: 'ingredient_name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.length;
  }

  // === Cached Products Operations ===

  Future<void> cacheProduct(String barcode, String productJson, int accessCount) async {
    final db = await database;
    await db.insert(
      'cached_products',
      {
        'barcode': barcode,
        'product_data': productJson,
        'cached_at': DateTime.now().toIso8601String(),
        'access_count': accessCount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCachedProduct(String barcode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cached_products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (maps.isNotEmpty) {
      return maps.first['product_data'] as String;
    }
    return null;
  }

  Future<void> deleteExpiredCaches(int maxCount) async {
    final db = await database;
    await db.delete(
      'cached_products',
      where: 'barcode NOT IN (SELECT barcode FROM cached_products ORDER BY cached_at DESC LIMIT ?)',
      whereArgs: [maxCount],
    );
  }

  // === Scan History Operations ===

  Future<void> addScanHistory(String id, String barcode, DateTime scanTime,
      String? method, double? confidence, List<String> matchedItems) async {
    final db = await database;
    await db.insert('scan_history', {
      'id': id,
      'barcode': barcode,
      'scan_time': scanTime.toIso8601String(),
      'scan_method': method,
      'confidence': confidence,
      'matched_items': matchedItems.join(','),
    });
  }

  Future<List<Map<String, dynamic>>> getRecentScans(int limit) async {
    final db = await database;
    return await db.query(
      'scan_history',
      orderBy: 'scan_time DESC',
      limit: limit,
    );
  }

  // === Preferences Operations ===

  Future<void> savePreference(String key, String value) async {
    final db = await database;
    await db.insert(
      'preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPreference(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  // === Database Management ===

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('avoid_list');
    await db.delete('cached_products');
    await db.delete('scan_history');
  }
}
