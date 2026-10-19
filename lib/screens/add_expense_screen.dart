import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finance_tracker/providers/expense_provider.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/services/receipt_scanning_service.dart';
import 'package:finance_tracker/utils/category_utils.dart';
import 'package:finance_tracker/widgets/bouncing_button.dart';
import 'package:finance_tracker/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Food & Drinks';
  String _selectedCurrency = 'TRY';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(
    text: 'Yiyecek & İçecek',
  );
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isScanning = false;
  bool _showExtraDetails = false;
  final _receiptService = ReceiptScanningService();

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    _receiptService.dispose();
    super.dispose();
  }

  void _addQuickAmount(double additional) {
    HapticFeedback.selectionClick();
    final current =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    final updated = current + additional;
    setState(() {
      _amountController.text = updated % 1 == 0
          ? updated.toInt().toString()
          : updated.toStringAsFixed(2);
    });
  }

  void _onCategorySelected(String categoryId, String displayName) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategory = categoryId;
      // Auto-populate name if empty or previous default category name
      if (_nameController.text.isEmpty ||
          CategoryUtils.categories.any(
            (c) => c.displayName == _nameController.text,
          )) {
        _nameController.text = displayName;
      }
    });
  }

  Future<void> _scanReceipt() async {
    try {
      HapticFeedback.lightImpact();
      setState(() => _isScanning = true);

      final XFile? image = await _receiptService.pickImage(ImageSource.gallery);
      if (image == null) {
        setState(() => _isScanning = false);
        return;
      }

      final result = await _receiptService.scanReceipt(image);

      if (mounted) {
        setState(() {
          if (result['amount'] != null) {
            _amountController.text = result['amount'].toString();
          }
          if (result['date'] != null) {
            _selectedDate = result['date'];
          }
          if (result['merchant'] != null) {
            _nameController.text = result['merchant'];
          }
          _isScanning = false;
          _showExtraDetails = true;
        });

        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Fiş başarıyla tarandı!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
      }
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      final title = _nameController.text.trim().isEmpty
          ? CategoryUtils.getDisplayName(_selectedCategory)
          : _nameController.text.trim();

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: title,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        currency: _selectedCurrency,
        date: _selectedDate,
        category: _selectedCategory,
        icon: _selectedCategory,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      provider.addExpense(expense);
      Navigator.pop(context);
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTopBar(context, theme),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              _buildAmountSection(theme),
                              const SizedBox(height: 10),
                              _buildQuickAmountChips(theme),
                              const SizedBox(height: 14),
                              _buildCurrencySelector(theme, isDark),
                              const SizedBox(height: 24),
                              _buildCategorySelector(theme),
                              const SizedBox(height: 20),
                              _buildNameInput(theme),
                              const SizedBox(height: 18),
                              _buildCollapsibleExtraSection(theme),
                              const SizedBox(height: 110),
                            ],
                          ),
                        ),
                      ),
                      _buildBottomButton(theme, isDark),
                    ],
                  ),
                ),
                if (_isScanning)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: isDark ? AppTheme.wiseLime : AppTheme.wiseForest,
                      ),
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BouncingButton(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close_rounded,
                size: 24,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            'Harcama Ekle',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: theme.colorScheme.onSurface,
            ),
          ),
          BouncingButton(
            onTap: _scanReceipt,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(ThemeData theme) {
    String currencySymbol = '₺';
    if (_selectedCurrency == 'USD') currencySymbol = '\$';
    if (_selectedCurrency == 'EUR') currencySymbol = '€';

    return Center(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    currencySymbol,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 50,
                        maxWidth: MediaQuery.of(context).size.width - 80,
                      ),
                      child: TextFormField(
                        controller: _amountController,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[\.,]?\d{0,2}'),
                          ),
                        ],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          color: theme.colorScheme.onSurface,
                          height: 1.05,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          filled: false,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                          ),
                          errorStyle: const TextStyle(fontSize: 0, height: 0),
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return '';
                          final numVal = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (numVal == null || numVal <= 0) return '';
                          return null;
                        },
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Harcama tutarını girin',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountChips(ThemeData theme) {
    final quickAmounts = [50.0, 100.0, 250.0, 500.0];
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: quickAmounts.map((amt) {
          return BouncingButton(
            onTap: () => _addQuickAmount(amt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                '+${amt.toInt()} ₺',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrencySelector(ThemeData theme, bool isDark) {
    const currencies = ['TRY', 'USD', 'EUR'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: currencies.map((curr) {
        final isSelected = _selectedCurrency == curr;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: BouncingButton(
            onTap: () {
              setState(() => _selectedCurrency = curr);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppTheme.wiseLime : AppTheme.wiseForest)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                isSelected ? '$curr ✓' : curr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? (isDark ? AppTheme.wiseForest : AppTheme.wiseLime)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 420;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: CategoryUtils.categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 3 : 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: isWide ? 2.8 : 2.5,
              ),
              itemBuilder: (context, index) {
                final cat = CategoryUtils.categories[index];
                final isSelected = _selectedCategory == cat.id;

                return BouncingButton(
                  onTap: () => _onCategorySelected(cat.id, cat.displayName),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.14)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.18),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNameInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Harcama Adı',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Örn: Akşam Yemeği, Benzin',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: Icon(
              Icons.edit_note_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            suffixIcon: _nameController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() => _nameController.clear()),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  // Faz 2: Collapsible extra details (Date, Note, Scan receipt)
  Widget _buildCollapsibleExtraSection(ThemeData theme) {
    String formattedDate;
    try {
      formattedDate = DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate);
    } catch (_) {
      formattedDate = DateFormat('d MMMM yyyy').format(_selectedDate);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          BouncingButton(
            onTap: () {
              setState(() => _showExtraDetails = !_showExtraDetails);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Tarih & Not Seçenekleri',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showExtraDetails ? 'Gizle' : formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showExtraDetails
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_showExtraDetails) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: Text(
                          'Değiştir',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Note Field
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Açıklama notu ekleyin...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Receipt scan action
                  OutlinedButton.icon(
                    onPressed: _scanReceipt,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size.fromHeight(46),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text(
                      'Fişten Tara',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: BouncingButton(
          onTap: _saveExpense,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.wiseLime : AppTheme.wiseForest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Harcamayı Kaydet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
                color: isDark ? AppTheme.wiseForest : AppTheme.wiseLime,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
