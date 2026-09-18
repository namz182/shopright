import '../local/app_database.dart';
import '../local/models.dart';
import '../remote/shop_right_api.dart';
import 'data_sources.dart';

class CatalogRepository implements CatalogDataSource {
  CatalogRepository({required AppDatabase db, ShopRightApi? api})
      : _api = api ?? ShopRightApi();

  final ShopRightApi _api;

  /// Products are always read from the backend.
  @override
  Future<List<GroceryProduct>> products({String? search}) async {
    return _api.fetchProducts(search: search);
  }

  Future<List<GroceryProduct>> productsForLocation({String? search, int? provinceId, int? districtId}) async {
    final products = await _api.fetchProducts(search: search);
    if (provinceId == null && districtId == null) return products;

    final stores = await _api.fetchStoresForLocation(
      provinceId: provinceId,
      districtId: districtId,
    );
    final storeIds = stores.map((store) => store.id).toSet();
    return products
        .map(
          (product) => product.copyWith(
            prices: product.prices
                .where((price) => storeIds.contains(price.storeId))
                .toList(),
          ),
        )
        .toList();
  }

  /// Stores are always read from the backend.
  @override
  Future<List<StoreInfo>> stores() async => _api.fetchStores();

  Future<List<StoreInfo>> storesForLocation({int? provinceId, int? districtId}) async {
    return _api.fetchStoresForLocation(
      provinceId: provinceId,
      districtId: districtId,
    );
  }

  /// Verifies that the backend catalog is reachable. No local catalog cache
  /// is written.
  @override
  Future<void> refreshFromApi() async {
    final products = await _api.fetchProductsForLocation();
    final stores = await _api.fetchStoresForLocation();
    if (products.isEmpty || stores.isEmpty) {
      throw const FormatException('Backend returned an empty catalog');
    }
  }
}
