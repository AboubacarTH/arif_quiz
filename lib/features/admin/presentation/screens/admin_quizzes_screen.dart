import 'dart:async';

import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/features/admin/presentation/widgets/translations_section.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:file_picker/file_picker.dart';
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

  /// Choix de la langue cible avant l'import :
  /// en = nouvelles questions ; fr/ar/es = traductions des questions existantes.
  Future<String?> _pickImportLocale() {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Langue du fichier',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          for (final l in const [
            (code: 'en', label: 'Anglais — nouvelles questions'),
            (code: 'fr', label: 'Français — traductions'),
            (code: 'ar', label: 'العربية — traductions'),
            (code: 'es', label: 'Español — traductions'),
          ])
            ListTile(
              title: Text(l.label),
              subtitle: l.code == 'en'
                  ? const Text('Ajoutées à la suite des questions existantes',
                      style: TextStyle(fontSize: 12))
                  : const Text('Appliquées aux questions existantes (colonne order)',
                      style: TextStyle(fontSize: 12)),
              onTap: () => Navigator.pop(ctx, l.code),
            ),
        ],
      ),
    );
  }

  Future<void> _importQuestions(AdminQuizModel quiz) async {
    final locale = await _pickImportLocale();
    if (locale == null) return;

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    if (file.path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Impossible d\'accéder au fichier sélectionné.'),
            backgroundColor: AppColors.error));
      }
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final res = await _repo.importQuestionsToQuiz(
          quizId: quiz.id,
          filePath: file.path!,
          fileName: file.name,
          locale: locale);
      if (!mounted) return;
      Navigator.pop(context); // ferme le loader
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] as String? ?? 'Questions importées.'),
          backgroundColor: AppColors.success));
      _load(reset: true);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: AppColors.error));
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
            onImport: () => _importQuestions(_quizzes[i]),
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
  final VoidCallback onImport;
  final VoidCallback onDelete;

  const _QuizTile({required this.quiz, required this.onEdit, required this.onToggle, required this.onImport, required this.onDelete});

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
                  onPressed: onImport,
                  icon: const Icon(Icons.upload_file_rounded, size: 15),
                  label: const Text('Importer'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(horizontal: 10)),
                ),
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
  bool _inJourney = false;
  String _visibility = 'public';
  final Set<int> _allowedUserIds = {};
  // Cache id → libellé pour afficher les utilisateurs déjà assignés.
  final Map<int, String> _userLabels = {};
  late final TranslationsMap _translations;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final q = widget.quiz;
    _translations = copyTranslations(q?.translations ?? const {});
    _title    = TextEditingController(text: q?.title ?? '');
    _desc     = TextEditingController(text: q?.description ?? '');
    _timeLimit = TextEditingController(text: (q?.timeLimit ?? 30).toString());
    _points   = TextEditingController(text: (q?.pointsPerQuestion ?? 10).toString());
    _categoryId  = q?.categoryId ?? (widget.categories.isNotEmpty ? widget.categories.first.id : null);
    _difficulty  = q?.difficulty ?? 'medium';
    _isPublished = q?.isPublished ?? false;
    _inJourney   = q?.inJourney ?? false;
    _visibility  = q?.visibility ?? 'public';
    _allowedUserIds.addAll(q?.allowedUserIds ?? const []);
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
        'in_journey': _inJourney,
        'visibility': _visibility,
        'allowed_user_ids':
            _visibility == 'restricted' ? _allowedUserIds.toList() : <int>[],
        'translations': _translations,
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
            SwitchListTile(
              value: _inJourney,
              onChanged: (v) => setState(() => _inJourney = v),
              title: Text('Inclure dans le Mode Parcours', style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: Text('Ses questions alimentent la map à niveaux', style: TextStyle(color: context.appColors.textMuted, fontSize: 12)),
              activeThumbColor: AppColors.secondary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _visibility,
              decoration: _inputDecoration('Visibilité'),
              items: const [
                DropdownMenuItem(value: 'public', child: Text('Public — visible par tous')),
                DropdownMenuItem(value: 'restricted', child: Text('Restreint — utilisateurs choisis')),
              ],
              onChanged: (v) => setState(() => _visibility = v ?? 'public'),
              dropdownColor: context.appColors.cardBg,
            ),
            if (_visibility == 'restricted') ...[
              const SizedBox(height: 12),
              _buildUserPicker(),
            ],
            const SizedBox(height: 20),
            TranslationsSection(
              filled: (l) => trGet(_translations, l, 'title').trim().isNotEmpty,
              builder: (ctx, locale) => Column(
                children: [
                  TextFormField(
                    initialValue: trGet(_translations, locale, 'title'),
                    decoration: _inputDecoration('Titre ($locale)'),
                    onChanged: (v) =>
                        setState(() => trSet(_translations, locale, 'title', v)),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: trGet(_translations, locale, 'description'),
                    maxLines: 3,
                    decoration: _inputDecoration('Description ($locale)'),
                    onChanged: (v) => trSet(
                        _translations, locale, 'description', v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Utilisateurs autorisés',
                style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            const Spacer(),
            Text('${_allowedUserIds.length} sélectionné(s)',
                style: TextStyle(color: context.appColors.textMuted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _openUserPicker,
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
          label: const Text('Choisir des utilisateurs'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        if (_allowedUserIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allowedUserIds.map((id) {
              final label = _userLabels[id] ?? 'ID $id';
              return Chip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                backgroundColor: context.appColors.cardBg,
                onDeleted: () => setState(() => _allowedUserIds.remove(id)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _openUserPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _UserPickerSheet(
        repo: widget.repo,
        selected: _allowedUserIds,
        labels: _userLabels,
        onChanged: () => setState(() {}),
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

// ─── Sélecteur d'utilisateurs (quiz restreint) ───────────────────────────────

class _UserPickerSheet extends StatefulWidget {
  final AdminRepository repo;
  final Set<int> selected;
  final Map<int, String> labels;
  final VoidCallback onChanged;

  const _UserPickerSheet({
    required this.repo,
    required this.selected,
    required this.labels,
    required this.onChanged,
  });

  @override
  State<_UserPickerSheet> createState() => _UserPickerSheetState();
}

class _UserPickerSheetState extends State<_UserPickerSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<({int id, String name, String? username})> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load(String q) async {
    setState(() => _loading = true);
    try {
      final users = await widget.repo.searchUsers(q);
      if (!mounted) return;
      setState(() {
        _results = users;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _load(v.trim()));
  }

  void _toggle(({int id, String name, String? username}) u) {
    setState(() {
      if (widget.selected.contains(u.id)) {
        widget.selected.remove(u.id);
      } else {
        widget.selected.add(u.id);
        widget.labels[u.id] = u.username != null && u.username!.isNotEmpty
            ? '${u.name} (@${u.username})'
            : u.name;
      }
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: context.appColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: _onSearch,
                style: TextStyle(color: context.appColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Rechercher (nom, username, email)…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: context.appColors.bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : _results.isEmpty
                      ? Center(
                          child: Text('Aucun utilisateur',
                              style: TextStyle(color: context.appColors.textMuted)))
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (_, i) {
                            final u = _results[i];
                            final sel = widget.selected.contains(u.id);
                            return CheckboxListTile(
                              value: sel,
                              onChanged: (_) => _toggle(u),
                              activeColor: AppColors.primary,
                              title: Text(u.name,
                                  style: TextStyle(
                                      color: context.appColors.textPrimary,
                                      fontWeight: FontWeight.w600)),
                              subtitle: u.username != null
                                  ? Text('@${u.username}',
                                      style: TextStyle(
                                          color: context.appColors.textMuted,
                                          fontSize: 12))
                                  : null,
                            );
                          },
                        ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: Text('OK · ${widget.selected.length} sélectionné(s)'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
