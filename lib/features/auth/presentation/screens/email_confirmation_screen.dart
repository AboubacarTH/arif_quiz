import 'package:arif_quiz/features/auth/presentation/screens/login_screen.dart';
import 'package:arif_quiz/features/home/presentation/screens/main_navigation.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/ui.dart';
import 'package:flutter/material.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String? email;
  final bool canContinue;
  final bool showBack;

  const EmailConfirmationScreen({
    super.key,
    this.email,
    this.canContinue = true,
    this.showBack = true,
  });

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _verifying = false;
  bool _resending = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.email ?? '';
  }

  String? _validateEmail() {
    final email = _emailCtrl.text.trim();
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (email.isEmpty) return 'Please enter your email address';
    if (!emailPattern.hasMatch(email)) return 'Please enter a valid email';

    return null;
  }

  Future<void> _verifyEmail() async {
    final validationError = _validateEmail();
    if (validationError != null) {
      setState(() {
        _error = validationError;
        _success = null;
      });
      return;
    }

    if (_codeCtrl.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter the confirmation code';
        _success = null;
      });
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
      _success = null;
    });

    try {
      await apiService.verifyEmail(
        email: _emailCtrl.text.trim(),
        code: _codeCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _success = 'Email address confirmed.');
      _continue();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to confirm this code.');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resendCode() async {
    final validationError = _validateEmail();
    if (validationError != null) {
      setState(() {
        _error = validationError;
        _success = null;
      });
      return;
    }

    setState(() {
      _resending = true;
      _error = null;
      _success = null;
    });

    try {
      await apiService.resendEmailVerification(email: _emailCtrl.text.trim());
      if (!mounted) return;
      setState(() => _success = 'A new confirmation email has been sent.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to resend the confirmation email.');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _continue() {
    isGuest.value = false;
    final destination =
        widget.canContinue ? const MainNavigation() : const LoginScreen();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => destination),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: QuizAppBar(
        title: 'Confirm Email',
        showBack: widget.showBack,
      ),
      body: SafeArea(
        child: BlobBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm\nEmail',
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Validate your email address to secure your account',
                  style:
                      TextStyle(color: context.appColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 36),
                if (_error != null) ...[
                  _ConfirmationMessage(
                    message: _error!,
                    color: AppColors.error,
                    icon: Icons.error_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                ],
                if (_success != null) ...[
                  _ConfirmationMessage(
                    message: _success!,
                    color: AppColors.success,
                    icon: Icons.mark_email_read_rounded,
                  ),
                  const SizedBox(height: 16),
                ],
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
                  controller: _codeCtrl,
                  label: 'Confirmation Code',
                  hint: 'Enter your code',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.pin_outlined,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _verifyEmail(),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Confirm Email',
                  icon: Icons.verified_rounded,
                  iconTrailing: true,
                  fullWidth: true,
                  size: AppButtonSize.large,
                  loading: _verifying,
                  onPressed: _verifying ? null : _verifyEmail,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Resend Email',
                  icon: Icons.refresh_rounded,
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  loading: _resending,
                  onPressed: _resending ? null : _resendCode,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: widget.canContinue ? 'Continue' : 'Back to Sign In',
                  icon: Icons.arrow_forward_rounded,
                  iconTrailing: true,
                  variant: AppButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationMessage extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _ConfirmationMessage({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
