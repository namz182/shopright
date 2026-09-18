import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../local/models.dart';

/// Thin client for the Shop Right backend catalog API
/// (`GET /api/products`, `GET /api/stores`).
///
/// Callers are expected to catch failures and fall back to the local cache.
class ShopRightApi {
  ShopRightApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = (baseUrl ?? (dotenv.isInitialized ? dotenv.env['API_BASE_URL'] : null) ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:8000',
            )).replaceFirst(RegExp(r'/+$'), '');

  final http.Client _client;
  final String baseUrl;

  Future<List<GroceryProduct>> fetchProducts({String? search}) async => fetchProductsForLocation(search: search);

  Future<List<GroceryProduct>> fetchProductsForLocation({String? search, int? provinceId, int? districtId}) async {
    final query = <String, String>{if (search != null && search.trim().isNotEmpty) 'search': search.trim(), if (provinceId != null) 'province_id': '$provinceId', if (districtId != null) 'district_id': '$districtId'};
    final uri = Uri.parse('$baseUrl/api/products').replace(queryParameters: query.isEmpty ? null : query);
    debugPrint('[ShopRight API] GET $uri');
    final body = await _get(uri);
    final data = _decodeList(body);
    final products = data
        .map<GroceryProduct>(
          (json) => _productFromJson(json as Map<String, dynamic>),
        )
        .toList();
    debugPrint('[ShopRight API] products fetched: ${products.length}');
    for (final product in products) {
      debugPrint('[ShopRight API] product: ${product.id} ${product.name} prices=${product.prices.length}');
    }
    return products;
  }

  Future<List<StoreInfo>> fetchStores() async => fetchStoresForLocation();

  Future<List<StoreInfo>> fetchStoresForLocation({int? provinceId, int? districtId}) async {
    final uri = Uri.parse('$baseUrl/api/stores').replace(queryParameters: {if (provinceId != null) 'province_id': '$provinceId', if (districtId != null) 'district_id': '$districtId'});
    debugPrint('[ShopRight API] GET $uri');
    final body = await _get(uri);
    final data = _decodeList(body);
    final stores = data
        .map(
          (store) => StoreInfo(
            id: store['id'] as int,
            name: store['name'] as String,
            location: store['location'] as String?,
            provinceId: _asInt(store['province_id']),
            districtId: _asInt(store['district_id']),
          ),
        )
        .toList();
    debugPrint('[ShopRight API] stores fetched: ${stores.length}');
    for (final store in stores) {
      debugPrint('[ShopRight API] store: ${store.id} ${store.name} location=${store.location}');
    }
    return stores;
  }

  Future<List<ProvinceInfo>> fetchProvinces() async {
    final data = _decodeList(await _get(Uri.parse('$baseUrl/api/locations/provinces')));
    return data.map((json) => ProvinceInfo(id: json['id'] as int, name: json['name'] as String, code: json['code'] as String?)).toList();
  }

  Future<List<DistrictInfo>> fetchDistricts(int provinceId) async {
    final data = _decodeList(await _get(Uri.parse('$baseUrl/api/locations/provinces/$provinceId/districts')));
    return data.map((json) => DistrictInfo(id: json['id'] as int, provinceId: json['province_id'] as int, name: json['name'] as String)).toList();
  }

  Future<String> _get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 6));
      debugPrint('[ShopRight API] response ${response.statusCode} ${uri.path} bytes=${response.bodyBytes.length}');
      if (response.statusCode != 200) {
        debugPrint('[ShopRight API] error body: ${response.body}');
        throw http.ClientException(
          'Unexpected status ${response.statusCode} for ${uri.path}',
          uri,
        );
      }
      return response.body;
    } catch (error, stackTrace) {
      debugPrint('[ShopRight API] request failed: $uri');
      debugPrint('[ShopRight API] error: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  List<dynamic> _decodeList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
      throw const FormatException('Malformed API response');
    }
    return decoded['data'] as List<dynamic>;
  }

  GroceryProduct _productFromJson(Map<String, dynamic> json) {
    return GroceryProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      unit: json['unit'] as String?,
      icon: json['icon'] as String?,
      category: json['category'] as String?,
      prices: (json['prices'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (price) => StorePrice(
              storeId: _asInt(price['store_id']) ?? 0,
              storeName: price['store'] as String? ?? 'Unknown',
              amount: _asDouble(price['amount']) ?? 0,
              currency: price['currency'] as String? ?? 'ZMW',
            ),
          )
          .toList(),
    );
  }

  static int? _asInt(Object? value) => switch (value) {
        int number => number,
        num number => number.toInt(),
        String text => int.tryParse(text),
        _ => null,
      };

  static double? _asDouble(Object? value) => switch (value) {
        num number => number.toDouble(),
        String text => double.tryParse(text),
        _ => null,
      };
}
