import '../config/api_config.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _api = ApiClient();

  Future<List<Product>> getProducts({String? search, String? category, bool? lowStock}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (lowStock == true) params['lowStock'] = 'true';

    final uri = Uri.parse(ApiConfig.products).replace(queryParameters: params.isEmpty ? null : params);
    final data = await _api.get(uri.toString());

    if (data['success'] == true) {
      return (data['products'] as List).map((e) => Product.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load products');
  }

  Future<Product> createProduct({
    required String name,
    required String sku,
    required String category,
    required String unitOfMeasure,
    required int reorderLevel,
    int? initialStock,
    String? warehouseId,
  }) async {
    final data = await _api.post(ApiConfig.products, {
      'name': name,
      'sku': sku,
      'category': category,
      'unitOfMeasure': unitOfMeasure,
      'reorderLevel': reorderLevel,
      if (initialStock != null) 'initialStock': initialStock,
      if (warehouseId != null) 'warehouse': warehouseId,
    });

    if (data['success'] == true) {
      return Product.fromJson(data['product']);
    }
    throw Exception(data['message'] ?? 'Failed to create product');
  }

  Future<void> deleteProduct(String id) async {
    final data = await _api.delete('${ApiConfig.products}/$id');
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete product');
    }
  }
}
