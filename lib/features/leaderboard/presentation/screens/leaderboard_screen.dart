import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> _leaders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);
    try {
      final data = await apiService.getGlobalLeaderboard();
      setState(() { _leaders = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leaderboard 🏆'),
        backgroundColor: AppColors.background,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // Top 3 podium
                  if (_leaders.length >= 3)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _PodiumCard(_leaders[1], 2, 90),
                            _PodiumCard(_leaders[0], 1, 120),
                            _PodiumCard(_leaders[2], 3, 70),
                          ],
                        ),
                      ),
                    ),

                  // Remaining users
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final user = _leaders[i + 3];
                        return Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBgLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                alignment: Alignment.center,
                                child: Text(
                                  '#${i + 4}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary.withOpacity(0.3),
                                child: Text(
                                  (user['name'] as String)[0].toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['name'],
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${user['quizzes_taken']} quizzes · ${user['accuracy']}% accuracy',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user['total_points']}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: (_leaders.length - 3).clamp(0, _leaders.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final dynamic user;
  final int rank;
  final double height;

  const _PodiumCard(this.user, this.rank, this.height);

  @override
  Widget build(BuildContext context) {
    final colors = {1: AppColors.warning, 2: const Color(0xFFAEB0B5), 3: const Color(0xFFCD7F32)};
    final color = colors[rank]!;
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(medals[rank]!, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: rank == 1 ? 28 : 22,
            backgroundColor: color.withOpacity(0.3),
            child: Text(
              (user['name'] as String)[0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: rank == 1 ? 22 : 18,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (user['name'] as String).split(' ')[0],
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${user['total_points']} pts',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
          ),
        ],
      ),
    );
  }
}
