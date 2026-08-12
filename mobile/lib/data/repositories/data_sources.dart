import '../local/models.dart';

abstract class CatalogDataSource {
  Future<List<GroceryProduct>> products({String? search});
  Future<List<StoreInfo>> stores();
  Future<void> refreshFromApi();
}

abstract class ComparisonDataSource {
  Future<ComparisonRecord> insert(ComparisonRecord record);
  Future<List<ComparisonRecord>> comparisons({int? limit});
  Future<ComparisonRecord?> comparisonById(int id);
  Future<void> delete(int id);
  Future<({double savings, int count})> monthSummary();
}

abstract class SettingsDataSource {
  Future<double?> budget();
  Future<void> setBudget(double value);
  Future<List<ShoppingItem>> shoppingItems();
  Future<void> saveShoppingItems(List<ShoppingItem> items);
}
