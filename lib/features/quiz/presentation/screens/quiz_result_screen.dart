import 'package:arif_quiz/features/auth/presentation/screens/login_screen.dart';
import 'package:arif_quiz/features/auth/presentation/screens/register_screen.dart';
import 'package:arif_quiz/features/challenges/presentation/screens/challenge_detail_screen.dart';
import 'package:arif_quiz/features/home/presentation/screens/main_navigation.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:arif_quiz/features/quiz/presentation/widgets/share_score_button.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/painters/background_painter.dart';
import 'package:arif_quiz/ui/widgets/app_button.dart';
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizAttemptResult result;
  final QuizModel quiz;
  final bool guestMode;
  final ChallengeModel? challenge;
  final bool training;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.quiz,
    this.guestMode = false,
    this.challenge,
    this.training = false,
  });

  @override
  Widget build(BuildContext context) {
    final grade = result.grade;
    final gradeColor = AppColors.gradeColor(grade);
    final scoreRatio = result.score / 100;

    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  children: [
                    // Score arc + grade
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(180, 180),
                            painter: ScoreArcPainter(
                                score: scoreRatio,
                                color: gradeColor,
                                strokeWidth: 14),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(grade,
                                  style: TextStyle(
                                      color: gradeColor,
                                      fontSize: 52,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Nunito')),
                              Text('${result.score.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      color: gradeColor.withValues(alpha: 0.7),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_headline(context, result.score),
                        style: TextStyle(
                            color: context.appColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Nunito')),
                    const SizedBox(height: 4),
                    Text(quiz.title,
                        style: TextStyle(
                            color: context.appColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 24),

                    if (training)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Text('🎯', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).trainingResultNote,
                                style: TextStyle(
                                    color: context.appColors.textSecondary,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Stats row
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: context.cardElevated,
                          borderRadius: AppRadius.rLg,
                          boxShadow: AppShadows.card(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(
                              '${result.correctCount}/${result.totalQuestions}',
                              AppLocalizations.of(context).correctLabel,
                              AppColors.success),
                          _divider(context),
                          _Stat('+${result.pointsEarned}', AppLocalizations.of(context).points,
                              AppColors.warning),
                          _divider(context),
                          _Stat(_fmtTime(result.timeTaken), AppLocalizations.of(context).timeLabel,
                              AppColors.info),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    ShareScoreButton(
                        result: result, quiz: quiz, challenge: challenge),
                    const SizedBox(height: 24),

                    // Review
                    Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(AppLocalizations.of(context).answerReview,
                            style: TextStyle(
                                color: context.appColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700))),
                    const SizedBox(height: 12),
                    ...result.results.map((r) => _ReviewCard(r, canReport: !guestMode)),
                  ],
                ),
              ),
            ),

            // Guest banner
            if (guestMode)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    Text(
                      '🏆 Sauvegarde ta progression !',
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Crée un compte pour suivre tes scores\net débloquer toutes les fonctionnalités.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: context.appColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              isGuest.value = false;
                              Navigator.pushAndRemoveUntil(
                                context,
                                FadeScaleRoute(page: const RegisterScreen()),
                                (_) => false,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                AppLocalizations.of(context).createAccount,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              isGuest.value = false;
                              Navigator.pushAndRemoveUntil(
                                context,
                                FadeScaleRoute(page: const LoginScreen()),
                                (_) => false,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: context.cardElevated,
                                borderRadius: AppRadius.rSm,
                                boxShadow: AppShadows.card(context),
                              ),
                              child: Text(
                                AppLocalizations.of(context).logIn,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: context.appColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Bottom actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
              decoration: BoxDecoration(
                color: context.appColors.bg,
                border: Border(top: BorderSide(color: context.appColors.cardBgLight)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppLocalizations.of(context).homeLabel,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          FadeScaleRoute(page: const MainNavigation()),
                          (_) => false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: challenge != null
                        ? AppButton(
                            label: AppLocalizations.of(context).viewChallenge,
                            icon: Icons.leaderboard_rounded,
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              SlideRightRoute(
                                page: ChallengeDetailScreen(
                                  challenge: challenge!.copyWithCompleted(),
                                ),
                              ),
                            ),
                          )
                        : AppButton(
                            label: AppLocalizations.of(context).replay,
                            icon: Icons.replay_rounded,
                            onPressed: () => Navigator.pushReplacement(
                                context,
                                SlideRightRoute(
                                    page: QuizDetailScreen(quizId: quiz.id))),
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

  String _headline(BuildContext context, double s) {
    final l10n = AppLocalizations.of(context);
    if (s >= 90) return l10n.headlineOutstanding;
    if (s >= 80) return l10n.headlineExcellent;
    if (s >= 70) return l10n.headlineGreat;
    if (s >= 60) return l10n.headlineNotBad;
    if (s >= 50) return l10n.headlineKeepGoing;
    return l10n.headlineTryAgain;
  }

  String _fmtTime(int s) => s < 60 ? '${s}s' : '${s ~/ 60}m ${s % 60}s';

  Widget _divider(BuildContext context) =>
      Container(width: 1, height: 36, color: context.appColors.cardBgLight);
}

class _Stat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Stat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Nunito')),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: context.appColors.textMuted, fontSize: 12)),
        ],
      );
}

class _ReviewCard extends StatefulWidget {
  final QuestionResult result;
  final bool canReport;
  const _ReviewCard(this.result, {this.canReport = true});
  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final color = r.isCorrect ? AppColors.success : AppColors.error;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                    r.isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: color,
                    size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(r.question,
                        style: TextStyle(
                            color: context.appColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3))),
                Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: context.appColors.textMuted,
                    size: 18),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              if (r.userAnswer != null && !r.isCorrect)
                _AnswerRow(AppLocalizations.of(context).yourAnswer, r.userAnswer!, AppColors.error),
              _AnswerRow(AppLocalizations.of(context).correctLabel, r.correctAnswer, AppColors.success),
              if (r.explanation != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: context.appColors.cardBgLight,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('?? ', style: TextStyle(fontSize: 13)),
                      Expanded(
                          child: Text(r.explanation!,
                              style: TextStyle(
                                  color: context.appColors.textSecondary,
                                  fontSize: 12,
                                  height: 1.4))),
                    ],
                  ),
                ),
              ],
              if (widget.canReport) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => _showReportSheet(context, r),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.flag_outlined, size: 16),
                    label: Text(AppLocalizations.of(context).reportQuestionAction,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Signalement d'une question ─────────────────────────────────────────────

List<(String, String)> _reportReasons(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return [
    ('wrong_answer', l10n.reasonWrongAnswer),
    ('ambiguous', l10n.reasonAmbiguous),
    ('typo', l10n.reasonTypo),
    ('outdated', l10n.reasonOutdated),
    ('other', l10n.reasonOther),
  ];
}

void _showReportSheet(BuildContext context, QuestionResult r) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReportSheet(result: r),
  );
}

class _ReportSheet extends StatefulWidget {
  final QuestionResult result;
  const _ReportSheet({required this.result});
  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String _reason = 'wrong_answer';
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final message = await QuizRepository(apiService).reportQuestion(
        questionId: widget.result.questionId,
        reason: _reason,
        comment: _commentCtrl.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).sendFailed),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appColors.cardBgLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.flag_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).reportQuestionTitle,
                      style: TextStyle(
                          color: context.appColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 4),
              Text(widget.result.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: context.appColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).reportReasonLabel,
                  style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ..._reportReasons(context).map((reason) {
                final selected = _reason == reason.$1;
                return GestureDetector(
                  onTap: _submitting
                      ? null
                      : () => setState(() => _reason = reason.$1),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selected
                              ? AppColors.primary
                              : context.appColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(reason.$2,
                              style: TextStyle(
                                  color: context.appColors.textPrimary,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              TextField(
                controller: _commentCtrl,
                enabled: !_submitting,
                maxLines: 3,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).commentOptional,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: AppLocalizations.of(context).sendReport,
                  icon: Icons.send_rounded,
                  loading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label, answer;
  final Color color;
  const _AnswerRow(this.label, this.answer, this.color);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 4, start: 26),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12, fontFamily: 'Nunito'),
            children: [
              TextSpan(
                  text: '$label: ',
                  style: TextStyle(color: context.appColors.textMuted)),
              TextSpan(
                  text: answer,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}
