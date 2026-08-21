import 'package:arif_quiz/features/daily_challenge/data/daily_challenge_repository.dart';
import 'package:arif_quiz/core/i18n/true_false_l10n.dart';
import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart' show GamePhase, GamePlayController;
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/answer_option_tile.dart';
import 'package:arif_quiz/ui/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final _dailyRepo = DailyChallengeRepository(apiService);
  final _quizRepo = QuizRepository(apiService);

  DailyChallengeModel? _daily;
  bool _loading = true;

  // Play state
  bool _playing = false;
  bool _submitting = false;
  late GamePlayController _playCtrl;

  @override
  void initState() {
    super.initState();
    _loadDaily();
  }

  Future<void> _loadDaily() async {
    try {
      _daily = await _dailyRepo.getToday();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _startPlay() async {
    setState(() => _loading = true);
    try {
      final data = await _quizRepo.getQuizQuestions(_daily!.quiz.id);
      _playCtrl = GamePlayController(
        mode: GameMode.classic,
        questions: data.questions,
        secondsPerQuestion: data.timeLimit,
      );
      _playCtrl.addListener(() {
        if (!mounted) return;
        setState(() {});
        if (_playCtrl.phase == GamePhase.submitting) _submit();
      });
      setState(() {
        _playing = true;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final result = await _dailyRepo.submit(
        answers: Map<String, String>.from(_playCtrl.answers),
        timeTaken: _playCtrl.totalTime,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        FadeScaleRoute(page: QuizResultScreen(result: result, quiz: _daily!.quiz)),
      );
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().contains('409') ? AppLocalizations.of(context).alreadyPlayedToday : AppLocalizations.of(context).submitError), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    if (_playing) _playCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: context.appColors.bg, body: const Center(child: CircularProgressIndicator(color: AppColors.accent)));

    if (_playing && !_submitting) return _buildPlayScreen();

    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(backgroundColor: context.appColors.bg, title: Text(AppLocalizations.of(context).dailyChallengeScreenTitle)),
      body: _daily == null ? _buildNone() : _buildInfo(),
    );
  }

  Widget _buildNone() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(AppLocalizations.of(context).noDailyToday, style: context.type.titleLarge.copyWith(color: context.appColors.textPrimary)),
            SizedBox(height: 8),
            Text(AppLocalizations.of(context).comeBackTomorrow, style: TextStyle(color: context.appColors.textSecondary)),
          ],
        ),
      );

  Widget _buildInfo() {
    final d = _daily!;
    final h = d.secondsUntilReset ~/ 3600;
    final m = (d.secondsUntilReset % 3600) ~/ 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                size: 40, color: AppColors.secondary),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context).todaysChallengeTag, style: context.type.labelMedium.copyWith(color: AppColors.accent, fontWeight: FontWeight.w800, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(d.quiz.title, style: context.type.headlineLarge.copyWith(color: context.appColors.textPrimary), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: context.appColors.cardBgLight, borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: context.appColors.textMuted),
                      const SizedBox(width: 6),
                      Text(AppLocalizations.of(context).renewsIn(h, m), style: context.type.labelMedium.copyWith(color: context.appColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 20),
          if (d.alreadyPlayed) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).challengeCompleted, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                        Text(AppLocalizations.of(context).yourScoreGrade(d.myScore?.toStringAsFixed(1) ?? '?', d.myGrade ?? '?'),
                            style: context.type.bodyMedium.copyWith(color: context.appColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.cardElevated,
                borderRadius: AppRadius.rLg,
                boxShadow: AppShadows.card(context),
              ),
              child: Column(
                children: [
                  _bonusRow(Icons.auto_awesome_rounded,
                      AppLocalizations.of(context).bonusXp30, AppColors.accent),
                  const SizedBox(height: 8),
                  _bonusRow(
                      Icons.local_fire_department_rounded,
                      AppLocalizations.of(context).bonusKeepsStreak,
                      AppColors.warning),
                  const SizedBox(height: 8),
                  _bonusRow(
                      Icons.emoji_events_rounded,
                      AppLocalizations.of(context).bonusDailyLeaderboard,
                      AppColors.secondary),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: AppLocalizations.of(context).takeChallenge,
              fullWidth: true,
              icon: Icons.play_arrow_rounded,
              tint: AppColors.accent,
              onPressed: _startPlay,
            ),
          ],
        ],
      ),
    );
  }

  /// L'icône est un paramètre à part : l'ancienne version découpait la chaîne
  /// au premier espace pour en extraire l'emoji, ce qui cassait dès qu'une
  /// traduction commençait par autre chose.
  Widget _bonusRow(IconData icon, String text, Color color) => Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: context.type.bodyLarge
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      );

  Widget _buildPlayScreen() {
    final ctrl = _playCtrl;
    final q = ctrl.currentQuestion;
    final opts = q.choices(context);
    final labels = ['A', 'B', 'C', 'D'];

    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.accent.withValues(alpha: 0.4))),
                    child: Text(AppLocalizations.of(context).dailyTag, style: context.type.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: LinearProgressIndicator(
                        value: ctrl.progress,
                        backgroundColor: context.appColors.cardBg,
                        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${ctrl.index + 1}/${ctrl.questions.length}', style: context.type.bodyMedium.copyWith(color: context.appColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: context.appColors.cardBg, borderRadius: BorderRadius.circular(AppRadius.lg)),
                child: Text('${ctrl.timeLeft}s', style: context.type.headlineMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 20),
              Align(alignment: AlignmentDirectional.centerStart, child: Text(AppLocalizations.of(context).questionNumber(ctrl.index + 1), style: context.type.labelMedium.copyWith(color: AppColors.accent, letterSpacing: 0.5))),
              const SizedBox(height: 8),
              Align(alignment: AlignmentDirectional.centerStart, child: Text(q.text, style: context.type.headlineMedium.copyWith(color: context.appColors.textPrimary, height: 1.4))),
              // Les réponses suivent directement l'énoncé, séparées par une
              // respiration ; elles défilent si elles ne tiennent pas.
              const SizedBox(height: AppSpacing.questionToAnswers),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: opts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final opt = opts[i];
                    return AnswerOptionTile(
                      label: labels[i < labels.length ? i : 0],
                      option: opt,
                      state: !ctrl.answered ? AnswerState.idle : (ctrl.selected == opt ? AnswerState.selected : AnswerState.idle),
                      onTap: () => ctrl.selectAnswer(opt),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
