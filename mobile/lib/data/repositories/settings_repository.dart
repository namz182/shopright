import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../local/app_database.dart';
import '../local/models.dart';
import 'data_sources.dart';

class SettingsRepository implements SettingsDataSource {
  SettingsRepository({required this._db});

  final AppDatabase _db;

  static const _budgetKey = 'budget';

  @override
  Future<double?> budget() async {
    final rows = await _db.raw.query(
      'settings',
      where: 'key = ?',
      whereArgs: [_budgetKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return double.tryParse(rows.first['value'] as String? ?? '');
  }

  @override
  Future<void> setBudget(double value) async {
    await _db.raw.insert(
      'settings',
      {'key': _budgetKey, 'value': '$value'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ShoppingItem>> shoppingItems() async {
    final rows = await _db.raw.query('shopping_items', orderBy: 'rowid');
    return rows
        .map(
          (row) => ShoppingItem(
            name: row['name'] as String,
            category: row['category'] as String? ?? 'Essential Staples',
            quantity: row['quantity'] as int,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveShoppingItems(List<ShoppingItem> items) async {
    await _db.raw.transaction((txn) async {
      await txn.delete('shopping_items');
      for (final item in items) {
        await txn.insert('shopping_items', {
          'name': item.name,
          'category': item.category,
          'quantity': item.quantity,
        });
      }
    });
  }
}
