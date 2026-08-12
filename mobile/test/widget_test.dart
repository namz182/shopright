import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopright/app/shop_right_app.dart';
import 'package:shopright/data/local/models.dart';
import 'package:shopright/data/local/seed_data.dart';
import 'package:shopright/data/repositories/data_sources.dart';
import 'package:shopright/data/repositories/repositories.dart';

class _FakeCatalog implements CatalogDataSource {
  _FakeCatalog({required this.catalog, required this.allStores});

  final List<GroceryProduct> catalog;
  final List<StoreInfo> allStores;

  @override
  Future<List<GroceryProduct>> products({String? search}) async {
    final term = search?.trim().toLowerCase();
    if (term == null || term.isEmpty) {
      return catalog;
    }
    return catalog
        .where((p) => p.name.toLowerCase().contains(term))
        .toList();
  }

  @override
  Future<List<StoreInfo>> stores() async => allStores;

  @override
  Future<void> refreshFromApi() async {}
}

class _FakeSettings implements SettingsDataSource {
  _FakeSettings({double? budget, List<ShoppingItem>? items})
      : _budget = budget ?? SeedData.budget,
        items = items ?? List.of(SeedData.shoppingList);

  double? _budget;
  final List<ShoppingItem> items;

  @override
  Future<double?> budget() async => _budget;

  @override
  Future<void> setBudget(double value) async => _budget = value;

  @override
  Future<List<ShoppingItem>> shoppingItems() async => List.of(items);

  @override
  Future<void> saveShoppingItems(List<ShoppingItem> value) async {
    items
      ..clear()
      ..addAll(value);
  }
}

class _FakeComparisons implements ComparisonDataSource {
  final List<ComparisonRecord> records = [];
  int _nextId = 1;

  @override
  Future<ComparisonRecord> insert(ComparisonRecord record) async {
    final copy = ComparisonRecord(
      id: _nextId++,
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
    records.insert(0, copy);
    return copy;
  }

  @override
  Future<List<ComparisonRecord>> comparisons({int? limit}) async => records;

  @override
  Future<ComparisonRecord?> comparisonById(int id) async =>
      records.where((r) => r.id == id).firstOrNull;

  @override
  Future<void> delete(int id) async =>
      records.removeWhere((r) => r.id == id);

  @override
  Future<({double savings, int count})> monthSummary() async {
    final now = DateTime.now();
    var savings = 0.0;
    var count = 0;
    for (final record in records) {
      if (record.createdAt.year == now.year &&
          record.createdAt.month == now.month) {
        savings += record.totalSavings;
        count++;
      }
    }
    return (savings: savings, count: count);
  }
}

List<GroceryProduct> _catalogFromSeed() {
  final storeId = <String, int>{
    for (final (index, store) in SeedData.stores.indexed)
      store['name'] as String: index + 1,
  };
  return [
    for (final (index, product) in SeedData.products.indexed)
      GroceryProduct(
        id: index + 1,
        name: product['name']!,
        unit: product['unit'],
        icon: product['icon'],
        category: product['category'],
        prices: [
          for (final MapEntry(:key, :value)
              in (SeedData.prices[product['name']] ?? const {}).entries)
            StorePrice(
              storeId: storeId[key]!,
              storeName: key,
              amount: value,
              currency: 'ZMW',
            ),
        ],
      ),
  ];
}

List<StoreInfo> _storesFromSeed() => [
      for (final (index, store) in SeedData.stores.indexed)
        StoreInfo(
          id: index + 1,
          name: store['name'] as String,
          location: store['location'] as String?,
          distanceKm: (store['distance_km'] as num).toDouble(),
        ),
    ];

Repositories buildTestRepositories() {
  return Repositories(
    catalog: _FakeCatalog(
      catalog: _catalogFromSeed(),
      allStores: _storesFromSeed(),
    ),
    comparisons: _FakeComparisons(),
    settings: _FakeSettings(),
  );
}

ShopRightApp _buildApp() {
  return ShopRightApp(repositories: buildTestRepositories());
}

void main() {
  testWidgets('home screen opens and runs the comparison flow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Shop Right'), findsOneWidget);
    expect(find.text('ZMW 1,200.00'), findsOneWidget);
    expect(
      find.text('Your Shopping List (3 Items)'.toUpperCase()),
      findsOneWidget,
    );

    await tester.tap(find.text('Compare'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('COMPARISON COMPLETE'), findsOneWidget);
    expect(find.text('ZMW 1,530.00'), findsWidgets);
    expect(find.text('Total Basket By Shop'.toUpperCase()), findsOneWidget);
  });

  testWidgets('search opens a modal sheet to pick items', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    expect(find.text('Add Items'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'meal');
    await tester.pump();

    expect(find.text('Breakfast Meal 25kg'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Add Items'), findsNothing);
  });

  testWidgets('swipe left removes an item from the list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    final card = find.widgetWithText(Dismissible, 'Cooking Oil 2.5L');
    expect(card, findsOneWidget);

    await tester.drag(card, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(card, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet taps toggle item selection', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Roller Meal 10kg'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Dismissible, 'Roller Meal 10kg'), findsOneWidget);

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Roller Meal 10kg'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Dismissible, 'Roller Meal 10kg'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
