import 'package:arif_quiz/core/i18n/difficulty_l10n.dart';
import 'package:arif_quiz/features/game_modes/presentation/screens/game_mode_select_screen.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/app_bar.dart';
import 'package:arif_quiz/ui/widgets/app_button.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/stats_card.dart';
import 'package:flutter/material.dart';

class QuizDetailScreen extends StatefulWidget {
  final int quizId;
  const QuizDetailScreen({super.key, required this.quizId});
  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  QuizModel? _quiz;
  bool _loading = true;
  // Le message d'erreur est résolu au build : la langue courante ne peut pas
  // être figée dans un `String` posé pendant l'appel réseau.
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final q = await QuizRepository(apiService).getQuiz(widget.quizId);
      setState(() {
        _quiz = q;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: QuizAppBar(title: AppLocalizations.of(context).quizDetails, showBack: true),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _failed
              ? ErrorState(
                  message: AppLocalizations.of(context).loadQuizFailed,
                  onRetry: _load)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final q = _quiz!;
    final diffColor = AppColors.difficultyColor(q.difficulty);
    final catColor = q.category?.color != null
        ? Color(int.parse(q.category!.color.replaceFirst('#', 'FF'), radix: 16))
        : AppColors.primary;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero banner
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: context.cardElevated,
                    borderRadius: AppRadius.rXl,
                    border: Border.all(color: context.appColors.border),
                    boxShadow: AppShadows.card(context),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.14),
                          borderRadius: AppRadius.rLg,
                        ),
                        child: Center(
                          child: Text(q.category?.icon ?? '📝',
                              style: AppType.score),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (q.category != null)
                        Text(q.category!.name,
                            style: context.type.titleMedium.copyWith(color: catColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(q.title,
                            style: context.type.headlineLarge.copyWith(color: context.appColors.textPrimary))),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border:
                              Border.all(color: diffColor.withValues(alpha: 0.3))),
                      child: Text(DifficultyL10n.badge(context, q.difficulty),
                          style: context.type.labelSmall.copyWith(color: diffColor)),
                    ),
                  ],
                ),

                if (q.description != null) ...[
                  const SizedBox(height: 10),
                  Text(q.description!,
                      style: context.type.bodyLarge.copyWith(color: context.appColors.textSecondary, height: 1.6)),
                ],
                const SizedBox(height: 24),

                // Stats grid
                Row(children: [
                  Expanded(
                      child: StatsCard(
                          value: '${q.timeLimit}s',
                          label: AppLocalizations.of(context).perQuestion,
                          icon: Icons.timer_rounded,
                          color: AppColors.info)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatsCard(
                          value: '+${q.pointsPerQuestion ?? 10}',
                          label: AppLocalizations.of(context).pointsPerQ,
                          icon: Icons.star_rounded,
                          color: AppColors.warning)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatsCard(
                          value: '${q.playCount}',
                          label: AppLocalizations.of(context).plays,
                          icon: Icons.play_circle_rounded,
                          color: AppColors.success)),
                ]),
                const SizedBox(height: 24),

                // How to play
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                      color: context.cardElevated,
                      borderRadius: AppRadius.rLg,
                      boxShadow: AppShadows.card(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).howToPlay,
                          style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary)),
                      const SizedBox(height: 12),
                      ...[
                        AppLocalizations.of(context).ruleSelectOne,
                        AppLocalizations.of(context).ruleTimer,
                        AppLocalizations.of(context).rulePoints(q.pointsPerQuestion ?? 10),
                        AppLocalizations.of(context).ruleReview,
                      ].map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.success, size: 16),
                              const SizedBox(width: 8),
                              Text(s,
                                  style: context.type.bodyMedium.copyWith(color: context.appColors.textSecondary)),
                            ]),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          child: AppButton(
            label: AppLocalizations.of(context).startQuiz,
            fullWidth: true,
            size: AppButtonSize.large,
            icon: Icons.play_arrow_rounded,
            iconTrailing: true,
            // Vers le choix du mode, pas directement vers le Classique : c'est
            // la seule porte d'entrée d'un joueur vers Survie, Speed et
            // Précision. Le portail de monétisation est sur le bouton « Jouer »
            // de l'écran suivant — le poser ici aussi ferait payer une partie
            // pour le simple fait de regarder la liste des modes.
            onPressed: () => Navigator.push(
                context, SlideUpRoute(page: GameModeSelectScreen(quiz: q))),
          ),
        ),
      ],
    );
  }
}
