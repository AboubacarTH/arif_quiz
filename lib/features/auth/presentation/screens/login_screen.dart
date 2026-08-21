import 'package:arif_quiz/core/i18n/auth_error_l10n.dart';
import 'package:arif_quiz/features/auth/bloc/auth_controller.dart';
import 'package:arif_quiz/features/auth/data/auth_repository.dart';
import 'package:arif_quiz/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:arif_quiz/features/auth/presentation/screens/register_screen.dart';
import 'package:arif_quiz/features/home/presentation/screens/main_navigation.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/ui.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  late final AuthController _auth;
  String? _emailError, _passError;

  @override
  void initState() {
    super.initState();
    _auth = AuthController(AuthRepository(apiService));
    _auth.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!mounted) return;
    if (_auth.isAuthenticated) {
      isGuest.value = false;
      messagingService.syncToken();
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavigation(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (_) => false,
      );
    } else {
      setState(() {});
    }
  }

  bool _validate() {
    setState(() {
      _emailError = _emailCtrl.text.trim().isEmpty ? AppLocalizations.of(context).emailRequired : null;
      _passError = _passCtrl.text.isEmpty ? AppLocalizations.of(context).passwordRequired : null;
    });
    return _emailError == null && _passError == null;
  }

  Future<void> _login() async {
    if (!_validate()) return;
    await _auth.login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _auth.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: BlobBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.asset(
                    'assets/images/arifquiz_192.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context).welcomeBack,
                  style: AppType.score.copyWith(color: context.appColors.textPrimary, height: 1.1),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).signInSubtitle,
                  style:
                      context.type.titleLarge.copyWith(color: context.appColors.textSecondary),
                ),
                const SizedBox(height: 40),
                // Error banner
                if (_auth.errorCode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3))),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                AuthErrorL10n.message(context, _auth.errorCode!),
                                style: context.type.bodyMedium.copyWith(color: AppColors.error))),
                        GestureDetector(
                            onTap: _auth.clearError,
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.error, size: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                AppTextField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  label: AppLocalizations.of(context).email,
                  hint: AppLocalizations.of(context).emailHint,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  errorText: _emailError,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passFocus.requestFocus(),
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                ),
                
                const SizedBox(height: 16),
                
                AppTextField(
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  label: AppLocalizations.of(context).password,
                  hint: '••••••••',
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  onChanged: (_) {
                    if (_passError != null) setState(() => _passError = null);
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ForgotPasswordScreen(
                          initialEmail: _emailCtrl.text.trim().isEmpty
                              ? null
                              : _emailCtrl.text.trim(),
                        ),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).forgotPassword,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: AppLocalizations.of(context).logIn,
                  onPressed: _auth.isLoading ? null : _login,
                  fullWidth: true,
                  size: AppButtonSize.large,
                  loading: _auth.isLoading,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: context.appColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).signUp,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: Divider(color: context.appColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou', style: context.type.bodyMedium.copyWith(color: context.appColors.textMuted)),
                  ),
                  Expanded(child: Divider(color: context.appColors.border)),
                ]),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    isGuest.value = true;
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const MainNavigation(),
                        transitionsBuilder: (_, a, __, child) =>
                            FadeTransition(opacity: a, child: child),
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                      (_) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: context.cardElevated,
                      borderRadius: AppRadius.rMd,
                      boxShadow: AppShadows.card(context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline_rounded,
                            color: context.appColors.textSecondary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).continueAsGuest,
                          style: context.type.titleMedium.copyWith(color: context.appColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).scoresNotSaved,
                  textAlign: TextAlign.center,
                  style: context.type.labelSmall.copyWith(color: context.appColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
