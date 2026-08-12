import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'seed_data.dart';

/// Local SQLite store for the catalog cache, comparison history, shopping
/// list and budget. Falls back to a bundled sample catalog when offline.
class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;

  static const _version = 1;
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
        distance_km REAL,
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

  static Future<void> _seed(Database db) async {
    final productCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products'),
        ) ??
        0;
    if (productCount > 0) {
      return;
    }

    await db.transaction((txn) async {
      final categoryIds = <String, int>{};
      for (final (name, slug) in SeedData.categories) {
        final id = await txn.insert('categories', {'name': name, 'slug': slug});
        categoryIds[name] = id;
      }

      final productIds = <String, int>{};
      for (final product in SeedData.products) {
        final id = await txn.insert('products', {
          'name': product['name'],
          'unit': product['unit'],
          'icon': product['icon'],
          'category_id': categoryIds[product['category']],
        });
        productIds[product['name']!] = id;
      }

      final storeIds = <String, int>{};
      for (final store in SeedData.stores) {
        final id = await txn.insert('stores', {
          'name': store['name'],
          'slug': store['slug'],
          'location': store['location'],
          'distance_km': store['distance_km'],
        });
        storeIds[store['name'] as String] = id;
      }

      for (final MapEntry<String, Map<String, double>> entry
          in SeedData.prices.entries) {
        for (final MapEntry<String, double> price in entry.value.entries) {
          await txn.insert('prices', {
            'product_id': productIds[entry.key],
            'store_id': storeIds[price.key],
            'amount': price.value,
            'currency': 'ZMW',
            'recorded_at': DateTime.now().toIso8601String(),
          });
        }
      }

      await txn.insert('settings', {
        'key': 'budget',
        'value': '${SeedData.budget}',
      });

      for (final item in SeedData.shoppingList) {
        await txn.insert('shopping_items', {
          'name': item.name,
          'category': item.category,
          'quantity': item.quantity,
        });
      }

      await _seedComparisons(txn);
    });
  }

  static Future<void> _seedComparisons(DatabaseExecutor txn) async {
    final now = DateTime.now();
    for (final sample in SeedData.sampleComparisons) {
      final createdAt = switch (sample['created_at']) {
        null => now,
        'yesterday' => now.subtract(const Duration(days: 1)),
        final String value => DateTime.tryParse(value) ?? now,
        _ => now,
      };
      final comparisonId = await txn.insert('comparisons', {
        'reference': sample['reference'],
        'currency': 'ZMW',
        'budget': sample['budget'],
        'total_lowest': sample['total_lowest'],
        'total_cheapest_store': sample['total_cheapest_store'],
        'total_savings': sample['total_savings'],
        'items_count': sample['items_count'],
        'created_at': createdAt.toUtc().toIso8601String(),
      });
      for (final item in sample['items'] as List<Map<String, dynamic>>) {
        await txn.insert('comparison_items', {
          'comparison_id': comparisonId,
          'product_name': item['product_name'],
          'product_unit': item['product_unit'],
          'quantity': item['quantity'],
          'store_name': item['store_name'],
          'unit_price': item['unit_price'],
          'line_total': item['line_total'],
        });
      }
    }
  }
}
