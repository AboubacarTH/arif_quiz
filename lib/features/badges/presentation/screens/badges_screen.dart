import 'package:arif_quiz/features/badges/data/badge_repository.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final _repo = BadgeRepository(apiService);
  List<BadgeModel> _badges = [];
  int _unlocked = 0;
  int _total = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getBadges();
      if (!mounted) return;
      setState(() {
        _badges = data.badges;
        _unlocked = data.unlocked;
        _total = data.total;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context).loadBadgesError;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Text(AppLocalizations.of(context).achievements),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      _progressHeader(context),
                      const SizedBox(height: AppSpacing.lg),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.78,
                        children:
                            _badges.map((b) => _BadgeTile(badge: b)).toList(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _progressHeader(BuildContext context) {
    final pct = _total == 0 ? 0.0 : _unlocked / _total;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).progression,
                  style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              Text('$_unlocked / $_total',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: context.appColors.cardBgLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeModel badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.unlocked;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.secondary.withValues(alpha: 0.10)
            : context.cardElevated,
        borderRadius: AppRadius.rLg,
        border: Border.all(
          color: unlocked
              ? AppColors.secondary.withValues(alpha: 0.5)
              : context.appColors.border,
          width: 1.5,
        ),
        boxShadow: unlocked ? null : AppShadows.card(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: unlocked ? 1 : 0.3,
            child: Text(badge.emoji, style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unlocked
                  ? context.appColors.textPrimary
                  : context.appColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: context.appColors.textMuted,
                fontSize: 11,
                height: 1.25),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (unlocked)
            const Icon(Icons.verified_rounded,
                color: AppColors.secondary, size: 18)
          else
            Icon(Icons.lock_outline_rounded,
                color: context.appColors.textMuted, size: 16),
        ],
      ),
    );
  }
}
