import 'package:arif_quiz/features/challenges/bloc/challenge_controller.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/widgets/game_mode_card.dart';
import 'package:arif_quiz/ui/widgets/neon_button.dart';
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
    if (_sourceType == 'all') return ['Source des questions', 'Configurer le défi'];
    if (_sourceType == 'category') {
      return ['Source des questions', 'Choisir une catégorie', 'Configurer le défi'];
    }
    return ['Source des questions', 'Choisir une catégorie', 'Choisir un quiz', 'Configurer le défi'];
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: context.appColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.appColors.border),
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
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
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
              padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                decoration: BoxDecoration(
                  color: done || active
                      ? AppColors.primary
                      : context.appColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Create ──────────────────────────────────────────────────────────────────

  Future<void> _create() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre un titre pour le défi')),
      );
      return;
    }

    final challenge = await widget.ctrl.createChallenge(
      sourceType: _sourceType,
      quizId: _sourceType == 'quiz' ? _selectedQuiz?.id : null,
      categoryId: _sourceType == 'category' ? _selectedCategory?.id : null,
      mode: _selectedMode.apiValue,
      title: _titleCtrl.text.trim(),
    );

    if (challenge != null && mounted) {
      Navigator.pop(context, challenge);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création'),
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
    const sources = [
      (
        id: 'quiz',
        icon: '🎯',
        label: 'Un quiz spécifique',
        desc: '10 questions tirées d\'un quiz de ton choix',
        color: AppColors.primary,
      ),
      (
        id: 'category',
        icon: '📚',
        label: 'Par catégorie',
        desc: '10 questions aléatoires parmi tous les quiz d\'une catégorie',
        color: AppColors.secondary,
      ),
      (
        id: 'all',
        icon: '🌐',
        label: 'Tous les quiz',
        desc: '10 questions aléatoires parmi tous les quiz disponibles',
        color: AppColors.accent,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(
          'D\'où viennent les questions ?',
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 13,
          ),
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
                      : context.appColors.cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        selected ? src.color : context.appColors.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: src.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(src.icon,
                            style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            src.label,
                            style: TextStyle(
                              color: selected
                                  ? src.color
                                  : context.appColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            src.desc,
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 12,
                            ),
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
        child: Text('Aucune catégorie disponible',
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
              borderRadius: BorderRadius.circular(12),
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
                    style: TextStyle(
                        color: context.appColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une catégorie...',
                      hintStyle: TextStyle(
                          color: context.appColors.textMuted, fontSize: 14),
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
                    'Aucun résultat pour "$_query"',
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
                          borderRadius: BorderRadius.circular(18),
                          border:
                              Border.all(color: color.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.icon ?? '📚',
                                style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: context.appColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${cat.quizCount} quiz${cat.quizCount != 1 ? 'zes' : ''}',
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
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
          'Aucun quiz dans cette catégorie',
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
              borderRadius: BorderRadius.circular(12),
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
                    style: TextStyle(
                        color: context.appColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un quiz...',
                      hintStyle: TextStyle(
                          color: context.appColors.textMuted, fontSize: 14),
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
                    'Aucun résultat pour "$_query"',
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
                              : context.appColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? catColor : context.appColors.border,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Center(
                                child: Text(
                                  widget.category.icon ?? '📚',
                                  style: const TextStyle(fontSize: 22),
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
                                    style: TextStyle(
                                      color: selected
                                          ? catColor
                                          : context.appColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _QuizChip(
                                          label: '10 questions',
                                          color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      _QuizChip(
                                        label: q.difficulty,
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
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700),
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
  final ValueChanged<GameMode> onModeChanged;
  final VoidCallback onCreate;

  const _StepConfig({
    super.key,
    required this.titleCtrl,
    required this.selectedMode,
    required this.sourceType,
    required this.selectedQuiz,
    required this.selectedCategory,
    required this.isCreating,
    required this.onModeChanged,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final (sourceIcon, sourceLabel, sourceColor) = switch (sourceType) {
      'category' => (
          selectedCategory?.icon ?? '📚',
          selectedCategory?.name ?? 'Catégorie',
          AppColors.secondary,
        ),
      'all' => ('🌐', 'Tous les quiz', AppColors.accent),
      _ => (
          '🎯',
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.appColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sourceColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(sourceIcon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sourceLabel,
                        style: TextStyle(
                          color: context.appColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '10 questions aléatoires',
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 12,
                        ),
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
            'Titre du défi',
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: titleCtrl,
            style: TextStyle(color: context.appColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ex: Qui connaît l\'aviation ?',
            ),
          ),
          const SizedBox(height: 24),

          // Mode
          Text(
            'Mode de jeu',
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
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
          NeonButton(
            label: isCreating ? 'Création...' : 'Créer le défi',
            width: double.infinity,
            icon: Icons.sports_esports,
            color: AppColors.modeColor(selectedMode.apiValue),
            onTap: isCreating ? null : onCreate,
          ),
        ],
      ),
    );
  }
}
