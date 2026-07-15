import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String menuItemId;
  final String nameSnapshot;
  final double priceSnapshot;
  final int quantity;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.nameSnapshot,
    required this.priceSnapshot,
    required this.quantity,
  });

  factory OrderItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderItem(
      id: doc.id,
      orderId: data['order_id'] ?? '',
      menuItemId: data['menu_item_id'] ?? '',
      nameSnapshot: data['name_snapshot'] ?? '',
      priceSnapshot: (data['price_snapshot'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'name_snapshot': nameSnapshot,
      'price_snapshot': priceSnapshot,
      'quantity': quantity,
    };
  }
}
