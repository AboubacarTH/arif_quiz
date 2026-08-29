import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/features/admin/presentation/screens/admin_questions_screen.dart';
import 'package:arif_quiz/features/admin/presentation/widgets/admin_card.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
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

  List<(String?, String)> _statuses(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      (null, l10n.allFilter),
      ('pending', l10n.pendingLabel),
      ('reviewed', l10n.inProgress),
      ('resolved', l10n.resolved),
      ('dismissed', l10n.rejected),
    ];
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(AppLocalizations.of(context).confirmDeleteTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(AppLocalizations.of(context).deleteReportBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context).cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).deleteBtn, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
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
        title: Text(AppLocalizations.of(context).reports, style: const TextStyle(fontWeight: FontWeight.w800)),
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
              for (final s in _statuses(context)) ...[
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
            Text(AppLocalizations.of(context).noReports, style: TextStyle(color: context.appColors.textSecondary)),
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
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i == _reports.length) {
            _loadMore();
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary)));
          }
          return _ReportTile(
            r: _reports[i],
            onSetStatus: (s) => _setStatus(_reports[i], s),
            onDelete: () => _delete(_reports[i]),
            // Sans quiz rattaché il n'y a rien à ouvrir : l'action est alors
            // absente plutôt qu'inerte.
            onOpenQuestion: _reports[i].quizId == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminQuestionsScreen(
                            initialQuizId: _reports[i].quizId),
                      ),
                    ),
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
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: active ? AppColors.primary : context.appColors.border),
          ),
          child: Text(
            label,
            style: context.type.labelMedium.copyWith(color: active ? AppColors.primary : context.appColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
      );
}

class _ReportTile extends StatelessWidget {
  final AdminReportModel r;
  final ValueChanged<String> onSetStatus;
  final VoidCallback onDelete;
  final VoidCallback? onOpenQuestion;

  const _ReportTile({
    required this.r,
    required this.onSetStatus,
    required this.onDelete,
    required this.onOpenQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor(r.status);
    return AdminCard(
      onTap: onOpenQuestion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminCardHeader(
            title: r.questionText ?? l10n.questionLabel,
            subtitle: r.correctAnswer != null
                ? Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 13, color: AppColors.success),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          l10n.markedCorrectAnswer(r.correctAnswer ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.labelMedium.copyWith(color: AppColors.success),
                        ),
                      ),
                    ],
                  )
                : null,
            badges: [
              AdminTag(label: r.statusLabel, color: statusColor, strong: true),
            ],
            // Changement de statut et suppression : un seul point d'entrée,
            // au lieu d'une barre d'icônes qui poussait hors de la carte.
            menuActions: [
              AdminAction(
                icon: Icons.schedule_rounded,
                label: l10n.markPending,
                color: AppColors.warning,
                onPressed: r.status == 'pending' ? null : () => onSetStatus('pending'),
              ),
              AdminAction(
                icon: Icons.autorenew_rounded,
                label: l10n.markInProgress,
                color: AppColors.info,
                onPressed: r.status == 'reviewed' ? null : () => onSetStatus('reviewed'),
              ),
              AdminAction(
                icon: Icons.check_circle_rounded,
                label: l10n.markResolved,
                color: AppColors.success,
                onPressed: r.status == 'resolved' ? null : () => onSetStatus('resolved'),
              ),
              AdminAction(
                icon: Icons.block_rounded,
                label: l10n.reject,
                color: context.appColors.textSecondary,
                onPressed: r.status == 'dismissed' ? null : () => onSetStatus('dismissed'),
              ),
              AdminAction(
                icon: Icons.delete_outline_rounded,
                label: l10n.deleteBtn,
                destructive: true,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AdminTag(label: r.reasonLabel, color: AppColors.error),
              AdminTag(
                label: r.userName ?? l10n.anonymous,
                color: context.appColors.textMuted,
                icon: Icons.person_outline_rounded,
              ),
              if (r.quizTitle != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 190),
                  child: AdminTag(
                    label: r.quizTitle!,
                    color: context.appColors.textMuted,
                    icon: Icons.folder_open_rounded,
                  ),
                ),
            ],
          ),
          if (r.comment != null && r.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.appColors.cardBgLight,
                borderRadius: AppRadius.rSm,
              ),
              child: Text(r.comment!, style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary, height: 1.4)),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: context.appColors.border),
          const SizedBox(height: AppSpacing.md),
          AdminActionBar(
            actions: [
              AdminAction(
                icon: Icons.open_in_new_rounded,
                label: l10n.questionLabel,
                color: AppColors.info,
                onPressed: onOpenQuestion,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
