import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AnswerState { idle, selected, correct, wrong }

class AnswerOptionTile extends StatefulWidget {
  final String label;
  final String option;
  final AnswerState state;
  final VoidCallback? onTap;

  const AnswerOptionTile({
    super.key,
    required this.label,
    required this.option,
    this.state = AnswerState.idle,
    this.onTap,
  });

  @override
  State<AnswerOptionTile> createState() => _AnswerOptionTileState();
}

class _AnswerOptionTileState extends State<AnswerOptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _shake;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(_shake);
  }

  @override
  void didUpdateWidget(AnswerOptionTile old) {
    super.didUpdateWidget(old);
    if (widget.state == AnswerState.wrong && old.state != AnswerState.wrong) {
      HapticFeedback.mediumImpact();
      _shake.forward(from: 0);
    }
    if (widget.state == AnswerState.correct &&
        old.state != AnswerState.correct) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Color get _bgColor => switch (widget.state) {
        AnswerState.idle => context.cardElevated,
        AnswerState.selected => AppColors.primary.withValues(alpha: 0.2),
        AnswerState.correct => AppColors.success.withValues(alpha: 0.2),
        AnswerState.wrong => AppColors.error.withValues(alpha: 0.15),
      };

  Color get _borderColor => switch (widget.state) {
        AnswerState.idle => Colors.transparent,
        AnswerState.selected => AppColors.primary,
        AnswerState.correct => AppColors.success,
        AnswerState.wrong => AppColors.error,
      };

  Color get _labelBg => switch (widget.state) {
        AnswerState.idle => context.appColors.cardBgLight,
        AnswerState.selected => AppColors.primary,
        AnswerState.correct => AppColors.success,
        AnswerState.wrong => AppColors.error,
      };

  Color get _labelFg => switch (widget.state) {
        AnswerState.idle => context.appColors.textSecondary,
        _ => Colors.white,
      };

  Widget? get _trailingIcon => switch (widget.state) {
        AnswerState.correct =>
          const Icon(Icons.check_circle_rounded, color: AppColors.success),
        AnswerState.wrong =>
          const Icon(Icons.cancel_rounded, color: AppColors.error),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.state == AnswerState.idle ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: AppRadius.rMd,
            border: Border.all(color: _borderColor, width: 2),
            boxShadow: widget.state == AnswerState.idle
                ? AppShadows.card(context)
                : null,
          ),
          child: Row(
            children: [
              // Label badge (A/B/C/D)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _labelBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: _labelFg,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.option,
                  style: TextStyle(
                    color: widget.state == AnswerState.idle
                        ? context.appColors.textPrimary
                        : _borderColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_trailingIcon != null) _trailingIcon!,
            ],
          ),
        ),
      ),
    );
  }
}
