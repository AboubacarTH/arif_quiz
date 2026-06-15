import 'package:arif_quiz/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/ui.dart';
import 'package:flutter/material.dart';

class AttemptHistoryScreen extends StatefulWidget {
  const AttemptHistoryScreen({super.key});

  @override
  State<AttemptHistoryScreen> createState() => _AttemptHistoryScreenState();
}

class _AttemptHistoryScreenState extends State<AttemptHistoryScreen> {
  List<Map<String, dynamic>> _attempts = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final res = await apiService.getAttemptHistory();
      final attempts = _extractAttemptItems(res)
          .map((a) => Map<String, dynamic>.from(a))
          .toList();

      if (!mounted) return;
      setState(() {
        _attempts = attempts;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Attempt history $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Impossible de charger l\'historique.';
      });
    }
  }

  List<dynamic> _extractAttemptItems(Map<String, dynamic> response) {
    final attempts = response['attempts'];
    if (attempts is List) return attempts;
    if (attempts is Map && attempts['data'] is List) {
      return attempts['data'] as List;
    }

    final data = response['data'];
    if (data is List) return data;
    if (data is Map && data['data'] is List) {
      return data['data'] as List;
    }

    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: const QuizAppBar(title: 'Quiz History', showBack: true),
      body: _loading
          ? const QuizListSkeleton()
          : _errorMessage != null
              ? ErrorState(message: _errorMessage!, onRetry: _loadAttempts)
              : _attempts.isEmpty
                  ? EmptyState(
                      title: 'No attempts yet',
                      subtitle:
                          'Play a quiz and your results will appear here.',
                      emoji: 'Q',
                      actionLabel: 'Refresh',
                      onAction: _loadAttempts,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAttempts,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _attempts.length,
                        itemBuilder: (context, index) {
                          return _AttemptTile(attempt: _attempts[index]);
                        },
                      ),
                    ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  final Map<String, dynamic> attempt;

  const _AttemptTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final quiz = attempt['quiz'];
    final quizMap = quiz is Map ? Map<String, dynamic>.from(quiz) : null;
    final quizId = _asInt(quizMap?['id'] ?? attempt['quiz_id']);
    final title = quizMap?['title']?.toString() ??
        attempt['quiz_title']?.toString() ??
        'Quiz';
    final grade = attempt['grade']?.toString() ?? 'F';
    final score = _asDouble(attempt['score']);
    final points = _asInt(attempt['points_earned']);
    final correct = _asInt(attempt['correct_count']);
    final total = _asInt(attempt['total_questions']);
    final timeTaken = _asInt(attempt['time_taken']);
    final gradeColor = AppColors.gradeColor(grade);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: quizId == null
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizDetailScreen(quizId: quizId),
                  ),
                ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.cardElevated,
            borderRadius: AppRadius.rLg,
            boxShadow: AppShadows.card(context),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  grade,
                  style: TextStyle(
                    color: gradeColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        _MetaText('${score.toStringAsFixed(1)}%'),
                        if (correct != null && total != null)
                          _MetaText('$correct/$total correct'),
                        if (points != null) _MetaText('+$points pts'),
                        if (timeTaken != null)
                          _MetaText(_formatTime(timeTaken)),
                      ],
                    ),
                    if (attempt['created_at'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(attempt['created_at'].toString()),
                        style: TextStyle(
                          color: context.appColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (quizId != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    return '${seconds ~/ 60}m ${seconds % 60}s';
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _MetaText extends StatelessWidget {
  final String text;

  const _MetaText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.appColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
