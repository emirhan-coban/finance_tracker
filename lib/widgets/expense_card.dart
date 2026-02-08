import 'package:finance_tracker/models/expense.dart';
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
    final tryAmount = expense.currency == 'USD'
        ? expense.amount * usdRate
        : expense.amount * eurRate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(expense.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getCategoryColor(expense.category).withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                expense.icon ?? '💰',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${_formatCurrency(tryAmount)} TRY',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${expense.currency == 'USD' ? '\$' : '€'}${expense.amount.toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(expense.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Drinks':
        return Colors.orange;
      case 'Transportation':
        return Colors.blue;
      case 'Sightseeing':
        return Colors.deepPurple;
      case 'Shopping':
        return Colors.pink;
      case 'Accommodation':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat("#,##0.00", "en_US");
    return format.format(amount);
  }
}
