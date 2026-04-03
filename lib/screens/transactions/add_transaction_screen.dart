import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zorvyn/config/constants.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/transaction_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? transactionId;
  const AddTransactionScreen({super.key, this.transactionId});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _type = 'expense';
  String _category = 'food';
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _isEdit = true;
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    try {
      final tx = await ref.read(transactionDetailProvider(widget.transactionId!).future);
      _amountCtrl.text = tx.amount.toString();
      _descCtrl.text = tx.description ?? '';
      setState(() {
        _type = tx.type;
        _category = tx.category;
        if (tx.date != null) {
          _date = DateTime.tryParse(tx.date!) ?? DateTime.now();
        }
      });
    } catch (_) {
      if (mounted) showAppSnackBar(context, 'Failed to load transaction', isError: true);
    }
  }

  List<String> get _categories =>
      _type == 'income' ? AppConstants.incomeCategories : AppConstants.expenseCategories;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'amount': double.parse(_amountCtrl.text.trim()),
      'type': _type,
      'category': _category,
      'description': _descCtrl.text.trim(),
      'date': _date.toIso8601String(),
    };

    String? error;
    if (_isEdit) {
      error = await ref.read(transactionNotifierProvider.notifier).updateTransaction(widget.transactionId!, data);
    } else {
      error = await ref.read(transactionNotifierProvider.notifier).createTransaction(data);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      showAppSnackBar(context, error, isError: true);
    } else {
      showAppSnackBar(context, _isEdit ? 'Transaction updated' : 'Transaction added');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Transaction' : 'Add Transaction')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Type toggle
                ClayCard(
                  child: Row(
                    children: ['expense', 'income'].map((t) {
                      final isActive = _type == t;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _type = t;
                              if (!_categories.contains(_category)) {
                                _category = _categories.first;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (t == 'income' ? AppTheme.success : AppTheme.accent)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                ClayTextField(
                  controller: _amountCtrl,
                  labelText: 'Amount',
                  prefixIcon: CupertinoIcons.money_dollar,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter amount';
                    if (double.tryParse(v.trim()) == null || double.parse(v.trim()) <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category picker
                GestureDetector(
                  onTap: () => showCupertinoPicker(
                    context: context,
                    items: _categories,
                    selectedItem: _category,
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  child: ClayCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(getCategoryIcon(_category), size: 20, color: getCategoryColor(_category)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Category', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                              Text(
                                _category[0].toUpperCase() + _category.substring(1).replaceAll('_', ' '),
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_down, size: 16, color: AppTheme.textHint),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date picker
                GestureDetector(
                  onTap: () => showCupertinoDatePicker(
                    context: context,
                    initialDate: _date,
                    maximumDate: DateTime.now(),
                    onChanged: (d) => setState(() => _date = d),
                  ),
                  child: ClayCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.calendar, size: 20, color: AppTheme.textHint),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Date', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_date),
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ClayTextField(
                  controller: _descCtrl,
                  labelText: 'Description (optional)',
                  hintText: 'What was this for?',
                  prefixIcon: CupertinoIcons.pencil,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  text: _isEdit ? 'Update Transaction' : 'Add Transaction',
                  isLoading: _isLoading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
