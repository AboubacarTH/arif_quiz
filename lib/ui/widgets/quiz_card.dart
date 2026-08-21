import 'package:arif_quiz/core/i18n/difficulty_l10n.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

enum QuizCardStyle { list, grid, featured }

class QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onTap;
  final QuizCardStyle style;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.onTap,
    this.style = QuizCardStyle.list,
  });

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      QuizCardStyle.list => _ListCard(quiz: quiz, onTap: onTap),
      QuizCardStyle.grid => _GridCard(quiz: quiz, onTap: onTap),
      QuizCardStyle.featured => _FeaturedCard(quiz: quiz, onTap: onTap),
    };
  }
}

// ── List style ────────────────────────────────────────────────
class _ListCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onTap;
  const _ListCard({required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final diffColor = AppColors.difficultyColor(quiz.difficulty);
    final catColor = quiz.category?.color != null
        ? Color(
            int.parse(quiz.category!.color.replaceFirst('#', 'FF'), radix: 16))
        : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: AppRadius.rMd,
              ),
              child: Center(
                child: Text(
                  quiz.category?.icon ?? '📝',
                  style: context.type.displayMedium,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Tag(DifficultyL10n.badge(context, quiz.difficulty),
                          diffColor),
                      _Meta(Icons.timer_outlined, '${quiz.timeLimit}s'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Play count + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.chevron_right_rounded,
                    color: context.appColors.textMuted),
                const SizedBox(height: 4),
                _Meta(Icons.play_circle_outline_rounded, '${quiz.playCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grid style ────────────────────────────────────────────────
class _GridCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onTap;
  const _GridCard({required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final diffColor = AppColors.difficultyColor(quiz.difficulty);
    final catColor = quiz.category?.color != null
        ? Color(
            int.parse(quiz.category!.color.replaceFirst('#', 'FF'), radix: 16))
        : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + difficulty
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: AppRadius.rMd,
                  ),
                  child: Center(
                    child: Text(quiz.category?.icon ?? '📝',
                        style: context.type.headlineLarge),
                  ),
                ),
                _Tag(DifficultyL10n.badge(context, quiz.difficulty), diffColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              quiz.title,
              style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                _Meta(Icons.timer_outlined, '${quiz.timeLimit}s'),
                const Spacer(),
                _Meta(Icons.play_circle_outline_rounded, '${quiz.playCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured (horizontal scroll) style ───────────────────────
class _FeaturedCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onTap;
  const _FeaturedCard({required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final catColor = quiz.category?.color != null
        ? Color(
            int.parse(quiz.category!.color.replaceFirst('#', 'FF'), radix: 16))
        : AppColors.primary;
    final diffColor = AppColors.difficultyColor(quiz.difficulty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rXl,
          border: Border.all(color: context.appColors.border),
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: AppRadius.rMd,
                  ),
                  child: Center(
                    child: Text(quiz.category?.icon ?? '📝',
                        style: context.type.displayMedium),
                  ),
                ),
                _Tag(DifficultyL10n.badge(context, quiz.difficulty), diffColor),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              quiz.title,
              style: context.type.titleLarge.copyWith(color: context.appColors.textPrimary, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                _Meta(Icons.timer_outlined, '${quiz.timeLimit}s'),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.rSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context).playNow,
                      style: context.type.labelLarge.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Text(label,
            style: context.type.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
      );
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Meta(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: context.appColors.textMuted, size: 13),
          const SizedBox(width: 3),
          Text(label,
              style: context.type.labelMedium.copyWith(color: context.appColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      );
}
