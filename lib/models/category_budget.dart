import 'package:flutter/material.dart';

class CategoryBudget {
  final String category;
  final String icon;
  final int colorValue;
  double limit;

  CategoryBudget({
    required this.category,
    required this.icon,
    required this.colorValue,
    this.limit = 0,
  });

  String get categoryDisplayName {
    switch (category) {
      case 'Food & Drinks':
        return 'Yiyecek & İçecek';
      case 'Transportation':
        return 'Ulaşım';
      case 'Sightseeing':
        return 'Gezi';
      case 'Shopping':
        return 'Alışveriş';
      case 'Accommodation':
        return 'Konaklama';
      default:
        return category;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'icon': icon,
      'colorValue': colorValue,
      'limit': limit,
    };
  }

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      category: json['category'] as String,
      icon: json['icon'] as String,
      colorValue: json['colorValue'] as int,
      limit: (json['limit'] as num).toDouble(),
    );
  }

  static List<CategoryBudget> defaults() {
    return [
      CategoryBudget(
        category: 'Food & Drinks',
        icon: '🍕',
        colorValue: Colors.orange.value,
      ),
      CategoryBudget(
        category: 'Transportation',
        icon: '🚕',
        colorValue: Colors.blue.value,
      ),
      CategoryBudget(
        category: 'Sightseeing',
        icon: '🎭',
        colorValue: Colors.deepPurple.value,
      ),
      CategoryBudget(
        category: 'Shopping',
        icon: '🛍️',
        colorValue: Colors.pink.value,
      ),
      CategoryBudget(
        category: 'Accommodation',
        icon: '🏨',
        colorValue: Colors.teal.value,
      ),
    ];
  }
}
