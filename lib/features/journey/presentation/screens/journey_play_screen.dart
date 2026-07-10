import 'package:arif_quiz/features/game_modes/bloc/game_play_controller.dart';
import 'package:arif_quiz/features/journey/data/journey_repository.dart';
import 'package:arif_quiz/features/journey/presentation/screens/journey_result_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/answer_option_tile.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/question_media.dart';
import 'package:arif_quiz/ui/widgets/quit_confirm_dialog.dart';
import 'package:arif_quiz/ui/widgets/timer_ring.dart';
import 'package:flutter/material.dart';

/// Gameplay d'un niveau du Mode Parcours. Reprend la mécanique de
/// [QuizPlayScreen] (timer par question, révélation, progression) mais charge
/// et soumet via les endpoints `journey/*`, puis affiche un écran d'étoiles.
class JourneyPlayScreen extends StatefulWidget {
  final int level;
  final bool isBoss;

  const JourneyPlayScreen({super.key, required this.level, this.isBoss = false});

  @override
  State<JourneyPlayScreen> createState() => _JourneyPlayScreenState();
}

class _JourneyPlayScreenState extends State<JourneyPlayScreen> {
  final _repo = JourneyRepository(apiService);
  GamePlayController? _ctrl;
  bool _initLoading = true;
  String? _initError;
  int? _sessionId;
  bool _submitting = false;

  Color get _accent =>
      widget.isBoss ? AppColors.error : AppColors.primary;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _initLoading = true;
      _initError = null;
    });
    try {
      final data = await _repo.startLevel(widget.level);
      _sessionId = data.sessionId;
      final ctrl = GamePlayController(
        mode: GameMode.classic,
        questions: data.questions,
        secondsPerQuestion: data.timeLimit,
      );
      ctrl.addListener(_onCtrlChange);
      if (!mounted) return;
      setState(() {
        _ctrl = ctrl;
        _initLoading = false;
      });
    } catch (e) {
      debugPrint('Journey load error: $e');
      if (!mounted) return;
      setState(() {
        _initError = 'Impossible de charger ce niveau.';
        _initLoading = false;
      });
    }
  }

  void _onCtrlChange() {
    if (!mounted) return;
    setState(() {});
    if (_ctrl?.phase == GamePhase.submitting) _submit();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    _submitting = true;

    final ctrl = _ctrl!;
    final answers = Map<String, String>.from(ctrl.answers);
    final timeTaken = ctrl.totalTime;

    if (_sessionId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Session invalide. Réessaie le niveau.'),
            backgroundColor: AppColors.error),
      );
      Navigator.pop(context);
      return;
    }

    try {
      final result = await _repo.submitLevel(
        level: widget.level,
        answers: answers,
        timeTaken: timeTaken,
        sessionId: _sessionId!,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        FadeScaleRoute(
            page: JourneyResultScreen(result: result, isBoss: widget.isBoss)),
      );
    } catch (e) {
      debugPrint('Journey submit error: $e');
      _submitting = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la soumission. Vérifie ta connexion.'),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onCtrlChange);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initLoading) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }
    if (_initError != null) {
      return Scaffold(
        backgroundColor: context.appColors.bg,
        body: ErrorState(message: _initError!, onRetry: _loadQuestions),
      );
    }

    final ctrl = _ctrl!;
    final q = ctrl.currentQuestion;
    final opts = q.options ?? ['True', 'False'];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final quit = await confirmQuitGame(context);
        if (quit && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: context.appColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (await confirmQuitGame(context) && mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: context.appColors.cardBg,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.close_rounded,
                            color: context.appColors.textSecondary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _LevelBadge(level: widget.level, isBoss: widget.isBoss, color: _accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ctrl.progress,
                          backgroundColor: context.appColors.cardBg,
                          valueColor: AlwaysStoppedAnimation(_accent),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${ctrl.index + 1}/${ctrl.questions.length}',
                        style: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 28),
                TimerRing(
                    timeLeft: ctrl.timeLeft,
                    totalTime: ctrl.secondsPerQuestion,
                    size: 80),
                const SizedBox(height: 24),
                // Média (image → audio) puis question : zone flexible/scrollable.
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (q.hasMedia)
                          QuestionMedia(
                              imageUrl: q.imageUrl, audioUrl: q.audioUrl),
                        Text('Question ${ctrl.index + 1}',
                            style: TextStyle(
                                color: _accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Text(q.text,
                            style: TextStyle(
                                color: context.appColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                fontFamily: 'Nunito')),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                // Réponses (bornées ≤ moitié de l'écran, ancrées en bas)
                AnswerOptionsGrid(
                  options: opts,
                  answered: ctrl.answered,
                  selected: ctrl.selected,
                  isCorrect: (o) => q.isCorrect(o),
                  onSelect: ctrl.selectAnswer,
                ),
                if (!ctrl.answered)
                  TextButton(
                    onPressed: ctrl.skip,
                    child: Text('Passer →',
                        style: TextStyle(
                            color: context.appColors.textMuted, fontSize: 14)),
                  )
                else
                  const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final bool isBoss;
  final Color color;
  const _LevelBadge(
      {required this.level, required this.isBoss, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isBoss ? '👑' : '🎯', style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(isBoss ? 'BOSS $level' : 'Niv. $level',
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}
