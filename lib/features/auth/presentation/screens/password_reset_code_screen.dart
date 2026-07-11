import 'package:arif_quiz/features/auth/presentation/screens/login_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/ui.dart';
import 'package:flutter/material.dart';

class PasswordResetCodeScreen extends StatefulWidget {
  final String email;

  const PasswordResetCodeScreen({super.key, required this.email});

  @override
  State<PasswordResetCodeScreen> createState() =>
      _PasswordResetCodeScreenState();
}

class _PasswordResetCodeScreenState extends State<PasswordResetCodeScreen> {
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _resending = false;
  String? _error;
  String? _success;

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (code.isEmpty || code.length != 6) {
      setState(() {
        _error = AppLocalizations.of(context).enterSixDigitCode;
        _success = null;
      });
      return;
    }
    if (password.length < 8) {
      setState(() {
        _error = AppLocalizations.of(context).passwordMin8;
        _success = null;
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _error = AppLocalizations.of(context).passwordsDontMatch;
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
      await apiService.resetPassword(
        email: widget.email,
        code: code,
        password: password,
      );
      if (!mounted) return;
      setState(() => _success = AppLocalizations.of(context).passwordResetSuccess);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).codeInvalidOrExpired);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _resending = true;
      _error = null;
      _success = null;
    });

    try {
      await apiService.forgotPassword(widget.email);
      if (!mounted) return;
      setState(() => _success = AppLocalizations.of(context).newCodeSentTo(widget.email));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).resendCodeFailed);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.cardElevated,
                      borderRadius: AppRadius.rMd,
                      boxShadow: AppShadows.card(context),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: context.appColors.textSecondary, size: 16),
                  ),
                ),
                const SizedBox(height: 28),
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
                  AppLocalizations.of(context).newPasswordTitle,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).enterCodeAndNewPassword(widget.email),
                  style: TextStyle(
                      color: context.appColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 36),
                if (_error != null) ...[
                  _Message(
                    message: _error!,
                    color: AppColors.error,
                    icon: Icons.error_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                ],
                if (_success != null) ...[
                  _Message(
                    message: _success!,
                    color: AppColors.success,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  controller: _codeCtrl,
                  label: AppLocalizations.of(context).verificationCode,
                  hint: '000000',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.pin_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordCtrl,
                  label: AppLocalizations.of(context).newPassword,
                  hint: '••••••••',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmCtrl,
                  label: AppLocalizations.of(context).confirmPassword,
                  hint: '••••••••',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: AppLocalizations.of(context).resetPasswordBtn,
                  icon: Icons.lock_reset_rounded,
                  iconTrailing: true,
                  fullWidth: true,
                  size: AppButtonSize.large,
                  loading: _loading,
                  onPressed: _loading ? null : _submit,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: AppLocalizations.of(context).resendCode,
                  icon: Icons.refresh_rounded,
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  loading: _resending,
                  onPressed: _resending ? null : _resendCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _Message({
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
