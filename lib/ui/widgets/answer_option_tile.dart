import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AnswerState { idle, selected, correct, wrong }

/// Disposition d'un tuile de réponse : liste (barre horizontale pleine largeur)
/// ou grille (carte compacte pour un affichage 2×2).
enum AnswerTileLayout { list, grid }

class AnswerOptionTile extends StatefulWidget {
  final String label;
  final String option;
  final AnswerState state;
  final VoidCallback? onTap;
  final AnswerTileLayout layout;

  const AnswerOptionTile({
    super.key,
    required this.label,
    required this.option,
    this.state = AnswerState.idle,
    this.onTap,
    this.layout = AnswerTileLayout.list,
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
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
        AnswerState.wrong =>
          const Icon(Icons.cancel_rounded, color: AppColors.error, size: 22),
        _ => null,
      };

  Color get _textColor => widget.state == AnswerState.idle
      ? context.appColors.textPrimary
      : _borderColor;

  Widget _labelBadge() => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 30,
        height: 30,
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
      );

  @override
  Widget build(BuildContext context) {
    final isGrid = widget.layout == AnswerTileLayout.grid;
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
          padding: isGrid
              ? const EdgeInsets.fromLTRB(14, 12, 14, 12)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: AppRadius.rMd,
            border: Border.all(color: _borderColor, width: 2),
            boxShadow: widget.state == AnswerState.idle
                ? AppShadows.card(context)
                : null,
          ),
          child: isGrid ? _gridChild() : _listChild(),
        ),
      ),
    );
  }

  // ─── Barre horizontale (liste) ────────────────────────────────────────────
  Widget _listChild() {
    return Row(
      children: [
        _labelBadge(),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.option,
            style: TextStyle(
              color: _textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_trailingIcon != null) _trailingIcon!,
      ],
    );
  }

  // ─── Carte compacte (grille) ──────────────────────────────────────────────
  Widget _gridChild() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _labelBadge(),
            const Spacer(),
            if (_trailingIcon != null) _trailingIcon!,
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Center(
            child: AutoSizeText(
              widget.option,
              textAlign: TextAlign.center,
              maxLines: 4,
              minFontSize: 11,
              style: TextStyle(
                color: _textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Affiche les réponses en grille : 2×2 pour 4 options (deux en haut, deux en
/// bas), 3 en « 2 + 1 », et une seule rangée de 2 en haut pour vrai/faux.
/// Centralise aussi le calcul d'état (idle/correct/wrong) commun aux modes.
class AnswerOptionsGrid extends StatelessWidget {
  final List<String> options;
  final bool answered;
  final String? selected;
  final bool Function(String option) isCorrect;
  final void Function(String option) onSelect;

  const AnswerOptionsGrid({
    super.key,
    required this.options,
    required this.answered,
    required this.selected,
    required this.isCorrect,
    required this.onSelect,
  });

  static const _labels = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const double _gap = 12;

  AnswerState _stateFor(String opt) {
    if (!answered) return AnswerState.idle;
    if (isCorrect(opt)) return AnswerState.correct;
    if (opt == selected) return AnswerState.wrong;
    return AnswerState.idle;
  }

  Widget _tile(int i) => AnswerOptionTile(
        layout: AnswerTileLayout.grid,
        label: _labels[i < _labels.length ? i : 0],
        option: options[i],
        state: _stateFor(options[i]),
        onTap: () => onSelect(options[i]),
      );

  @override
  Widget build(BuildContext context) {
    final n = options.length;
    final cols = n == 1 ? 1 : 2; // 2 colonnes (une seule si 1 option)
    final rowCount = (n / cols).ceil();

    // L'ensemble ne doit jamais dépasser ~la moitié de la hauteur de l'écran :
    // les tuiles ont une hauteur fixe (elles ne s'étirent pas) pour que le bloc
    // reste lisible même quand une question longue le repousse vers le bas.
    final screenH = MediaQuery.sizeOf(context).height;
    final maxTotal = screenH * 0.5;
    final rowHeight =
        ((maxTotal - (rowCount - 1) * _gap) / rowCount).clamp(74.0, 132.0);

    final rows = <Widget>[];
    for (var r = 0; r < rowCount; r++) {
      if (r > 0) rows.add(const SizedBox(height: _gap));
      rows.add(SizedBox(
        height: rowHeight,
        child: Row(
          children: [
            for (var c = 0; c < cols; c++) ...[
              if (c > 0) const SizedBox(width: _gap),
              // Cellule vide si nombre impair, pour garder l'alignement.
              Expanded(
                child: (r * cols + c) < n
                    ? _tile(r * cols + c)
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ));
    }

    // Bloc borné (≤ moitié de l'écran), ajusté à son contenu ; les écrans de
    // jeu le placent directement sous l'énoncé, dans la même zone scrollable.
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}
