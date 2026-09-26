import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/warehouse.dart';
import '../services/product_service.dart';
import '../services/warehouse_service.dart';
import '../services/stock_move_service.dart';

class StockMoveFormScreen extends StatefulWidget {
  const StockMoveFormScreen({super.key});

  @override
  State<StockMoveFormScreen> createState() => _StockMoveFormScreenState();
}

class _StockMoveFormScreenState extends State<StockMoveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _warehouseService = WarehouseService();
  final _moveService = StockMoveService();

  final _quantityController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'receipt';
  String? _productId;
  String? _fromWarehouseId;
  String? _toWarehouseId;

  List<Product> _products = [];
  List<Warehouse> _warehouses = [];
  bool _isLoadingData = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final products = await _productService.getProducts();
      final warehouses = await _warehouseService.getWarehouses();
      setState(() {
        _products = products;
        _warehouses = warehouses;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingData = false;
      });
    }
  }

  bool get _needsFrom => _type == 'delivery' || _type == 'transfer' || _type == 'adjustment';
  bool get _needsTo => _type == 'receipt' || _type == 'transfer';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_productId == null) {
      setState(() => _error = 'Please select a product');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final result = await _moveService.createMove(
        type: _type,
        productId: _productId!,
        quantity: int.parse(_quantityController.text),
        fromWarehouseId: _needsFrom ? _fromWarehouseId : null,
        toWarehouseId: _needsTo ? _toWarehouseId : null,
        reference: _referenceController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'Failed to create move');
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Stock Move')),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(labelText: 'Move Type', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'receipt', child: Text('Receipt (Incoming)')),
                        DropdownMenuItem(value: 'delivery', child: Text('Delivery (Outgoing)')),
                        DropdownMenuItem(value: 'transfer', child: Text('Internal Transfer')),
                        DropdownMenuItem(value: 'adjustment', child: Text('Stock Adjustment')),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? 'receipt'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _productId,
                      decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
                      items: _products
                          .map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} (${p.sku})')))
                          .toList(),
                      onChanged: (v) => setState(() => _productId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: _type == 'adjustment' ? 'Quantity Delta (+/-)' : 'Quantity',
                        border: const OutlineInputBorder(),
                        helperText: _type == 'adjustment' ? 'Use negative for damaged/lost stock' : null,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_needsFrom)
                      DropdownButtonFormField<String>(
                        value: _fromWarehouseId,
                        decoration: InputDecoration(
                          labelText: _type == 'adjustment' ? 'Location' : 'From Warehouse',
                          border: const OutlineInputBorder(),
                        ),
                        items: _warehouses.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
                        onChanged: (v) => setState(() => _fromWarehouseId = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    if (_needsFrom) const SizedBox(height: 12),
                    if (_needsTo)
                      DropdownButtonFormField<String>(
                        value: _toWarehouseId,
                        decoration: const InputDecoration(labelText: 'To Warehouse', border: OutlineInputBorder()),
                        items: _warehouses.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
                        onChanged: (v) => setState(() => _toWarehouseId = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    if (_needsTo) const SizedBox(height: 12),
                    TextFormField(
                      controller: _referenceController,
                      decoration: const InputDecoration(
                        labelText: 'Reference (supplier / order id)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Create (Draft)'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Created as a draft. Validate it from the Operations list to apply the stock change.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
