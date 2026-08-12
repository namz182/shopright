import '../local/app_database.dart';
import '../local/models.dart';
import 'data_sources.dart';

class ComparisonRepository implements ComparisonDataSource {
  ComparisonRepository({required this._db});

  final AppDatabase _db;

  /// Inserts a comparison and its line items.
  @override
  Future<ComparisonRecord> insert(ComparisonRecord record) async {
    final id = await _db.raw.transaction((txn) async {
      final comparisonId = await txn.insert('comparisons', {
        'reference': record.reference,
        'currency': record.currency,
        'budget': record.budget,
        'total_lowest': record.totalLowest,
        'total_cheapest_store': record.totalCheapestStore,
        'total_savings': record.totalSavings,
        'items_count': record.itemsCount,
        'created_at': record.createdAt.toUtc().toIso8601String(),
      });
      for (final item in record.items) {
        await txn.insert('comparison_items', {
          'comparison_id': comparisonId,
          'product_name': item.productName,
          'product_unit': item.productUnit,
          'quantity': item.quantity,
          'store_name': item.storeName,
          'unit_price': item.unitPrice,
          'line_total': item.lineTotal,
        });
      }
      return comparisonId;
    });

    return ComparisonRecord(
      id: id,
      reference: record.reference,
      currency: record.currency,
      budget: record.budget,
      totalLowest: record.totalLowest,
      totalCheapestStore: record.totalCheapestStore,
      totalSavings: record.totalSavings,
      itemsCount: record.itemsCount,
      createdAt: record.createdAt,
      items: record.items,
    );
  }

  /// Recent comparisons, newest first.
  @override
  Future<List<ComparisonRecord>> comparisons({int? limit}) async {
    final rows = await _db.raw.query(
      'comparisons',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    if (rows.isEmpty) {
      return const [];
    }
    final items = await _itemsForComparisonIds(rows.map((r) => r['id'] as int));
    return rows
        .map((row) => _comparisonFromRow(row, items[row['id']] ?? const []))
        .toList();
  }

  @override
  Future<ComparisonRecord?> comparisonById(int id) async {
    final rows = await _db.raw.query(
      'comparisons',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final items = await _itemsForComparisonIds([id]);
    return _comparisonFromRow(rows.first, items[id] ?? const []);
  }

  @override
  Future<void> delete(int id) async {
    await _db.raw.transaction((txn) async {
      await txn.delete('comparison_items',
          where: 'comparison_id = ?', whereArgs: [id]);
      await txn.delete('comparisons', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Total savings and comparison count for the current calendar month.
  @override
  Future<({double savings, int count})> monthSummary() async {
    final now = DateTime.now();
    final monthStart =
        DateTime.utc(now.year, now.month, 1).toIso8601String();
    final rows = await _db.raw.rawQuery(
      '''
      SELECT COALESCE(SUM(total_savings), 0) AS savings, COUNT(*) AS count
      FROM comparisons
      WHERE created_at >= ?
      ''',
      [monthStart],
    );
    final row = rows.first;
    return (
      savings: (row['savings'] as num).toDouble(),
      count: row['count'] as int,
    );
  }

  Future<Map<int, List<ComparisonItemRecord>>> _itemsForComparisonIds(
    Iterable<int> ids,
  ) async {
    final idList = ids.toList();
    if (idList.isEmpty) {
      return const {};
    }
    final placeholders = List.filled(idList.length, '?').join(',');
    final rows = await _db.raw.rawQuery(
      'SELECT * FROM comparison_items '
      'WHERE comparison_id IN ($placeholders) ORDER BY id',
      idList,
    );
    final grouped = <int, List<ComparisonItemRecord>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row['comparison_id'] as int, () => []).add(
            ComparisonItemRecord(
              productName: row['product_name'] as String,
              productUnit: row['product_unit'] as String?,
              quantity: row['quantity'] as int,
              storeName: row['store_name'] as String?,
              unitPrice: (row['unit_price'] as num).toDouble(),
              lineTotal: (row['line_total'] as num).toDouble(),
            ),
          );
    }
    return grouped;
  }

  ComparisonRecord _comparisonFromRow(
    Map<String, Object?> row,
    List<ComparisonItemRecord> items,
  ) {
    return ComparisonRecord(
      id: row['id'] as int,
      reference: row['reference'] as String,
      currency: row['currency'] as String? ?? 'ZMW',
      budget: (row['budget'] as num?)?.toDouble(),
      totalLowest: (row['total_lowest'] as num).toDouble(),
      totalCheapestStore: (row['total_cheapest_store'] as num).toDouble(),
      totalSavings: (row['total_savings'] as num).toDouble(),
      itemsCount: row['items_count'] as int,
      createdAt:
          DateTime.parse(row['created_at'] as String).toLocal(),
      items: items,
    );
  }
}
