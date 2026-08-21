import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/features/game_modes/presentation/widgets/question_stage.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/quit_confirm_dialog.dart';
import 'package:arif_quiz/ui/widgets/timer_ring.dart';
import 'package:flutter/material.dart';

/// Le mode Précision : +2 pour une bonne réponse, −1 pour une mauvaise, 0 pour
/// une question qu'on laisse passer.
///
/// C'est le premier mode où renoncer est un coup à jouer. L'écran met donc deux
/// choses sous les yeux en permanence : le total qui monte et descend, et le
/// bouton « Passer » — qui n'est plus un lien discret en bas de page comme dans
/// les autres modes, mais l'autre moitié de la décision.
class PrecisionPlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final int? challengeId;
  final ChallengeModel? challenge;

  const PrecisionPlayScreen({
    super.key,
    required this.quiz,
    this.challengeId,
    this.challenge,
  });

  @override
  State<PrecisionPlayScreen> createState() => _PrecisionPlayScreenState();
}

class _PrecisionPlayScreenState extends State<PrecisionPlayScreen> {
  static const _accent = AppColors.modePrecision;

  final _repo = QuizRepository(apiService);
  GamePlayController? _ctrl;
  bool _loading = true;
  bool _failed = false;
  bool _submitting = false;
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final List<QuestionModel> questions;
      final int timeLimit;
      if (widget.challengeId != null) {
        final data = await ChallengeRepository(apiService)
            .getChallengeQuestions(widget.challengeId!);
        questions = data.questions;
        timeLimit = data.timeLimit;
        _sessionId = data.sessionId;
      } else {
        final data = await _repo.getQuizQuestions(widget.quiz.id);
        questions = data.questions;
        timeLimit = data.timeLimit;
        _sessionId = data.sessionId;
      }

      final ctrl = GamePlayController(
        mode: GameMode.precision,
        questions: questions,
        secondsPerQuestion: timeLimit,
      );
      ctrl.addListener(_onChange);
      setState(() {
        _ctrl = ctrl;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Precision load error: $e');
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    if (_ctrl?.phase == GamePhase.submitting) _submit();
  }

  Future<void> _submit() async {
    final ctrl = _ctrl!;
    if (_submitting) return;
    setState(() => _submitting = true);

    final answers = Map<String, String>.from(ctrl.answers);
    final questionIds = ctrl.questions.map((q) => q.id).toList();

    if (isGuest.value) {
      final result = QuizAttemptResult.fromLocalScoring(
        questions: ctrl.questions,
        answers: answers,
        timeTaken: ctrl.totalTime,
        mode: GameMode.precision,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        FadeScaleRoute(
            page: QuizResultScreen(
                result: result, quiz: widget.quiz, guestMode: true)),
      );
      return;
    }

    try {
      QuizAttemptResult result;
      if (widget.challengeId != null) {
        result = await ChallengeRepository(apiService).submitChallenge(
          challengeId: widget.challengeId!,
          answers: answers,
          timeTaken: ctrl.totalTime,
          questionIds: questionIds,
          sessionId: _sessionId,
        );
      } else {
        result = await _repo.submitQuiz(
          quizId: widget.quiz.id,
          answers: answers,
          timeTaken: ctrl.totalTime,
          questionIds: questionIds,
          mode: GameMode.precision.apiValue,
          sessionId: _sessionId,
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        FadeScaleRoute(
            page: QuizResultScreen(
                result: result,
                quiz: widget.quiz,
                challenge: widget.challenge)),
      );
    } catch (e) {
      debugPrint('Precision submit error: $e');
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).submitError),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onChange);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: const Center(child: CircularProgressIndicator(color: _accent)),
      );
    }
    if (_failed) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: ErrorState(
            message: AppLocalizations.of(context).loadQuestionsError,
            onRetry: _loadQuestions),
      );
    }
    if (_submitting) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: _accent),
              const SizedBox(height: AppSpacing.lg),
              Text(AppLocalizations.of(context).calculatingResults,
                  style: context.type.bodyLarge
                      .copyWith(color: context.appColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final ctrl = _ctrl!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final quit = await confirmQuitGame(context);
        if (!context.mounted) return;
        if (quit) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: context.appColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                _topBar(ctrl),
                const SizedBox(height: AppSpacing.lg),
                _tallyRow(ctrl),
                const SizedBox(height: AppSpacing.xl),
                TimerRing(
                    timeLeft: ctrl.timeLeft,
                    totalTime: ctrl.currentSeconds,
                    size: 80),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                    child: QuestionStage(controller: ctrl, accent: _accent)),
                _passButton(ctrl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Bandeau ──────────────────────────────────────────────────────────────

  Widget _topBar(GamePlayController ctrl) => Row(
        children: [
          GestureDetector(
            onTap: () async {
              // Ici `context` est celui du State : c'est `mounted` du State qui
              // le garde, pas `context.mounted`.
              final quit = await confirmQuitGame(context);
              if (!mounted) return;
              if (quit) Navigator.pop(context);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.appColors.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.close_rounded,
                  color: context.appColors.textSecondary, size: 18),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: LinearProgressIndicator(
                value: ctrl.progress,
                backgroundColor: context.appColors.cardBg,
                valueColor: const AlwaysStoppedAnimation(_accent),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('${ctrl.index + 1}/${ctrl.questions.length}',
              style: context.type.bodyMedium.copyWith(
                  color: context.appColors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ],
      );

  /// Le total, et ce que la question vient de lui faire. C'est toute la tension
  /// du mode : on doit pouvoir la lire sans quitter la question des yeux.
  Widget _tallyRow(GamePlayController ctrl) {
    final points = ctrl.modePoints ?? 0;
    final max = ctrl.maxModePoints ?? 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 6),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.12),
            borderRadius: AppRadius.rPill,
            border: Border.all(color: _accent.withValues(alpha: 0.4)),
          ),
          child: Text(
            AppLocalizations.of(context)
                .precisionTally(ModeScoring.format(points), max),
            style: context.type.titleMedium.copyWith(
                color: _accent,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ),
        const Spacer(),
        _deltaPill(ctrl),
      ],
    );
  }

  Widget _deltaPill(GamePlayController ctrl) {
    final outcome = ctrl.currentOutcome;
    // La place reste prise même sans pastille : sinon la ligne se réorganise à
    // chaque réponse et l'énoncé saute d'un cran.
    if (outcome == null) return const SizedBox(height: 30);

    final (label, color) = switch (outcome) {
      AnswerOutcome.right => ('+${ModeScoring.precisionReward}', AppColors.success),
      AnswerOutcome.wrong => ('−${ModeScoring.precisionPenalty}', AppColors.error),
      AnswerOutcome.skipped => ('0', context.appColors.textMuted),
    };

    return Container(
      height: 30,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.rPill,
      ),
      child: Text(label,
          style: context.type.titleMedium
              .copyWith(color: color, fontWeight: FontWeight.w800)),
    );
  }

  // ─── Passer ───────────────────────────────────────────────────────────────

  /// Ailleurs « Passer » est une sortie de secours. Ici c'est un coup à part
  /// entière — il mérite un vrai bouton, et qu'on rappelle ce qu'il coûte.
  Widget _passButton(GamePlayController ctrl) {
    if (ctrl.answered) return const SizedBox(height: 72);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: ctrl.skip,
              icon: const Icon(Icons.redo_rounded, size: 18),
              label: Text(AppLocalizations.of(context).skip),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appColors.textSecondary,
                side: BorderSide(color: context.appColors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(AppLocalizations.of(context).precisionSkipHint,
              style: context.type.labelSmall
                  .copyWith(color: context.appColors.textMuted)),
        ],
      ),
    );
  }
}
