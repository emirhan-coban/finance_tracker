import 'package:flutter/foundation.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/category_budget.dart';
import 'package:finance_tracker/services/storage_service.dart';
import 'package:finance_tracker/services/currency_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final CurrencyService _currencyService = CurrencyService();

  List<Expense> _expenses = [];
  List<CategoryBudget> _budgets = [];
  double _usdRate = 43.60;
  double _eurRate = 46.50;
  bool _isLoadingRates = true;

  List<Expense> get expenses => _expenses;
  List<CategoryBudget> get budgets => _budgets;
  double get usdRate => _usdRate;
  double get eurRate => _eurRate;
  bool get isLoadingRates => _isLoadingRates;

  ExpenseProvider() {
    _loadExpenses();
    _loadBudgets();
    _fetchRates();
  }

  Future<void> _loadExpenses() async {
    _expenses = await _storageService.loadExpenses();
    notifyListeners();
  }

  Future<void> _loadBudgets() async {
    _budgets = await _storageService.loadBudgets();
    notifyListeners();
  }

  Future<void> _fetchRates() async {
    try {
      final rates = await _currencyService.fetchRates();
      _usdRate = rates['USD'] ?? 43.60;
      _eurRate = rates['EUR'] ?? 46.50;
      _isLoadingRates = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching rates: $e');
      _isLoadingRates = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await Future.wait([_loadExpenses(), _loadBudgets(), _fetchRates()]);
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
    await _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    await _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  double getTotalInTRY() {
    return _expenses.fold(0.0, (sum, expense) {
      if (expense.currency == 'TRY') {
        return sum + expense.amount;
      } else if (expense.currency == 'USD') {
        return sum + (expense.amount * _usdRate);
      } else if (expense.currency == 'EUR') {
        return sum + (expense.amount * _eurRate);
      }
      return sum + expense.amount;
    });
  }

  /// Get the total spent for a given category in TRY
  double getSpentByCategory(String category) {
    return getSpentByCategoryInTRY(category);
  }

  double getSpentByCategoryInTRY(String category) {
    return _expenses.where((e) => e.category == category).fold(0.0, (
      sum,
      expense,
    ) {
      if (expense.currency == 'TRY') {
        return sum + expense.amount;
      } else if (expense.currency == 'USD') {
        return sum + (expense.amount * _usdRate);
      } else if (expense.currency == 'EUR') {
        return sum + (expense.amount * _eurRate);
      }
      return sum + expense.amount;
    });
  }

  /// Set the budget limit for a given category
  Future<void> setBudgetLimit(String category, double limit) async {
    final index = _budgets.indexWhere((b) => b.category == category);
    if (index != -1) {
      _budgets[index].limit = limit;
    }
    await _storageService.saveBudgets(_budgets);
    notifyListeners();
  }

  double convertToTRY(double amount, String currency) {
    if (currency == 'TRY') {
      return amount;
    } else if (currency == 'USD') {
      return amount * _usdRate;
    } else if (currency == 'EUR') {
      return amount * _eurRate;
    }
    return amount;
  }
}
