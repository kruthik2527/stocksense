import 'package:flutter/material.dart';

Color statusColor(String status) {
  switch (status) {
    case 'done':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    case 'ready':
      return Colors.blue;
    case 'waiting':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

IconData moveTypeIcon(String type) {
  switch (type) {
    case 'receipt':
      return Icons.call_received;
    case 'delivery':
      return Icons.local_shipping;
    case 'transfer':
      return Icons.swap_horiz;
    case 'adjustment':
      return Icons.tune;
    default:
      return Icons.inventory;
  }
}
