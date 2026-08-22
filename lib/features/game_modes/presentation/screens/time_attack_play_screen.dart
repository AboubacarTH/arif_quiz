import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/features/game_modes/presentation/screens/mode_play_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Le mode Contre-la-montre : une seule horloge pour toute la manche, que les
/// bonnes réponses rallongent.
///
/// C'est le seul mode où le temps ne se remet pas à zéro d'une question à
/// l'autre — l'anneau des autres modes n'aurait aucun sens ici, puisqu'il
/// mesurerait toujours la même chose. Le chrono prend donc la forme d'un
/// décompte lisible de loin, avec une barre qui se vide sur toute la manche.
class TimeAttackPlayScreen extends ModePlayScreen {
  const TimeAttackPlayScreen({
    super.key,
    required super.quiz,
    super.challengeId,
    super.challenge,
  });

  @override
  State<TimeAttackPlayScreen> createState() => _TimeAttackPlayScreenState();
}

class _TimeAttackPlayScreenState
    extends ModePlayScreenState<TimeAttackPlayScreen> {
  @override
  GameMode get mode => GameMode.timeattack;

  @override
  Color get accent => AppColors.modeTimeAttack;

  @override
  GamePlayController createController(
    List<QuestionModel> questions,
    int timeLimit,
  ) =>
      GamePlayController(
        mode: GameMode.timeattack,
        questions: questions,
        // Le temps par question annoncé par le serveur ne s'applique pas :
        // c'est la manche entière qui est chronométrée.
        secondsPerQuestion: ModeScoring.timeAttackSeconds,
        clock: GameClock.global,
        bonusSecondsPerCorrect: ModeScoring.timeAttackBonus,
      );

  /// Le chrono, pas l'anneau : sur une horloge de deux minutes, un cercle qui
  /// se vide lentement ne dit rien, et c'est le nombre de secondes qui compte.
  @override
  Widget buildTimer(GamePlayController ctrl) {
    final seconds = ctrl.timeLeft.clamp(0, ctrl.timeLeft).toInt();
    final urgent = seconds <= 15;
    final color = urgent ? AppColors.error : accent;

    // La barre se remplit sur le budget de départ ; le bonus peut la faire
    // dépasser, et c'est bon signe — on la borne à plein.
    final ratio =
        (seconds / ModeScoring.timeAttackSeconds).clamp(0.0, 1.0).toDouble();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$seconds',
              style: AppType.scoreHero.copyWith(
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 6),
            Text('s',
                style: context.type.titleLarge
                    .copyWith(color: context.appColors.textMuted)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: context.appColors.cardBg,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildBanner(GamePlayController ctrl) {
    // Le gain de temps ne se voit que s'il est annoncé : sans cette pastille,
    // le chrono qui remonte passerait pour un bug.
    final justEarned = ctrl.currentOutcome == AnswerOutcome.right;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: SizedBox(
        height: 32,
        child: justEarned
            ? Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ModeBadge(
                  label: AppLocalizations.of(context)
                      .jokerTimeLabel(ModeScoring.timeAttackBonus),
                  color: AppColors.success,
                  icon: Icons.add_alarm_rounded,
                ),
              )
            : null,
      ),
    );
  }
}
