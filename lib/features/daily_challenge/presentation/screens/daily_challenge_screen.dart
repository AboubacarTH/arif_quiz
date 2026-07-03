import 'package:arif_quiz/features/daily_challenge/data/daily_challenge_repository.dart';
import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart' show GamePhase, GamePlayController;
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/answer_option_tile.dart';
import 'package:arif_quiz/ui/widgets/neon_button.dart';
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
        SnackBar(content: Text(e.toString().contains('409') ? 'Vous avez déjà joué aujourd\'hui !' : 'Erreur de soumission'), backgroundColor: AppColors.error),
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
      appBar: AppBar(backgroundColor: context.appColors.bg, title: const Text('Défi Quotidien')),
      body: _daily == null ? _buildNone() : _buildInfo(),
    );
  }

  Widget _buildNone() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📅', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Pas de défi aujourd\'hui', style: TextStyle(color: context.appColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Revenez demain !', style: TextStyle(color: context.appColors.textSecondary)),
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text('🌟', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                const Text('DÉFI DU JOUR', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(d.quiz.title, style: TextStyle(color: context.appColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('${d.quiz.totalQuestions} questions', style: TextStyle(color: context.appColors.textSecondary)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: context.appColors.cardBgLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: context.appColors.textMuted),
                      const SizedBox(width: 6),
                      Text('Renouvelle dans ${h}h ${m}m', style: TextStyle(color: context.appColors.textMuted, fontSize: 12)),
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
                borderRadius: BorderRadius.circular(16),
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
                        const Text('Défi complété !', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                        Text('Votre score : ${d.myScore?.toStringAsFixed(1) ?? '?'}% • Grade ${d.myGrade ?? '?'}',
                            style: TextStyle(color: context.appColors.textSecondary, fontSize: 13)),
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
                  _bonusRow('⚡ +30 XP bonus', AppColors.accent),
                  const SizedBox(height: 8),
                  _bonusRow('🔥 Maintient ton streak', AppColors.warning),
                  const SizedBox(height: 8),
                  _bonusRow('🏆 Classement quotidien', AppColors.secondary),
                ],
              ),
            ),
            const SizedBox(height: 20),
            NeonButton(
              label: 'Relever le défi',
              width: double.infinity,
              icon: Icons.play_arrow_rounded,
              color: AppColors.accent,
              onTap: _startPlay,
            ),
          ],
        ],
      ),
    );
  }

  Widget _bonusRow(String text, Color color) => Row(
        children: [
          Text(text.split(' ')[0], style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(text.substring(text.indexOf(' ') + 1), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      );

  Widget _buildPlayScreen() {
    final ctrl = _playCtrl;
    final q = ctrl.currentQuestion;
    final opts = q.options ?? ['Vrai', 'Faux'];
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
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withValues(alpha: 0.4))),
                    child: const Text('🌟 Quotidien', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ctrl.progress,
                        backgroundColor: context.appColors.cardBg,
                        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${ctrl.index + 1}/${ctrl.questions.length}', style: TextStyle(color: context.appColors.textSecondary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: context.appColors.cardBg, borderRadius: BorderRadius.circular(20)),
                child: Text('${ctrl.timeLeft}s', style: TextStyle(color: context.appColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text('Question ${ctrl.index + 1}', style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: Text(q.text, style: TextStyle(color: context.appColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, height: 1.4))),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
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
