import 'warehouse.dart';

class StockEntry {
  final Warehouse? warehouse;
  final int quantity;

  StockEntry({this.warehouse, required this.quantity});

  factory StockEntry.fromJson(Map<String, dynamic> json) {
    return StockEntry(
      warehouse: json['warehouse'] is Map ? Warehouse.fromJson(json['warehouse']) : null,
      quantity: (json['quantity'] ?? 0) as int,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String unitOfMeasure;
  final int reorderLevel;
  final List<StockEntry> stock;
  final int totalStock;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.unitOfMeasure,
    required this.reorderLevel,
    required this.stock,
    required this.totalStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      category: json['category'] ?? '',
      unitOfMeasure: json['unitOfMeasure'] ?? 'pcs',
      reorderLevel: (json['reorderLevel'] ?? 0) as int,
      stock: (json['stock'] as List<dynamic>? ?? [])
          .map((e) => StockEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalStock: (json['totalStock'] ?? 0) as int,
    );
  }

  bool get isLowStock => totalStock > 0 && totalStock <= reorderLevel;
  bool get isOutOfStock => totalStock == 0;
}
