import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/features/admin/presentation/screens/admin_questions_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  late final AdminRepository _repo;
  List<AdminReportModel> _reports = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _lastPage = 1;
  String? _filterStatus = 'pending';

  static const _statuses = <(String?, String)>[
    (null, 'Tous'),
    ('pending', 'En attente'),
    ('reviewed', 'En cours'),
    ('resolved', 'Résolu'),
    ('dismissed', 'Rejeté'),
  ];

  @override
  void initState() {
    super.initState();
    _repo = AdminRepository(apiService);
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) setState(() { _loading = true; _error = null; _page = 1; });
    try {
      final result = await _repo.getReports(status: _filterStatus, page: _page);
      if (mounted) {
        setState(() {
          if (reset) {
            _reports = result.reports;
          } else {
            _reports.addAll(result.reports);
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

  Future<void> _setStatus(AdminReportModel r, String status) async {
    try {
      await _repo.updateReportStatus(r.id, status);
      _load(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _delete(AdminReportModel r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Ce signalement sera supprimé définitivement.'),
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
      await _repo.deleteReport(r.id);
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
        title: const Text('Signalements', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final s in _statuses) ...[
                _FilterChip(
                  label: s.$2,
                  active: _filterStatus == s.$1,
                  onTap: () {
                    setState(() => _filterStatus = s.$1);
                    _load(reset: true);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      );

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) return Center(child: Text(_error!, style: TextStyle(color: context.appColors.textSecondary)));
    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 48, color: context.appColors.textMuted),
            const SizedBox(height: 12),
            Text('Aucun signalement', style: TextStyle(color: context.appColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _reports.length + (_page < _lastPage ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i == _reports.length) {
            _loadMore();
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary)));
          }
          return _ReportTile(
            r: _reports[i],
            onSetStatus: (s) => _setStatus(_reports[i], s),
            onDelete: () => _delete(_reports[i]),
            onOpenQuestion: () {
              final quizId = _reports[i].quizId;
              if (quizId == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminQuestionsScreen(initialQuizId: quizId)),
              );
            },
          );
        },
      ),
    );
  }
}

Color _statusColor(String status) => switch (status) {
      'pending' => AppColors.warning,
      'reviewed' => AppColors.info,
      'resolved' => AppColors.success,
      'dismissed' => AppColors.error,
      _ => AppColors.info,
    };

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

class _ReportTile extends StatelessWidget {
  final AdminReportModel r;
  final ValueChanged<String> onSetStatus;
  final VoidCallback onDelete;
  final VoidCallback onOpenQuestion;

  const _ReportTile({
    required this.r,
    required this.onSetStatus,
    required this.onDelete,
    required this.onOpenQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(r.status);
    return Container(
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
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(r.reasonLabel, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(r.statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (r.questionText != null)
            Text(r.questionText!, style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          if (r.correctAnswer != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('Réponse marquée correcte : ${r.correctAnswer}',
                      style: const TextStyle(color: AppColors.success, fontSize: 12), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          if (r.comment != null && r.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: context.appColors.cardBgLight, borderRadius: BorderRadius.circular(8)),
              child: Text(r.comment!, style: TextStyle(color: context.appColors.textSecondary, fontSize: 12, height: 1.4)),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 13, color: context.appColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  r.userName ?? 'Anonyme',
                  style: TextStyle(color: context.appColors.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (r.quizTitle != null)
                Flexible(
                  child: Text(
                    r.quizTitle!,
                    style: TextStyle(color: context.appColors.textMuted, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
          Divider(height: 18, color: context.appColors.border),
          Row(
            children: [
              TextButton.icon(
                onPressed: onOpenQuestion,
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Question'),
                style: TextButton.styleFrom(foregroundColor: AppColors.info, padding: const EdgeInsets.symmetric(horizontal: 6)),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: onSetStatus,
                color: context.appColors.cardBg,
                icon: Icon(Icons.more_horiz_rounded, color: context.appColors.textSecondary),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'pending', child: Text('Marquer en attente')),
                  PopupMenuItem(value: 'reviewed', child: Text('Marquer en cours')),
                  PopupMenuItem(value: 'resolved', child: Text('Marquer résolu')),
                  PopupMenuItem(value: 'dismissed', child: Text('Rejeter')),
                ],
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
