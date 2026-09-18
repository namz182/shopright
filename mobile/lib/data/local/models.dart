class GroceryProduct {
  GroceryProduct({
    required this.id,
    required this.name,
    required this.category,
    this.unit,
    this.icon,
    this.prices = const [],
  });

  final int id;
  final String name;
  final String? unit;
  final String? icon;
  final String? category;
  final List<StorePrice> prices;

  GroceryProduct copyWith({List<StorePrice>? prices}) => GroceryProduct(
        id: id,
        name: name,
        unit: unit,
        icon: icon,
        category: category,
        prices: prices ?? this.prices,
      );
}

class StorePrice {
  StorePrice({
    required this.storeId,
    required this.storeName,
    required this.amount,
    required this.currency,
  });

  final int storeId;
  final String storeName;
  final double amount;
  final String currency;
}

class StoreInfo {
  StoreInfo({
    required this.id,
    required this.name,
    this.location,
    this.provinceId,
    this.districtId,
  });

  final int id;
  final String name;
  final String? location;
  final int? provinceId;
  final int? districtId;
}

class ProvinceInfo {
  const ProvinceInfo({required this.id, required this.name, this.code});
  final int id;
  final String name;
  final String? code;
}

class DistrictInfo {
  const DistrictInfo({required this.id, required this.provinceId, required this.name});
  final int id;
  final int provinceId;
  final String name;
}

class UserLocation {
  const UserLocation({this.provinceId, this.provinceName, this.districtId, this.districtName});
  final int? provinceId;
  final String? provinceName;
  final int? districtId;
  final String? districtName;
  bool get isSelected => provinceId != null && districtId != null;
  String get label => isSelected ? '$districtName, $provinceName' : 'Choose your location';
}

class ShoppingItem {
  const ShoppingItem({
    required this.name,
    required this.category,
    required this.quantity,
  });

  final String name;
  final String category;
  final int quantity;
}

class ComparisonRecord {
  ComparisonRecord({
    required this.id,
    required this.reference,
    required this.currency,
    required this.totalLowest,
    required this.totalCheapestStore,
    required this.totalSavings,
    required this.itemsCount,
    required this.createdAt,
    this.budget,
    this.items = const [],
  });

  final int id;
  final String reference;
  final String currency;
  final double? budget;
  final double totalLowest;
  final double totalCheapestStore;
  final double totalSavings;
  final int itemsCount;
  final DateTime createdAt;
  final List<ComparisonItemRecord> items;
}

class ComparisonItemRecord {
  ComparisonItemRecord({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.productUnit,
    this.storeName,
  });

  final String productName;
  final String? productUnit;
  final int quantity;
  final String? storeName;
  final double unitPrice;
  final double lineTotal;
}
