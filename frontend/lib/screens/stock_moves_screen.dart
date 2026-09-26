import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stock_move.dart';
import '../services/stock_move_service.dart';
import '../widgets/status_badge.dart';
import 'stock_move_form_screen.dart';

class StockMovesScreen extends StatefulWidget {
  const StockMovesScreen({super.key});

  @override
  State<StockMovesScreen> createState() => _StockMovesScreenState();
}

class _StockMovesScreenState extends State<StockMovesScreen> with SingleTickerProviderStateMixin {
  final _moveService = StockMoveService();
  late TabController _tabController;
  final List<String?> _types = [null, 'receipt', 'delivery', 'transfer', 'adjustment'];

  List<StockMove> _moves = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _types.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _loadMoves();
    });
    _loadMoves();
  }

  Future<void> _loadMoves() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final moves = await _moveService.getMoves(type: _types[_tabController.index]);
      setState(() {
        _moves = moves;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _validateMove(StockMove move) async {
    try {
      final result = await _moveService.validateMove(move.id);
      if (result['success'] != true) throw Exception(result['message']);
      _loadMoves();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _cancelMove(StockMove move) async {
    try {
      final result = await _moveService.cancelMove(move.id);
      if (result['success'] != true) throw Exception(result['message']);
      _loadMoves();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Receipts'),
            Tab(text: 'Deliveries'),
            Tab(text: 'Transfers'),
            Tab(text: 'Adjustments'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _moves.isEmpty
                  ? const Center(child: Text('No moves found'))
                  : RefreshIndicator(
                      onRefresh: _loadMoves,
                      child: ListView.builder(
                        itemCount: _moves.length,
                        itemBuilder: (context, index) {
                          final move = _moves[index];
                          final route = move.type == 'transfer'
                              ? '${move.fromWarehouseName ?? '?'} → ${move.toWarehouseName ?? '?'}'
                              : move.type == 'receipt'
                                  ? '→ ${move.toWarehouseName ?? '?'}'
                                  : '${move.fromWarehouseName ?? '?'} →';

                          return ListTile(
                            leading: CircleAvatar(child: Icon(moveTypeIcon(move.type))),
                            title: Text('${move.productName} (${move.productSku})'),
                            subtitle: Text(
                              '${move.type.toUpperCase()} · Qty ${move.quantity} · $route\n${DateFormat.yMMMd().add_jm().format(move.createdAt)}',
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatusBadge(status: move.status),
                                if (move.status != 'done' && move.status != 'cancelled')
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                        tooltip: 'Validate',
                                        onPressed: () => _validateMove(move),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                                        tooltip: 'Cancel',
                                        onPressed: () => _cancelMove(move),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const StockMoveFormScreen()),
          );
          if (created == true) _loadMoves();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Move'),
      ),
    );
  }
}
