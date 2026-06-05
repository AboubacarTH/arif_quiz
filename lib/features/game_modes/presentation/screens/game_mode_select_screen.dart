import 'package:arif_quiz/features/game_modes/presentation/screens/speed_play_screen.dart';
import 'package:arif_quiz/features/game_modes/presentation/screens/survival_play_screen.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_play_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/game_mode_card.dart';
import 'package:arif_quiz/ui/widgets/neon_button.dart';
import 'package:arif_quiz/ui/widgets/paywall_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameModeSelectScreen extends StatefulWidget {
  final QuizModel? quiz;
  final GameMode? forcedMode;
  final int? challengeId;
  final String? challengeSourceLabel;
  final ChallengeModel? challenge;

  const GameModeSelectScreen({
    super.key,
    this.quiz,
    this.forcedMode,
    this.challengeId,
    this.challengeSourceLabel,
    this.challenge,
  });

  @override
  State<GameModeSelectScreen> createState() => _GameModeSelectScreenState();
}

class _GameModeSelectScreenState extends State<GameModeSelectScreen> {
  late GameMode _selected;

  Color get _modeColor => AppColors.modeColor(_selected.apiValue);

  @override
  void initState() {
    super.initState();
    _selected = widget.forcedMode ?? GameMode.classic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuizCard(),
                    const SizedBox(height: 28),
                    _buildModeLabel(),
                    const SizedBox(height: 12),
                    ...GameMode.values.map((m) {
                      final locked = widget.forcedMode != null &&
                          m != widget.forcedMode;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Opacity(
                          opacity: locked ? 0.35 : 1.0,
                          child: GameModeCard(
                            mode: m,
                            selected: _selected == m,
                            onTap: locked
                                ? () {}
                                : () => setState(() => _selected = m),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    _buildPreviewBanner(),
                  ],
                ),
              ),
            ),
            _buildPlayButton(),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: context.appColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.appColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.appColors.textSecondary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Choisir le mode',
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ─── Quiz info card ──────────────────────────────────────────────────────────

  Widget _buildQuizCard() {
    final displayTitle = widget.challengeSourceLabel
        ?? widget.quiz?.title
        ?? '10 questions aléatoires';
    final diff = widget.quiz?.difficulty;
    final diffColor = diff != null ? AppColors.difficultyColor(diff) : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _InfoChip(
                      label: '10 questions',
                      icon: Icons.help_outline_rounded,
                      color: AppColors.primary,
                    ),
                    if (diff != null) ...[
                      const SizedBox(width: 6),
                      _InfoChip(
                        label: diff,
                        icon: Icons.bar_chart_rounded,
                        color: diffColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.08);
  }

  // ─── Section label ───────────────────────────────────────────────────────────

  Widget _buildModeLabel() => Text(
        'Mode de jeu',
        style: TextStyle(
          color: context.appColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ).animate().fadeIn(delay: 100.ms);

  // ─── Preview banner ──────────────────────────────────────────────────────────

  Widget _buildPreviewBanner() {
    final info = switch (_selected) {
      GameMode.classic => (
          icon: '🎮',
          title: 'Mode Classique',
          body: '10 questions aléatoires · Timer par question · Score en %',
        ),
      GameMode.survival => (
          icon: '❤️',
          title: 'Mode Survie',
          body:
              '10 questions · Une mauvaise réponse et c\'est terminé · Bonus ×1.3',
        ),
      GameMode.speed => (
          icon: '⚡',
          title: 'Speed Round',
          body: '10 questions · 5 secondes par question · Bonus XP ×1.5',
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(_selected),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _modeColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _modeColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text(info.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: TextStyle(
                      color: _modeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.body,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Play button ─────────────────────────────────────────────────────────────

  Widget _buildPlayButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: NeonButton(
        label: 'Jouer en mode ${_selected.label}',
        width: double.infinity,
        icon: Icons.play_arrow_rounded,
        color: _modeColor,
        onTap: _startGame,
      ),
    );
  }

  // ─── Logic ───────────────────────────────────────────────────────────────────

  void _startGame() {
    monetizationController.requestPlay(
      onGranted: _launchScreen,
      onNoAd: () => PaywallSheet.show(
        context,
        ctrl: monetizationController,
        onGranted: _launchScreen,
      ),
    );
  }

  void _launchScreen() {
    final quiz = widget.quiz ?? QuizModel.fromJson(
        {'id': 0, 'title': '', 'difficulty': 'medium', 'time_limit': 30, 'total_questions': 0, 'play_count': 0});
    final screen = switch (_selected) {
      GameMode.survival =>
        SurvivalPlayScreen(quiz: quiz, challengeId: widget.challengeId, challenge: widget.challenge),
      GameMode.speed =>
        SpeedPlayScreen(quiz: quiz, challengeId: widget.challengeId, challenge: widget.challenge),
      GameMode.classic =>
        QuizPlayScreen(quiz: quiz, challengeId: widget.challengeId, challenge: widget.challenge),
    };
    if (mounted) {
      Navigator.pushReplacement(context, SlideRightRoute(page: screen));
    }
  }
}

// ─── Info chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 11),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}
