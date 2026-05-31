import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool outlined;
  final double? width;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.outlined = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: outlined ? Colors.transparent : c,
              borderRadius: BorderRadius.circular(14),
              border: outlined ? Border.all(color: c, width: 2) : null,
              boxShadow: outlined
                  ? null
                  : [
                      BoxShadow(
                        color: c.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: outlined ? c : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
