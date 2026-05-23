import 'package:arif_quiz/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List<QuizModel> _quizzes = [];
  bool _loading = true;
  String? _selectedDifficulty;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _loading = true);
    try {
      final res = await apiService.getQuizzes(
        difficulty: _selectedDifficulty,
        search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
      );
      setState(() {
        _quizzes = (res['quizzes'] as List).map((q) => QuizModel.fromJson(q)).toList();
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
        title: const Text('All Quizzes'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search quizzes...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchCtrl.clear();
                          _loadQuizzes();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _loadQuizzes(),
            ),
          ),

          // Difficulty filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                for (final diff in [null, 'easy', 'medium', 'hard'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(diff?.toUpperCase() ?? 'ALL'),
                      selected: _selectedDifficulty == diff,
                      onSelected: (_) {
                        setState(() => _selectedDifficulty = diff);
                        _loadQuizzes();
                      },
                      backgroundColor: AppColors.cardBg,
                      selectedColor: AppColors.primary.withOpacity(0.3),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedDifficulty == diff
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: _selectedDifficulty == diff
                            ? AppColors.primary
                            : AppColors.cardBgLight,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
              ],
            ),
          ),

          // Quiz list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _quizzes.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.quiz_outlined, color: AppColors.textMuted, size: 60),
                            SizedBox(height: 12),
                            Text('No quizzes found', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadQuizzes,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: _quizzes.length,
                          itemBuilder: (ctx, i) {
                            final quiz = _quizzes[i];
                            final diffColor = AppColors.difficultyColor(quiz.difficulty);
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizDetailScreen(quizId: quiz.id),
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.cardBgLight),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            quiz.title,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: diffColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            quiz.difficulty.toUpperCase(),
                                            style: TextStyle(
                                              color: diffColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (quiz.description != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        quiz.description!,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _InfoChip(Icons.help_outline, '${quiz.totalQuestions} Questions'),
                                        const SizedBox(width: 12),
                                        _InfoChip(Icons.timer_outlined, '${quiz.timeLimit}s / Q'),
                                        const SizedBox(width: 12),
                                        _InfoChip(Icons.play_circle_outline, '${quiz.playCount} plays'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      );
}
