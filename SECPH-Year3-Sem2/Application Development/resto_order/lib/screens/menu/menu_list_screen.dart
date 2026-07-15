import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../models/menu_item.dart';
import '../../services/firestore_service.dart';
import '../../widgets/category_switcher.dart';
import '../../widgets/image_placeholder.dart';
import 'menu_form_screen.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  final _service = FirestoreService();
  String _selectedCategory = 'All';

  static const _categories = ['All', 'Food', 'Drink', 'Dessert', 'Snack'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Menu',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5)),
                        SizedBox(height: 2),
                        Text('Manage your menu items',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Category switcher
            CategorySwitcher(
              categories: _categories,
              selected: _selectedCategory,
              onChanged: (cat) =>
                  setState(() => _selectedCategory = cat),
            ),
            // Grid
            Expanded(
              child: StreamBuilder<List<MenuItem>>(
                stream: _service.watchMenuItems(),
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
                    return _emptyState(context);
                  }
                  final filtered = snapshot.data!
                      .where((i) =>
                          _selectedCategory == 'All' ||
                          i.category == _selectedCategory)
                      .toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No items in "$_selectedCategory"',
                        style: const TextStyle(
                            color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _MenuCard(item: filtered[i], service: _service),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MenuFormScreen())),
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
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
            child: const Icon(Icons.restaurant_menu_rounded,
                size: 40, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text('No menu items yet',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Tap the button below to add your first item',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final FirestoreService service;

  const _MenuCard({required this.item, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final imageH = constraints.maxHeight * 0.50;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder with overlay buttons
              Stack(
                children: [
                  ImagePlaceholder(
                      category: item.category,
                      height: imageH,
                      topRadius: 16),
                  // Edit + delete overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _OverlayIconBtn(
                          icon: Icons.edit_rounded,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MenuFormScreen(item: item)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _OverlayIconBtn(
                          icon: Icons.delete_rounded,
                          onTap: () => _confirmDelete(context),
                        ),
                      ],
                    ),
                  ),
                  // Available badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.available
                            ? AppColors.olive.withValues(alpha: 0.9)
                            : Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.available ? 'Available' : 'Unavailable',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RM ${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.terracotta,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.75,
                            child: Switch(
                              value: item.available,
                              activeTrackColor: AppColors.olive,
                              onChanged: (v) =>
                                  service.toggleAvailable(item.id, v),
                            ),
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove item?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Delete "${item.name}" from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              service.deleteMenuItem(item.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _OverlayIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}
