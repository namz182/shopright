import '../local/models.dart';
import 'catalog_repository.dart';
import 'settings_repository.dart';

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

extension CatalogLocationMethods on CatalogDataSource {
  Future<List<GroceryProduct>> productsForLocation({String? search, int? provinceId, int? districtId}) => this is CatalogRepository ? (this as CatalogRepository).productsForLocation(search: search, provinceId: provinceId, districtId: districtId) : products(search: search);
  Future<List<StoreInfo>> storesForLocation({int? provinceId, int? districtId}) => this is CatalogRepository ? (this as CatalogRepository).storesForLocation(provinceId: provinceId, districtId: districtId) : stores();
}

extension SettingsLocationMethods on SettingsDataSource {
  Future<UserLocation> location() => this is SettingsRepository ? (this as SettingsRepository).location() : Future.value(const UserLocation());
  Future<void> setLocation(UserLocation location) => this is SettingsRepository ? (this as SettingsRepository).setLocation(location) : Future.value();
}
