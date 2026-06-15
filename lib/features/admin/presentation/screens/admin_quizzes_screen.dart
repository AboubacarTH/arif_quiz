import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class AdminQuizzesScreen extends StatefulWidget {
  const AdminQuizzesScreen({super.key});

  @override
  State<AdminQuizzesScreen> createState() => _AdminQuizzesScreenState();
}

class _AdminQuizzesScreenState extends State<AdminQuizzesScreen> {
  late final AdminRepository _repo;
  List<AdminQuizModel> _quizzes = [];
  List<AdminCategoryModel> _categories = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _lastPage = 1;

  final _searchCtrl = TextEditingController();
  int? _filterCategoryId;
  String? _filterDifficulty;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _repo = AdminRepository(apiService);
    _loadCategories();
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _repo.getCategories();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() { _loading = true; _error = null; _page = 1; });
    }
    try {
      final result = await _repo.getQuizzes(
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        categoryId: _filterCategoryId,
        difficulty: _filterDifficulty,
        status: _filterStatus,
        page: _page,
      );
      if (mounted) {
        setState(() {
          if (reset) {
            _quizzes = result.quizzes;
          } else {
            _quizzes.addAll(result.quizzes);
          }
          _lastPage = result.lastPage;
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; _loadingMore = false; });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _lastPage) return;
    setState(() { _loadingMore = true; _page++; });
    await _load();
  }

  void _applyFilters() => _load(reset: true);

  Future<void> _toggle(AdminQuizModel quiz) async {
    try {
      final newVal = await _repo.toggleQuiz(quiz.id);
      setState(() {
        final idx = _quizzes.indexWhere((q) => q.id == quiz.id);
        if (idx != -1) {
          _quizzes[idx] = AdminQuizModel(
            id: quiz.id, categoryId: quiz.categoryId, title: quiz.title,
            description: quiz.description, difficulty: quiz.difficulty,
            timeLimit: quiz.timeLimit, totalQuestions: quiz.totalQuestions,
            pointsPerQuestion: quiz.pointsPerQuestion, isPublished: newVal,
            thumbnail: quiz.thumbnail, playCount: quiz.playCount,
            questionsCount: quiz.questionsCount, attemptsCount: quiz.attemptsCount,
            category: quiz.category,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _delete(AdminQuizModel quiz) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Supprimer "${quiz.title}" et toutes ses questions ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.deleteQuiz(quiz.id);
      _load(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showForm({AdminQuizModel? quiz}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _QuizFormScreen(
          repo: _repo,
          quiz: quiz,
          categories: _categories,
          onSaved: () => _load(reset: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: const Text('Quiz', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), color: AppColors.primary, onPressed: () => _showForm()),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Rechercher un quiz...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () { _searchCtrl.clear(); _applyFilters(); })
                  : null,
              filled: true,
              fillColor: context.appColors.cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.appColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.appColors.border)),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: _filterCategoryId == null ? 'Catégorie' : (_categories.firstWhere((c) => c.id == _filterCategoryId, orElse: () => _categories.first).name),
                  active: _filterCategoryId != null,
                  onTap: () => _showCategoryFilter(),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _filterDifficulty ?? 'Difficulté',
                  active: _filterDifficulty != null,
                  onTap: () => _showDifficultyFilter(),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _filterStatus == null ? 'Statut' : (_filterStatus == 'published' ? 'Publié' : 'Brouillon'),
                  active: _filterStatus != null,
                  onTap: () => _showStatusFilter(),
                ),
                if (_filterCategoryId != null || _filterDifficulty != null || _filterStatus != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() {
                      _filterCategoryId = null; _filterDifficulty = null; _filterStatus = null;
                      _applyFilters();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Réinitialiser', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Filtrer par catégorie', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Toutes'),
            onTap: () { setState(() => _filterCategoryId = null); Navigator.pop(context); _applyFilters(); },
          ),
          ..._categories.map((c) => ListTile(
            title: Text(c.name),
            trailing: _filterCategoryId == c.id ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () { setState(() => _filterCategoryId = c.id); Navigator.pop(context); _applyFilters(); },
          )),
        ],
      ),
    );
  }

  void _showDifficultyFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Filtrer par difficulté', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          for (final d in [null, 'easy', 'medium', 'hard'])
            ListTile(
              title: Text(d == null ? 'Toutes' : _difficultyLabel(d)),
              trailing: _filterDifficulty == d ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () { setState(() => _filterDifficulty = d); Navigator.pop(context); _applyFilters(); },
            ),
        ],
      ),
    );
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Filtrer par statut', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          for (final s in [null, 'published', 'draft'])
            ListTile(
              title: Text(s == null ? 'Tous' : (s == 'published' ? 'Publié' : 'Brouillon')),
              trailing: _filterStatus == s ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () { setState(() => _filterStatus = s); Navigator.pop(context); _applyFilters(); },
            ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) return Center(child: Text(_error!, style: TextStyle(color: context.appColors.textSecondary)));
    if (_quizzes.isEmpty) return Center(child: Text('Aucun quiz trouvé', style: TextStyle(color: context.appColors.textSecondary)));

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _quizzes.length + (_page < _lastPage ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i == _quizzes.length) {
            _loadMore();
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary)));
          }
          return _QuizTile(
            quiz: _quizzes[i],
            onEdit: () => _showForm(quiz: _quizzes[i]),
            onToggle: () => _toggle(_quizzes[i]),
            onDelete: () => _delete(_quizzes[i]),
          );
        },
      ),
    );
  }

  String _difficultyLabel(String d) => d == 'easy' ? 'Facile' : d == 'medium' ? 'Moyen' : 'Difficile';
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withValues(alpha: 0.12) : context.appColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? AppColors.primary : context.appColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.primary : context.appColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}

class _QuizTile extends StatelessWidget {
  final AdminQuizModel quiz;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _QuizTile({required this.quiz, required this.onEdit, required this.onToggle, required this.onDelete});

  Color get _diffColor => quiz.difficulty == 'easy' ? AppColors.easy : quiz.difficulty == 'medium' ? AppColors.medium : AppColors.hard;
  String get _diffLabel => quiz.difficulty == 'easy' ? 'Facile' : quiz.difficulty == 'medium' ? 'Moyen' : 'Difficile';

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(quiz.title, style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (quiz.isPublished ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quiz.isPublished ? 'Publié' : 'Brouillon',
                      style: TextStyle(
                        color: quiz.isPublished ? AppColors.success : AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                if (quiz.category != null)
                  _Tag(label: quiz.category!.name, color: AppColors.info),
                _Tag(label: _diffLabel, color: _diffColor),
                _Tag(label: '${quiz.questionsCount} questions', color: AppColors.primary),
                _Tag(label: '${quiz.attemptsCount} essais', color: context.appColors.textMuted),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 15),
                  label: const Text('Modifier'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.info, padding: const EdgeInsets.symmetric(horizontal: 10)),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded, size: 15),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error, padding: const EdgeInsets.symmetric(horizontal: 10)),
                ),
              ],
            ),
          ],
        ),
      );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

// ─── Quiz Form Screen ─────────────────────────────────────────────────────────

class _QuizFormScreen extends StatefulWidget {
  final AdminRepository repo;
  final AdminQuizModel? quiz;
  final List<AdminCategoryModel> categories;
  final VoidCallback onSaved;

  const _QuizFormScreen({required this.repo, this.quiz, required this.categories, required this.onSaved});

  @override
  State<_QuizFormScreen> createState() => _QuizFormScreenState();
}

class _QuizFormScreenState extends State<_QuizFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _timeLimit;
  late final TextEditingController _points;
  int? _categoryId;
  String _difficulty = 'medium';
  bool _isPublished = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final q = widget.quiz;
    _title    = TextEditingController(text: q?.title ?? '');
    _desc     = TextEditingController(text: q?.description ?? '');
    _timeLimit = TextEditingController(text: (q?.timeLimit ?? 30).toString());
    _points   = TextEditingController(text: (q?.pointsPerQuestion ?? 10).toString());
    _categoryId  = q?.categoryId ?? (widget.categories.isNotEmpty ? widget.categories.first.id : null);
    _difficulty  = q?.difficulty ?? 'medium';
    _isPublished = q?.isPublished ?? false;
  }

  @override
  void dispose() {
    _title.dispose(); _desc.dispose(); _timeLimit.dispose(); _points.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final data = {
        'category_id': _categoryId,
        'title': _title.text.trim(),
        'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        'difficulty': _difficulty,
        'time_limit': int.parse(_timeLimit.text.trim()),
        'points_per_question': int.parse(_points.text.trim()),
        'is_published': _isPublished,
      };
      if (widget.quiz == null) {
        await widget.repo.createQuiz(data);
      } else {
        await widget.repo.updateQuiz(widget.quiz!.id, data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.quiz != null;
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Text(isEdit ? 'Modifier le quiz' : 'Nouveau quiz', style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : const Text('Enregistrer', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
              const SizedBox(height: 12),
            ],
            _field('Titre *', _title, validator: (v) => v!.trim().isEmpty ? 'Requis' : null),
            const SizedBox(height: 12),
            _field('Description', _desc, maxLines: 3),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _categoryId,
              decoration: _inputDecoration('Catégorie *'),
              items: widget.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? 'Requis' : null,
              dropdownColor: context.appColors.cardBg,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _difficulty,
              decoration: _inputDecoration('Difficulté *'),
              items: const [
                DropdownMenuItem(value: 'easy', child: Text('Facile')),
                DropdownMenuItem(value: 'medium', child: Text('Moyen')),
                DropdownMenuItem(value: 'hard', child: Text('Difficile')),
              ],
              onChanged: (v) => setState(() => _difficulty = v!),
              dropdownColor: context.appColors.cardBg,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field('Temps (s) *', _timeLimit, keyboardType: TextInputType.number, validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 5 || n > 600) return '5–600';
                  return null;
                })),
                const SizedBox(width: 12),
                Expanded(child: _field('Points/question *', _points, keyboardType: TextInputType.number, validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 1000) return '1–1000';
                  return null;
                })),
              ],
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              value: _isPublished,
              onChanged: (v) => setState(() => _isPublished = v),
              title: Text('Publier le quiz', style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w600)),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: context.appColors.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.appColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.appColors.border)),
      );

  Widget _field(String label, TextEditingController ctrl, {String? Function(String?)? validator, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
    );
  }
}
