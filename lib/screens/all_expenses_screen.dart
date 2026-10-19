import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import '../widgets/bouncing_button.dart';
import '../utils/category_utils.dart';
import '../theme/app_theme.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    String monthName;
    try {
      monthName = DateFormat('MMMM yyyy', 'tr_TR').format(now);
    } catch (_) {
      monthName = DateFormat('MMMM yyyy').format(now);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                _buildTopBar(context, theme),
                Expanded(
                  child: Consumer<ExpenseProvider>(
                    builder: (context, provider, child) {
                      if (provider.expenses.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 56,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Henüz harcama bulunmuyor',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Filter by category and search query
                      final filteredExpenses = provider.expenses.where((e) {
                        final matchesCategory =
                            _selectedCategoryFilter == 'All' ||
                            e.category == _selectedCategoryFilter;
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            e.name.toLowerCase().contains(_searchQuery) ||
                            (e.note?.toLowerCase().contains(_searchQuery) ??
                                false) ||
                            CategoryUtils.getDisplayName(
                              e.category,
                            ).toLowerCase().contains(_searchQuery);
                        return matchesCategory && matchesSearch;
                      }).toList();

                      final totalTRY = filteredExpenses.fold<double>(
                        0.0,
                        (sum, e) =>
                            sum + provider.convertToTRY(e.amount, e.currency),
                      );
                      final count = filteredExpenses.length;
                      final format = NumberFormat("#,##0.00", "tr_TR");

                      final groupedExpenses = _groupExpensesByDate(
                        filteredExpenses,
                      );

                      return ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        children: [
                          // Faz 3: Streamlined Summary Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Dönem Toplamı ($monthName)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Aktif',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${format.format(totalTRY)} TL',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.8,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$count İşlem',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                if (totalTRY > 0) ...[
                                  const SizedBox(height: 12),
                                  _buildSpendingBreakdownBar(
                                    filteredExpenses,
                                    totalTRY,
                                    provider,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Faz 3: Fast Category Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  theme: theme,
                                  isDark: isDark,
                                  label: 'Tümü',
                                  id: 'All',
                                ),
                                ...CategoryUtils.categories.map(
                                  (cat) => _buildFilterChip(
                                    theme: theme,
                                    isDark: isDark,
                                    label: cat.displayName,
                                    id: cat.id,
                                    icon: cat.icon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Grouped Expenses List
                          if (filteredExpenses.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Aramanızla eşleşen harcama bulunamadı'
                                      : 'Bu filtrede harcama bulunmuyor',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...groupedExpenses.entries.expand((entry) {
                              final dateHeader = entry.key;
                              final items = entry.value;

                              return [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 14,
                                    bottom: 8,
                                    left: 4,
                                  ),
                                  child: Text(
                                    dateHeader,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                ...items.map(
                                  (expense) => Dismissible(
                                    key: Key(expense.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.danger,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 22),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
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
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onDismissed: (direction) {
                                      HapticFeedback.mediumImpact();
                                      provider.deleteExpense(expense.id);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).clearSnackBars();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 3),
                                          content: Text(
                                            '${expense.name} silindi',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          action: SnackBarAction(
                                            label: 'Geri Al',
                                            textColor: AppTheme.wiseLime,
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
                                  ),
                                ),
                              ];
                            }),
                          const SizedBox(height: 40),
                        ],
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

  Widget _buildTopBar(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Row(
        children: [
          BouncingButton(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
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
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Harcama ara...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val.trim().toLowerCase());
                    },
                  )
                : Text(
                    'Tüm Harcamalar',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
          ),
          BouncingButton(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
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
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                size: 19,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Faz 3: Multi-color Category Distribution Bar
  Widget _buildSpendingBreakdownBar(
    List<Expense> expenses,
    double totalTRY,
    ExpenseProvider provider,
  ) {
    final Map<String, double> categorySums = {};
    for (var e in expenses) {
      final amountInTRY = provider.convertToTRY(e.amount, e.currency);
      categorySums[e.category] =
          (categorySums[e.category] ?? 0.0) + amountInTRY;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: Row(
          children: categorySums.entries.map((entry) {
            final share = (entry.value / totalTRY).clamp(0.01, 1.0);
            final meta = CategoryUtils.getMeta(entry.key);
            return Expanded(
              flex: (share * 100).toInt().clamp(1, 100),
              child: Container(
                color: meta.color,
                margin: const EdgeInsets.only(right: 1),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required ThemeData theme,
    required bool isDark,
    required String label,
    required String id,
    IconData? icon,
  }) {
    final isSelected = _selectedCategoryFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: BouncingButton(
        onTap: () {
          setState(() => _selectedCategoryFilter = id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppTheme.wiseLime : AppTheme.wiseForest)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: isSelected
                      ? (isDark ? AppTheme.wiseForest : AppTheme.wiseLime)
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? AppTheme.wiseForest : AppTheme.wiseLime)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var expense in expenses) {
      final expDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      String header;
      if (expDate == today) {
        header = 'Bugün';
      } else if (expDate == yesterday) {
        header = 'Dün';
      } else {
        try {
          header = DateFormat('d MMMM yyyy', 'tr_TR').format(expense.date);
        } catch (_) {
          header = DateFormat('d MMMM yyyy').format(expense.date);
        }
      }

      grouped.putIfAbsent(header, () => []).add(expense);
    }

    return grouped;
  }
}
