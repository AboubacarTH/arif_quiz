import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Dialog de confirmation partagé pour quitter une partie en cours.
///
/// Utilisé par les modes Classique, Speed et Survie afin d'unifier le
/// comportement du bouton « fermer » et du geste retour système.
Future<bool> confirmQuitGame(BuildContext context) async {
  final quit = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.appColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.rXl),
      title: Text(
        AppLocalizations.of(context).quitGameTitle,
        style: TextStyle(
          color: ctx.appColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        AppLocalizations.of(context).quitGameBody,
        style: TextStyle(color: ctx.appColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            AppLocalizations.of(context).keepPlaying,
            style: TextStyle(color: ctx.appColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            AppLocalizations.of(context).quit,
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  return quit ?? false;
}
