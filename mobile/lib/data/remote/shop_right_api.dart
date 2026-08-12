import 'dart:convert';

import 'package:http/http.dart' as http;

import '../local/models.dart';

/// Thin client for the Shop Right backend catalog API
/// (`GET /api/products`, `GET /api/stores`).
///
/// Callers are expected to catch failures and fall back to the local cache.
class ShopRightApi {
  ShopRightApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:8000',
            );

  final http.Client _client;
  final String baseUrl;

  Future<List<GroceryProduct>> fetchProducts({String? search}) async {
    final uri = Uri.parse('$baseUrl/api/products').replace(
      queryParameters: search == null || search.trim().isEmpty
          ? null
          : {'search': search.trim()},
    );
    final body = await _get(uri);
    final data = _decodeList(body);
    return data
        .map<GroceryProduct>(
          (json) => _productFromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<StoreInfo>> fetchStores() async {
    final body = await _get(Uri.parse('$baseUrl/api/stores'));
    final data = _decodeList(body);
    return data
        .map(
          (store) => StoreInfo(
            id: store['id'] as int,
            name: store['name'] as String,
            location: store['location'] as String?,
            distanceKm: (store['distance_km'] as num?)?.toDouble(),
          ),
        )
        .toList();
  }

  Future<String> _get(Uri uri) async {
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 6));
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Unexpected status ${response.statusCode} for ${uri.path}',
        uri,
      );
    }
    return response.body;
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
              storeId: price['store_id'] as int,
              storeName: price['store'] as String? ?? 'Unknown',
              amount: (price['amount'] as num).toDouble(),
              currency: price['currency'] as String? ?? 'ZMW',
            ),
          )
          .toList(),
    );
  }
}
