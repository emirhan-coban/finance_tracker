import 'package:finance_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

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
    final tryAmount = expense.currency == 'USD'
        ? expense.amount * usdRate
        : expense.amount * eurRate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight, // Zinc 800
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(expense.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatCurrency(tryAmount)} TRY',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.5),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, HH:mm').format(expense.date),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.3),
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
