import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatsCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double minTileWidth;

  const StatsGrid({
    super.key,
    required this.children,
    this.spacing = 12,
    this.minTileWidth = 150,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth = MediaQuery.sizeOf(context).width;
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fallbackWidth;
        final useTwoColumns = maxWidth >= (minTileWidth * 2 + spacing);
        final itemWidth = useTwoColumns ? (maxWidth - spacing) / 2 : maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class StatsRow extends StatelessWidget {
  final List<StatItem> stats;

  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: context.appColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.cardBgLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final stat in stats) Expanded(child: _StatCell(stat)),
        ],
      ),
    );
  }
}

class StatItem {
  final String value;
  final String label;
  final Color color;
  const StatItem(this.value, this.label, this.color);
}

class _StatCell extends StatelessWidget {
  final StatItem stat;
  const _StatCell(this.stat);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.value,
            style: TextStyle(
              color: stat.color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      );
}
