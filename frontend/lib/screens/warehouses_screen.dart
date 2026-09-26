import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../services/warehouse_service.dart';

class WarehousesScreen extends StatefulWidget {
  const WarehousesScreen({super.key});

  @override
  State<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends State<WarehousesScreen> {
  final _warehouseService = WarehouseService();
  List<Warehouse> _warehouses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final warehouses = await _warehouseService.getWarehouses();
      setState(() {
        _warehouses = warehouses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    final locationController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Warehouse'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              try {
                await _warehouseService.createWarehouse(
                  name: nameController.text.trim(),
                  location: locationController.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.pop(context, true);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warehouses')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _warehouses.isEmpty
                  ? const Center(child: Text('No warehouses yet'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        itemCount: _warehouses.length,
                        itemBuilder: (context, index) {
                          final w = _warehouses[index];
                          return ListTile(
                            leading: const Icon(Icons.warehouse_outlined),
                            title: Text(w.name),
                            subtitle: Text(w.location),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Warehouse'),
      ),
    );
  }
}
