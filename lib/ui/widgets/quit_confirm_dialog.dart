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
        'Quitter la partie ?',
        style: TextStyle(
          color: ctx.appColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        'Ta progression sera perdue.',
        style: TextStyle(color: ctx.appColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            'Continuer',
            style: TextStyle(color: ctx.appColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(
            'Quitter',
            style: TextStyle(
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
