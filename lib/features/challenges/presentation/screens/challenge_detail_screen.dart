import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/features/game_modes/presentation/screens/game_mode_select_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/widgets/app_button.dart';
import 'package:arif_quiz/ui/widgets/challenge_card.dart';
import 'package:arif_quiz/ui/widgets/neon_button.dart';
import 'package:flutter/material.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  late ChallengeModel _challenge;
  Map<String, dynamic>? _leaderboardData;
  bool _loading = true;
  bool _rematching = false;

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge;
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final repo = ChallengeRepository(apiService);
      _leaderboardData = await repo.getChallengeLeaderboard(_challenge.id);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _rematch() async {
    if (_rematching) return;
    setState(() => _rematching = true);
    try {
      final newChallenge =
          await ChallengeRepository(apiService).rematch(_challenge.id);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(challenge: newChallenge)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _rematching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).rematchError),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(backgroundColor: context.appColors.bg, title: Text(_challenge.title)),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _loading = true);
          await _loadLeaderboard();
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ChallengeCard(challenge: _challenge, showShareCode: true),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _challenge.myCompleted
                    ? Column(
                        children: [
                          _buildAlreadyPlayedBanner(),
                          const SizedBox(height: 12),
                          AppButton(
                            label: AppLocalizations.of(context).rematch,
                            icon: Icons.replay_rounded,
                            fullWidth: true,
                            loading: _rematching,
                            onPressed: _rematching ? null : _rematch,
                          ),
                        ],
                      )
                    : NeonButton(
                        label: AppLocalizations.of(context).playThisChallenge,
                        width: double.infinity,
                        icon: Icons.play_arrow_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameModeSelectScreen(
                              quiz: _challenge.quiz,
                              challengeSourceLabel: _challenge.quiz == null
                                  ? _challenge.sourceLabel
                                  : null,
                              forcedMode: GameMode.values.firstWhere(
                                (m) => m.apiValue == _challenge.mode,
                                orElse: () => GameMode.classic,
                              ),
                              challengeId: _challenge.id,
                              challenge: _challenge,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            if (_loading)
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_leaderboardData != null)
              ..._buildLeaderboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyPlayedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).alreadyPlayed,
              style: TextStyle(
                color: AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLeaderboard() {
    final completed = _leaderboardData!['completed'] as List? ?? [];
    final pending = _leaderboardData!['pending'] as List? ?? [];

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text(AppLocalizations.of(context).leaderboardCompleted(completed.length),
              style: TextStyle(color: context.appColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
      if (completed.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(AppLocalizations.of(context).nobodyCompleted, style: TextStyle(color: context.appColors.textMuted)),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final p = completed[i];
              final user = p['user'] as Map<String, dynamic>;
              final rank = p['rank'] ?? i + 1;
              return ListTile(
                leading: _rankWidget(rank as int),
                title: Text(user['name'] ?? '', style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w700)),
                subtitle: Text('${(p['time_taken'] ?? 0)}s • ${p['correct_count']}/${_challenge.questionsCount}',
                    style: TextStyle(color: context.appColors.textMuted, fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${(p['score'] as num).toStringAsFixed(1)}%',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                ),
              );
            },
            childCount: completed.length,
          ),
        ),
      if (pending.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(AppLocalizations.of(context).pendingCount(pending.length),
                style: TextStyle(color: context.appColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final p = pending[i];
              final user = p['user'] as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(radius: 16, backgroundColor: context.appColors.cardBgLight, child: Icon(Icons.hourglass_empty, size: 14, color: context.appColors.textMuted)),
                title: Text(user['name'] ?? '', style: TextStyle(color: context.appColors.textSecondary)),
                trailing: Text(AppLocalizations.of(context).pendingLabel, style: TextStyle(color: context.appColors.textMuted, fontSize: 12)),
              );
            },
            childCount: pending.length,
          ),
        ),
      ],
    ];
  }

  Widget _rankWidget(int rank) {
    final (icon, color) = switch (rank) {
      1 => ('🥇', AppColors.accent),
      2 => ('🥈', context.appColors.textSecondary),
      3 => ('🥉', const Color(0xFFCD7F32)),
      _ => ('', context.appColors.textMuted),
    };
    if (icon.isNotEmpty) return Text(icon, style: const TextStyle(fontSize: 24));
    return CircleAvatar(
      radius: 16,
      backgroundColor: context.appColors.cardBgLight,
      child: Text('$rank', style: TextStyle(color: context.appColors.textMuted, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}
