import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_play_screen.dart';
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
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final q = await QuizRepository(apiService).getQuiz(widget.quizId);
      setState(() {
        _quiz = q;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load quiz.';
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
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
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
                              style: const TextStyle(fontSize: 40)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (q.category != null)
                        Text(q.category!.name,
                            style: TextStyle(
                                color: catColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(q.title,
                            style: TextStyle(
                                color: context.appColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Nunito'))),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: diffColor.withValues(alpha: 0.3))),
                      child: Text(q.difficulty.toUpperCase(),
                          style: TextStyle(
                              color: diffColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),

                if (q.description != null) ...[
                  const SizedBox(height: 10),
                  Text(q.description!,
                      style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 14,
                          height: 1.6)),
                ],
                const SizedBox(height: 24),

                // Stats grid
                Row(children: [
                  Expanded(
                      child: StatsCard(
                          value: '${q.totalQuestions}',
                          label: AppLocalizations.of(context).questions,
                          icon: Icons.help_rounded,
                          color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatsCard(
                          value: '${q.timeLimit}s',
                          label: AppLocalizations.of(context).perQuestion,
                          icon: Icons.timer_rounded,
                          color: AppColors.info)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
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
                      Text('📌 How to Play',
                          style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
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
                                  style: TextStyle(
                                      color: context.appColors.textSecondary,
                                      fontSize: 13)),
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
            onPressed: () => Navigator.push(
                context, SlideUpRoute(page: QuizPlayScreen(quiz: q))),
          ),
        ),
      ],
    );
  }
}
