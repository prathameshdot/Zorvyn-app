import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/providers/auth_provider.dart';
import 'package:zorvyn/widgets/common_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      showAppSnackBar(context, 'Please enter your email', isError: true);
      return;
    }
    setState(() => _loading = true);
    final result = await ref.read(authNotifierProvider.notifier).forgotPassword(email);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result != null && result.startsWith('ERROR:')) {
      showAppSnackBar(context, result.replaceFirst('ERROR:', ''), isError: true);
    } else if (result != null) {
      showAppSnackBar(context, 'Reset token sent! Check your email.');
      context.push('/reset-password?token=$result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
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
                child: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 32),
              const Text('Forgot Password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text("Enter your email and we'll send you a reset token.", style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 40),
              ClayTextField(
                controller: _emailCtrl,
                labelText: 'Email',
                hintText: 'Enter your registered email',
                prefixIcon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              PrimaryButton(text: 'Send Reset Token', isLoading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
