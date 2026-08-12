import '../local/app_database.dart';
import '../local/models.dart';
import '../remote/shop_right_api.dart';
import 'data_sources.dart';

class CatalogRepository implements CatalogDataSource {
  CatalogRepository({required this._db, ShopRightApi? api})
      : _api = api ?? ShopRightApi();

  final AppDatabase _db;
  final ShopRightApi _api;

  /// Products from the local cache, optionally filtered by [search].
  @override
  Future<List<GroceryProduct>> products({String? search}) async {
    final term = search?.trim();
    final like = term == null || term.isEmpty ? null : '%$term%';
    final db = _db.raw;

    final productRows = await db.rawQuery(
      '''
      SELECT p.id, p.name, p.unit, p.icon, c.name AS category
      FROM products p
      LEFT JOIN categories c ON c.id = p.category_id
      WHERE p.active = 1 ${like == null ? '' : 'AND p.name LIKE ?'}
      ORDER BY p.name
      ''',
      like == null ? null : [like],
    );

    final prices = await _pricesByProduct();
    return productRows.map((row) {
      final productId = row['id'] as int;
      return GroceryProduct(
        id: productId,
        name: row['name'] as String,
        unit: row['unit'] as String?,
        icon: row['icon'] as String?,
        category: row['category'] as String?,
        prices: prices[productId] ?? const [],
      );
    }).toList();
  }

  /// All active stores from the local cache, nearest first.
  @override
  Future<List<StoreInfo>> stores() async {
    final rows = await _db.raw.rawQuery(
      '''
      SELECT id, name, location, distance_km
      FROM stores
      WHERE active = 1
      ORDER BY distance_km IS NULL, distance_km ASC, name ASC
      ''',
    );
    return rows
        .map(
          (row) => StoreInfo(
            id: row['id'] as int,
            name: row['name'] as String,
            location: row['location'] as String?,
            distanceKm: (row['distance_km'] as num?)?.toDouble(),
          ),
        )
        .toList();
  }

  /// Refreshes the local catalog cache from the backend API.
  /// Throws on failure so callers can fall back to the cache.
  @override
  Future<void> refreshFromApi() async {
    final products = await _api.fetchProducts();
    final stores = await _api.fetchStores();

    await _db.raw.transaction((txn) async {
      await txn.delete('prices');
      await txn.delete('products');
      await txn.delete('stores');
      await txn.delete('categories');

      final categoryIds = <String, int>{};
      for (final product in products) {
        final category = product.category;
        if (category != null && !categoryIds.containsKey(category)) {
          categoryIds[category] = await txn.insert('categories', {
            'name': category,
            'slug': _slugify(category),
          });
        }
      }

      for (final store in stores) {
        await txn.insert('stores', {
          'id': store.id,
          'name': store.name,
          'slug': _slugify(store.name),
          'location': store.location,
          'distance_km': store.distanceKm,
        });
      }

      final now = DateTime.now().toUtc().toIso8601String();
      for (final product in products) {
        await txn.insert('products', {
          'id': product.id,
          'name': product.name,
          'unit': product.unit,
          'icon': product.icon,
          'category_id': product.category == null
              ? null
              : categoryIds[product.category],
        });
        for (final price in product.prices) {
          await txn.insert('prices', {
            'product_id': product.id,
            'store_id': price.storeId,
            'amount': price.amount,
            'currency': price.currency,
            'recorded_at': now,
          });
        }
      }
    });
  }

  Future<Map<int, List<StorePrice>>> _pricesByProduct() async {
    final rows = await _db.raw.rawQuery(
      '''
      SELECT price.product_id, price.store_id, price.amount,
             price.currency, s.name AS store_name
      FROM prices price
      JOIN stores s ON s.id = price.store_id
      WHERE price.active = 1
      ORDER BY price.amount ASC
      ''',
    );

    final grouped = <int, List<StorePrice>>{};
    for (final row in rows) {
      final productId = row['product_id'] as int;
      grouped.putIfAbsent(productId, () => []).add(
            StorePrice(
              storeId: row['store_id'] as int,
              storeName: row['store_name'] as String,
              amount: (row['amount'] as num).toDouble(),
              currency: row['currency'] as String? ?? 'ZMW',
            ),
          );
    }
    return grouped;
  }

  static String _slugify(String value) {
    final slug = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return slug.replaceAll(RegExp(r'^-|-$'), '');
  }
}
