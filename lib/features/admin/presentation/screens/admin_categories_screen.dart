import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  late final AdminRepository _repo;
  List<AdminCategoryModel> _categories = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repo = AdminRepository(apiService);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String? search}) async {
    setState(() { _loading = true; _error = null; });
    try {
      _categories = await _repo.getCategories(search: search);
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showForm({AdminCategoryModel? cat}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CategoryForm(
        repo: _repo,
        category: cat,
        onSaved: () {
          Navigator.pop(context);
          _load(search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim());
        },
      ),
    );
  }

  Future<void> _delete(AdminCategoryModel cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Supprimer "${cat.name}" ? Cette action est irréversible.'),
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
      await _repo.deleteCategory(cat.id);
      _load();
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
        title: const Text('Catégories', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppColors.primary,
            onPressed: () => _showForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: context.appColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.appColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.appColors.border),
                ),
              ),
              onChanged: (v) => _load(search: v.trim().isEmpty ? null : v.trim()),
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) return Center(child: Text(_error!, style: TextStyle(color: context.appColors.textSecondary)));
    if (_categories.isEmpty) return Center(child: Text('Aucune catégorie', style: TextStyle(color: context.appColors.textSecondary)));

    return RefreshIndicator(
      onRefresh: () => _load(search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim()),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _CategoryTile(
          cat: _categories[i],
          onEdit: () => _showForm(cat: _categories[i]),
          onDelete: () => _delete(_categories[i]),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final AdminCategoryModel cat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({required this.cat, required this.onEdit, required this.onDelete});

  Color _parseColor() {
    try {
      final hex = cat.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor();
    return Container(
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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: cat.icon != null
                  ? Text(cat.icon!, style: const TextStyle(fontSize: 20))
                  : Icon(Icons.category_rounded, color: color, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(cat.name, style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(width: 6),
                    if (!cat.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Inactif', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${cat.quizzesCount} quiz · ${cat.publishedQuizzesCount} publiés',
                  style: TextStyle(color: context.appColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_rounded, size: 18), color: AppColors.info, onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_rounded, size: 18), color: AppColors.error, onPressed: onDelete),
        ],
      ),
    );
  }
}

class _CategoryForm extends StatefulWidget {
  final AdminRepository repo;
  final AdminCategoryModel? category;
  final VoidCallback onSaved;

  const _CategoryForm({required this.repo, this.category, required this.onSaved});

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _icon;
  late final TextEditingController _color;
  late bool _isActive;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    _name  = TextEditingController(text: cat?.name ?? '');
    _desc  = TextEditingController(text: cat?.description ?? '');
    _icon  = TextEditingController(text: cat?.icon ?? '');
    _color = TextEditingController(text: cat?.color ?? '#16A34A');
    _isActive = cat?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose(); _desc.dispose(); _icon.dispose(); _color.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final data = {
        'name': _name.text.trim(),
        'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        'icon': _icon.text.trim().isEmpty ? null : _icon.text.trim(),
        'color': _color.text.trim(),
        'is_active': _isActive,
      };
      if (widget.category == null) {
        await widget.repo.createCategory(data);
      } else {
        await widget.repo.updateCategory(widget.category!.id, data);
      }
      widget.onSaved();
    } catch (e) {
      setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isEdit ? 'Modifier la catégorie' : 'Nouvelle catégorie',
                  style: TextStyle(color: context.appColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ),
              const SizedBox(height: 12),
            ],
            _field('Nom *', _name, validator: (v) => v!.trim().isEmpty ? 'Requis' : null),
            const SizedBox(height: 10),
            _field('Description', _desc),
            const SizedBox(height: 10),
            _field('Icône (emoji)', _icon, hint: '🎓'),
            const SizedBox(height: 10),
            _field('Couleur (hex) *', _color, hint: '#16A34A', validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Requis';
              if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(v.trim())) return 'Format: #RRGGBB';
              return null;
            }),
            const SizedBox(height: 10),
            SwitchListTile(
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
              title: Text('Catégorie active', style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w600)),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Enregistrer' : 'Créer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: context.appColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.appColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.appColors.border)),
      ),
    );
  }
}
