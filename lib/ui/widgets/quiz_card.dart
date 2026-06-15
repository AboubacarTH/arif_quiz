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
                  style: const TextStyle(fontSize: 26),
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
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Tag(quiz.difficulty.toUpperCase(), diffColor),
                      _Meta(Icons.help_outline_rounded,
                          '${quiz.totalQuestions}Q'),
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
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                _Tag(quiz.difficulty.toUpperCase(), diffColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              quiz.title,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                _Meta(Icons.help_outline_rounded, '${quiz.totalQuestions}Q'),
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
          boxShadow: AppShadows.tinted(context, catColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(quiz.category?.icon ?? '📝',
                    style: const TextStyle(fontSize: 32)),
                _Tag(quiz.difficulty.toUpperCase(), diffColor),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              quiz.title,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                _Meta(Icons.help_outline_rounded, '${quiz.totalQuestions} Q'),
                const SizedBox(width: 10),
                _Meta(Icons.timer_outlined, '${quiz.timeLimit}s'),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: catColor,
                borderRadius: AppRadius.rSm,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Play Now',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
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
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700)),
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
              style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      );
}
