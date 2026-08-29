import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bouton « Continuer avec Google ».
///
/// Il emprunte sa géométrie à [AppButton] taille `large` — même rayon, même
/// hauteur, même échelle de texte — pour s'aligner sur le bouton de connexion
/// juste au-dessus. Ce qu'il ne partage pas, c'est le logo : le « G » est
/// quadrichrome, donc ni un `IconData` ni une couleur de premier plan.
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxxl, vertical: AppSpacing.lg + 2),
        decoration: BoxDecoration(
          color: context.appColors.cardBg,
          borderRadius: AppRadius.rMd,
          border: Border.all(color: context.appColors.cardBgLight, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: context.appColors.textPrimary,
                  strokeWidth: 2,
                ),
              )
            else ...[
              // Le logo garde ses couleurs quel que soit le thème : c'est une
              // marque, pas une icône de l'interface.
              SvgPicture.asset('assets/images/google_g.svg',
                  width: 20, height: 20),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).continueWithGoogle,
                  style: context.type.titleLarge.copyWith(
                    color: disabled
                        ? context.appColors.textMuted
                        : context.appColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
