import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/features/game_modes/presentation/screens/mode_play_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Le mode Précision : +2 pour une bonne réponse, −1 pour une mauvaise, 0 pour
/// une question qu'on laisse passer.
///
/// C'est le premier mode où renoncer est un coup à jouer. L'écran met donc deux
/// choses sous les yeux en permanence : le total qui monte et descend, et le
/// bouton « Passer » — qui n'est plus un lien discret en bas de page comme dans
/// les autres modes, mais l'autre moitié de la décision.
class PrecisionPlayScreen extends ModePlayScreen {
  const PrecisionPlayScreen({
    super.key,
    required super.quiz,
    super.challengeId,
    super.challenge,
  });

  @override
  State<PrecisionPlayScreen> createState() => _PrecisionPlayScreenState();
}

class _PrecisionPlayScreenState
    extends ModePlayScreenState<PrecisionPlayScreen> {
  @override
  GameMode get mode => GameMode.precision;

  @override
  Color get accent => AppColors.modePrecision;

  @override
  GamePlayController createController(
    List<QuestionModel> questions,
    int timeLimit,
  ) =>
      GamePlayController(
        mode: GameMode.precision,
        questions: questions,
        secondsPerQuestion: timeLimit,
      );

  /// Le total, et ce que la question vient de lui faire. C'est toute la tension
  /// du mode : on doit pouvoir la lire sans quitter la question des yeux.
  @override
  Widget buildBanner(GamePlayController ctrl) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Row(
          children: [
            ModeBadge(
              label: AppLocalizations.of(context).modeTally(
                  ModeScoring.format(ctrl.modePoints ?? 0),
                  ctrl.maxModePoints ?? 0),
              color: accent,
              filled: true,
            ),
            const Spacer(),
            _deltaPill(ctrl),
          ],
        ),
      );

  Widget _deltaPill(GamePlayController ctrl) {
    final outcome = ctrl.currentOutcome;
    // La place reste prise même sans pastille : sinon la ligne se réorganise à
    // chaque réponse et l'énoncé saute d'un cran.
    if (outcome == null) return const SizedBox(height: 34);

    final (label, color) = switch (outcome) {
      AnswerOutcome.right => (
          '+${ModeScoring.precisionReward}',
          AppColors.success,
        ),
      AnswerOutcome.wrong => (
          '−${ModeScoring.precisionPenalty}',
          AppColors.error,
        ),
      AnswerOutcome.skipped => ('0', context.appColors.textMuted),
    };

    return ModeBadge(label: label, color: color);
  }

  /// Ailleurs « Passer » est une sortie de secours. Ici c'est un coup à part
  /// entière — il mérite un vrai bouton, et qu'on rappelle ce qu'il coûte.
  @override
  Widget buildFooter(GamePlayController ctrl) {
    if (ctrl.answered) return const SizedBox(height: 72);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: ctrl.skip,
              icon: const Icon(Icons.redo_rounded, size: 18),
              label: Text(AppLocalizations.of(context).skip),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appColors.textSecondary,
                side: BorderSide(color: context.appColors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(AppLocalizations.of(context).precisionSkipHint,
              style: context.type.labelSmall
                  .copyWith(color: context.appColors.textMuted)),
        ],
      ),
    );
  }
}
