import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zorvyn/config/constants.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/goal_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  final String? goalId;
  const AddGoalScreen({super.key, this.goalId});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  String _goalType = 'savings';
  String _priority = 'medium';
  DateTime? _deadline;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.goalId != null) {
      _isEdit = true;
      _loadGoal();
    }
  }

  Future<void> _loadGoal() async {
    try {
      final goal = await ref.read(goalDetailProvider(widget.goalId!).future);
      _nameCtrl.text = goal.name;
      _descCtrl.text = goal.description ?? '';
      _targetCtrl.text = goal.targetAmount.toString();
      setState(() {
        _goalType = goal.goalType;
        _priority = goal.priority ?? 'medium';
        if (goal.deadline != null) _deadline = DateTime.tryParse(goal.deadline!);
      });
    } catch (_) {
      if (mounted) showAppSnackBar(context, 'Failed to load goal', isError: true);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'target_amount': double.parse(_targetCtrl.text.trim()),
      'goal_type': _goalType,
      'priority': _priority,
      if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
      if (_deadline != null) 'deadline': _deadline!.toIso8601String(),
    };

    String? error;
    if (_isEdit) {
      error = await ref.read(goalNotifierProvider.notifier).updateGoal(widget.goalId!, data);
    } else {
      error = await ref.read(goalNotifierProvider.notifier).createGoal(data);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      showAppSnackBar(context, error, isError: true);
    } else {
      showAppSnackBar(context, _isEdit ? 'Goal updated' : 'Goal created');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Goal' : 'Add Goal')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ClayTextField(
                  controller: _nameCtrl,
                  labelText: 'Goal Name',
                  hintText: 'e.g. Emergency Fund',
                  prefixIcon: CupertinoIcons.flag,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a goal name' : null,
                ),
                const SizedBox(height: 16),

                ClayTextField(
                  controller: _targetCtrl,
                  labelText: 'Target Amount',
                  prefixIcon: CupertinoIcons.money_dollar,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter target amount';
                    if (double.tryParse(v.trim()) == null || double.parse(v.trim()) <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Goal Type picker
                GestureDetector(
                  onTap: () => showCupertinoPicker(
                    context: context,
                    items: AppConstants.goalTypes,
                    selectedItem: _goalType,
                    onChanged: (v) => setState(() => _goalType = v),
                  ),
                  child: ClayCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.tag, size: 20, color: AppTheme.textHint),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Goal Type', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                              Text(
                                _goalType.replaceAll('_', ' ')[0].toUpperCase() + _goalType.replaceAll('_', ' ').substring(1),
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

                // Priority picker
                GestureDetector(
                  onTap: () => showCupertinoPicker(
                    context: context,
                    items: const ['low', 'medium', 'high'],
                    selectedItem: _priority,
                    onChanged: (v) => setState(() => _priority = v),
                  ),
                  child: ClayCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_circle,
                          size: 20,
                          color: _priority == 'high' ? AppTheme.accent : (_priority == 'medium' ? AppTheme.warning : AppTheme.success),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Priority', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                              Text(
                                _priority[0].toUpperCase() + _priority.substring(1),
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

                // Deadline picker
                GestureDetector(
                  onTap: () => showCupertinoDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
                    minimumDate: DateTime.now(),
                    onChanged: (d) => setState(() => _deadline = d),
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
                            const Text('Deadline (optional)', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
                            Text(
                              _deadline != null ? DateFormat('MMM dd, yyyy').format(_deadline!) : 'Not set',
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
                  hintText: 'Why this goal matters...',
                  prefixIcon: CupertinoIcons.pencil,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  text: _isEdit ? 'Update Goal' : 'Create Goal',
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
