import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/providers/expense_provider.dart';
import 'package:finance_tracker/providers/theme_provider.dart';

void main() {
  testWidgets('App smoke test renders Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const FinanceTrackerApp(),
      ),
    );

    await tester.pump();
    expect(find.text('Merhaba, Emirhan'), findsOneWidget);
  });
}
