import 'package:arif_quiz/features/quiz/bloc/quiz_list_controller.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/core/i18n/difficulty_l10n.dart';
import 'package:arif_quiz/ui/widgets/app_button.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/app_text_field.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/quiz_card.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';

class QuizListScreen extends StatefulWidget {
  final int? initialCategoryId;
  final String? initialCategoryName;

  const QuizListScreen({
    super.key,
    this.initialCategoryId,
    this.initialCategoryName,
  });

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  late final QuizListController _ctrl;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<CategoryModel> _categories = [];
  bool _categoriesLoading = true;
  int? _selectedCatId;
  String? _selectedDiff;

  @override
  void initState() {
    super.initState();
    _selectedCatId = widget.initialCategoryId;
    _ctrl = QuizListController(QuizRepository(apiService))
      ..categoryId = _selectedCatId;
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.load();
    _scrollCtrl.addListener(_onScroll);
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

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _ctrl.loadMore();
    }
  }

  void _applyFilter({int? catId, String? diff, String? q}) {
    _ctrl.applyFilter(catId: catId, diff: diff, q: q);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  int get _activeFilters =>
      (_selectedCatId != null ? 1 : 0) + (_selectedDiff != null ? 1 : 0);

  CategoryModel? get _selectedCategory =>
      _categories.where((c) => c.id == _selectedCatId).firstOrNull;

  String get _title {
    final category = _selectedCategory;
    if (category != null) return category.name;
    return widget.initialCategoryName ?? AppLocalizations.of(context).allQuizzes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      // La barre du haut se retire au défilement : sans zone sûre, les quiz
      // passaient dessous et venaient se glisser derrière l'heure, le réseau
      // et la batterie. Les autres onglets l'avaient déjà, pas celui-ci.
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _ctrl.refresh,
          color: AppColors.primary,
          backgroundColor: context.appColors.cardBg,
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _appBar(),
              SliverToBoxAdapter(child: _search()),
              SliverToBoxAdapter(child: _filterSummary()),
              ..._listSlivers(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Barre ───────────────────────────────────────────────────────────────

  /// Elle flotte : elle s'efface quand on descend dans la liste et revient dès
  /// qu'on remonte, sans jamais occuper la page en permanence.
  Widget _appBar() {
    // Cet écran sert à la fois d'onglet (racine de la pile, rien à dépiler) et
    // de page poussée depuis l'accueil. En onglet, `Navigator.pop` remontait au
    // `PopScope` de MainNavigation et ouvrait la popup « Quitter l'application »
    // : la flèche n'a de sens que s'il y a vraiment une page en dessous.
    final canGoBack = Navigator.of(context).canPop();

    return SliverAppBar(
      floating: true,
      snap: true,
      centerTitle: false,
      backgroundColor: context.appColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: canGoBack ? 0 : AppSpacing.gutter,
      automaticallyImplyLeading: false,
      leading: canGoBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: context.appColors.textSecondary, size: 18),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        _title,
        overflow: TextOverflow.ellipsis,
        style: context.type.headlineMedium.copyWith(fontWeight: FontWeight.w800),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: _FilterButton(
            activeCount: _activeFilters,
            onTap: _openFilterSheet,
          ),
        ),
      ],
    );
  }

  // ─── Recherche ───────────────────────────────────────────────────────────

  Widget _search() => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
        child: AppTextField(
          label: '',
          hint: AppLocalizations.of(context).searchQuizHint,
          controller: _searchCtrl,
          prefixIcon: Icons.search_rounded,
          suffix: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded,
                      color: context.appColors.textMuted, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    _applyFilter(catId: _selectedCatId, diff: _selectedDiff);
                  })
              : null,
          onChanged: (v) {
            if (v.isEmpty) {
              _applyFilter(catId: _selectedCatId, diff: _selectedDiff);
            }
          },
          onSubmitted: (v) =>
              _applyFilter(catId: _selectedCatId, diff: _selectedDiff, q: v),
          textInputAction: TextInputAction.search,
        ),
      );

  // ─── Filtres actifs + compteur ───────────────────────────────────────────

  /// Une seule ligne : ce qui filtre, et combien de quiz il en reste. Les
  /// filtres se retirent d'un tap — inutile de rouvrir la feuille pour annuler.
  Widget _filterSummary() {
    final category = _selectedCategory;
    final chips = <Widget>[
      if (category != null)
        _ActiveFilterChip(
          label: category.name,
          onRemove: () {
            setState(() => _selectedCatId = null);
            _applyFilter(diff: _selectedDiff, q: _searchCtrl.text);
          },
        ),
      if (_selectedDiff != null)
        _ActiveFilterChip(
          label: DifficultyL10n.label(context, _selectedDiff!),
          onRemove: () {
            setState(() => _selectedDiff = null);
            _applyFilter(catId: _selectedCatId, q: _searchCtrl.text);
          },
        ),
    ];

    if (chips.isEmpty && _ctrl.quizzes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
      child: Row(
        children: [
          if (_ctrl.quizzes.isNotEmpty)
            Text(
              AppLocalizations.of(context).quizCount(_ctrl.quizzes.length),
              style: context.type.labelMedium
                  .copyWith(color: context.appColors.textMuted),
            ),
          if (chips.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                alignment: WrapAlignment.end,
                children: chips,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(
        categories: _categories,
        categoriesLoading: _categoriesLoading,
        selectedCategory: _selectedCategory,
        selectedDifficulty: _selectedDiff,
        onPickCategory: () {
          Navigator.pop(context);
          _openCategorySheet();
        },
        onDifficulty: (d) {
          setState(() => _selectedDiff = d);
          _applyFilter(
              catId: _selectedCatId, diff: d, q: _searchCtrl.text);
        },
        onClear: () {
          Navigator.pop(context);
          setState(() {
            _selectedCatId = null;
            _selectedDiff = null;
          });
          _applyFilter(q: _searchCtrl.text);
        },
      ),
    );
  }

  // ─── Liste ───────────────────────────────────────────────────────────────

  List<Widget> _listSlivers() {
    if (_ctrl.isLoading) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: QuizListSkeleton(),
          ),
        ),
      ];
    }

    if (_ctrl.error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(
              message: AppLocalizations.of(context).loadQuizzesFailed,
              onRetry: _ctrl.load),
        ),
      ];
    }

    if (_ctrl.quizzes.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: AppLocalizations.of(context).noQuizFound,
            subtitle: AppLocalizations.of(context).tryAnotherFilter,
            icon: Icons.search_off_rounded,
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        sliver: SliverList.separated(
          itemCount: _ctrl.quizzes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => QuizCard(
            quiz: _ctrl.quizzes[i],
            style: QuizCardStyle.list,
            onTap: () => Navigator.push(
              context,
              SlideRightRoute(
                  page: QuizDetailScreen(quizId: _ctrl.quizzes[i].id)),
            ),
          ),
        ),
      ),
      if (_ctrl.loadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            ),
          ),
        ),
    ];
  }

  void _openCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.72,
        child: _CategorySheet(
          categories: _categories,
          selectedId: _selectedCatId,
          onSelect: (cat) {
            Navigator.pop(ctx);
            setState(() => _selectedCatId = cat?.id);
            if (cat == null) {
              _applyFilter(diff: _selectedDiff, q: _searchCtrl.text);
            } else {
              _applyFilter(catId: cat.id, diff: _selectedDiff, q: _searchCtrl.text);
            }
          },
        ),
      ),
    );
  }

}

// ─── Category bottom sheet ───────────────────────────────────────────────────

class _CategorySheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final int? selectedId;
  final void Function(CategoryModel?) onSelect;

  const _CategorySheet({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
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
    final filtered = _filtered;

    return Column(
      children: [
        // Drag handle
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: context.appColors.border,
            borderRadius: BorderRadius.circular(AppRadius.xxs),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).categories,
                style: context.type.titleLarge.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (widget.selectedId != null)
                GestureDetector(
                  onTap: () => widget.onSelect(null),
                  child: Text(
                    AppLocalizations.of(context).seeAll,
                    style: context.type.labelLarge.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.appColors.bg,
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
                    autofocus: false,
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
        const Divider(height: 1),
        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context).noResultsFor(_query),
                    style: TextStyle(color: context.appColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final cat = filtered[i];
                    final color = Color(
                        int.parse(cat.color.replaceFirst('#', 'FF'), radix: 16));
                    final isSelected = cat.id == widget.selectedId;

                    return GestureDetector(
                      onTap: () => widget.onSelect(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? color.withValues(alpha: 0.4)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Center(
                                child: Text(cat.icon ?? '📚',
                                    style: context.type.headlineMedium),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: context.type.titleMedium.copyWith(color: isSelected
                                          ? color
                                          : context.appColors.textPrimary, fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600),
                                  ),
                                  if (cat.quizCount > 0)
                                    Text(
                                      '${cat.quizCount} quiz${cat.quizCount > 1 ? 'zes' : ''}',
                                      style: context.type.labelMedium.copyWith(color: context.appColors.textMuted),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    );
  }
}

// ─── Chip réutilisable ────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.18)
                : context.appColors.cardBg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? color : context.appColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: context.type.labelMedium.copyWith(color: selected ? color : context.appColors.textSecondary),
          ),
        ),
      );
}

// ─── Bouton de filtres ───────────────────────────────────────────────────────

/// Il remplace deux rangées épinglées en permanence. La pastille dit combien de
/// filtres sont actifs, pour qu'on n'ait pas à ouvrir la feuille pour le savoir.
class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = activeCount > 0;

    return Material(
      color: active
          ? AppColors.primary.withValues(alpha: 0.12)
          : context.cardElevated,
      borderRadius: AppRadius.rMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded,
                  size: 18,
                  color: active
                      ? AppColors.primary
                      : context.appColors.textSecondary),
              if (active) ...[
                const SizedBox(width: 6),
                Text('$activeCount',
                    style: context.type.labelLarge
                        .copyWith(color: AppColors.primary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Un filtre actif, retirable d'un tap.
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: AppRadius.rPill,
        child: InkWell(
          onTap: onRemove,
          borderRadius: AppRadius.rPill,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 7, 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.labelSmall
                        .copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.close_rounded,
                    size: 13, color: AppColors.primary),
              ],
            ),
          ),
        ),
      );
}

// ─── Feuille de filtres ──────────────────────────────────────────────────────

/// Catégorie et difficulté, appelées quand on en a besoin plutôt qu'occupant
/// deux rangées en permanence.
class _FilterSheet extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool categoriesLoading;
  final CategoryModel? selectedCategory;
  final String? selectedDifficulty;
  final VoidCallback onPickCategory;
  final ValueChanged<String?> onDifficulty;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.categories,
    required this.categoriesLoading,
    required this.selectedCategory,
    required this.selectedDifficulty,
    required this.onPickCategory,
    required this.onDifficulty,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasFilters = selectedCategory != null || selectedDifficulty != null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md,
            AppSpacing.gutter, AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.border,
                  borderRadius: AppRadius.rPill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(l10n.categories, style: context.type.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: categoriesLoading ? null : onPickCategory,
              borderRadius: AppRadius.rMd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.appColors.bg,
                  borderRadius: AppRadius.rMd,
                  border: Border.all(color: context.appColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedCategory?.name ?? l10n.allCategories,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.bodyLarge,
                      ),
                    ),
                    Icon(Icons.expand_more_rounded,
                        color: context.appColors.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(l10n.difficulty, style: context.type.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final entry in {
                  null: l10n.allDifficulties,
                  'easy': l10n.diffEasy,
                  'medium': l10n.diffMedium,
                  'hard': l10n.diffHard,
                }.entries)
                  _FilterChip(
                    label: entry.value,
                    selected: selectedDifficulty == entry.key,
                    color: entry.key == null
                        ? context.appColors.textSecondary
                        : AppColors.difficultyColor(entry.key!),
                    onTap: () => onDifficulty(entry.key),
                  ),
              ],
            ),

            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.resetFilters,
                  variant: AppButtonVariant.ghost,
                  icon: Icons.close_rounded,
                  onPressed: onClear,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
