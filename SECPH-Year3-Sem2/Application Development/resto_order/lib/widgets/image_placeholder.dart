import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  final String category;
  final double? height;
  final double topRadius;
  final double bottomRadius;

  const ImagePlaceholder({
    super.key,
    required this.category,
    this.height,
    this.topRadius = 16,
    this.bottomRadius = 0,
  });

  List<Color> _gradient(String cat) {
    switch (cat) {
      case 'Drink':
        return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)];
      case 'Dessert':
        return [const Color(0xFFFDAA8B), const Color(0xFFE05C97)];
      case 'Snack':
        return [const Color(0xFFFFD166), const Color(0xFFEF8C4B)];
      default: // Food
        return [const Color(0xFFF9A86A), const Color(0xFFD95F3B)];
    }
  }

  IconData _icon(String cat) {
    switch (cat) {
      case 'Drink':   return Icons.local_drink_rounded;
      case 'Dessert': return Icons.cake_rounded;
      case 'Snack':   return Icons.fastfood_rounded;
      default:        return Icons.restaurant_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradient(category);
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(topRadius),
          bottom: Radius.circular(bottomRadius),
        ),
      ),
      child: Center(
        child: Icon(_icon(category), size: 46,
            color: Colors.white.withValues(alpha: 0.88)),
      ),
    );
  }
}
