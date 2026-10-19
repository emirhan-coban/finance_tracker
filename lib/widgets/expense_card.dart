import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/utils/category_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final double usdRate;
  final double eurRate;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.usdRate,
    required this.eurRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryMeta = CategoryUtils.getMeta(expense.category);
    final formattedDate = _formatDate(expense.date);
    final formattedAmount = _formatAmount(expense.amount, expense.currency);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: categoryMeta.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(
                categoryMeta.icon,
                color: categoryMeta.color,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expense.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        categoryMeta.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      formattedDate,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    formattedAmount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (expense.currency != 'TRY') ...[
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '≈ ${_formatTryEquivalent()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount, String currency) {
    final format = NumberFormat("#,##0.00", "tr_TR");
    if (currency == 'TRY') {
      return '-${format.format(amount)} ₺';
    } else if (currency == 'USD') {
      return '-\$${format.format(amount)}';
    } else if (currency == 'EUR') {
      return '-€${format.format(amount)}';
    }
    return '-${format.format(amount)} $currency';
  }

  String _formatTryEquivalent() {
    double tryAmount = expense.amount;
    if (expense.currency == 'USD') {
      tryAmount = expense.amount * usdRate;
    } else if (expense.currency == 'EUR') {
      tryAmount = expense.amount * eurRate;
    }
    final format = NumberFormat("#,##0.00", "tr_TR");
    return '${format.format(tryAmount)} ₺';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Bugün, ${DateFormat('HH:mm').format(date)}';
    } else if (expenseDate == today.subtract(const Duration(days: 1))) {
      return 'Dün, ${DateFormat('HH:mm').format(date)}';
    } else {
      try {
        return DateFormat('d MMM, HH:mm', 'tr_TR').format(date);
      } catch (_) {
        return DateFormat('d MMM, HH:mm').format(date);
      }
    }
  }
}
