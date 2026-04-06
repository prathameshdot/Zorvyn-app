import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/auth_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_passwordCtrl.text.length < 6) {
      showAppSnackBar(context, 'Password must be at least 6 characters', isError: true);
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      showAppSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }
    setState(() => _loading = true);
    final error = await ref.read(authNotifierProvider.notifier).resetPassword(
          widget.token,
          _passwordCtrl.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      showAppSnackBar(context, error, isError: true);
    } else {
      showAppSnackBar(context, 'Password reset successful!');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgC(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.pop(),
                child: Icon(CupertinoIcons.back, color: AppTheme.textPrimaryC(context)),
              ),
              const SizedBox(height: 32),
              Text('Reset Password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryC(context))),
              const SizedBox(height: 8),
              Text('Enter your new password.', style: TextStyle(color: AppTheme.textSecondaryC(context))),
              const SizedBox(height: 40),
              ClayTextField(
                controller: _passwordCtrl,
                labelText: 'New Password',
                hintText: 'Min 6 characters',
                prefixIcon: CupertinoIcons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ClayTextField(
                controller: _confirmCtrl,
                labelText: 'Confirm Password',
                hintText: 'Re-enter new password',
                prefixIcon: CupertinoIcons.lock_shield,
                obscureText: true,
              ),
              const SizedBox(height: 32),
              PrimaryButton(text: 'Reset Password', isLoading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
