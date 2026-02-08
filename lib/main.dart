import 'package:finance_tracker/screens/dashboard_screen.dart';
import 'package:finance_tracker/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/providers/expense_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: const FinanceTrackerApp(),
    ),
  );
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force dark mode as per design
      home: const DashboardScreen(),
    );
  }
}
