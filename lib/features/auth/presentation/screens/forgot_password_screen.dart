import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/ui.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail ?? '';
  }

  String? _validateEmail() {
    final email = _emailCtrl.text.trim();
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (email.isEmpty) return 'Please enter your email address';
    if (!emailPattern.hasMatch(email)) return 'Please enter a valid email';

    return null;
  }

  Future<void> _sendResetLink() async {
    final validationError = _validateEmail();
    if (validationError != null) {
      setState(() {
        _error = validationError;
        _success = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      await apiService.forgotPassword(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _success = 'If this email exists, a password reset link has been sent.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to send reset link. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: BlobBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.appColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: context.appColors.textSecondary, size: 16),
                  ),
                ),
                const SizedBox(height: 28),
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/arifquiz_192.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Réinitialiser\nle mot de passe',
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entre ton email pour recevoir un lien de réinitialisation',
                  style:
                      TextStyle(color: context.appColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 36),
                if (_error != null) ...[
                  _AuthMessage(
                    message: _error!,
                    color: AppColors.error,
                    icon: Icons.error_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                ],
                if (_success != null) ...[
                  _AuthMessage(
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
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _sendResetLink(),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Send Reset Link',
                  icon: Icons.send_rounded,
                  iconTrailing: true,
                  fullWidth: true,
                  size: AppButtonSize.large,
                  loading: _loading,
                  onPressed: _loading ? null : _sendResetLink,
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Text(
                      'Back to Sign In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
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
}

class _AuthMessage extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _AuthMessage({
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
