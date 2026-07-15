import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../models/menu_item.dart';
import '../../services/firestore_service.dart';
import '../../widgets/image_placeholder.dart';

class MenuFormScreen extends StatefulWidget {
  final MenuItem? item;
  const MenuFormScreen({super.key, this.item});

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _category = 'Food';
  bool _available = true;
  final _service = FirestoreService();

  static const _categories = ['Food', 'Drink', 'Dessert', 'Snack'];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameCtrl.text = widget.item!.name;
      _priceCtrl.text = widget.item!.price.toString();
      _category = widget.item!.category;
      _available = widget.item!.available;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSave() async {
    final item = MenuItem(
      id: widget.item?.id ?? '',
      name: _nameCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      category: _category,
      available: _available,
    );
    if (widget.item == null) {
      await _service.addMenuItem(item);
    } else {
      await _service.updateMenuItem(item);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await _doSave();
  }

  Future<void> _confirmUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
        );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Save Changes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Save the following changes?',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 14),
            row('Name', _nameCtrl.text.trim()),
            row(
              'Price',
              'RM ${double.parse(_priceCtrl.text.trim()).toStringAsFixed(2)}',
            ),
            row('Category', _category),
            row('Available', _available ? 'Yes' : 'No'),
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
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) await _doSave();
  }

  Future<void> _confirmSave() async {
    if (!_formKey.currentState!.validate()) return;

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
        );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add to Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please confirm the item details:',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 14),
            row('Name', _nameCtrl.text.trim()),
            row(
              'Price',
              'RM ${double.parse(_priceCtrl.text.trim()).toStringAsFixed(2)}',
            ),
            row('Category', _category),
            row('Available', _available ? 'Yes' : 'No'),
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
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) await _doSave();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEdit ? 'Edit Item' : 'New Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ImagePlaceholder(
                    category: _category,
                    height: 160,
                    topRadius: 16,
                    bottomRadius: 16),
              ),
              const SizedBox(height: 24),
              // Name
              const _Label('Item Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Nasi Lemak',
                  prefixIcon: Icon(Icons.label_outline_rounded,
                      color: AppColors.textSecondary),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter item name' : null,
              ),
              const SizedBox(height: 18),
              // Price
              const _Label('Price (RM)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money_rounded,
                      color: AppColors.textSecondary),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter a price';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 22),
              // Category
              const _Label('Category'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final sel = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.terracotta
                            : AppColors.switcherBg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: AppColors.terracotta
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: sel
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              // Available toggle
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textPrimary)),
                        Text(
                          _available
                              ? 'Shown in new orders'
                              : 'Hidden from orders',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Switch(
                      value: _available,
                      activeTrackColor: AppColors.olive,
                      onChanged: (v) => setState(() => _available = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEdit ? _confirmUpdate : _confirmSave,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(isEdit ? 'Save Changes' : 'Add to Menu',
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary));
  }
}
