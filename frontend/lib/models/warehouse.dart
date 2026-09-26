class Warehouse {
  final String id;
  final String name;
  final String location;

  Warehouse({required this.id, required this.name, required this.location});

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }
}
