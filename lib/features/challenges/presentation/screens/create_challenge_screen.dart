import 'package:arif_quiz/core/i18n/difficulty_l10n.dart';
import 'package:arif_quiz/features/challenges/bloc/challenge_controller.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/widgets/game_mode_card.dart';
import 'package:arif_quiz/ui/widgets/app_button.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Steps: 0=source, 1=category, 2=quiz, 3=config
// quiz source:     0 → 1 → 2 → 3
// category source: 0 → 1 → 3
// all source:      0 → 3

class CreateChallengeScreen extends StatefulWidget {
  final ChallengeController ctrl;

  const CreateChallengeScreen({super.key, required this.ctrl});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  String _sourceType = 'quiz'; // 'quiz' | 'category' | 'all'

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _categoriesLoading = true;

  List<QuizModel> _quizzes = [];
  QuizModel? _selectedQuiz;
  bool _quizzesLoading = false;

  final _titleCtrl = TextEditingController();
  GameMode _selectedMode = GameMode.classic;

  int _step = 0;

  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final raw = await apiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = raw.map((c) => CategoryModel.fromJson(c)).toList();
          _categoriesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _categoriesLoading = false);
    }
  }

  Future<void> _loadQuizzes(int categoryId) async {
    setState(() {
      _quizzesLoading = true;
      _quizzes = [];
      _selectedQuiz = null;
    });
    try {
      final res = await apiService.getQuizzes(categoryId: categoryId);
      final list = res['quizzes'] as List? ?? [];
      if (mounted) {
        setState(() {
          _quizzes = list.map((e) => QuizModel.fromJson(e)).toList();
          _quizzesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _quizzesLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  // ─── Navigation ──────────────────────────────────────────────────────────────

  void _onSourceSelected(String sourceType) {
    setState(() {
      _sourceType = sourceType;
      _selectedCategory = null;
      _selectedQuiz = null;
    });
    if (sourceType == 'all') {
      setState(() => _step = 3);
    } else {
      setState(() => _step = 1);
    }
  }

  void _onCategorySelected(CategoryModel cat) {
    setState(() => _selectedCategory = cat);
    if (_sourceType == 'quiz') {
      _loadQuizzes(cat.id);
      setState(() => _step = 2);
    } else {
      // category source → skip quiz step
      setState(() => _step = 3);
    }
  }

  void _onQuizSelected(QuizModel quiz) {
    setState(() {
      _selectedQuiz = quiz;
      _step = 3;
    });
  }

  bool _canGoBack() => _step > 0;

  void _back() {
    if (_step == 3) {
      if (_sourceType == 'all') {
        setState(() => _step = 0);
      } else if (_sourceType == 'category') {
        setState(() => _step = 1);
      } else {
        setState(() => _step = 2);
      }
    } else if (_step == 2) {
      setState(() => _step = 1);
    } else if (_step == 1) {
      setState(() => _step = 0);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  int get _totalSteps {
    if (_sourceType == 'all') return 2;
    if (_sourceType == 'category') return 3;
    return 4;
  }

  int get _currentStepIndex {
    if (_step == 0) return 0;
    if (_step == 1) return 1;
    if (_step == 2) return 2;
    return _totalSteps - 1;
  }

  List<String> get _stepTitles {
    if (_sourceType == 'all') return [AppLocalizations.of(context).stepSource, AppLocalizations.of(context).stepConfigure];
    if (_sourceType == 'category') {
      return [AppLocalizations.of(context).stepSource, AppLocalizations.of(context).stepPickCategory, AppLocalizations.of(context).stepConfigure];
    }
    return [AppLocalizations.of(context).stepSource, AppLocalizations.of(context).stepPickCategory, AppLocalizations.of(context).stepPickQuiz, AppLocalizations.of(context).stepConfigure];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_canGoBack(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _canGoBack()) _back();
      },
      child: Scaffold(
        backgroundColor: context.appColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStepIndicator(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0.05, 0), end: Offset.zero)
                          .animate(anim),
                      child: child,
                    ),
                  ),
                  child: switch (_step) {
                    0 => _StepSource(
                        key: const ValueKey(0),
                        selectedSource: _sourceType,
                        onSelect: _onSourceSelected,
                      ),
                    1 => _StepCategory(
                        key: const ValueKey(1),
                        categories: _categories,
                        loading: _categoriesLoading,
                        onSelect: _onCategorySelected,
                      ),
                    2 => _StepQuiz(
                        key: const ValueKey(2),
                        category: _selectedCategory!,
                        quizzes: _quizzes,
                        loading: _quizzesLoading,
                        selectedQuiz: _selectedQuiz,
                        onSelect: _onQuizSelected,
                      ),
                    _ => _StepConfig(
                        key: const ValueKey(3),
                        titleCtrl: _titleCtrl,
                        selectedMode: _selectedMode,
                        sourceType: _sourceType,
                        selectedQuiz: _selectedQuiz,
                        selectedCategory: _selectedCategory,
                        isCreating: widget.ctrl.isCreating,
                        onModeChanged: (m) => setState(() => _selectedMode = m),
                        questionsCount: _questionsCount,
                        onCountChanged: (n) =>
                            setState(() => _questionsCount = n),
                        onCreate: _create,
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final title = _stepTitles[_currentStepIndex];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _canGoBack() ? _back : () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.cardElevated,
                borderRadius: AppRadius.rMd,
                boxShadow: AppShadows.card(context),
              ),
              child: Icon(
                _canGoBack()
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.close_rounded,
                color: context.appColors.textSecondary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: context.type.headlineMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step indicator ──────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final total = _totalSteps;
    final current = _currentStepIndex;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: List.generate(total, (i) {
          final active = i == current;
          final done = i < current;
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: i < total - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                decoration: BoxDecoration(
                  color: done || active
                      ? AppColors.primary
                      : context.appColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.xxs),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Create ──────────────────────────────────────────────────────────────────

  /// Longueur du défi. Elle était figée à dix côté serveur, dans quatre
  /// littéraux, tout en circulant dans les réponses comme si elle se réglait.
  int _questionsCount = 10;

  Future<void> _create() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).enterChallengeTitle)),
      );
      return;
    }

    final challenge = await widget.ctrl.createChallenge(
      sourceType: _sourceType,
      quizId: _sourceType == 'quiz' ? _selectedQuiz?.id : null,
      categoryId: _sourceType == 'category' ? _selectedCategory?.id : null,
      mode: _selectedMode.apiValue,
      title: _titleCtrl.text.trim(),
      questionsCount: _questionsCount,
    );

    if (challenge != null && mounted) {
      Navigator.pop(context, challenge);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).createError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// ─── Étape 0 : Source ────────────────────────────────────────────────────────

class _StepSource extends StatelessWidget {
  final String selectedSource;
  final ValueChanged<String> onSelect;

  const _StepSource({
    super.key,
    required this.selectedSource,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final sources = [
      (
        id: 'quiz',
        icon: Icons.my_location_rounded,
        label: AppLocalizations.of(context).srcQuizLabel,
        desc: AppLocalizations.of(context).srcQuizDesc,
        color: AppColors.primary,
      ),
      (
        id: 'category',
        icon: Icons.category_rounded,
        label: AppLocalizations.of(context).srcCategoryLabel,
        desc: AppLocalizations.of(context).srcCategoryDesc,
        color: AppColors.secondary,
      ),
      (
        id: 'all',
        icon: Icons.public_rounded,
        label: AppLocalizations.of(context).allQuizzes,
        desc: AppLocalizations.of(context).srcAllDesc,
        color: AppColors.accent,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(
          AppLocalizations.of(context).whereQuestionsFrom,
          style: context.type.bodyMedium.copyWith(color: context.appColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ...sources.asMap().entries.map((entry) {
          final i = entry.key;
          final src = entry.value;
          final selected = selectedSource == src.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => onSelect(src.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: selected
                      ? src.color.withValues(alpha: 0.1)
                      : context.cardElevated,
                  borderRadius: AppRadius.rLg,
                  border: selected
                      ? Border.all(color: src.color, width: 2)
                      : null,
                  boxShadow: selected
                      ? AppShadows.tinted(context, src.color)
                      : AppShadows.card(context),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: src.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Icon(src.icon, size: 26, color: src.color),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            src.label,
                            style: context.type.titleMedium.copyWith(color: selected
                                  ? src.color
                                  : context.appColors.textPrimary, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            src.desc,
                            style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selected ? src.color : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? src.color
                              : context.appColors.border,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 13)
                          : null,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.06),
          );
        }),
      ],
    );
  }
}

// ─── Étape 1 : Catégories ────────────────────────────────────────────────────

class _StepCategory extends StatefulWidget {
  final List<CategoryModel> categories;
  final bool loading;
  final ValueChanged<CategoryModel> onSelect;

  const _StepCategory({
    super.key,
    required this.categories,
    required this.loading,
    required this.onSelect,
  });

  @override
  State<_StepCategory> createState() => _StepCategoryState();
}

class _StepCategoryState extends State<_StepCategory> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CategoryModel> get _filtered {
    if (_query.isEmpty) return widget.categories;
    final q = _query.toLowerCase();
    return widget.categories
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (widget.categories.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).noCategoryAvailable,
            style: TextStyle(color: context.appColors.textSecondary)),
      );
    }

    final filtered = _filtered;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.appColors.cardBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.appColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: context.appColors.textMuted, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: context.type.bodyLarge.copyWith(color: context.appColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).searchCategoryHint,
                      hintStyle: context.type.bodyLarge.copyWith(color: context.appColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                    child: Icon(Icons.close_rounded,
                        color: context.appColors.textMuted, size: 16),
                  ),
              ],
            ),
          ),
        ),
        // Grid
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context).noResultsFor(_query),
                    style:
                        TextStyle(color: context.appColors.textMuted),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final cat = filtered[i];
                    final color = Color(
                        int.parse(cat.color.replaceFirst('#', 'FF'), radix: 16));
                    return GestureDetector(
                      onTap: () => widget.onSelect(cat),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: AppRadius.rLg,
                          boxShadow: AppShadows.tinted(context, color),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.icon ?? '📚',
                                style: context.type.displayLarge),
                            const SizedBox(height: 8),
                            Text(
                              cat.name,
                              style: context.type.labelLarge.copyWith(color: context.appColors.textPrimary),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${cat.quizCount} quiz${cat.quizCount != 1 ? 'zes' : ''}',
                              style: context.type.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (i * 40).ms).slideY(begin: 0.06);
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Étape 2 : Quiz ──────────────────────────────────────────────────────────

class _StepQuiz extends StatefulWidget {
  final CategoryModel category;
  final List<QuizModel> quizzes;
  final bool loading;
  final QuizModel? selectedQuiz;
  final ValueChanged<QuizModel> onSelect;

  const _StepQuiz({
    super.key,
    required this.category,
    required this.quizzes,
    required this.loading,
    required this.selectedQuiz,
    required this.onSelect,
  });

  @override
  State<_StepQuiz> createState() => _StepQuizState();
}

class _StepQuizState extends State<_StepQuiz> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<QuizModel> get _filtered {
    if (_query.isEmpty) return widget.quizzes;
    final q = _query.toLowerCase();
    return widget.quizzes
        .where((quiz) => quiz.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final catColor = Color(
        int.parse(widget.category.color.replaceFirst('#', 'FF'), radix: 16));

    if (widget.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: QuizListSkeleton(count: 4),
      );
    }
    if (widget.quizzes.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noQuizInCategory,
          style: TextStyle(color: context.appColors.textSecondary),
        ),
      );
    }

    final filtered = _filtered;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.appColors.cardBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.appColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: context.appColors.textMuted, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: context.type.bodyLarge.copyWith(color: context.appColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).searchQuizHint,
                      hintStyle: context.type.bodyLarge.copyWith(color: context.appColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                    child: Icon(Icons.close_rounded,
                        color: context.appColors.textMuted, size: 16),
                  ),
              ],
            ),
          ),
        ),
        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context).noResultsFor(_query),
                    style: TextStyle(color: context.appColors.textMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final q = filtered[i];
                    final selected = widget.selectedQuiz?.id == q.id;
                    return GestureDetector(
                      onTap: () => widget.onSelect(q),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? catColor.withValues(alpha: 0.1)
                              : context.cardElevated,
                          borderRadius: AppRadius.rLg,
                          border: selected
                              ? Border.all(color: catColor, width: 2)
                              : null,
                          boxShadow: selected
                              ? AppShadows.tinted(context, catColor)
                              : AppShadows.card(context),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Center(
                                child: Text(
                                  widget.category.icon ?? '📚',
                                  style: context.type.headlineLarge,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    q.title,
                                    style: context.type.titleMedium.copyWith(color: selected
                                          ? catColor
                                          : context.appColors.textPrimary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // La longueur du défi se choisit à
                                      // l'étape suivante : annoncer un nombre
                                      // ici serait une promesse en l'air. Le
                                      // total de questions d'un quiz reste par
                                      // ailleurs masqué aux joueurs.
                                      _QuizChip(
                                        label: DifficultyL10n.label(
                                            context, q.difficulty),
                                        color: AppColors.difficultyColor(
                                            q.difficulty),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: selected ? catColor : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? catColor
                                      : context.appColors.border,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 13)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (i * 40).ms);
                  },
                ),
        ),
      ],
    );
  }
}

class _QuizChip extends StatelessWidget {
  final String label;
  final Color color;
  const _QuizChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Text(
          label,
          style: context.type.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      );
}

// ─── Étape 3 : Config ────────────────────────────────────────────────────────

class _StepConfig extends StatelessWidget {
  final TextEditingController titleCtrl;
  final GameMode selectedMode;
  final String sourceType;
  final QuizModel? selectedQuiz;
  final CategoryModel? selectedCategory;
  final bool isCreating;
  final int questionsCount;
  final ValueChanged<GameMode> onModeChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onCreate;

  const _StepConfig({
    super.key,
    required this.titleCtrl,
    required this.selectedMode,
    required this.sourceType,
    required this.selectedQuiz,
    required this.selectedCategory,
    required this.isCreating,
    required this.questionsCount,
    required this.onModeChanged,
    required this.onCountChanged,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final (sourceIcon, sourceLabel, sourceColor) = switch (sourceType) {
      'category' => (
          Icons.category_rounded,
          selectedCategory?.name ?? AppLocalizations.of(context).categoryLabel,
          AppColors.secondary,
        ),
      'all' => (
          Icons.public_rounded,
          AppLocalizations.of(context).allQuizzes,
          AppColors.accent,
        ),
      _ => (
          Icons.my_location_rounded,
          selectedQuiz?.title ?? 'Quiz',
          AppColors.primary,
        ),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source résumé
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.cardElevated,
              borderRadius: AppRadius.rLg,
              boxShadow: AppShadows.card(context),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sourceColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Icon(sourceIcon, size: 22, color: sourceColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sourceLabel,
                        style: context.type.labelLarge.copyWith(color: context.appColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppLocalizations.of(context).randomQuestionsCount(questionsCount),
                        style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Titre
          Text(
            AppLocalizations.of(context).challengeTitleLabel,
            style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: titleCtrl,
            style: TextStyle(color: context.appColors.textPrimary),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).challengeTitleHint,
            ),
          ),
          const SizedBox(height: 24),

          // Longueur
          Text(
            AppLocalizations.of(context).questionsCountLabel,
            style: context.type.titleMedium
                .copyWith(color: context.appColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final n in const [5, 10, 15, 20, 30])
                _CountChip(
                  count: n,
                  selected: questionsCount == n,
                  onTap: () => onCountChanged(n),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Mode
          Text(
            AppLocalizations.of(context).gameModeLabel,
            style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary),
          ),
          const SizedBox(height: 10),
          ...GameMode.values.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GameModeCard(
                mode: m,
                selected: selectedMode == m,
                onTap: () => onModeChanged(m),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bouton créer
          AppButton(
            label: isCreating ? AppLocalizations.of(context).creating : AppLocalizations.of(context).createChallengeBtn,
            fullWidth: true,
            icon: Icons.sports_esports,
            tint: AppColors.modeColor(selectedMode.apiValue),
            onPressed: isCreating ? null : onCreate,
          ),
        ],
      ),
    );
  }
}

/// Puce de longueur : le créateur choisit en un tap combien de questions
/// comptera son défi.
class _CountChip extends StatelessWidget {
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _CountChip({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? AppColors.primary
            : context.appColors.cardBgLight,
        borderRadius: AppRadius.rPill,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rPill,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
            child: Text(
              '$count',
              style: context.type.labelLarge.copyWith(
                  color: selected
                      ? Colors.white
                      : context.appColors.textSecondary),
            ),
          ),
        ),
      );
}
