import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/dashboard_service.dart';
import '../widgets/kpi_card.dart';
import 'products_screen.dart';
import 'stock_moves_screen.dart';
import 'warehouses_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dashboardService = DashboardService();
  DashboardKpis? _kpis;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKpis();
  }

  Future<void> _loadKpis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final kpis = await _dashboardService.getKpis();
      setState(() {
        _kpis = kpis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? ''),
              accountEmail: Text(user?.role == 'inventory_manager' ? 'Inventory Manager' : 'Warehouse Staff'),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Products'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Operations (Stock Moves)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockMovesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse_outlined),
              title: const Text('Warehouses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WarehousesScreen()));
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadKpis,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 100),
                      Center(child: Text('Error: $_error')),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Welcome back, ${user?.name.split(' ').first ?? ''} 👋',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          KpiCard(
                            label: 'Total Products',
                            value: '${_kpis?.totalProducts ?? 0}',
                            icon: Icons.inventory_2,
                            color: Colors.indigo,
                          ),
                          KpiCard(
                            label: 'Low Stock',
                            value: '${_kpis?.lowStockItems ?? 0}',
                            icon: Icons.warning_amber_rounded,
                            color: Colors.orange,
                          ),
                          KpiCard(
                            label: 'Out of Stock',
                            value: '${_kpis?.outOfStockItems ?? 0}',
                            icon: Icons.remove_shopping_cart,
                            color: Colors.red,
                          ),
                          KpiCard(
                            label: 'Pending Receipts',
                            value: '${_kpis?.pendingReceipts ?? 0}',
                            icon: Icons.call_received,
                            color: Colors.green,
                          ),
                          KpiCard(
                            label: 'Pending Deliveries',
                            value: '${_kpis?.pendingDeliveries ?? 0}',
                            icon: Icons.local_shipping,
                            color: Colors.blue,
                          ),
                          KpiCard(
                            label: 'Scheduled Transfers',
                            value: '${_kpis?.scheduledTransfers ?? 0}',
                            icon: Icons.swap_horiz,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
