import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/constants.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/budget_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  final String? budgetId;
  const AddBudgetScreen({super.key, this.budgetId});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitCtrl = TextEditingController();

  String _category = 'food';
  String _period = 'monthly';
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.budgetId != null) {
      _isEdit = true;
      _loadBudget();
    }
  }

  Future<void> _loadBudget() async {
    // Find from loaded budgets
    final budgets = ref.read(budgetNotifierProvider).budgets;
    final budget = budgets.where((b) => b.id == widget.budgetId).firstOrNull;
    if (budget != null) {
      _limitCtrl.text = budget.limitAmount.toString();
      setState(() {
        _category = budget.category;
        _period = budget.period;
      });
    }
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'category': _category,
      'limit_amount': double.parse(_limitCtrl.text.trim()),
      'period': _period,
    };

    String? error;
    if (_isEdit) {
      error = await ref.read(budgetNotifierProvider.notifier).updateBudget(widget.budgetId!, data);
    } else {
      error = await ref.read(budgetNotifierProvider.notifier).createBudget(data);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      showAppSnackBar(context, error, isError: true);
    } else {
      showAppSnackBar(context, _isEdit ? 'Budget updated' : 'Budget created');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      appBar: AppBar(title: Text(_isEdit ? 'Edit Budget' : 'Add Budget')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Category picker
                GestureDetector(
                  onTap: () => showCupertinoPicker(
                    context: context,
                    items: AppConstants.expenseCategories,
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
                              Text('Category', style: TextStyle(fontSize: 12, color: AppTheme.textHintC(context))),
                              Text(
                                _category[0].toUpperCase() + _category.substring(1),
                                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimaryC(context)),
                              ),
                            ],
                          ),
                        ),
                        Icon(CupertinoIcons.chevron_down, size: 16, color: AppTheme.textHintC(context)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ClayTextField(
                  controller: _limitCtrl,
                  labelText: 'Budget Limit',
                  prefixIcon: CupertinoIcons.money_dollar,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter budget limit';
                    if (double.tryParse(v.trim()) == null || double.parse(v.trim()) <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Period picker
                GestureDetector(
                  onTap: () => showCupertinoPicker(
                    context: context,
                    items: AppConstants.budgetPeriods,
                    selectedItem: _period,
                    onChanged: (v) => setState(() => _period = v),
                  ),
                  child: ClayCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.time, size: 20, color: AppTheme.textHintC(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Period', style: TextStyle(fontSize: 12, color: AppTheme.textHintC(context))),
                              Text(
                                _period[0].toUpperCase() + _period.substring(1),
                                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimaryC(context)),
                              ),
                            ],
                          ),
                        ),
                        Icon(CupertinoIcons.chevron_down, size: 16, color: AppTheme.textHintC(context)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  text: _isEdit ? 'Update Budget' : 'Create Budget',
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
