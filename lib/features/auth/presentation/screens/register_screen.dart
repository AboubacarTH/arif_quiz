import 'package:arif_quiz/features/auth/presentation/screens/email_confirmation_screen.dart';
import 'package:arif_quiz/features/auth/presentation/screens/login_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/ui.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  String? _validate() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final confirmPassword = _confirmPassCtrl.text;
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Please fill all fields';
    }
    if (name.length < 2) {
      return 'Please enter your full name';
    }
    if (!emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _register() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await apiService.register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      final token = res['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await apiService.saveToken(token);
      }
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => EmailConfirmationScreen(
            email: _emailCtrl.text.trim(),
            canContinue: token != null && token.isNotEmpty,
            showBack: false,
          ),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _error = 'Registration failed. Email may already be taken.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: const QuizAppBar(title: 'Create Account', showBack: true),
      body: SafeArea(
        child: BlobBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create\nAccount',
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join thousands of quiz enthusiasts',
                  style:
                      TextStyle(color: context.appColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 36),
                if (_error != null) ...[
                  _AuthError(message: _error!),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  hint: 'Your name',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passCtrl,
                  label: 'Password',
                  hint: 'Choose a password',
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmPassCtrl,
                  label: 'Confirm Password',
                  hint: 'Repeat your password',
                  obscureText: true,
                  prefixIcon: Icons.verified_user_outlined,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Create Account',
                  fullWidth: true,
                  size: AppButtonSize.large,
                  loading: _loading,
                  onPressed: _loading ? null : _register,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: context.appColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: _goToLogin,
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthError extends StatelessWidget {
  final String message;

  const _AuthError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
