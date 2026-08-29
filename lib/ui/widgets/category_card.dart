import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(category.color.replaceFirst('#', 'FF'), radix: 16));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : context.cardElevated,
          borderRadius: AppRadius.rXl,
          border: selected
              ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5)
              : null,
          boxShadow: selected ? null : AppShadows.card(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon ?? '📚', style: context.type.titleLarge),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                category.name,
                style: context.type.labelLarge.copyWith(color: selected ? color : context.appColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(category.color.replaceFirst('#', 'FF'), radix: 16));
    final compact = MediaQuery.sizeOf(context).width < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 88 : 100,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 12 : 14,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon ?? '📚', style: context.type.displayLarge),
            const SizedBox(height: 8),
            AutoSizeText(
              category.name,
              style: context.type.labelMedium.copyWith(color: context.appColors.textPrimary, // taille maximale de départ
                fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2, // reste sur une seule ligne
              minFontSize:
                  10, // taille minimale avant l'ellipse
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${category.quizCount} quiz${category.quizCount != 1 ? 'zes' : ''}',
              style: context.type.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
