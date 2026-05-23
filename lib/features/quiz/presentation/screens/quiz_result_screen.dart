import 'package:arif_quiz/features/home/presentation/screens/main_navigation.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizAttemptResult result;
  final QuizModel quiz;

  const QuizResultScreen({super.key, required this.result, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppColors.gradeColor(result.grade);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Grade circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: gradeColor.withOpacity(0.15),
                        border: Border.all(color: gradeColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: gradeColor.withOpacity(0.3),
                            blurRadius: 32,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          result.grade,
                          style: TextStyle(
                            color: gradeColor,
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _getMessage(result.score),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      quiz.title,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    // Score card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBgLight),
                      ),
                      child: Column(
                        children: [
                          // Score percentage
                          Text(
                            '${result.score.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: gradeColor,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Score',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          const Divider(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem('${result.correctCount}/${result.totalQuestions}', 'Correct', AppColors.success),
                              _StatItem('+${result.pointsEarned}', 'Points', AppColors.warning),
                              _StatItem('${_formatTime(result.timeTaken)}', 'Time', AppColors.info),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Review answers
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Review Answers',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...result.results.map((r) => _ReviewCard(r)),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainNavigation()),
                        (_) => false,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.cardBgLight),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Play Again'),
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

  String _getMessage(double score) {
    if (score >= 90) return 'Outstanding! 🏆';
    if (score >= 80) return 'Excellent! 🎉';
    if (score >= 70) return 'Great Job! 👏';
    if (score >= 60) return 'Not Bad! 👍';
    if (score >= 50) return 'Keep Going! 💪';
    return 'Try Again! 🔄';
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    return '${seconds ~/ 60}m ${seconds % 60}s';
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      );
}

class _ReviewCard extends StatelessWidget {
  final QuestionResult result;
  const _ReviewCard(this.result);

  @override
  Widget build(BuildContext context) {
    final color = result.isCorrect ? AppColors.success : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                result.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.question,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (result.userAnswer != null && !result.isCorrect)
            _AnswerRow('Your answer', result.userAnswer!, AppColors.error),
          _AnswerRow('Correct answer', result.correctAnswer, AppColors.success),
          if (result.explanation != null) ...[
            const SizedBox(height: 6),
            Text(
              '💡 ${result.explanation}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String answer;
  final Color color;

  const _AnswerRow(this.label, this.answer, this.color);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4, left: 26),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, fontFamily: 'Nunito'),
            children: [
              TextSpan(text: '$label: ', style: const TextStyle(color: AppColors.textMuted)),
              TextSpan(text: answer, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
