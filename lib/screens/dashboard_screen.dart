import 'package:finance_tracker/screens/add_expense_screen.dart';
import 'package:finance_tracker/screens/all_expenses_screen.dart';
import 'package:finance_tracker/widgets/expense_card.dart';
import 'package:finance_tracker/widgets/category_budget_card.dart';
import 'package:finance_tracker/widgets/modern_refresh_indicator.dart';
import 'package:finance_tracker/widgets/bouncing_button.dart';
import 'package:finance_tracker/utils/category_utils.dart';
import 'package:finance_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/providers/expense_provider.dart';
import 'package:finance_tracker/providers/theme_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildHeader(context, theme, provider, isDark),
                        Expanded(
                          child: ModernRefreshIndicator(
                            onRefresh: () async {
                              HapticFeedback.lightImpact();
                              await provider.refreshData();
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    _buildHeroCard(
                                      context,
                                      theme,
                                      provider,
                                      isDark,
                                    ),
                                    const SizedBox(height: 22),
                                    _buildCategoryBudgetCarousel(
                                      context,
                                      theme,
                                      provider,
                                    ),
                                    const SizedBox(height: 22),
                                    _buildRecentHeader(
                                      context,
                                      theme,
                                      provider,
                                    ),
                                    const SizedBox(height: 12),
                                    if (provider.expenses.isEmpty)
                                      _buildEmptyState(theme)
                                    else
                                      ...provider.expenses
                                          .take(4)
                                          .map(
                                            (e) => Dismissible(
                                              key: Key(e.id),
                                              direction:
                                                  DismissDirection.endToStart,
                                              background: Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.danger,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                                padding: const EdgeInsets.only(
                                                  right: 22,
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Sil',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onDismissed: (direction) {
                                                HapticFeedback.mediumImpact();
                                                provider.deleteExpense(e.id);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).clearSnackBars();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    duration: const Duration(
                                                      seconds: 3,
                                                    ),
                                                    content: Text(
                                                      '${e.name} silindi',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    action: SnackBarAction(
                                                      label: 'Geri Al',
                                                      textColor:
                                                          AppTheme.wiseLime,
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
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 28,
                      right: 20,
                      child: BouncingButton(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddExpenseScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.wiseLime
                                : AppTheme.wiseForest,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isDark
                                            ? AppTheme.wiseLime
                                            : AppTheme.wiseForest)
                                        .withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add,
                            color: isDark
                                ? AppTheme.wiseForest
                                : AppTheme.wiseLime,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ExpenseProvider provider,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hoş geldiniz',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Merhaba, Emirhan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.18),
                  ),
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
                        '1\$ = ${provider.usdRate.toStringAsFixed(2)} ₺',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              BouncingButton(
                onTap: () {
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(
                    isDark
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_outlined,
                    size: 19,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    ThemeData theme,
    ExpenseProvider provider,
    bool isDark,
  ) {
    final totalTRY = provider.getTotalInTRY();
    final format = NumberFormat("#,##0.00", "tr_TR");

    final totalLimit = provider.budgets.fold<double>(
      0.0,
      (sum, b) => sum + b.limit,
    );
    final remainingBudget = totalLimit > 0 ? (totalLimit - totalTRY) : 0.0;
    final budgetProgress = totalLimit > 0
        ? (totalTRY / totalLimit).clamp(0.0, 1.0)
        : 0.0;

    final foodSpent = provider.getSpentByCategory('Food & Drinks');
    final transportSpent = provider.getSpentByCategory('Transportation');
    final shoppingSpent = provider.getSpentByCategory('Shopping');

    final cardBg = isDark ? const Color(0xFF111811) : AppTheme.wiseForest;
    const numberColor = Colors.white;
    final mutedTextColor = Colors.white.withValues(alpha: 0.72);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFF233223)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : AppTheme.wiseForest.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "BU AYKİ HARCAMA",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: mutedTextColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.wiseLime.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 13,
                      color: AppTheme.wiseLime,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '%12.5 azaldı',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.wiseLime,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${format.format(totalTRY)} TL',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: numberColor,
                  height: 1.05,
                ),
              ),
            ),
          ),
          if (totalLimit > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kalan: ${format.format(remainingBudget)} TL',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: remainingBudget < 0
                        ? Colors.red.shade300
                        : AppTheme.wiseLime,
                  ),
                ),
                Text(
                  'Hedef: ${NumberFormat("#,##0", "tr_TR").format(totalLimit)} TL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: mutedTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budgetProgress,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  remainingBudget < 0 ? Colors.red.shade400 : AppTheme.wiseLime,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(
              'Düzenle butonundan aylık bütçe hedefi belirleyebilirsiniz',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: mutedTextColor,
              ),
            ),
          ],
          const SizedBox(height: 18),
          // 3 Compact Stat Pills
          Row(
            children: [
              Expanded(
                child: _buildMiniStatPill(
                  label: 'Yiyecek',
                  amount: foodSpent,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatPill(
                  label: 'Ulaşım',
                  amount: transportSpent,
                  color: const Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatPill(
                  label: 'Alışveriş',
                  amount: shoppingSpent,
                  color: const Color(0xFFFB7185),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatPill({
    required String label,
    required double amount,
    required Color color,
  }) {
    final format = NumberFormat.compact(locale: 'tr_TR');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${format.format(amount)} ₺',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Faz 1: Compact Horizontal Carousel (Clean & Space-Saving)
  Widget _buildCategoryBudgetCarousel(
    BuildContext context,
    ThemeData theme,
    ExpenseProvider provider,
  ) {
    final budgets = provider.budgets;
    if (budgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Kategori Bütçeleri',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            BouncingButton(
              onTap: () => _showBudgetSettingsDialog(context, provider),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Limitler',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 128,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return CategoryBudgetCompactCard(
                category: budget.category,
                spent: provider.getSpentByCategory(budget.category),
                limit: budget.limit,
                onTap: () => _showEditLimitDialog(
                  context,
                  provider,
                  budget.category,
                  budget.limit,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentHeader(
    BuildContext context,
    ThemeData theme,
    ExpenseProvider provider,
  ) {
    final count = provider.expenses.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Son Harcamalar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (count > 0)
          BouncingButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllExpensesScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tümünü Gör ($count)',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showBudgetSettingsDialog(
    BuildContext context,
    ExpenseProvider provider,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Bütçe Limitleri',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aylık harcama hedeflerinizi belirleyin',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Consumer<ExpenseProvider>(
                    builder: (context, provider, _) {
                      final budgets = provider.budgets;
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: budgets.length,
                        separatorBuilder: (context, index) => Divider(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.1,
                          ),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final budget = budgets[index];
                          final meta = CategoryUtils.getMeta(budget.category);
                          final spent = provider.getSpentByCategory(
                            budget.category,
                          );
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: meta.color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                meta.icon,
                                color: meta.color,
                                size: 21,
                              ),
                            ),
                            title: Text(
                              meta.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Harcama: ${NumberFormat("#,##0", "tr_TR").format(spent)} ₺',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditLimitDialog(
                                  context,
                                  provider,
                                  budget.category,
                                  budget.limit,
                                );
                              },
                              child: Text(
                                budget.limit > 0
                                    ? '${NumberFormat("#,##0", "tr_TR").format(budget.limit)} ₺'
                                    : 'Limit Koy',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditLimitDialog(
    BuildContext context,
    ExpenseProvider provider,
    String category,
    double currentLimit,
  ) {
    final theme = Theme.of(context);
    final meta = CategoryUtils.getMeta(category);
    final controller = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        title: Text(
          '${meta.displayName} Limiti',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aylık harcama hedefinizi belirleyin (TRY)',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: '₺ ',
                prefixStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                hintText: '0',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              provider.setBudgetLimit(category, 0);
              Navigator.pop(context);
            },
            child: Text(
              'Kaldır',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              final value = double.tryParse(controller.text) ?? 0;
              provider.setBudgetLimit(category, value);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Kaydet',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 52,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              'Henüz harcama eklenmedi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+ butonuna basarak ilk harcamanızı kaydedin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
