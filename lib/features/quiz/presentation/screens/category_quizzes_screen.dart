import 'package:arif_quiz/features/quiz/bloc/quiz_list_controller.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/quiz_card.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategoryQuizzesScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryQuizzesScreen({super.key, required this.category});

  @override
  State<CategoryQuizzesScreen> createState() => _CategoryQuizzesScreenState();
}

class _CategoryQuizzesScreenState extends State<CategoryQuizzesScreen> {
  late final QuizListController _ctrl;
  final _scrollCtrl = ScrollController();
  String? _selectedDiff;

  Color get _color => Color(
      int.parse(widget.category.color.replaceFirst('#', 'FF'), radix: 16));

  @override
  void initState() {
    super.initState();
    _ctrl = QuizListController(QuizRepository(apiService))
      ..categoryId = widget.category.id;
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
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: CustomScrollView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildHeader(),
          _buildFilters(),
          _buildList(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.08),
          border: Border(
            bottom: BorderSide(color: _color.withValues(alpha: 0.15), width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _color.withValues(alpha: 0.25)),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: _color, size: 16),
                  ),
                ),
                const SizedBox(height: 20),
                // Icon + title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: _color.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          widget.category.icon ?? '📚',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name,
                            style: TextStyle(
                              color: context.appColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${widget.category.quizCount} quiz${widget.category.quizCount != 1 ? 'zes' : ''}',
                              style: TextStyle(
                                color: _color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.category.description != null &&
                    widget.category.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.category.description!,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final d in [null, 'easy', 'medium', 'hard'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _DiffChip(
                    label: d == null
                        ? AppLocalizations.of(context).allFilter
                        : d == 'easy'
                            ? AppLocalizations.of(context).diffEasy
                            : d == 'medium'
                                ? AppLocalizations.of(context).diffMedium
                                : AppLocalizations.of(context).diffHard,
                    selected: _selectedDiff == d,
                    color: d == null ? _color : AppColors.difficultyColor(d),
                    onTap: () {
                      setState(() => _selectedDiff = d);
                      _ctrl.applyFilter(catId: widget.category.id, diff: d);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_ctrl.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: QuizListSkeleton(count: 5),
        ),
      );
    }

    if (_ctrl.error != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: ErrorState(message: _ctrl.error!, onRetry: _ctrl.load),
        ),
      );
    }

    if (_ctrl.quizzes.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: EmptyState(
            title: AppLocalizations.of(context).noQuizFound,
            subtitle: AppLocalizations.of(context).tryAnotherDifficulty,
            emoji: '🔍',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            if (i == _ctrl.quizzes.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: QuizCard(
                quiz: _ctrl.quizzes[i],
                style: QuizCardStyle.list,
                onTap: () => Navigator.push(
                  ctx,
                  SlideRightRoute(
                      page: QuizDetailScreen(quizId: _ctrl.quizzes[i].id)),
                ),
              ).animate().fadeIn(delay: (i * 50).ms).slideY(begin: 0.08),
            );
          },
          childCount: _ctrl.quizzes.length + (_ctrl.loadingMore ? 1 : 0),
        ),
      ),
    );
  }
}

class _DiffChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _DiffChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.2)
                : context.appColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : context.appColors.cardBgLight,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? color : context.appColors.textSecondary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
}
