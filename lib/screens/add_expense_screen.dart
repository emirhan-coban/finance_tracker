import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/providers/expense_provider.dart';
import '../theme/app_theme.dart';
import 'package:finance_tracker/models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Food & Drinks';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    debugPrint('Save button pressed');
    debugPrint('Amount: ${_amountController.text}');
    debugPrint('Name: ${_nameController.text}');

    if (_formKey.currentState!.validate()) {
      debugPrint('Form validation passed');
      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text),
        currency: 'USD',
        date: _selectedDate,
        category: _selectedCategory,
        icon: _getCategoryIcon(_selectedCategory),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      debugPrint('Adding expense: ${expense.name} - \$${expense.amount}');
      provider.addExpense(expense);
      debugPrint('Expense added, navigating back');
      Navigator.pop(context);
    } else {
      debugPrint('Form validation FAILED');
    }
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Drinks':
        return '🍕';
      case 'Transportation':
        return '🚕';
      case 'Sightseeing':
        return '🎭';
      case 'Shopping':
        return '🛍️';
      case 'Accommodation':
        return '🏨';
      default:
        return '💰';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAmountInput(theme),
                      const SizedBox(height: 24),
                      _buildForm(theme),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildSaveButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              padding: EdgeInsets.zero,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Text(
              'Yeni Harcama Ekle',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAmountInput(ThemeData theme) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final amount = double.tryParse(_amountController.text) ?? 0.0;
        final tryAmount = amount * provider.usdRate;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: IntrinsicWidth(
                      child: TextFormField(
                        controller: _amountController,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                        decoration: InputDecoration(
                          fillColor: theme.scaffoldBackgroundColor,
                          filled: true,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.1),
                            fontSize: 56,
                          ),
                          errorStyle: const TextStyle(fontSize: 0, height: 0),
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return '';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFA1A1AA),
                    ),
                    children: [
                      TextSpan(
                        text: '≈ ',
                        style: TextStyle(color: Colors.white.withOpacity(0.4)),
                      ),
                      TextSpan(
                        text: tryAmount.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const TextSpan(text: ' '),
                      const TextSpan(
                        text: 'TRY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D6AEE),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildInputField(
            label: 'HARCAMA ADI',
            icon: Icons.shopping_bag_outlined,
            hint: 'Örn: Akşam Yemeği',
            controller: _nameController,
          ),
          const SizedBox(height: 24),
          _buildDropdownField(label: 'KATEGORİ', icon: Icons.category_outlined),
          const SizedBox(height: 24),
          _buildInputField(
            label: 'TARİH',
            icon: Icons.calendar_today_outlined,
            hint: '2024-05-20',
            controller: _dateController,
            isDate: true,
          ),
          const SizedBox(height: 24),
          _buildInputField(
            label: 'NOT (OPSİYONEL)',
            icon: Icons.description_outlined,
            hint: 'Detay ekleyin...',
            controller: _noteController,
            maxLines: 3,
            isOptional: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required String hint,
    TextEditingController? controller,
    bool isDate = false,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF71717A),
              letterSpacing: 0.8,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: isDate,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          validator: isOptional
              ? null
              : (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bu alan zorunludur';
                  }
                  return null;
                },
          onTap: isDate
              ? () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                      controller?.text = DateFormat('yyyy-MM-dd').format(date);
                    });
                  }
                }
              : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF71717A), size: 20),
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF71717A).withOpacity(0.4),
            ),
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2D6AEE), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 48,
              vertical: maxLines > 1 ? 16 : 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF71717A),
              letterSpacing: 0.8,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            _showCategoryModal(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF71717A), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCategory == 'Food & Drinks'
                        ? 'Yiyecek & İçecek'
                        : _selectedCategory == 'Transportation'
                        ? 'Ulaşım'
                        : _selectedCategory == 'Sightseeing'
                        ? 'Gezi'
                        : _selectedCategory == 'Shopping'
                        ? 'Alışveriş'
                        : _selectedCategory == 'Accommodation'
                        ? 'Konaklama'
                        : _selectedCategory,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  _getCategoryIcon(_selectedCategory),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF71717A),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF18181B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Kategori Seçin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: const EdgeInsets.all(24),
                children: [
                  _buildCategoryItem(
                    'Food & Drinks',
                    'Yiyecek & İçecek',
                    '🍕',
                    Colors.orange,
                  ),
                  _buildCategoryItem(
                    'Transportation',
                    'Ulaşım',
                    '🚕',
                    Colors.blue,
                  ),
                  _buildCategoryItem(
                    'Sightseeing',
                    'Gezi',
                    '🎭',
                    Colors.deepPurple,
                  ),
                  _buildCategoryItem(
                    'Shopping',
                    'Alışveriş',
                    '🛍️',
                    Colors.pink,
                  ),
                  _buildCategoryItem(
                    'Accommodation',
                    'Konaklama',
                    '🏨',
                    Colors.teal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String id, String label, String icon, Color color) {
    final isSelected = _selectedCategory == id;
    return InkWell(
      onTap: () {
        setState(() => _selectedCategory = id);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _saveExpense,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: AppTheme.primaryColor.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, size: 20),
              SizedBox(width: 8),
              Text(
                'Kaydet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
