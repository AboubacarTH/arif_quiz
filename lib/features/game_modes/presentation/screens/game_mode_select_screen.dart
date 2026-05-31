import 'package:arif_quiz/features/game_modes/presentation/screens/speed_play_screen.dart';
import 'package:arif_quiz/features/game_modes/presentation/screens/survival_play_screen.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_play_screen.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/game_mode_card.dart';
import 'package:arif_quiz/ui/widgets/neon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameModeSelectScreen extends StatefulWidget {
  final QuizModel quiz;
  final GameMode? forcedMode;
  final int? challengeId;

  const GameModeSelectScreen({
    super.key,
    required this.quiz,
    this.forcedMode,
    this.challengeId,
  });

  @override
  State<GameModeSelectScreen> createState() => _GameModeSelectScreenState();
}

class _GameModeSelectScreenState extends State<GameModeSelectScreen> {
  late GameMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.forcedMode ?? GameMode.classic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: const Text('Choisir le mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.appColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A4A)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.quiz_rounded, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.quiz.title, style: TextStyle(color: context.appColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${widget.quiz.totalQuestions} questions • ${widget.quiz.difficulty}',
                            style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
            const SizedBox(height: 24),
            Text('Mode de jeu', style: TextStyle(color: context.appColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...GameMode.values.map((m) {
              final locked = widget.forcedMode != null && m != widget.forcedMode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Opacity(
                  opacity: locked ? 0.4 : 1.0,
                  child: GameModeCard(
                    mode: m,
                    selected: _selected == m,
                    onTap: locked ? () {} : () => setState(() => _selected = m),
                  ),
                ),
              );
            }),
            const Spacer(),
            NeonButton(
              label: 'Jouer',
              width: double.infinity,
              icon: Icons.play_arrow_rounded,
              color: AppColors.modeColor(_selected.apiValue),
              onTap: _startGame,
            ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    final screen = switch (_selected) {
      GameMode.survival => SurvivalPlayScreen(quiz: widget.quiz, challengeId: widget.challengeId),
      GameMode.speed => SpeedPlayScreen(quiz: widget.quiz, challengeId: widget.challengeId),
      GameMode.classic => QuizPlayScreen(quiz: widget.quiz, challengeId: widget.challengeId),
    };
    Navigator.pushReplacement(context, SlideRightRoute(page: screen));
  }
}
