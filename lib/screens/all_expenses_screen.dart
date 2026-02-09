import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/expense_card.dart';

class AllExpensesScreen extends StatelessWidget {
  const AllExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Tüm Harcamalar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz harcama yok',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.expenses.length,
            itemBuilder: (context, index) {
              final expense = provider.expenses[index];
              return Dismissible(
                key: Key(expense.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                onDismissed: (direction) {
                  provider.deleteExpense(expense.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${expense.name} silindi'),
                      action: SnackBarAction(
                        label: 'Geri Al',
                        onPressed: () {
                          provider.addExpense(expense);
                        },
                      ),
                    ),
                  );
                },
                child: ExpenseCard(
                  expense: expense,
                  usdRate: provider.usdRate,
                  eurRate: provider.eurRate,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
