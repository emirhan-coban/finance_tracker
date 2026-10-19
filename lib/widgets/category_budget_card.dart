import 'package:finance_tracker/utils/category_utils.dart';
import 'package:finance_tracker/widgets/bouncing_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Compact Category Budget Card used in the horizontal carousel.
class CategoryBudgetCompactCard extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final VoidCallback onTap;

  const CategoryBudgetCompactCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = CategoryUtils.getMeta(category);
    final hasLimit = limit > 0;
    final progress = hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = hasLimit && spent > limit;
    final format = NumberFormat.compact(locale: 'tr_TR');

    return BouncingButton(
      onTap: onTap,
      child: Container(
        width: 142,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOverBudget
                ? Colors.red.withValues(alpha: 0.4)
                : theme.colorScheme.outline.withValues(alpha: 0.16),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(meta.icon, color: meta.color, size: 17),
                  ),
                ),
                if (hasLimit)
                  Text(
                    '%${(progress * 100).toInt()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isOverBudget ? Colors.red.shade400 : meta.color,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  meta.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hasLimit
                        ? '${format.format(spent)} / ${format.format(limit)} ₺'
                        : '${format.format(spent)} ₺',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: hasLimit ? progress : 0.0,
                minHeight: 4,
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.08,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? Colors.red.shade400 : meta.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
