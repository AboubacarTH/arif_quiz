import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }
enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool iconTrailing;
  final bool loading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconTrailing = false,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapUp(_) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  Color get _bgColor => switch (widget.variant) {
        AppButtonVariant.primary   => AppColors.primary,
        AppButtonVariant.secondary => AppColors.cardBg,
        AppButtonVariant.danger    => AppColors.error,
        AppButtonVariant.ghost     => Colors.transparent,
      };

  Color get _fgColor => switch (widget.variant) {
        AppButtonVariant.primary   => Colors.white,
        AppButtonVariant.secondary => AppColors.textPrimary,
        AppButtonVariant.danger    => Colors.white,
        AppButtonVariant.ghost     => AppColors.primary,
      };

  BorderSide get _border => switch (widget.variant) {
        AppButtonVariant.secondary => const BorderSide(color: AppColors.cardBgLight, width: 1.5),
        AppButtonVariant.ghost     => const BorderSide(color: AppColors.primary, width: 1.5),
        _                          => BorderSide.none,
      };

  EdgeInsets get _padding => switch (widget.size) {
        AppButtonSize.small  => const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        AppButtonSize.large  => const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      };

  double get _fontSize => switch (widget.size) {
        AppButtonSize.small  => 13,
        AppButtonSize.medium => 15,
        AppButtonSize.large  => 17,
      };

  double get _iconSize => switch (widget.size) {
        AppButtonSize.small  => 16,
        AppButtonSize.medium => 18,
        AppButtonSize.large  => 20,
      };

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;

    return GestureDetector(
      onTapDown: disabled ? null : _onTapDown,
      onTapUp: disabled ? null : _onTapUp,
      onTapCancel: disabled ? null : _onTapCancel,
      onTap: disabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.fullWidth ? double.infinity : null,
          padding: _padding,
          decoration: BoxDecoration(
            color: disabled ? _bgColor.withOpacity(0.5) : _bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.fromBorderSide(_border),
            boxShadow: widget.variant == AppButtonVariant.primary && !disabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                SizedBox(
                  width: _iconSize,
                  height: _iconSize,
                  child: CircularProgressIndicator(
                    color: _fgColor,
                    strokeWidth: 2,
                  ),
                )
              else ...[
                if (widget.icon != null && !widget.iconTrailing) ...[
                  Icon(widget.icon, color: _fgColor, size: _iconSize),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: _fgColor,
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito',
                  ),
                ),
                if (widget.icon != null && widget.iconTrailing) ...[
                  const SizedBox(width: 8),
                  Icon(widget.icon, color: _fgColor, size: _iconSize),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
