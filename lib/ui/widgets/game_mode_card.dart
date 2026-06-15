import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameModeCard extends StatelessWidget {
  final GameMode mode;
  final bool selected;
  final VoidCallback onTap;

  const GameModeCard({
    super.key,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  Color get _color => switch (mode) {
        GameMode.classic => AppColors.primary,
        GameMode.survival => AppColors.error,
        GameMode.speed => AppColors.secondary,
      };

  List<_Badge> get _badges => switch (mode) {
        GameMode.classic => [
            const _Badge(icon: Icons.timer_outlined, label: '30s / question'),
            const _Badge(icon: Icons.star_rounded, label: '×1.0 XP'),
          ],
        GameMode.survival => [
            const _Badge(icon: Icons.favorite_rounded, label: '1 vie'),
            const _Badge(icon: Icons.star_rounded, label: '×1.3 XP'),
          ],
        GameMode.speed => [
            const _Badge(icon: Icons.bolt_rounded, label: '5s / question'),
            const _Badge(icon: Icons.star_rounded, label: '×1.5 XP'),
          ],
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? _color.withValues(alpha: 0.1) : context.cardElevated,
          borderRadius: AppRadius.rXl,
          border: selected
              ? Border.all(color: _color.withValues(alpha: 0.6), width: 2)
              : null,
          boxShadow: selected
              ? AppShadows.tinted(context, _color)
              : AppShadows.card(context),
        ),
        child: Row(
          children: [
            // Icon box
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: selected ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(mode.icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            // Text + badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        mode.label,
                        style: TextStyle(
                          color: selected
                              ? _color
                              : context.appColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (mode == GameMode.speed) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BEST XP',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mode.description,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _badges
                        .map((b) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _BadgeWidget(badge: b, color: _color),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? _color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _color : context.appColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (mode.index * 80).ms).slideY(begin: 0.15);
  }
}

class _Badge {
  final IconData icon;
  final String label;
  const _Badge({required this.icon, required this.label});
}

class _BadgeWidget extends StatelessWidget {
  final _Badge badge;
  final Color color;
  const _BadgeWidget({required this.badge, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(badge.icon, color: color, size: 11),
            const SizedBox(width: 3),
            Text(
              badge.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}
