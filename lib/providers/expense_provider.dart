import 'package:flutter/foundation.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/services/storage_service.dart';
import 'package:finance_tracker/services/currency_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final CurrencyService _currencyService = CurrencyService();

  List<Expense> _expenses = [];
  double _usdRate = 43.60;
  double _eurRate = 46.50;
  bool _isLoadingRates = true;

  List<Expense> get expenses => _expenses;
  double get usdRate => _usdRate;
  double get eurRate => _eurRate;
  bool get isLoadingRates => _isLoadingRates;

  ExpenseProvider() {
    _loadExpenses();
    _fetchRates();
  }

  Future<void> _loadExpenses() async {
    _expenses = await _storageService.loadExpenses();
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
      _isLoadingRates = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await Future.wait([_loadExpenses(), _fetchRates()]);
  }

  Future<void> addExpense(Expense expense) async {
    debugPrint('ExpenseProvider: Adding expense ${expense.name}');
    _expenses.insert(0, expense); // Add to beginning for recent-first order
    debugPrint(
      'ExpenseProvider: Expense list now has ${_expenses.length} items',
    );
    await _storageService.saveExpenses(_expenses);
    debugPrint('ExpenseProvider: Saved to storage');
    notifyListeners();
    debugPrint('ExpenseProvider: Notified listeners');
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    await _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  double getTotalAmount({String? currency}) {
    if (currency != null) {
      return _expenses
          .where((e) => e.currency == currency)
          .fold(0.0, (sum, expense) => sum + expense.amount);
    }

    // Convert all to USD for total
    return _expenses.fold(0.0, (sum, expense) {
      if (expense.currency == 'EUR') {
        return sum + (expense.amount * (_eurRate / _usdRate));
      }
      return sum + expense.amount;
    });
  }

  double getTotalInTRY() {
    final totalUSD = getTotalAmount();
    return totalUSD * _usdRate;
  }

  List<Expense> getExpensesByDate(DateTime date) {
    return _expenses.where((expense) {
      return expense.date.year == date.year &&
          expense.date.month == date.month &&
          expense.date.day == date.day;
    }).toList();
  }

  double convertToTRY(double amount, String currency) {
    if (currency == 'USD') {
      return amount * _usdRate;
    } else if (currency == 'EUR') {
      return amount * _eurRate;
    }
    return amount;
  }
}
