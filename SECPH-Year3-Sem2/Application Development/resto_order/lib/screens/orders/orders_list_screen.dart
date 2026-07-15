import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../models/order.dart';
import '../../services/firestore_service.dart';
import 'new_order_screen.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  OrderStatus? _filter;
  final _service = FirestoreService();

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:   return AppColors.pending;
      case OrderStatus.preparing: return AppColors.preparing;
      case OrderStatus.served:    return AppColors.served;
      case OrderStatus.paid:      return AppColors.paid;
    }
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:   return Icons.access_time_rounded;
      case OrderStatus.preparing: return Icons.soup_kitchen_rounded;
      case OrderStatus.served:    return Icons.check_circle_rounded;
      case OrderStatus.paid:      return Icons.payments_rounded;
    }
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Orders',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5)),
                  SizedBox(height: 2),
                  Text('Track and manage tables',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            // Status filter
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.switcherBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('All', null),
                    ...OrderStatus.values.map((s) => _chip(s.label, s)),
                  ],
                ),
              ),
            ),
            // List
            Expanded(
              child: StreamBuilder<List<Order>>(
                stream: _service.watchOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red)));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.terracotta));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _emptyState();
                  }
                  final orders = snapshot.data!
                      .where((o) =>
                          _filter == null || o.status == _filter)
                      .toList();
                  if (orders.isEmpty) {
                    return const Center(
                        child: Text('No orders for this status.',
                            style:
                                TextStyle(color: AppColors.textSecondary)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final order = orders[i];
                      final color = _statusColor(order.status);
                      return GestureDetector(
                        onTap: () async {
                          final result =
                              await Navigator.push<OrderStatus?>(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailScreen(order: order)),
                          );
                          if (result != null && mounted) {
                            setState(() => _filter = result);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              left: BorderSide(color: color, width: 4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Status icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(_statusIcon(order.status),
                                    color: color, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Table ${order.tableNo}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.textPrimary)),
                                    const SizedBox(height: 3),
                                    Text(_formatTime(order.createdAt),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'RM ${order.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.terracotta),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(order.status.label,
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<OrderStatus?>(context,
              MaterialPageRoute(builder: (_) => const NewOrderScreen()));
          if (result != null && mounted) setState(() => _filter = result);
        },
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Order',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _chip(String label, OrderStatus? status) {
    final sel = _filter == status;
    return GestureDetector(
      onTap: () => setState(() => _filter = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? AppColors.terracotta : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: AppColors.terracotta.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? Colors.white : AppColors.textSecondary,
                fontWeight:
                    sel ? FontWeight.bold : FontWeight.w500,
                fontSize: 14)),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.switcherBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 40, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text('No orders yet',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Tap the button below to take a new order',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
