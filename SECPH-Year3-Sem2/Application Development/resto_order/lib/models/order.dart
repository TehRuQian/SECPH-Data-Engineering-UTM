import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, preparing, served, paid }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.served:
        return 'Served';
      case OrderStatus.paid:
        return 'Paid';
    }
  }

  OrderStatus? get next {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.served;
      case OrderStatus.served:
        return OrderStatus.paid;
      case OrderStatus.paid:
        return null;
    }
  }
}

OrderStatus orderStatusFromString(String value) {
  return OrderStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OrderStatus.pending,
  );
}

class Order {
  final String id;
  final int tableNo;
  final OrderStatus status;
  final double total;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.tableNo,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      tableNo: data['table_no'] ?? 0,
      status: orderStatusFromString(data['status'] ?? 'pending'),
      total: (data['total'] ?? 0).toDouble(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'table_no': tableNo,
      'status': status.name,
      'total': total,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
