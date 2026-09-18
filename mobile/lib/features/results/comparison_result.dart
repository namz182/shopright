import 'dart:math';

import '../../data/local/models.dart';

class ComparisonResult {
  ComparisonResult({
    required this.reference,
    required this.currency,
    required this.totalLowest,
    required this.totalCheapestStore,
    required this.totalSavings,
    required this.itemsCount,
    required this.createdAt,
    required this.items,
    required this.storeTotals,
    this.budget,
  });

  final String reference;
  final String currency;
  final double? budget;
  final double totalLowest;
  final double totalCheapestStore;
  final double totalSavings;
  final int itemsCount;
  final DateTime createdAt;
  final List<ComparisonItem> items;
  final List<StoreTotal> storeTotals;

  /// Finds the cheapest store per item and totals per store.
  factory ComparisonResult.compute({
    required List<ShoppingItem> basket,
    required List<GroceryProduct> catalog,
    required List<StoreInfo> stores,
    double? budget,
  }) {
    final byName = {for (final product in catalog) product.name: product};

    final items = <ComparisonItem>[];
    for (final entry in basket) {
      final product = byName[entry.name];
      if (product == null || product.prices.isEmpty) {
        continue;
      }
      final sorted = [...product.prices]
        ..sort((a, b) => a.amount.compareTo(b.amount));
      final lowest = sorted.first;
      items.add(
        ComparisonItem(
          productName: product.name,
          unit: product.unit,
          quantity: entry.quantity,
          storeName: lowest.storeName,
          unitPrice: lowest.amount,
          lineTotal: lowest.amount * entry.quantity,
          prices: sorted,
        ),
      );
    }

    final totalLowest =
        items.fold(0.0, (sum, item) => sum + item.lineTotal);

    final priceAt = <String, Map<int, double>>{};
    for (final item in items) {
      final storePrices = <int, double>{
        for (final price in item.prices) price.storeId: price.amount,
      };
      priceAt[item.productName] = storePrices;
    }

    final storeTotals = <StoreTotal>[];
    for (final store in stores) {
      var total = 0.0;
      var covered = 0;
      for (final item in items) {
        final amount = priceAt[item.productName]?[store.id];
        if (amount != null) {
          total += amount * item.quantity;
          covered++;
        }
      }
      if (covered == 0) {
        continue;
      }
      storeTotals.add(
        StoreTotal(
          storeName: store.name,
          total: total,
          coveredItems: covered,
        ),
      );
    }

    var cheapestStoreTotal = 0.0;
    if (storeTotals.isNotEmpty) {
      storeTotals.sort((a, b) => a.total.compareTo(b.total));
      cheapestStoreTotal = storeTotals.first.total;
    }

    return ComparisonResult(
      reference: _generateReference(),
      currency: 'ZMW',
      budget: budget,
      totalLowest: totalLowest,
      totalCheapestStore: cheapestStoreTotal,
      totalSavings: cheapestStoreTotal - totalLowest,
      itemsCount: items.length,
      createdAt: DateTime.now(),
      items: items,
      storeTotals: storeTotals,
    );
  }

  ComparisonRecord toRecord() {
    return ComparisonRecord(
      id: 0,
      reference: reference,
      currency: currency,
      budget: budget,
      totalLowest: totalLowest,
      totalCheapestStore: totalCheapestStore,
      totalSavings: totalSavings,
      itemsCount: itemsCount,
      createdAt: createdAt,
      items: items
          .map(
            (item) => ComparisonItemRecord(
              productName: item.productName,
              productUnit: item.unit,
              quantity: item.quantity,
              storeName: item.storeName,
              unitPrice: item.unitPrice,
              lineTotal: item.lineTotal,
            ),
          )
          .toList(),
    );
  }

  static String _generateReference() {
    final random = Random();
    final sequence = random.nextInt(900) + 100;
    final region = random.nextInt(90) + 10;
    return 'CMP-$sequence-ZM$region';
  }
}

class ComparisonItem {
  ComparisonItem({
    required this.productName,
    required this.quantity,
    required this.storeName,
    required this.unitPrice,
    required this.lineTotal,
    required this.prices,
    this.unit,
  });

  final String productName;
  final String? unit;
  final int quantity;
  final String storeName;
  final double unitPrice;
  final double lineTotal;

  /// All store prices for this product, sorted cheapest first.
  final List<StorePrice> prices;
}

class StoreTotal {
  StoreTotal({
    required this.storeName,
    required this.total,
    required this.coveredItems,
  });

  final String storeName;
  final double total;

  /// How many basket items this store had a price for.
  final int coveredItems;
}
