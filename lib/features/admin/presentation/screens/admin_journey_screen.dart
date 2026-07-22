import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/features/admin/presentation/screens/admin_questions_screen.dart';
import 'package:arif_quiz/features/admin/presentation/widgets/export_questions_sheet.dart';
import 'package:arif_quiz/features/admin/presentation/widgets/translations_section.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Administration du Mode Parcours : création, réglage, ordre et publication
/// des paliers. Les questions d'un niveau s'ouvrent depuis sa tuile — chaque
/// niveau possède les siennes, aucune n'est partagée avec un quiz.
///
/// La liste est affichée sommet en haut / départ en bas, comme la map côté
/// joueur : l'admin voit littéralement ce que le joueur va gravir.
class AdminJourneyScreen extends StatefulWidget {
  const AdminJourneyScreen({super.key});

  @override
  State<AdminJourneyScreen> createState() => _AdminJourneyScreenState();
}

class _AdminJourneyScreenState extends State<AdminJourneyScreen> {
  late final AdminRepository _repo;
  List<AdminJourneyLevelModel> _levels = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = AdminRepository(apiService);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _levels = await _repo.getJourneyLevels();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showForm({AdminJourneyLevelModel? level}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LevelForm(
        repo: _repo,
        level: level,
        nextPosition: _levels.isEmpty ? 1 : _levels.last.position + 1,
        onSaved: () {
          Navigator.pop(context);
          _load();
        },
      ),
    );
  }

  Future<void> _delete(AdminJourneyLevelModel level) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.confirmDeleteTitle,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(l10n.deleteJourneyLevelBody(
            level.displayTitle, level.questionsCount)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteBtn,
                style: const TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.deleteJourneyLevel(level.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  /// Échange deux paliers voisins. On envoie l'ordre complet : le serveur
  /// réécrit les positions 1..N d'un bloc, sans trou ni doublon.
  Future<void> _swap(int indexA, int indexB) async {
    if (indexA < 0 || indexB < 0 || indexA >= _levels.length || indexB >= _levels.length) {
      return;
    }
    final ids = _levels.map((l) => l.id).toList();
    final tmp = ids[indexA];
    ids[indexA] = ids[indexB];
    ids[indexB] = tmp;

    try {
      final updated = await _repo.reorderJourneyLevels(ids);
      if (mounted) setState(() => _levels = updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _export(AdminJourneyLevelModel level) {
    ExportQuestionsSheet.show(
      context,
      title: level.displayTitle,
      download: (locale) => _repo.exportJourneyLevelQuestions(
        levelId: level.id,
        levelTitle: level.displayTitle,
        locale: locale,
      ),
    );
  }

  void _openQuestions(AdminJourneyLevelModel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminQuestionsScreen(journeyLevel: level),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Text(l10n.journeyMapTitle,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppColors.primary,
            onPressed: () => _showForm(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
          child: Text(_error!,
              style: TextStyle(color: context.appColors.textSecondary)));
    }
    if (_levels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 42)),
              const SizedBox(height: 12),
              Text(l10n.noJourneyLevels,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(l10n.noJourneyLevelsHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: context.appColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _showForm(),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addLevel),
              ),
            ],
          ),
        ),
      );
    }

    // Sommet en haut, départ en bas : miroir de la map joueur.
    final displayed = _levels.reversed.toList();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: displayed.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final level = displayed[i];
          final realIndex = _levels.length - 1 - i;
          return _LevelTile(
            level: level,
            // Monter dans la liste = grimper sur la map = position + 1.
            onUp: i == 0 ? null : () => _swap(realIndex, realIndex + 1),
            onDown: i == displayed.length - 1
                ? null
                : () => _swap(realIndex, realIndex - 1),
            onEdit: () => _showForm(level: level),
            onDelete: () => _delete(level),
            onQuestions: () => _openQuestions(level),
            onExport: () => _export(level),
          );
        },
      ),
    );
  }
}

// ─── Tuile d'un niveau ───────────────────────────────────────────────────────

class _LevelTile extends StatelessWidget {
  final AdminJourneyLevelModel level;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onQuestions;
  final VoidCallback onExport;

  const _LevelTile({
    required this.level,
    required this.onUp,
    required this.onDown,
    required this.onEdit,
    required this.onDelete,
    required this.onQuestions,
    required this.onExport,
  });

  Color get _accent => level.isBoss ? AppColors.error : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Opacity(
      opacity: level.isPlayable ? 1 : 0.72,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(color: _accent, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('${level.position}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (level.isBoss) ...[
                            const Text('👑',
                                style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(level.displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: context.appColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${level.questionsCount} Q · ${level.timeLimit}s · ${level.pointsPerQuestion} pts · ${level.difficulty}',
                        style: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _MiniIcon(
                        icon: Icons.keyboard_arrow_up_rounded, onTap: onUp),
                    _MiniIcon(
                        icon: Icons.keyboard_arrow_down_rounded,
                        onTap: onDown),
                  ],
                ),
              ],
            ),
            if (!level.isPlayable) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      level.questionsCount == 0
                          ? l10n.levelHasNoQuestions
                          : l10n.levelNotPublished,
                      style: const TextStyle(
                          color: AppColors.warning, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onQuestions,
                  icon: const Icon(Icons.help_outline_rounded, size: 15),
                  label: Text(l10n.questions),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
                TextButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.download_rounded, size: 15),
                  label: Text(l10n.exportBtn),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 15),
                  label: Text(l10n.editBtn),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.info,
                      padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 15),
                  label: Text(l10n.deleteBtn),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _MiniIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(icon,
              size: 20,
              color: onTap == null
                  ? context.appColors.textMuted.withValues(alpha: 0.4)
                  : context.appColors.textSecondary),
        ),
      );
}

// ─── Formulaire d'un niveau ──────────────────────────────────────────────────

class _LevelForm extends StatefulWidget {
  final AdminRepository repo;
  final AdminJourneyLevelModel? level;
  final int nextPosition;
  final VoidCallback onSaved;

  const _LevelForm({
    required this.repo,
    required this.level,
    required this.nextPosition,
    required this.onSaved,
  });

  @override
  State<_LevelForm> createState() => _LevelFormState();
}

class _LevelFormState extends State<_LevelForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _position;
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _timeLimit;
  late final TextEditingController _points;
  late String _difficulty;
  late bool _isBoss;
  late bool _isPublished;
  late final TranslationsMap _translations;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final l = widget.level;
    _position =
        TextEditingController(text: '${l?.position ?? widget.nextPosition}');
    _title = TextEditingController(text: l?.title ?? '');
    _description = TextEditingController(text: l?.description ?? '');
    _timeLimit = TextEditingController(text: '${l?.timeLimit ?? 30}');
    _points = TextEditingController(text: '${l?.pointsPerQuestion ?? 10}');
    _difficulty = l?.difficulty ?? 'easy';
    _isBoss = l?.isBoss ?? false;
    _isPublished = l?.isPublished ?? false;
    _translations = {
      for (final e in (l?.translations ?? const {}).entries)
        e.key: Map<String, dynamic>.from(e.value),
    };
  }

  @override
  void dispose() {
    _position.dispose();
    _title.dispose();
    _description.dispose();
    _timeLimit.dispose();
    _points.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final data = {
        'position': int.parse(_position.text.trim()),
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'difficulty': _difficulty,
        'is_boss': _isBoss,
        'time_limit': int.parse(_timeLimit.text.trim()),
        'points_per_question': int.parse(_points.text.trim()),
        'is_published': _isPublished,
        'translations': _translations,
      };
      if (widget.level == null) {
        await widget.repo.createJourneyLevel(data);
      } else {
        await widget.repo.updateJourneyLevel(widget.level!.id, data);
      }
      widget.onSaved();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: context.appColors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.appColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.appColors.border),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.level == null ? l10n.addLevel : l10n.editLevel,
                style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _position,
                      keyboardType: TextInputType.number,
                      decoration: _dec(l10n.levelPosition),
                      validator: (v) =>
                          (int.tryParse(v?.trim() ?? '') ?? 0) < 1
                              ? l10n.requiredField
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _difficulty,
                      decoration: _dec(l10n.difficulty),
                      dropdownColor: context.appColors.cardBg,
                      items: const ['easy', 'medium', 'hard']
                          .map((d) =>
                              DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _difficulty = v ?? 'easy'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _title, decoration: _dec(l10n.levelTitle)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 2,
                decoration: _dec(l10n.descriptionLabel),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeLimit,
                      keyboardType: TextInputType.number,
                      decoration: _dec(l10n.secondsPerQuestion),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _points,
                      keyboardType: TextInputType.number,
                      decoration: _dec(l10n.pointsPerQuestion),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isBoss,
                onChanged: (v) => setState(() => _isBoss = v),
                title: Text('👑 ${l10n.bossLevel}',
                    style: TextStyle(
                        color: context.appColors.textPrimary, fontSize: 14)),
                activeThumbColor: AppColors.error,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPublished,
                onChanged: (v) => setState(() => _isPublished = v),
                title: Text(l10n.published,
                    style: TextStyle(
                        color: context.appColors.textPrimary, fontSize: 14)),
                subtitle: Text(l10n.levelPublishHint,
                    style: TextStyle(
                        color: context.appColors.textSecondary, fontSize: 11)),
                activeThumbColor: AppColors.success,
              ),
              const SizedBox(height: 12),
              TranslationsSection(
                filled: (locale) =>
                    trGet(_translations, locale, 'title').isNotEmpty,
                builder: (context, locale) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: trGet(_translations, locale, 'title'),
                      decoration: _dec('${l10n.levelTitle} ($locale)'),
                      onChanged: (v) => setState(
                          () => trSet(_translations, locale, 'title', v)),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: trGet(_translations, locale, 'description'),
                      maxLines: 2,
                      decoration: _dec('${l10n.descriptionLabel} ($locale)'),
                      onChanged: (v) => setState(
                          () => trSet(_translations, locale, 'description', v)),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(l10n.saveChanges),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
