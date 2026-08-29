import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Vignette d'état : le carré arrondi teinté qui coiffe un écran vide ou en
/// erreur. Une seule forme pour les deux, sinon chaque écran vide invente la
/// sienne — c'est exactement ce que faisaient les emoji posés en `fontSize: 60`.
class StateGlyph extends StatelessWidget {
  final IconData icon;
  final Color tint;

  const StateGlyph({super.key, required this.icon, required this.tint});

  @override
  Widget build(BuildContext context) => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.10),
          borderRadius: AppRadius.rXl,
        ),
        child: Icon(icon, color: tint, size: 34),
      );
}

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Teinte de la vignette. Par défaut la couleur muette : un écran vide n'est
  /// pas un événement, il n'a pas à attirer l'œil comme une erreur.
  final Color? tint;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.tint,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.sizeOf(context).width < 360 ? 24.0 : 40.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              StateGlyph(
                  icon: icon!, tint: tint ?? context.appColors.textMuted),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              title,
              style: context.type.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: context.type.bodyLarge
                    .copyWith(color: context.appColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.sizeOf(context).width < 360 ? 24.0 : 40.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StateGlyph(
                icon: Icons.wifi_off_rounded, tint: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(context).oops,
              style: context.type.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              message ?? AppLocalizations.of(context).somethingWrong,
              style: context.type.bodyLarge
                  .copyWith(color: context.appColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(AppLocalizations.of(context).tryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
      color: AppColors.error.withValues(alpha: 0.9),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(
            AppLocalizations.of(context).noInternet,
            style: context.type.labelLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
