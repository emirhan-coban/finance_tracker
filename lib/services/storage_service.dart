import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_tracker/models/expense.dart';

class StorageService {
  static const String _expensesKey = 'expenses';

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expensesKey, json.encode(jsonList));
  }

  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_expensesKey);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Expense.fromJson(json)).toList();
  }

  Future<void> clearExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_expensesKey);
  }
}
