import 'package:arif_quiz/features/quiz/bloc/quiz_list_controller.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/app_bar.dart';
import 'package:arif_quiz/ui/widgets/app_text_field.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/quiz_card.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});
  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  late final QuizListController _ctrl;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _selectedDiff;

  @override
  void initState() {
    super.initState();
    _ctrl = QuizListController(QuizRepository(apiService));
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.load();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _ctrl.loadMore();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: QuizAppBar(title: 'All Quizzes'),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: AppTextField(
              label: '',
              hint: 'Search quizzes...',
              controller: _searchCtrl,
              prefixIcon: Icons.search_rounded,
              suffix: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded,
                          color: context.appColors.textMuted, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        _ctrl.applyFilter(diff: _selectedDiff);
                      })
                  : null,
              onChanged: (v) {
                if (v.isEmpty) _ctrl.applyFilter(diff: _selectedDiff);
              },
              onSubmitted: (v) => _ctrl.applyFilter(q: v, diff: _selectedDiff),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Difficulty chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final d in [null, 'easy', 'medium', 'hard'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _DiffChip(
                        label: d?.toUpperCase() ?? 'ALL',
                        selected: _selectedDiff == d,
                        color: d == null
                            ? AppColors.primary
                            : AppColors.difficultyColor(d),
                        onTap: () {
                          setState(() => _selectedDiff = d);
                          _ctrl.applyFilter(q: _searchCtrl.text, diff: d);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Results count
          if (_ctrl.quizzes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_ctrl.quizzes.length} quizzes',
                  style:
                      TextStyle(color: context.appColors.textMuted, fontSize: 12),
                ),
              ),
            ),

          // List
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_ctrl.isLoading) return const QuizListSkeleton();
    if (_ctrl.error != null) {
      return ErrorState(message: _ctrl.error!, onRetry: _ctrl.load);
    }
    if (_ctrl.quizzes.isEmpty) {
      return const EmptyState(
          title: 'No quizzes found',
          subtitle: 'Try a different search or filter',
          emoji: '🔍');
    }

    return RefreshIndicator(
      onRefresh: () => _ctrl.load(),
      color: AppColors.primary,
      backgroundColor: context.appColors.cardBg,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _ctrl.quizzes.length + (_ctrl.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          if (i == _ctrl.quizzes.length) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2)));
          }
          return QuizCard(
            quiz: _ctrl.quizzes[i],
            style: QuizCardStyle.list,
            onTap: () => Navigator.push(
                context,
                SlideRightRoute(
                    page: QuizDetailScreen(quizId: _ctrl.quizzes[i].id))),
          );
        },
      ),
    );
  }
}

class _DiffChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _DiffChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.2) : context.appColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? color : context.appColors.cardBgLight,
                width: selected ? 1.5 : 1),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: selected ? color : context.appColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
          ),
        ),
      );
}
