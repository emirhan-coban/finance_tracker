import 'package:finance_tracker/utils/category_utils.dart';
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

  Color get color => Color(colorValue);

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
      icon: json['icon'] as String? ?? '',
      colorValue:
          json['colorValue'] as int? ??
          CategoryUtils.getColor(json['category'] as String?).toARGB32(),
      limit: (json['limit'] as num?)?.toDouble() ?? 0,
    );
  }

  static List<CategoryBudget> defaults() {
    return CategoryUtils.categories.map((c) {
      return CategoryBudget(
        category: c.id,
        icon: c.id,
        colorValue: c.color.toARGB32(),
        limit: 0,
      );
    }).toList();
  }
}
