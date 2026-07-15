import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Menu Items
  Stream<List<MenuItem>> watchMenuItems() {
    return _db.collection('menu_items').snapshots().map(
          (snap) => snap.docs.map((doc) => MenuItem.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addMenuItem(MenuItem item) async {
    await _db.collection('menu_items').add(item.toMap());
  }

  Future<void> updateMenuItem(MenuItem item) async {
    await _db.collection('menu_items').doc(item.id).update(item.toMap());
  }

  Future<void> deleteMenuItem(String id) async {
    await _db.collection('menu_items').doc(id).delete();
  }

  Future<void> toggleAvailable(String id, bool value) async {
    await _db.collection('menu_items').doc(id).update({'available': value});
  }

  // Orders
  Stream<List<Order>> watchOrders() {
    return _db
        .collection('orders')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

  Future<String> createOrder(Order order, List<OrderItem> items) async {
    final batch = _db.batch();
    final orderRef = _db.collection('orders').doc();

    batch.set(orderRef, order.toMap());

    for (final item in items) {
      final itemRef = _db.collection('order_items').doc();
      final itemWithOrderId = OrderItem(
        id: '',
        orderId: orderRef.id,
        menuItemId: item.menuItemId,
        nameSnapshot: item.nameSnapshot,
        priceSnapshot: item.priceSnapshot,
        quantity: item.quantity,
      );
      batch.set(itemRef, itemWithOrderId.toMap());
    }

    await batch.commit();
    return orderRef.id;
  }

  Future<void> advanceStatus(String orderId, OrderStatus nextStatus) async {
    await _db
        .collection('orders')
        .doc(orderId)
        .update({'status': nextStatus.name});
  }

  Future<void> deleteOrder(String orderId) async {
    final batch = _db.batch();
    final orderRef = _db.collection('orders').doc(orderId);
    batch.delete(orderRef);

    final itemsSnap = await _db
        .collection('order_items')
        .where('order_id', isEqualTo: orderId)
        .get();
    for (final doc in itemsSnap.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Order Items
  Stream<List<OrderItem>> watchOrderItems(String orderId) {
    return _db
        .collection('order_items')
        .where('order_id', isEqualTo: orderId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => OrderItem.fromFirestore(doc)).toList());
  }
}
