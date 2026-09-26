import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _productService = ProductService();
  final _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;
  bool _lowStockOnly = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await _productService.getProducts(
        search: _searchController.text,
        lowStock: _lowStockOnly ? true : null,
      );
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('This will permanently remove "${product.name}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _productService.deleteProduct(product.id);
      _loadProducts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by name or SKU',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _loadProducts(),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Low stock'),
                  selected: _lowStockOnly,
                  onSelected: (v) {
                    setState(() => _lowStockOnly = v);
                    _loadProducts();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _products.isEmpty
                        ? const Center(child: Text('No products found'))
                        : RefreshIndicator(
                            onRefresh: _loadProducts,
                            child: ListView.builder(
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: product.isOutOfStock
                                        ? Colors.red.shade50
                                        : product.isLowStock
                                            ? Colors.orange.shade50
                                            : Colors.green.shade50,
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: product.isOutOfStock
                                          ? Colors.red
                                          : product.isLowStock
                                              ? Colors.orange
                                              : Colors.green,
                                    ),
                                  ),
                                  title: Text(product.name),
                                  subtitle: Text('SKU: ${product.sku} · ${product.category}'),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${product.totalStock} ${product.unitOfMeasure}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                        onPressed: () => _deleteProduct(product),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
          if (created == true) _loadProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Product'),
      ),
    );
  }
}
