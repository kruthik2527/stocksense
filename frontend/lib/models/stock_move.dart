class StockMove {
  final String id;
  final String type; // receipt | delivery | transfer | adjustment
  final String status; // draft | waiting | ready | done | cancelled
  final int quantity;
  final String productName;
  final String productSku;
  final String? fromWarehouseName;
  final String? toWarehouseName;
  final String? reference;
  final String? notes;
  final DateTime createdAt;

  StockMove({
    required this.id,
    required this.type,
    required this.status,
    required this.quantity,
    required this.productName,
    required this.productSku,
    this.fromWarehouseName,
    this.toWarehouseName,
    this.reference,
    this.notes,
    required this.createdAt,
  });

  factory StockMove.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final fromWh = json['fromWarehouse'];
    final toWh = json['toWarehouse'];

    return StockMove(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'draft',
      quantity: (json['quantity'] ?? 0) as int,
      productName: product is Map ? (product['name'] ?? '') : '',
      productSku: product is Map ? (product['sku'] ?? '') : '',
      fromWarehouseName: fromWh is Map ? fromWh['name'] : null,
      toWarehouseName: toWh is Map ? toWh['name'] : null,
      reference: json['reference'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
