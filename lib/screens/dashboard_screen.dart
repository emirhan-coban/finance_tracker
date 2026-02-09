import 'package:finance_tracker/screens/add_expense_screen.dart';
import '../theme/app_theme.dart';
import 'package:finance_tracker/screens/all_expenses_screen.dart';
import 'package:finance_tracker/widgets/expense_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/providers/expense_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(theme, provider),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildSummaryCard(theme, provider),
                              const SizedBox(height: 24),
                              _buildRecentHeader(context, theme),
                              const SizedBox(height: 16),
                              if (provider.expenses.isEmpty)
                                _buildEmptyState(theme)
                              else
                                ...provider.expenses
                                    .take(5)
                                    .map(
                                      (e) => Dismissible(
                                        key: Key(e.id),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(
                                            right: 24,
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        onDismissed: (direction) {
                                          provider.deleteExpense(e.id);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${e.name} silindi',
                                              ),
                                              action: SnackBarAction(
                                                label: 'Geri Al',
                                                onPressed: () {
                                                  provider.addExpense(e);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: ExpenseCard(
                                          expense: e,
                                          usdRate: provider.usdRate,
                                          eurRate: provider.eurRate,
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddExpenseScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: const CircleBorder(),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppTheme.mainGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Harcamalarım',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: provider.isLoadingRates
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Text(
                    'USD → TRY ${provider.usdRate.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, ExpenseProvider provider) {
    final totalUSD = provider.getTotalAmount();
    final totalTRY = provider.getTotalInTRY();

    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: AppTheme.mainGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TOPLAM HARCAMAM",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${totalUSD.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YEREL PARA BİRİMİ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${totalTRY.toStringAsFixed(2)} ',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const TextSpan(
                              text: 'TRY',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Son Harcamalar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllExpensesScreen(),
              ),
            );
          },
          child: Text(
            'Tümünü Gör',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz harcama eklemediniz',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni harcama eklemek için + butonuna tıklayın',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
