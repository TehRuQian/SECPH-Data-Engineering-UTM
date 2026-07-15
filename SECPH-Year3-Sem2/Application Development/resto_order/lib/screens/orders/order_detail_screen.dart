import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../services/firestore_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

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

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final nextStatus = order.status.next;
    final color = _statusColor(order.status);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.switcherBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Table ${order.tableNo}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4)),
                  ),
                  if (order.status == OrderStatus.pending)
                    GestureDetector(
                      onTap: () => _confirmDelete(context, service),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.delete_outline_rounded,
                            size: 20, color: Colors.red.shade600),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Status progress bar
            _StatusStepper(current: order.status),
            const SizedBox(height: 16),
            // Status banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: color.withValues(alpha: 0.2), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_statusIcon(order.status),
                        color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.status.label,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(_statusDescription(order.status),
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Items list
            Expanded(
              child: StreamBuilder<List<OrderItem>>(
                stream: service.watchOrderItems(order.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.terracotta));
                  }
                  final items = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.terracotta
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text('×${item.quantity}',
                                    style: const TextStyle(
                                        color: AppColors.terracotta,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(item.nameSnapshot,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.textPrimary)),
                                  Text(
                                    'RM ${item.priceSnapshot.toStringAsFixed(2)} each',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'RM ${(item.priceSnapshot * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Total + action
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary)),
                      Text('RM ${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.terracotta)),
                    ],
                  ),
                  if (nextStatus != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmAdvance(
                            context, service, nextStatus),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _statusColor(nextStatus),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: Icon(_statusIcon(nextStatus), size: 18),
                        label: Text('Mark as ${nextStatus.label}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusDescription(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:   return 'Order sent to kitchen';
      case OrderStatus.preparing: return 'Kitchen is cooking';
      case OrderStatus.served:    return 'Delivered to the table';
      case OrderStatus.paid:      return 'Order complete';
    }
  }

  void _confirmAdvance(BuildContext context, FirestoreService service,
      OrderStatus nextStatus) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Mark as ${nextStatus.label}?',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Move Table ${order.tableNo} to "${nextStatus.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await service.advanceStatus(order.id, nextStatus);
              if (context.mounted) Navigator.pop(context, nextStatus);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _statusColor(nextStatus)),
            child: Text('Mark as ${nextStatus.label}'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, FirestoreService service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Cancel order for Table ${order.tableNo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await service.deleteOrder(order.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context, OrderStatus.pending);
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  final OrderStatus current;
  const _StatusStepper({required this.current});

  Color _color(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:   return AppColors.pending;
      case OrderStatus.preparing: return AppColors.preparing;
      case OrderStatus.served:    return AppColors.served;
      case OrderStatus.paid:      return AppColors.paid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: OrderStatus.values.map((s) {
          final done = s.index <= current.index;
          final isLast = s == OrderStatus.paid;
          final c = done ? _color(s) : AppColors.divider;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: done ? c : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: done ? c : AppColors.divider,
                            width: 2),
                      ),
                      child: done
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(s.label,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: done
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: done
                                ? c
                                : AppColors.textSecondary)),
                  ],
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: s.index < current.index
                          ? _color(OrderStatus.values[s.index + 1])
                          : AppColors.divider,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
