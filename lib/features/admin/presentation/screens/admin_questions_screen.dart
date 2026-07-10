import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AdminQuestionsScreen extends StatefulWidget {
  final int? initialQuizId;
  const AdminQuestionsScreen({super.key, this.initialQuizId});

  @override
  State<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends State<AdminQuestionsScreen> {
  late final AdminRepository _repo;
  List<AdminQuestionModel> _questions = [];
  List<AdminQuizModel> _quizzes = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _lastPage = 1;

  final _searchCtrl = TextEditingController();
  int? _filterQuizId;
  String? _filterType;

  @override
  void initState() {
    super.initState();
    _repo = AdminRepository(apiService);
    _filterQuizId = widget.initialQuizId;
    _loadQuizzes();
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuizzes() async {
    try {
      final result = await _repo.getQuizzes();
      if (mounted) setState(() => _quizzes = result.quizzes);
    } catch (_) {}
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) setState(() { _loading = true; _error = null; _page = 1; });
    try {
      final result = await _repo.getQuestions(
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        quizId: _filterQuizId,
        type: _filterType,
        page: _page,
      );
      if (mounted) {
        setState(() {
          if (reset) {
            _questions = result.questions;
          } else {
            _questions.addAll(result.questions);
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

  void _showForm({AdminQuestionModel? question}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _QuestionFormScreen(
          repo: _repo,
          question: question,
          quizzes: _quizzes,
          defaultQuizId: _filterQuizId,
          onSaved: () => _load(reset: true),
        ),
      ),
    );
  }

  Future<void> _delete(AdminQuestionModel q) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Cette question sera supprimée définitivement.'),
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
      await _repo.deleteQuestion(q.id);
      _load(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: const Text('Questions', style: TextStyle(fontWeight: FontWeight.w800)),
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
              hintText: 'Rechercher une question...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () { _searchCtrl.clear(); _load(reset: true); })
                  : null,
              filled: true,
              fillColor: context.appColors.cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.appColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.appColors.border)),
            ),
            onChanged: (_) => _load(reset: true),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: _filterQuizId == null ? 'Quiz' : (_quizzes.where((q) => q.id == _filterQuizId).firstOrNull?.title ?? 'Quiz'),
                  active: _filterQuizId != null,
                  onTap: _showQuizFilter,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: _filterType == null ? 'Type' : _typeLabel(_filterType!),
                  active: _filterType != null,
                  onTap: _showTypeFilter,
                ),
                if (_filterQuizId != null || _filterType != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() {
                      _filterQuizId = null; _filterType = null;
                      _load(reset: true);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
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

  void _showQuizFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Filtrer par quiz', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Tous'),
            onTap: () { setState(() => _filterQuizId = null); Navigator.pop(context); _load(reset: true); },
          ),
          ..._quizzes.map((q) => ListTile(
            title: Text(q.title),
            trailing: _filterQuizId == q.id ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () { setState(() => _filterQuizId = q.id); Navigator.pop(context); _load(reset: true); },
          )),
        ],
      ),
    );
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Filtrer par type', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          for (final t in [null, 'multiple_choice', 'true_false', 'short_answer'])
            ListTile(
              title: Text(t == null ? 'Tous' : _typeLabel(t)),
              trailing: _filterType == t ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () { setState(() => _filterType = t); Navigator.pop(context); _load(reset: true); },
            ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) return Center(child: Text(_error!, style: TextStyle(color: context.appColors.textSecondary)));
    if (_questions.isEmpty) return Center(child: Text('Aucune question trouvée', style: TextStyle(color: context.appColors.textSecondary)));

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _questions.length + (_page < _lastPage ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i == _questions.length) {
            _loadMore();
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary)));
          }
          return _QuestionTile(
            q: _questions[i],
            onEdit: () => _showForm(question: _questions[i]),
            onDelete: () => _delete(_questions[i]),
          );
        },
      ),
    );
  }

  String _typeLabel(String t) => t == 'multiple_choice' ? 'QCM' : t == 'true_false' ? 'Vrai/Faux' : 'Réponse libre';
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

class _QuestionTile extends StatelessWidget {
  final AdminQuestionModel q;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionTile({required this.q, required this.onEdit, required this.onDelete});

  String get _typeLabel => q.type == 'multiple_choice' ? 'QCM' : q.type == 'true_false' ? 'Vrai/Faux' : 'Réponse libre';
  Color get _typeColor => q.type == 'multiple_choice' ? AppColors.info : q.type == 'true_false' ? AppColors.success : AppColors.secondary;

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: _typeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(_typeLabel, style: TextStyle(color: _typeColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                if (q.quizTitle != null)
                  Expanded(
                    child: Text(q.quizTitle!, style: TextStyle(color: context.appColors.textMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(q.text, style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(q.correctAnswer, style: TextStyle(color: AppColors.success, fontSize: 12), overflow: TextOverflow.ellipsis),
                ),
                Text('${q.points} pts', style: TextStyle(color: context.appColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            if (q.options != null && q.options!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: q.options!.map((o) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: o == q.correctAnswer ? AppColors.success.withValues(alpha: 0.1) : context.appColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: o == q.correctAnswer ? AppColors.success.withValues(alpha: 0.3) : context.appColors.border),
                  ),
                  child: Text(o, style: TextStyle(color: o == q.correctAnswer ? AppColors.success : context.appColors.textSecondary, fontSize: 11)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text('Modifier'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.info, padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded, size: 14),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error, padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
              ],
            ),
          ],
        ),
      );
}

// ─── Question Form Screen ─────────────────────────────────────────────────────

class _QuestionFormScreen extends StatefulWidget {
  final AdminRepository repo;
  final AdminQuestionModel? question;
  final List<AdminQuizModel> quizzes;
  final int? defaultQuizId;
  final VoidCallback onSaved;

  const _QuestionFormScreen({
    required this.repo,
    this.question,
    required this.quizzes,
    this.defaultQuizId,
    required this.onSaved,
  });

  @override
  State<_QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<_QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _text;
  late final TextEditingController _explanation;
  late final TextEditingController _correctAnswer;
  late final TextEditingController _order;
  late final TextEditingController _points;
  late final TextEditingController _imageUrl;
  late final TextEditingController _audioUrl;
  final List<TextEditingController> _optionCtrls = [];

  int? _quizId;
  String _type = 'multiple_choice';
  bool _saving = false;
  bool _uploadingImage = false;
  bool _uploadingAudio = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final q = widget.question;
    _text        = TextEditingController(text: q?.text ?? '');
    _explanation = TextEditingController(text: q?.explanation ?? '');
    _correctAnswer = TextEditingController(text: q?.correctAnswer ?? '');
    _order       = TextEditingController(text: (q?.order ?? 0).toString());
    _points      = TextEditingController(text: (q?.points ?? 10).toString());
    _imageUrl    = TextEditingController(text: q?.imageUrl ?? '');
    _audioUrl    = TextEditingController(text: q?.audioUrl ?? '');
    _quizId      = q?.quizId ?? widget.defaultQuizId ?? (widget.quizzes.isNotEmpty ? widget.quizzes.first.id : null);
    _type        = q?.type ?? 'multiple_choice';

    final opts = q?.options ?? ['', '', '', ''];
    for (final o in opts) {
      _optionCtrls.add(TextEditingController(text: o));
    }
    if (_optionCtrls.isEmpty && _type == 'multiple_choice') {
      for (var i = 0; i < 4; i++) { _optionCtrls.add(TextEditingController()); }
    }
  }

  @override
  void dispose() {
    _text.dispose(); _explanation.dispose(); _correctAnswer.dispose();
    _order.dispose(); _points.dispose();
    _imageUrl.dispose(); _audioUrl.dispose();
    for (final c in _optionCtrls) { c.dispose(); }
    super.dispose();
  }

  void _setType(String t) {
    setState(() {
      _type = t;
      if (t == 'true_false') {
        _correctAnswer.text = 'True';
      } else if (t == 'multiple_choice' && _optionCtrls.isEmpty) {
        for (var i = 0; i < 4; i++) { _optionCtrls.add(TextEditingController()); }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final options = _type == 'multiple_choice'
          ? _optionCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList()
          : null;

      final data = {
        'quiz_id': _quizId,
        'text': _text.text.trim(),
        'type': _type,
        if (options != null) 'options': options,
        'correct_answer': _correctAnswer.text.trim(),
        'explanation': _explanation.text.trim().isEmpty ? null : _explanation.text.trim(),
        'image_url': _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
        'audio_url': _audioUrl.text.trim().isEmpty ? null : _audioUrl.text.trim(),
        'order': int.parse(_order.text.trim()),
        'points': int.parse(_points.text.trim()),
      };

      if (widget.question == null) {
        await widget.repo.createQuestion(data);
      } else {
        await widget.repo.updateQuestion(widget.question!.id, data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.question != null;
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Text(isEdit ? 'Modifier la question' : 'Nouvelle question', style: const TextStyle(fontWeight: FontWeight.w800)),
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
            // Quiz selector
            DropdownButtonFormField<int>(
              initialValue: _quizId,
              decoration: _dec('Quiz *'),
              items: widget.quizzes.map((q) => DropdownMenuItem(value: q.id, child: Text(q.title, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setState(() => _quizId = v),
              validator: (v) => v == null ? 'Requis' : null,
              dropdownColor: context.appColors.cardBg,
            ),
            const SizedBox(height: 12),
            // Type selector
            Text('Type *', style: TextStyle(color: context.appColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final t in ['multiple_choice', 'true_false', 'short_answer'])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => _setType(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _type == t ? AppColors.primary : context.appColors.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _type == t ? AppColors.primary : context.appColors.border),
                          ),
                          child: Text(
                            t == 'multiple_choice' ? 'QCM' : t == 'true_false' ? 'Vrai/Faux' : 'Libre',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _type == t ? Colors.white : context.appColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Question text
            TextFormField(
              controller: _text,
              maxLines: 3,
              decoration: _dec('Question *'),
              validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            // Options (QCM only)
            if (_type == 'multiple_choice') ...[
              Text('Options *', style: TextStyle(color: context.appColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              for (var i = 0; i < _optionCtrls.length; i++) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _optionCtrls[i],
                        decoration: _dec('Option ${i + 1}'),
                      ),
                    ),
                    if (_optionCtrls.length > 2)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 20),
                        onPressed: () {
                          final c = _optionCtrls.removeAt(i);
                          c.dispose();
                          setState(() {});
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (_optionCtrls.length < 6)
                TextButton.icon(
                  onPressed: () => setState(() => _optionCtrls.add(TextEditingController())),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Ajouter une option'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _correctAnswer,
                decoration: _dec('Bonne réponse * (doit correspondre à une option)'),
                validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
            ],
            // True/False
            if (_type == 'true_false') ...[
              Text('Bonne réponse *', style: TextStyle(color: context.appColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final v in ['True', 'False'])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _correctAnswer.text = v),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _correctAnswer.text == v ? AppColors.primary : context.appColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _correctAnswer.text == v ? AppColors.primary : context.appColors.border),
                            ),
                            child: Text(
                              v,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _correctAnswer.text == v ? Colors.white : context.appColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // Short answer
            if (_type == 'short_answer') ...[
              TextFormField(
                controller: _correctAnswer,
                decoration: _dec('Bonne réponse *'),
                validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
            ],
            // Explanation
            TextFormField(
              controller: _explanation,
              maxLines: 2,
              decoration: _dec('Explication (optionnel)'),
            ),
            const SizedBox(height: 16),
            // Média (image / audio)
            Text('Média (optionnel)', style: TextStyle(color: context.appColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _mediaField('Image', _imageUrl, 'image', _uploadingImage),
            const SizedBox(height: 12),
            _mediaField('Audio', _audioUrl, 'audio', _uploadingAudio),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(
                  controller: _order,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Ordre'),
                  validator: (v) => int.tryParse(v ?? '') == null ? 'Nombre entier' : null,
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _points,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Points'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1 || n > 1000) return '1–1000';
                    return null;
                  },
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: context.appColors.cardBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.appColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.appColors.border)),
      );

  Widget _mediaField(String label, TextEditingController ctrl, String type, bool uploading) {
    final isImage = type == 'image';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: ctrl,
                decoration: _dec('$label (URL, optionnel)'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: uploading ? null : () => _pickAndUpload(type),
                icon: uploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload_rounded, size: 18),
                label: Text(uploading ? '...' : 'Fichier'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.secondary),
              ),
            ),
          ],
        ),
        if (ctrl.text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: ctrl.text.trim(),
                height: 110,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => Icon(Icons.broken_image_rounded,
                    color: context.appColors.textMuted, size: 30),
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.audiotrack_rounded, color: AppColors.secondary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(ctrl.text.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: context.appColors.textMuted, fontSize: 12)),
                ),
              ],
            ),
        ],
      ],
    );
  }

  Future<void> _pickAndUpload(String type) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: type == 'image'
          ? ['jpg', 'jpeg', 'png', 'gif', 'webp']
          : ['mp3', 'wav', 'ogg', 'm4a', 'aac'],
    );
    if (picked == null || picked.files.isEmpty) return;
    final f = picked.files.first;
    if (f.path == null) return;

    setState(() {
      if (type == 'image') {
        _uploadingImage = true;
      } else {
        _uploadingAudio = true;
      }
    });
    try {
      final url = await widget.repo
          .uploadMedia(type: type, filePath: f.path!, fileName: f.name);
      if (!mounted) return;
      setState(() {
        if (type == 'image') {
          _imageUrl.text = url;
        } else {
          _audioUrl.text = url;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Upload échoué : $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploadingImage = false;
          _uploadingAudio = false;
        });
      }
    }
  }
}
