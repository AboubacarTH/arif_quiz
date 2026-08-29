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

/// Le squelette d'un écran de jeu : charger les questions, tenir la partie,
/// soumettre, montrer le résultat.
///
/// Ces cent cinquante lignes étaient recopiées dans chaque mode. Elles l'ont
/// déjà été quatre fois — et le cinquième exemplaire, le défi du jour, avait
/// fini par diverger sans que personne le remarque : il perdait le média des
/// questions et ne révélait jamais la bonne réponse. La scène de jeu a été
/// mise en commun à ce moment-là ; ce qui l'entoure ne l'était pas encore.
///
/// Un mode n'a plus qu'à dire ce qui lui est propre : sa couleur, la façon dont
/// il monte son contrôleur, le bandeau qu'il pose au-dessus de la question et
/// ce qu'il met dessous.
abstract class ModePlayScreen extends StatefulWidget {
  final QuizModel quiz;
  final int? challengeId;
  final ChallengeModel? challenge;

  const ModePlayScreen({
    super.key,
    required this.quiz,
    this.challengeId,
    this.challenge,
  });
}

abstract class ModePlayScreenState<W extends ModePlayScreen> extends State<W> {
  // ─── Ce que chaque mode doit fournir ──────────────────────────────────────

  GameMode get mode;

  Color get accent;

  /// Monte la partie. [timeLimit] est le temps par question annoncé par le
  /// serveur ; un mode à horloge globale peut l'ignorer.
  GamePlayController createController(
    List<QuestionModel> questions,
    int timeLimit,
  );

  // ─── Ce qu'il peut ajouter ────────────────────────────────────────────────

  /// Le bandeau propre au mode, entre la barre de progression et le chrono.
  Widget buildBanner(GamePlayController ctrl) => const SizedBox.shrink();

  /// Le chrono. Un mode à horloge globale préfère souvent autre chose qu'un
  /// anneau de trente secondes.
  Widget buildTimer(GamePlayController ctrl) => TimerRing(
        timeLeft: ctrl.timeLeft,
        totalTime: ctrl.currentSeconds,
        size: 80,
      );

  /// Ce qui se pose sous la question : bouton « Passer », barre de jokers…
  Widget buildFooter(GamePlayController ctrl) => const SizedBox.shrink();

  /// Coups de pouce consommés, à transmettre au serveur : il ne peut pas les
  /// deviner à partir des réponses.
  int get jokersUsed => 0;

  /// Choix à retirer de la grille — le joker 50/50 s'en sert.
  Set<String> get hiddenOptions => const {};

  // ─── La mécanique commune ─────────────────────────────────────────────────

  final _repo = QuizRepository(apiService);
  GamePlayController? controller;
  bool _loading = true;
  bool _failed = false;
  bool _submitting = false;
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
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

      final ctrl = createController(questions, timeLimit);
      ctrl.addListener(_onChange);
      setState(() {
        controller = ctrl;
        _loading = false;
      });
    } catch (e) {
      debugPrint('${mode.apiValue} load error: $e');
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    if (controller?.phase == GamePhase.submitting) _submit();
  }

  Future<void> _submit() async {
    final ctrl = controller!;
    if (_submitting) return;
    setState(() => _submitting = true);

    final answers = Map<String, String>.from(ctrl.answers);
    final questionIds = ctrl.questions.map((q) => q.id).toList();

    // Invité : notation locale, aucune soumission — donc aucun impact XP,
    // classement ou statistiques.
    if (isGuest.value) {
      final result = QuizAttemptResult.fromLocalScoring(
        questions: ctrl.questions,
        answers: answers,
        timeTaken: ctrl.totalTime,
        mode: mode,
        jokersUsed: jokersUsed,
      );
      if (!mounted) return;
      _openResult(result, guest: true);
      return;
    }

    try {
      final QuizAttemptResult result;
      if (widget.challengeId != null) {
        result = await ChallengeRepository(apiService).submitChallenge(
          challengeId: widget.challengeId!,
          answers: answers,
          timeTaken: ctrl.totalTime,
          questionIds: questionIds,
          sessionId: _sessionId,
          jokersUsed: jokersUsed,
        );
      } else {
        result = await _repo.submitQuiz(
          quizId: widget.quiz.id,
          answers: answers,
          timeTaken: ctrl.totalTime,
          questionIds: questionIds,
          mode: mode.apiValue,
          sessionId: _sessionId,
          jokersUsed: jokersUsed,
        );
      }
      if (!mounted) return;
      _openResult(result);
    } catch (e) {
      debugPrint('${mode.apiValue} submit error: $e');
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).submitError),
            backgroundColor: AppColors.error),
      );
    }
  }

  void _openResult(QuizAttemptResult result, {bool guest = false}) {
    Navigator.pushReplacement(
      context,
      FadeScaleRoute(
        page: QuizResultScreen(
          result: result,
          quiz: widget.quiz,
          guestMode: guest,
          challenge: guest ? null : widget.challenge,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.removeListener(_onChange);
    controller?.dispose();
    super.dispose();
  }

  // ─── Rendu ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: Center(child: CircularProgressIndicator(color: accent)),
      );
    }

    if (_failed) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: ErrorState(
            message: AppLocalizations.of(context).loadQuestionsError,
            onRetry: loadQuestions),
      );
    }

    if (_submitting) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: accent),
              const SizedBox(height: AppSpacing.lg),
              Text(AppLocalizations.of(context).calculatingResults,
                  style: context.type.bodyLarge
                      .copyWith(color: context.appColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final ctrl = controller!;

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
                _progressBar(ctrl),
                buildBanner(ctrl),
                const SizedBox(height: AppSpacing.xl),
                buildTimer(ctrl),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: QuestionStage(
                    controller: ctrl,
                    accent: accent,
                    hiddenOptions: hiddenOptions,
                  ),
                ),
                buildFooter(ctrl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _progressBar(GamePlayController ctrl) => Row(
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
                valueColor: AlwaysStoppedAnimation(accent),
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
}

/// Une pastille de bandeau : la même forme pour le total du mode, la série en
/// cours ou le temps restant.
class ModeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  const ModeBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: filled ? 0.20 : 0.12),
        borderRadius: AppRadius.rPill,
        border: filled ? Border.all(color: color.withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: context.type.titleMedium
                .copyWith(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
