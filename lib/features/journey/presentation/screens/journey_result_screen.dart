import 'package:arif_quiz/core/monetization/play_gate.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/features/journey/presentation/screens/journey_play_screen.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/app_button.dart';
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

  /// Les libellés existaient déjà en 4 langues (`resultPerfect`…) mais l'écran
  /// gardait des chaînes françaises en dur : le titre ne suivait pas la langue.
  ({IconData icon, Color color, String title}) _headline(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (result.stars) {
      3 => (
          icon: Icons.emoji_events_rounded,
          color: AppColors.secondary,
          title: l10n.resultPerfect
        ),
      2 => (
          icon: Icons.celebration_rounded,
          color: AppColors.success,
          title: l10n.resultGreat
        ),
      1 => (
          icon: Icons.thumb_up_rounded,
          color: AppColors.info,
          title: l10n.resultPassed
        ),
      _ => (
          icon: Icons.replay_rounded,
          color: AppColors.textMuted,
          title: l10n.resultAlmost
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final h = _headline(context);
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
                Icon(h.icon, size: 72, color: h.color)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.6, 0.6)),
                const SizedBox(height: 12),
                Text(
                  h.title,
                  style: context.type.displayMedium.copyWith(color: context.appColors.textPrimary),
                ).animate().fadeIn(delay: 120.ms),
                const SizedBox(height: 6),
                Text(
                  isBoss ? AppLocalizations.of(context).bossLevelLabel(result.level) : AppLocalizations.of(context).levelLabel(result.level),
                  style: context.type.bodyLarge.copyWith(color: context.appColors.textSecondary),
                ),
                const SizedBox(height: 28),
                _StarsRow(stars: result.stars, color: _accent),
                const SizedBox(height: 28),
                _StatsCard(result: result, accent: _accent),
                const Spacer(),
                if (result.nextLevelUnlocked && result.nextLevelId != null)
                  AppButton(
                    label: AppLocalizations.of(context).nextLevel,
                    fullWidth: true,
                    icon: Icons.arrow_forward_rounded,
                    tint: _accent,
                    onPressed: () => _goToLevel(context, result.nextLevelId!,
                        result.nextLevel!, result.nextLevelIsBoss),
                  )
                else if (!passed)
                  AppButton(
                    label: AppLocalizations.of(context).retry,
                    fullWidth: true,
                    icon: Icons.refresh_rounded,
                    tint: _accent,
                    onPressed: () =>
                        _goToLevel(context, result.id, result.level, isBoss),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (passed)
                      Expanded(
                        child: _SecondaryButton(
                          label: AppLocalizations.of(context).replay,
                          icon: Icons.refresh_rounded,
                          onTap: () =>
                        _goToLevel(context, result.id, result.level, isBoss),
                        ),
                      ),
                    if (passed) const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryButton(
                        label: AppLocalizations.of(context).viewMap,
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

  /// Enchaîne sur le niveau suivant. Le serveur renvoie son identifiant ET son
  /// rang : on ne devine plus rien (le « boss tous les 5 » n'existe plus, c'est
  /// désormais un réglage par niveau côté admin).
  void _goToLevel(
      BuildContext context, int levelId, int levelNumber, bool boss) {
    // « Niveau suivant » et « Rejouer » lancent une partie comme les autres :
    // sans ce passage par le portail, l'enchaînement depuis le résultat était
    // un contournement gratuit du système de crédits.
    PlayGate.requestPlay(
      context,
      onGranted: () => Navigator.pushReplacement(
        context,
        SlideRightRoute(
          page: JourneyPlayScreen(
              levelId: levelId, levelNumber: levelNumber, isBoss: boss),
        ),
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
                style: context.type.headlineMedium.copyWith(color: color, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary)),
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
                  style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary)),
            ],
          ),
        ),
      );
}
