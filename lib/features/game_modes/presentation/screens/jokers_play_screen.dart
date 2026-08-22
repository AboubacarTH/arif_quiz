import 'dart:math';

import 'package:arif_quiz/core/i18n/true_false_l10n.dart';
import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/features/game_modes/presentation/screens/mode_play_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Le mode Jokers : trois coups de pouce pour la manche, chacun coûte un point.
///
/// La tension du mode n'est pas dans la question mais dans la réserve : un
/// joker dépensé trop tôt manquera plus tard. La barre du bas montre donc les
/// trois en permanence, consommés ou non, plutôt que de les faire disparaître.
class JokersPlayScreen extends ModePlayScreen {
  const JokersPlayScreen({
    super.key,
    required super.quiz,
    super.challengeId,
    super.challenge,
  });

  @override
  State<JokersPlayScreen> createState() => _JokersPlayScreenState();
}

enum _Joker { fiftyFifty, hint, time }

class _JokersPlayScreenState extends ModePlayScreenState<JokersPlayScreen> {
  final _spent = <_Joker>{};

  /// Les choix écartés par le 50/50, pour la question en cours seulement.
  Set<String> _hidden = const {};
  int _hiddenForIndex = -1;

  @override
  GameMode get mode => GameMode.jokers;

  @override
  Color get accent => AppColors.modeJokers;

  @override
  int get jokersUsed => _spent.length;

  @override
  Set<String> get hiddenOptions =>
      controller?.index == _hiddenForIndex ? _hidden : const {};

  @override
  GamePlayController createController(
    List<QuestionModel> questions,
    int timeLimit,
  ) =>
      GamePlayController(
        mode: GameMode.jokers,
        questions: questions,
        secondsPerQuestion: timeLimit,
      );

  // ─── Bandeau ──────────────────────────────────────────────────────────────

  @override
  Widget buildBanner(GamePlayController ctrl) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Row(
          children: [
            ModeBadge(
              label: AppLocalizations.of(context).modeTally(
                  ModeScoring.format(ctrl.modePoints ?? 0),
                  ctrl.maxModePoints ?? 0),
              color: accent,
              filled: true,
            ),
            const Spacer(),
            ModeBadge(
              label: AppLocalizations.of(context).jokerCountBadge(ctrl.jokersLeft),
              color: ctrl.jokersLeft > 0 ? accent : context.appColors.textMuted,
              icon: Icons.auto_awesome_rounded,
            ),
          ],
        ),
      );

  // ─── Les trois coups de pouce ─────────────────────────────────────────────

  @override
  Widget buildFooter(GamePlayController ctrl) => Padding(
        padding:
            const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: _jokerButton(
                ctrl,
                joker: _Joker.fiftyFifty,
                icon: Icons.hdr_strong_rounded,
                label: '50/50',
                onUse: () => _useFiftyFifty(ctrl),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _jokerButton(
                ctrl,
                joker: _Joker.hint,
                icon: Icons.lightbulb_outline_rounded,
                label: AppLocalizations.of(context).jokerHintLabel,
                onUse: () => _useHint(ctrl),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _jokerButton(
                ctrl,
                joker: _Joker.time,
                icon: Icons.more_time_rounded,
                label: AppLocalizations.of(context)
                    .jokerTimeLabel(ModeScoring.jokerTimeBonus),
                onUse: () => _useTime(ctrl),
              ),
            ),
          ],
        ),
      );

  Widget _jokerButton(
    GamePlayController ctrl, {
    required _Joker joker,
    required IconData icon,
    required String label,
    required VoidCallback onUse,
  }) {
    final spent = _spent.contains(joker);
    // Après la réponse, un coup de pouce n'a plus d'objet : le bouton reste en
    // place mais s'éteint, pour que la barre ne change pas de hauteur.
    final usable = !spent && !ctrl.answered && ctrl.phase == GamePhase.playing;
    final color = spent ? context.appColors.textMuted : accent;

    return Opacity(
      opacity: usable ? 1 : 0.45,
      child: OutlinedButton(
        onPressed: usable ? onUse : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.labelSmall
                    .copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ─── Ce que chacun fait ───────────────────────────────────────────────────

  /// Deux mauvaises réponses disparaissent. La bonne reste, évidemment — et si
  /// la question n'a que deux choix, il n'y a rien à retirer.
  void _useFiftyFifty(GamePlayController ctrl) {
    final question = ctrl.currentQuestion;
    final choices = question.choices(context);
    final wrong = choices.where((o) => !question.isCorrect(o)).toList();
    if (wrong.length < 2) return;

    if (!ctrl.useJoker()) return;

    wrong.shuffle(Random());
    setState(() {
      _spent.add(_Joker.fiftyFifty);
      _hidden = wrong.take(wrong.length - 1).toSet();
      _hiddenForIndex = ctrl.index;
    });
  }

  /// La première lettre de la bonne réponse : assez pour départager deux
  /// candidats, pas assez pour se passer de réfléchir.
  void _useHint(GamePlayController ctrl) {
    final answer = ctrl.currentQuestion.correctAnswer?.trim() ?? '';
    if (answer.isEmpty) return;

    if (!ctrl.useJoker()) return;

    setState(() => _spent.add(_Joker.hint));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)
            .hintFirstLetter(answer.characters.first.toUpperCase())),
        backgroundColor: accent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _useTime(GamePlayController ctrl) {
    if (!ctrl.useJoker()) return;

    setState(() => _spent.add(_Joker.time));
    ctrl.addSeconds(ModeScoring.jokerTimeBonus);
  }
}
