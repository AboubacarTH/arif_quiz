import 'package:arif_quiz/features/quiz/presentation/screens/quiz_play_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuizDetailScreen extends StatefulWidget {
  final int quizId;
  const QuizDetailScreen({super.key, required this.quizId});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  QuizModel? _quiz;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final res = await apiService.getQuiz(widget.quizId);
      setState(() {
        _quiz = QuizModel.fromJson(res['quiz']);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Quiz Details'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _quiz == null
              ? const Center(child: Text('Quiz not found', style: TextStyle(color: AppColors.textSecondary)))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail / hero
                            Container(
                              width: double.infinity,
                              height: 160,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.quiz_rounded, color: AppColors.primary, size: 60),
                                  const SizedBox(height: 8),
                                  if (_quiz!.category != null)
                                    Text(
                                      _quiz!.category!.name,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Title and difficulty
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _quiz!.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _DiffBadge(_quiz!.difficulty),
                              ],
                            ),

                            if (_quiz!.description != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _quiz!.description!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],

                            const SizedBox(height: 28),
                            const Text(
                              'Quiz Info',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Info grid
                            Row(
                              children: [
                                Expanded(child: _InfoCard(Icons.help_rounded, '${_quiz!.totalQuestions}', 'Questions', AppColors.primary)),
                                const SizedBox(width: 12),
                                Expanded(child: _InfoCard(Icons.timer_rounded, '${_quiz!.timeLimit}s', 'Per Question', AppColors.info)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _InfoCard(Icons.star_rounded, '${_quiz!.pointsPerQuestion ?? 10}', 'Points/Q', AppColors.warning)),
                                const SizedBox(width: 12),
                                Expanded(child: _InfoCard(Icons.play_circle_rounded, '${_quiz!.playCount}', 'Times Played', AppColors.success)),
                              ],
                            ),

                            const SizedBox(height: 28),
                            // Instructions
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.cardBgLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('📌 How to Play', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                                  SizedBox(height: 10),
                                  _Instruction('Select one answer per question'),
                                  _Instruction('Answer before the timer runs out'),
                                  _Instruction('Earn points for each correct answer'),
                                  _Instruction('Review your results at the end'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Start button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizPlayScreen(quiz: _quiz!),
                            ),
                          ),
                          child: const Text('Start Quiz 🚀', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  final String difficulty;
  const _DiffBadge(this.difficulty);

  @override
  Widget build(BuildContext context) {
    final color = AppColors.difficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _InfoCard(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      );
}

class _Instruction extends StatelessWidget {
  final String text;
  const _Instruction(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
}
