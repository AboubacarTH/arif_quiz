import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/features/game_modes/presentation/screens/mode_play_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Le mode Série : chaque bonne réponse enchaînée vaut plus que la précédente,
/// et une erreur remet le compteur à zéro.
///
/// Ce que le joueur doit voir n'est pas ce qu'il vient de gagner mais ce qu'il
/// perdrait en se trompant : le bandeau montre donc la série en cours et la
/// valeur de la PROCHAINE bonne réponse.
class StreakPlayScreen extends ModePlayScreen {
  const StreakPlayScreen({
    super.key,
    required super.quiz,
    super.challengeId,
    super.challenge,
  });

  @override
  State<StreakPlayScreen> createState() => _StreakPlayScreenState();
}

class _StreakPlayScreenState extends ModePlayScreenState<StreakPlayScreen> {
  @override
  GameMode get mode => GameMode.streak;

  @override
  Color get accent => AppColors.modeStreak;

  @override
  GamePlayController createController(
    List<QuestionModel> questions,
    int timeLimit,
  ) =>
      GamePlayController(
        mode: GameMode.streak,
        questions: questions,
        secondsPerQuestion: timeLimit,
      );

  @override
  Widget buildBanner(GamePlayController ctrl) {
    final l10n = AppLocalizations.of(context);
    final streak = ctrl.currentStreak;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Row(
        children: [
          ModeBadge(
            label: l10n.modeTally(
                ModeScoring.format(ctrl.modePoints ?? 0), ctrl.maxModePoints ?? 0),
            color: accent,
            filled: true,
          ),
          const Spacer(),
          // La série se lit d'un coup d'œil ; ce qu'elle rapportera à la
          // prochaine question est écrit sous l'énoncé.
          if (streak > 0)
            ModeBadge(
              label: l10n.streakRun(streak),
              color: accent,
              icon: Icons.trending_up_rounded,
            ),
        ],
      ),
    );
  }

  @override
  Widget buildFooter(GamePlayController ctrl) {
    if (ctrl.answered) return const SizedBox(height: 40);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Text(
        AppLocalizations.of(context).nextAnswerWorth(ctrl.nextStreakTier),
        style: context.type.bodyLarge
            .copyWith(color: accent, fontWeight: FontWeight.w700),
      ),
    );
  }
}
