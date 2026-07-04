import 'package:arif_quiz/features/journey/presentation/screens/journey_play_screen.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/neon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Écran de résultat d'un niveau de parcours, façon Candy Crush : étoiles
/// animées (0-3), score, et accès au niveau suivant.
class JourneyResultScreen extends StatelessWidget {
  final JourneyLevelResult result;
  final bool isBoss;

  const JourneyResultScreen(
      {super.key, required this.result, this.isBoss = false});

  Color get _accent => isBoss ? AppColors.error : AppColors.primary;

  ({String emoji, String title}) get _headline => switch (result.stars) {
        3 => (emoji: '🏆', title: 'Parfait !'),
        2 => (emoji: '🎉', title: 'Bien joué !'),
        1 => (emoji: '👍', title: 'Niveau réussi'),
        _ => (emoji: '😕', title: 'Presque !'),
      };

  @override
  Widget build(BuildContext context) {
    final h = _headline;
    final passed = result.stars >= 1;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: context.appColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(h.emoji, style: const TextStyle(fontSize: 64))
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.6, 0.6)),
                const SizedBox(height: 12),
                Text(
                  h.title,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 120.ms),
                const SizedBox(height: 6),
                Text(
                  isBoss ? 'Boss · Niveau ${result.level}' : 'Niveau ${result.level}',
                  style: TextStyle(
                      color: context.appColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 28),
                _StarsRow(stars: result.stars, color: _accent),
                const SizedBox(height: 28),
                _StatsCard(result: result, accent: _accent),
                const Spacer(),
                if (result.nextLevelUnlocked && result.nextLevel != null)
                  NeonButton(
                    label: 'Niveau suivant',
                    width: double.infinity,
                    icon: Icons.arrow_forward_rounded,
                    color: _accent,
                    onTap: () => _goToLevel(context, result.nextLevel!),
                  )
                else if (!passed)
                  NeonButton(
                    label: 'Réessayer',
                    width: double.infinity,
                    icon: Icons.refresh_rounded,
                    color: _accent,
                    onTap: () => _goToLevel(context, result.level),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (passed)
                      Expanded(
                        child: _SecondaryButton(
                          label: 'Rejouer',
                          icon: Icons.refresh_rounded,
                          onTap: () => _goToLevel(context, result.level),
                        ),
                      ),
                    if (passed) const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryButton(
                        label: 'Voir la carte',
                        icon: Icons.map_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToLevel(BuildContext context, int level) {
    Navigator.pushReplacement(
      context,
      SlideRightRoute(
        page: JourneyPlayScreen(level: level, isBoss: level % 5 == 0),
      ),
    );
  }
}

// ─── Stars ───────────────────────────────────────────────────────────────────

class _StarsRow extends StatelessWidget {
  final int stars;
  final Color color;
  const _StarsRow({required this.stars, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final earned = i < stars;
        final star = Icon(
          earned ? Icons.star_rounded : Icons.star_outline_rounded,
          size: i == 1 ? 66 : 54,
          color: earned ? AppColors.accent : context.appColors.border,
        );
        return Padding(
          padding: EdgeInsets.only(top: i == 1 ? 0 : 14, left: 4, right: 4),
          child: earned
              ? star
                  .animate()
                  .fadeIn(delay: (300 + i * 220).ms)
                  .scale(
                      begin: const Offset(0.2, 0.2),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                      duration: 500.ms)
              : star,
        );
      }),
    );
  }
}

// ─── Stats ───────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final JourneyLevelResult result;
  final Color accent;
  const _StatsCard({required this.result, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardElevated,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          _stat(context, '${result.score.toStringAsFixed(0)}%', 'Score', accent),
          _divider(context),
          _stat(context, '${result.correctCount}/${result.totalQuestions}',
              'Bonnes', AppColors.success),
          _divider(context),
          _stat(context, '+${result.xpEarned}', 'XP', AppColors.secondary),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1);
  }

  Widget _stat(BuildContext context, String value, String label, Color color) =>
      Expanded(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: context.appColors.textSecondary, fontSize: 12)),
          ],
        ),
      );

  Widget _divider(BuildContext context) => Container(
        width: 1,
        height: 34,
        color: context.appColors.border,
      );
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SecondaryButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: context.cardElevated,
            borderRadius: AppRadius.rMd,
            border: Border.all(color: context.appColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: context.appColors.textSecondary),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}
