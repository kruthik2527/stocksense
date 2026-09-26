import '../config/api_config.dart';
import '../models/stock_move.dart';
import 'api_client.dart';

class StockMoveService {
  final ApiClient _api = ApiClient();

  Future<List<StockMove>> getMoves({String? type, String? status}) async {
    final params = <String, String>{};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final uri = Uri.parse(ApiConfig.stockMoves).replace(queryParameters: params.isEmpty ? null : params);
    final data = await _api.get(uri.toString());

    if (data['success'] == true) {
      return (data['moves'] as List).map((e) => StockMove.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load stock moves');
  }

  Future<Map<String, dynamic>> createMove({
    required String type,
    required String productId,
    required int quantity,
    String? fromWarehouseId,
    String? toWarehouseId,
    String? reference,
    String? notes,
  }) async {
    return _api.post(ApiConfig.stockMoves, {
      'type': type,
      'product': productId,
      'quantity': quantity,
      if (fromWarehouseId != null) 'fromWarehouse': fromWarehouseId,
      if (toWarehouseId != null) 'toWarehouse': toWarehouseId,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
    });
  }

  Future<Map<String, dynamic>> validateMove(String id) async {
    return _api.patch('${ApiConfig.stockMoves}/$id/validate');
  }

  Future<Map<String, dynamic>> cancelMove(String id) async {
    return _api.patch('${ApiConfig.stockMoves}/$id/cancel');
  }
}
