import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:shopright/data/local/app_database.dart';
import 'package:shopright/data/local/models.dart';
import 'package:shopright/data/repositories/catalog_repository.dart';
import 'package:shopright/data/repositories/comparison_repository.dart';
import 'package:shopright/data/repositories/settings_repository.dart';
import 'package:shopright/data/remote/shop_right_api.dart';

class _StubApi extends ShopRightApi {
  @override
  Future<List<GroceryProduct>> fetchProducts({String? search}) async {
    return [
      GroceryProduct(
        id: 99,
        name: 'Fresh Fish 1kg',
        unit: '1 kg',
        category: 'Fresh Produce',
        prices: [
          StorePrice(
            storeId: 1,
            storeName: 'Shoprite Ndola',
            amount: 45,
            currency: 'ZMW',
          ),
        ],
      ),
    ];
  }

  @override
  Future<List<StoreInfo>> fetchStores() async {
    return [
      StoreInfo(id: 1, name: 'Shoprite Ndola', location: 'Ndola', distanceKm: 1.0),
    ];
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<AppDatabase> openDb() => AppDatabase.open(path: inMemoryDatabasePath);

  test('seed populates the local catalog, settings and history', () async {
    final db = await openDb();
    addTearDown(() => db.raw.close());

    final catalog = CatalogRepository(db: db);
    final settings = SettingsRepository(db: db);
    final comparisons = ComparisonRepository(db: db);

    final products = await catalog.products();
    expect(products, hasLength(20));

    final priced = products.where((p) => p.prices.isNotEmpty).toList();
    expect(priced, hasLength(3));
    expect(priced.firstWhere((p) => p.name == 'Breakfast Meal 25kg').prices,
        hasLength(4));

    final stores = await catalog.stores();
    expect(stores, hasLength(4));
    expect(stores.first.name, 'Local Market (Chifubu)');

    expect(await settings.budget(), 1200.0);
    expect(await settings.shoppingItems(), hasLength(3));

    final history = await comparisons.comparisons();
    expect(history, hasLength(3));
    expect(history.first.reference, 'CMP-904-ZM21');
  });

  test('catalog search filters products by name', () async {
    final db = await openDb();
    addTearDown(() => db.raw.close());

    final catalog = CatalogRepository(db: db);
    final results = await catalog.products(search: 'sugar');
    expect(results.map((p) => p.name), containsAll(['White Sugar 2kg', 'Brown Sugar 1kg']));

    expect(await catalog.products(search: 'xyzzy'), isEmpty);
  });

  test('settings persist budget and shopping list', () async {
    final db = await openDb();
    addTearDown(() => db.raw.close());

    final settings = SettingsRepository(db: db);
    await settings.setBudget(950.5);
    expect(await settings.budget(), 950.5);

    await settings.saveShoppingItems([
      const ShoppingItem(name: 'Rice 5kg', category: 'Pantry Items', quantity: 1),
    ]);
    final saved = await settings.shoppingItems();
    expect(saved, hasLength(1));
    expect(saved.first.name, 'Rice 5kg');
  });

  test('comparisons insert, list, summarize and delete', () async {
    final db = await openDb();
    addTearDown(() => db.raw.close());

    final comparisons = ComparisonRepository(db: db);
    final before = await comparisons.monthSummary();

    final inserted = await comparisons.insert(
      ComparisonRecord(
        id: 0,
        reference: 'CMP-111-ZM01',
        currency: 'ZMW',
        budget: 500,
        totalLowest: 430,
        totalCheapestStore: 460,
        totalSavings: 30,
        itemsCount: 1,
        createdAt: DateTime.now(),
        items: [
          ComparisonItemRecord(
            productName: 'Rice 5kg',
            quantity: 1,
            unitPrice: 430,
            lineTotal: 430,
            storeName: 'Shoprite Ndola',
          ),
        ],
      ),
    );
    expect(inserted.id, greaterThan(0));

    final history = await comparisons.comparisons();
    expect(history.first.reference, 'CMP-111-ZM01');
    expect(history.first.items, hasLength(1));

    final after = await comparisons.monthSummary();
    expect(after.count, before.count + 1);
    expect(after.savings, before.savings + 30);

    final byId = await comparisons.comparisonById(inserted.id);
    expect(byId?.reference, 'CMP-111-ZM01');

    await comparisons.delete(inserted.id);
    expect(await comparisons.comparisonById(inserted.id), isNull);
  });

  test('refreshFromApi replaces the cached catalog', () async {
    final db = await openDb();
    addTearDown(() => db.raw.close());

    final catalog = CatalogRepository(db: db, api: _StubApi());
    await catalog.refreshFromApi();

    final products = await catalog.products();
    expect(products, hasLength(1));
    expect(products.first.name, 'Fresh Fish 1kg');
    expect(products.first.prices.first.amount, 45);

    final stores = await catalog.stores();
    expect(stores, hasLength(1));
    expect(stores.first.name, 'Shoprite Ndola');
  });
}
