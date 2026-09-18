import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


/// Local SQLite store for the catalog cache, comparison history, shopping
/// list and budget. Falls back to a bundled sample catalog when offline.
class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;

  static const _version = 5;
  static const _fileName = 'shopright.db';

  /// Opens (creating if needed) the local database and seeds it with the
  /// bundled sample catalog when it is empty.
  ///
  /// Pass [path] for an in-memory database in tests.
  static Future<AppDatabase> open({String? path}) async {
    await _configurePlatformFactory();

    final dbPath = path ?? await _resolvePath();
    final db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _version,
        onCreate: (db, _) async {
          await _createSchema(db);
          await _seed(db);
        },
        onUpgrade: _upgrade,
      ),
    );

    return AppDatabase._(db);
  }

  Database get raw => _db;

  static Future<void> _configurePlatformFactory() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'The local database is not supported on web. '
        'Run Shop Right on mobile or desktop.',
      );
    }
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.linux ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  static Future<String> _resolvePath() async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, _fileName);
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        slug TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY,
        category_id INTEGER,
        name TEXT NOT NULL,
        unit TEXT,
        icon TEXT,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS stores (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        slug TEXT NOT NULL UNIQUE,
        location TEXT,
        province_id INTEGER,
        district_id INTEGER,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        store_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL DEFAULT 'ZMW',
        recorded_at TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        UNIQUE(product_id, store_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS comparisons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL,
        currency TEXT NOT NULL DEFAULT 'ZMW',
        budget REAL,
        total_lowest REAL NOT NULL,
        total_cheapest_store REAL NOT NULL,
        total_savings REAL NOT NULL DEFAULT 0,
        items_count INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS comparison_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        comparison_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        product_unit TEXT,
        quantity INTEGER NOT NULL,
        store_name TEXT,
        unit_price REAL NOT NULL,
        line_total REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS shopping_items (
        name TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE stores ADD COLUMN province_id INTEGER');
      await db.execute('ALTER TABLE stores ADD COLUMN district_id INTEGER');
      await db.delete('shopping_items');
      await db.insert('settings', {'key': 'budget', 'value': '0'}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    if (oldVersion < 3) {
      await db.update(
        'stores',
        {'province_id': 2, 'district_id': 10},
        where: "location LIKE ? OR location LIKE ?",
        whereArgs: ['%Copperbelt%', '%Ndola%'],
      );
    }
    if (oldVersion < 4) {
      await db.delete('prices');
      await db.delete('products');
      await db.delete('stores');
      await db.delete('categories');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE stores DROP COLUMN distance_km');
    }
  }

  static Future<void> _seed(Database db) async {
    await db.insert(
      'settings',
      {'key': 'budget', 'value': '0'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

}
