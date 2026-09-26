import 'package:flutter/material.dart';
import '../models/warehouse.dart';
import '../services/product_service.dart';
import '../services/warehouse_service.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _warehouseService = WarehouseService();

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();
  final _uomController = TextEditingController(text: 'pcs');
  final _reorderController = TextEditingController(text: '10');
  final _initialStockController = TextEditingController(text: '0');

  List<Warehouse> _warehouses = [];
  String? _selectedWarehouseId;
  bool _isLoading = false;
  bool _isLoadingWarehouses = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    try {
      final warehouses = await _warehouseService.getWarehouses();
      setState(() {
        _warehouses = warehouses;
        _selectedWarehouseId = warehouses.isNotEmpty ? warehouses.first.id : null;
        _isLoadingWarehouses = false;
      });
    } catch (e) {
      setState(() => _isLoadingWarehouses = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _productService.createProduct(
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        category: _categoryController.text.trim(),
        unitOfMeasure: _uomController.text.trim(),
        reorderLevel: int.tryParse(_reorderController.text) ?? 10,
        initialStock: int.tryParse(_initialStockController.text) ?? 0,
        warehouseId: _selectedWarehouseId,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU / Code', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _uomController,
                      decoration:
                          const InputDecoration(labelText: 'Unit of Measure', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _reorderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Reorder Level', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _isLoadingWarehouses
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    )
                  : _warehouses.isEmpty
                      ? const Text('No warehouses yet — create one first under Warehouses.',
                          style: TextStyle(color: Colors.orange))
                      : DropdownButtonFormField<String>(
                          value: _selectedWarehouseId,
                          decoration:
                              const InputDecoration(labelText: 'Initial Warehouse', border: OutlineInputBorder()),
                          items: _warehouses
                              .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedWarehouseId = v),
                        ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _initialStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Initial Stock (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
