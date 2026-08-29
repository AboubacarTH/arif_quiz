import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/features/auth/presentation/screens/login_screen.dart';
import 'package:arif_quiz/features/auth/presentation/screens/register_screen.dart';
import 'package:arif_quiz/features/home/presentation/screens/main_navigation.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:flutter/material.dart';

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  void _goLogin(BuildContext context) => Navigator.push(
        context,
        SlideRightRoute(page: const LoginScreen()),
      );

  void _goRegister(BuildContext context) => Navigator.push(
        context,
        SlideRightRoute(page: const RegisterScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_rounded, size: 40, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context).signInToContinue,
                  textAlign: TextAlign.center,
                  style: context.type.headlineMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context).guestScreenBody,
                  textAlign: TextAlign.center,
                  style: context.type.bodyLarge.copyWith(color: context.appColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _goRegister(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    child: Text(
                      AppLocalizations.of(context).createAccount,
                      style: context.type.titleMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _goLogin(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.appColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                    child: Text(
                      AppLocalizations.of(context).logIn,
                      style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, _, _) =>
                            const MainNavigation(initialIndex: 0),
                        transitionsBuilder: (_, a, _, child) =>
                            FadeTransition(opacity: a, child: child),
                      ),
                      (_) => false,
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context).backToHome,
                    style: context.type.bodyMedium.copyWith(color: context.appColors.textMuted, decoration: TextDecoration.underline),
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
