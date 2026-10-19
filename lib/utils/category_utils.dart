import 'package:flutter/material.dart';

class CategoryMeta {
  final String id;
  final String displayName;
  final IconData icon;
  final Color color;

  const CategoryMeta({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.color,
  });
}

class CategoryUtils {
  static const List<CategoryMeta> categories = [
    CategoryMeta(
      id: 'Food & Drinks',
      displayName: 'Yiyecek & İçecek',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF59E0B), // Warm Amber
    ),
    CategoryMeta(
      id: 'Transportation',
      displayName: 'Ulaşım',
      icon: Icons.directions_subway_rounded,
      color: Color(0xFF38BDF8), // Sky Blue
    ),
    CategoryMeta(
      id: 'Shopping',
      displayName: 'Alışveriş',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFFB7185), // Soft Rose
    ),
    CategoryMeta(
      id: 'Sightseeing',
      displayName: 'Gezi & Kültür',
      icon: Icons.theater_comedy_rounded,
      color: Color(0xFFA78BFA), // Lavender
    ),
    CategoryMeta(
      id: 'Accommodation',
      displayName: 'Konaklama',
      icon: Icons.hotel_rounded,
      color: Color(0xFF34D399), // Mint Green
    ),
  ];

  static CategoryMeta getMeta(String? categoryOrId) {
    if (categoryOrId == null) {
      return const CategoryMeta(
        id: 'Other',
        displayName: 'Diğer',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF10B981),
      );
    }

    return categories.firstWhere(
      (c) =>
          c.id.toLowerCase() == categoryOrId.toLowerCase() ||
          c.displayName.toLowerCase() == categoryOrId.toLowerCase(),
      orElse: () => const CategoryMeta(
        id: 'Other',
        displayName: 'Diğer',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF10B981),
      ),
    );
  }

  static IconData getIcon(String? categoryOrIcon) {
    // If it's one of the legacy emojis, map to icon
    if (categoryOrIcon == '🍕') return Icons.restaurant_rounded;
    if (categoryOrIcon == '🚕') return Icons.directions_subway_rounded;
    if (categoryOrIcon == '🛍️') return Icons.shopping_bag_rounded;
    if (categoryOrIcon == '🎭') return Icons.theater_comedy_rounded;
    if (categoryOrIcon == '🏨') return Icons.hotel_rounded;

    return getMeta(categoryOrIcon).icon;
  }

  static Color getColor(String? category) {
    return getMeta(category).color;
  }

  static String getDisplayName(String? category) {
    return getMeta(category).displayName;
  }
}
