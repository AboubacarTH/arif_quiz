import 'package:arif_quiz/features/quiz/bloc/quiz_list_controller.dart';
import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearch(),
            _buildCategoryChips(),
            _buildDiffChips(),
            if (_ctrl.quizzes.isNotEmpty) _buildCount(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final title = _selectedCatId != null
        ? (_categories
                .where((c) => c.id == _selectedCatId)
                .firstOrNull
                ?.name ??
            widget.initialCategoryName ??
            'Quiz')
        : 'Tous les quiz';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.cardElevated,
                borderRadius: AppRadius.rMd,
                boxShadow: AppShadows.card(context),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: context.appColors.textSecondary, size: 16),
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search ──────────────────────────────────────────────────────────────────

  Widget _buildSearch() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: AppTextField(
          label: '',
          hint: 'Rechercher un quiz...',
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
            if (v.isEmpty) _applyFilter(catId: _selectedCatId, diff: _selectedDiff);
          },
          onSubmitted: (v) =>
              _applyFilter(catId: _selectedCatId, diff: _selectedDiff, q: v),
          textInputAction: TextInputAction.search,
        ),
      );

  // ─── Category select box ─────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    final selected = _categories.where((c) => c.id == _selectedCatId).firstOrNull;
    final selectedColor = selected != null
        ? Color(int.parse(selected.color.replaceFirst('#', 'FF'), radix: 16))
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GestureDetector(
        onTap: _categoriesLoading ? null : _openCategorySheet,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _selectedCatId != null
                ? selectedColor.withValues(alpha: 0.08)
                : context.cardElevated,
            borderRadius: AppRadius.rMd,
            border: _selectedCatId != null
                ? Border.all(color: selectedColor.withValues(alpha: 0.5), width: 1.5)
                : null,
            boxShadow: _selectedCatId != null ? null : AppShadows.card(context),
          ),
          child: Row(
            children: [
              if (_categoriesLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: context.appColors.textMuted,
                    strokeWidth: 2,
                  ),
                )
              else
                Text(
                  selected?.icon ?? '📚',
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _categoriesLoading
                      ? 'Chargement...'
                      : selected?.name ?? 'Toutes les catégories',
                  style: TextStyle(
                    color: _selectedCatId != null
                        ? selectedColor
                        : context.appColors.textSecondary,
                    fontSize: 14,
                    fontWeight: _selectedCatId != null
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (_selectedCatId != null)
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedCatId = null);
                    _applyFilter(diff: _selectedDiff, q: _searchCtrl.text);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selectedColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, color: selectedColor, size: 12),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.appColors.textMuted,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
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

  // ─── Difficulty chips ─────────────────────────────────────────────────────────

  Widget _buildDiffChips() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final entry in {
                null: 'Difficulté',
                'easy': 'Facile',
                'medium': 'Moyen',
                'hard': 'Difficile',
              }.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: entry.value,
                    selected: _selectedDiff == entry.key,
                    color: entry.key == null
                        ? context.appColors.textSecondary
                        : AppColors.difficultyColor(entry.key!),
                    onTap: () {
                      setState(() => _selectedDiff = entry.key);
                      _applyFilter(
                          catId: _selectedCatId,
                          diff: entry.key,
                          q: _searchCtrl.text);
                    },
                  ),
                ),
            ],
          ),
        ),
      );

  // ─── Count ───────────────────────────────────────────────────────────────────

  Widget _buildCount() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${_ctrl.quizzes.length} quiz${_ctrl.quizzes.length > 1 ? 'zes' : ''}',
            style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
          ),
        ),
      );

  // ─── List ─────────────────────────────────────────────────────────────────────

  Widget _buildList() {
    if (_ctrl.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: QuizListSkeleton(),
      );
    }
    if (_ctrl.error != null) {
      return ErrorState(message: _ctrl.error!, onRetry: _ctrl.load);
    }
    if (_ctrl.quizzes.isEmpty) {
      return const EmptyState(
        title: 'Aucun quiz trouvé',
        subtitle: 'Essaie un autre filtre ou une autre recherche',
        emoji: '🔍',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _ctrl.load(),
      color: AppColors.primary,
      backgroundColor: context.appColors.cardBg,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _ctrl.quizzes.length + (_ctrl.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          if (i == _ctrl.quizzes.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2),
              ),
            );
          }
          return QuizCard(
            quiz: _ctrl.quizzes[i],
            style: QuizCardStyle.list,
            onTap: () => Navigator.push(
              ctx,
              SlideRightRoute(
                  page: QuizDetailScreen(quizId: _ctrl.quizzes[i].id)),
            ),
          );
        },
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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            children: [
              Text(
                'Catégories',
                style: TextStyle(
                  color: context.appColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (widget.selectedId != null)
                GestureDetector(
                  onTap: () => widget.onSelect(null),
                  child: const Text(
                    'Tout voir',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
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
                    autofocus: false,
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
        const Divider(height: 1),
        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'Aucun résultat pour "$_query"',
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
                          borderRadius: BorderRadius.circular(14),
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(cat.icon ?? '📚',
                                    style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? color
                                          : context.appColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  if (cat.quizCount > 0)
                                    Text(
                                      '${cat.quizCount} quiz${cat.quizCount > 1 ? 'zes' : ''}',
                                      style: TextStyle(
                                        color: context.appColors.textMuted,
                                        fontSize: 12,
                                      ),
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : context.appColors.border,
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
