import 'package:arif_quiz/core/i18n/true_false_l10n.dart';
import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/widgets/answer_option_tile.dart';
import 'package:arif_quiz/ui/widgets/question_media.dart';
import 'package:flutter/material.dart';

/// La scène de jeu : média, énoncé, réponses. Une seule, pour tous les modes.
///
/// Elle était recopiée à l'identique dans quatre écrans (quiz, parcours, speed,
/// survie) — et le cinquième, le défi du jour, avait fini par en diverger parce
/// qu'il n'avait jamais fait partie de la copie : il perdait le média des
/// questions, ne révélait jamais la bonne réponse, et posait ses choix en liste
/// au lieu de la grille. Un mode de jeu ne doit pas se jouer différemment
/// selon l'écran par lequel on y entre.
///
/// Seule la couleur d'accent change d'un mode à l'autre. Le reste — l'ordre des
/// éléments, la respiration entre l'énoncé et les choix, le fait que tout
/// défile ensemble — est le même partout.
///
/// À poser dans un [Expanded] : la scène prend la hauteur restante et défile.
class QuestionStage extends StatelessWidget {
  final GamePlayController controller;

  /// Teinte du mode : rouille en classique, or au défi du jour, rouge en
  /// survie… Elle ne colore que l'étiquette « Question n ».
  final Color accent;

  const QuestionStage({
    super.key,
    required this.controller,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final q = controller.currentQuestion;
    final options = q.choices(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (q.hasMedia)
            QuestionMedia(imageUrl: q.imageUrl, audioUrl: q.audioUrl),
          Text(
            AppLocalizations.of(context).questionNumber(controller.index + 1),
            style: context.type.labelMedium
                .copyWith(color: accent, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            q.text,
            style: context.type.headlineMedium.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.questionToAnswers),
          AnswerOptionsGrid(
            options: options,
            answered: controller.answered,
            selected: controller.selected,
            isCorrect: (o) => q.isCorrect(o),
            onSelect: controller.selectAnswer,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Le bouton « Passer », rendu à la même place dans tous les modes. Il laisse
/// sa hauteur libre une fois la question répondue, pour que la scène ne saute
/// pas d'un cran.
class SkipQuestionButton extends StatelessWidget {
  final GamePlayController controller;

  const SkipQuestionButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.answered) return const SizedBox(height: 48);

    return TextButton(
      onPressed: controller.skip,
      child: Text(
        AppLocalizations.of(context).skip,
        style: context.type.bodyLarge
            .copyWith(color: context.appColors.textMuted),
      ),
    );
  }
}
