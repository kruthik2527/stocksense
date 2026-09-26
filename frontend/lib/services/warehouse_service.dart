import '../config/api_config.dart';
import '../models/warehouse.dart';
import 'api_client.dart';

class WarehouseService {
  final ApiClient _api = ApiClient();

  Future<List<Warehouse>> getWarehouses() async {
    final data = await _api.get(ApiConfig.warehouses);
    if (data['success'] == true) {
      return (data['warehouses'] as List).map((e) => Warehouse.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load warehouses');
  }

  Future<Warehouse> createWarehouse({required String name, required String location}) async {
    final data = await _api.post(ApiConfig.warehouses, {'name': name, 'location': location});
    if (data['success'] == true) {
      return Warehouse.fromJson(data['warehouse']);
    }
    throw Exception(data['message'] ?? 'Failed to create warehouse');
  }
}
