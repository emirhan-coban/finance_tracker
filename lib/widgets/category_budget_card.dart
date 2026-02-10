import 'package:flutter/material.dart';

class CategoryBudgetCard extends StatelessWidget {
  final String category;
  final String icon;
  final Color color;
  final double spent;
  final double limit;
  final String currency;
  final VoidCallback onEditLimit;

  const CategoryBudgetCard({
    super.key,
    required this.category,
    required this.icon,
    required this.color,
    required this.spent,
    required this.limit,
    required this.currency,
    required this.onEditLimit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLimit = limit > 0;
    final progress = hasLimit ? (spent / limit).clamp(0.0, 1.5) : 0.0;
    final isOverBudget = hasLimit && spent > limit;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverBudget
              ? Colors.red.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          // Top row: icon + name + spent/limit
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _categoryDisplayName(category),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasLimit
                          ? '\$${spent.toStringAsFixed(2)} / \$${limit.toStringAsFixed(0)}'
                          : '\$${spent.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isOverBudget
                            ? Colors.red.shade400
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOverBudget)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Aşıldı',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isOverBudget && hasLimit)
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(progress),
                  ),
                ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onEditLimit,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    hasLimit ? Icons.edit_outlined : Icons.add_circle_outline,
                    size: 18,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          // Progress bar
          if (hasLimit) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(
                      0.06,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverBudget
                          ? Colors.red.shade400
                          : _getProgressColor(progress),
                    ),
                  );
                },
              ),
            ),
          ],
          if (!hasLimit) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0,
                minHeight: 6,
                backgroundColor: theme.colorScheme.onSurface.withOpacity(0.06),
                valueColor: AlwaysStoppedAnimation<Color>(
                  color.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return color;
    if (progress < 0.75) return Colors.orange;
    if (progress < 1.0) return Colors.deepOrange;
    return Colors.red;
  }

  String _categoryDisplayName(String category) {
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
}
