import '../config/api_config.dart';
import 'api_client.dart';

class DashboardKpis {
  final int totalProducts;
  final int lowStockItems;
  final int outOfStockItems;
  final int pendingReceipts;
  final int pendingDeliveries;
  final int scheduledTransfers;

  DashboardKpis({
    required this.totalProducts,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.pendingReceipts,
    required this.pendingDeliveries,
    required this.scheduledTransfers,
  });

  factory DashboardKpis.fromJson(Map<String, dynamic> json) {
    return DashboardKpis(
      totalProducts: json['totalProducts'] ?? 0,
      lowStockItems: json['lowStockItems'] ?? 0,
      outOfStockItems: json['outOfStockItems'] ?? 0,
      pendingReceipts: json['pendingReceipts'] ?? 0,
      pendingDeliveries: json['pendingDeliveries'] ?? 0,
      scheduledTransfers: json['scheduledTransfers'] ?? 0,
    );
  }
}

class DashboardService {
  final ApiClient _api = ApiClient();

  Future<DashboardKpis> getKpis() async {
    final data = await _api.get(ApiConfig.dashboard);
    if (data['success'] == true) {
      return DashboardKpis.fromJson(data['kpis']);
    }
    throw Exception(data['message'] ?? 'Failed to load dashboard');
  }
}
