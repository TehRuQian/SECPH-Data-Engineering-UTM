import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../models/menu_item.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../services/firestore_service.dart';
import '../../widgets/category_switcher.dart';
import '../../widgets/image_placeholder.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _tableCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _service = FirestoreService();
  final Map<String, int> _qty = {}; // keyed by item.id
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Food', 'Drink', 'Dessert', 'Snack'];

  double _total(List<MenuItem> items) =>
      items.fold(0, (s, i) => s + i.price * (_qty[i.id] ?? 0));

  int _count(List<MenuItem> items) =>
      items.fold(0, (s, i) => s + (_qty[i.id] ?? 0));

  Future<void> _place(List<MenuItem> all) async {
    if (!_formKey.currentState!.validate()) return;
    final selected = all.where((i) => (_qty[i.id] ?? 0) > 0).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table ${_tableCtrl.text.trim()}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ...selected.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(i.name,
                            style: const TextStyle(fontSize: 13)),
                      ),
                      Text('x${_qty[i.id]}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      Text(
                        'RM ${(i.price * _qty[i.id]!).toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  'RM ${_total(all).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.terracotta),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta),
            child: const Text('Place Order'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final order = Order(
      id: '',
      tableNo: int.parse(_tableCtrl.text.trim()),
      status: OrderStatus.pending,
      total: _total(all),
      createdAt: DateTime.now(),
    );
    final items = selected
        .map((i) => OrderItem(
              id: '',
              orderId: '',
              menuItemId: i.id,
              nameSnapshot: i.name,
              priceSnapshot: i.price,
              quantity: _qty[i.id]!,
            ))
        .toList();
    await _service.createOrder(order, items);
    if (mounted) Navigator.pop(context, OrderStatus.pending);
  }

  @override
  void dispose() {
    _tableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: StreamBuilder<List<MenuItem>>(
            stream: _service.watchMenuItems(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.terracotta));
              }
              final all =
                  snapshot.data!.where((m) => m.available).toList();
              final filtered = _selectedCategory == 'All'
                  ? all
                  : all
                      .where((m) => m.category == _selectedCategory)
                      .toList();

              return Column(
                children: [
                  // Header + table input
                  _Header(ctrl: _tableCtrl),
                  // Category switcher
                  CategorySwitcher(
                    categories: _categories,
                    selected: _selectedCategory,
                    onChanged: (c) =>
                        setState(() => _selectedCategory = c),
                  ),
                  // Item grid
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'No items in "$_selectedCategory"',
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                16, 4, 16, 100),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final item = filtered[i];
                              final qty = _qty[item.id] ?? 0;
                              return _OrderItemCard(
                                item: item,
                                qty: qty,
                                onAdd: () => setState(
                                    () => _qty[item.id] = qty + 1),
                                onRemove: qty > 0
                                    ? () => setState(() {
                                          qty == 1
                                              ? _qty.remove(item.id)
                                              : _qty[item.id] = qty - 1;
                                        })
                                    : null,
                              );
                            },
                          ),
                  ),
                  // Bottom bar
                  _OrderBar(
                    count: _count(all),
                    total: _total(all),
                    onPlace: () => _place(all),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TextEditingController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 12),
              const Text('New Order',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4)),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: 'Enter table number',
              prefixIcon: Icon(Icons.table_restaurant_rounded,
                  color: AppColors.textSecondary),
              labelText: 'Table Number',
            ),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter table number';
              if (int.tryParse(v) == null) return 'Must be a number';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final MenuItem item;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  const _OrderItemCard({
    required this.item,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final selected = qty > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? AppColors.terracotta
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? AppColors.terracotta.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final imageH = constraints.maxHeight * 0.45;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ImagePlaceholder(
                      category: item.category,
                      height: imageH,
                      topRadius: 14),
                  if (selected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.terracotta,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('$qty',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11)),
                        ),
                      ),
                    ),
                ],
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'RM ${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: AppColors.terracotta,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              _Btn(
                                icon: Icons.remove,
                                active: qty > 0,
                                color: AppColors.terracotta,
                                onTap: onRemove,
                              ),
                              SizedBox(
                                width: 24,
                                child: Text('$qty',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                    textAlign: TextAlign.center),
                              ),
                              _Btn(
                                icon: Icons.add,
                                active: true,
                                color: AppColors.terracotta,
                                onTap: onAdd,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback? onTap;

  const _Btn(
      {required this.icon,
      required this.active,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: active ? color : AppColors.switcherBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 14,
            color: active ? Colors.white : AppColors.textSecondary),
      ),
    );
  }
}

class _OrderBar extends StatelessWidget {
  final int count;
  final double total;
  final VoidCallback onPlace;

  const _OrderBar(
      {required this.count, required this.total, required this.onPlace});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.switcherBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$count item${count != 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary)),
                Text('RM ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onPlace,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.terracotta,
              ),
              child: const Text('Place Order',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
