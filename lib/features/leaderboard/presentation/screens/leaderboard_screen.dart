import 'package:arif_quiz/features/leaderboard/data/leaderboard_repository.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/widgets/app_bar.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/leaderboard_tile.dart';
import 'package:flutter/material.dart';


class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final LeaderboardController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = LeaderboardController(LeaderboardRepository(apiService));
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: QuizAppBar(title: 'Leaderboard 🏆'),
      body: RefreshIndicator(
        onRefresh: _ctrl.load,
        color: AppColors.primary,
        backgroundColor: context.appColors.cardBg,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_ctrl.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_ctrl.error != null) {
      return ErrorState(message: _ctrl.error!, onRetry: _ctrl.load);
    }
    if (_ctrl.entries.isEmpty) {
      return const EmptyState(
          title: 'No rankings yet',
          subtitle: 'Be the first to complete a quiz!',
          emoji: '🏁');
    }

    final entries = _ctrl.entries;
    final top3 = entries.take(3).toList();
    final rest = entries.skip(3).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Podium
        if (top3.length == 3)
          SliverToBoxAdapter(child: PodiumDisplay(top3: top3)),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Divider label
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(children: [
              Expanded(child: Divider(color: context.appColors.cardBgLight)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('All Rankings',
                    style: TextStyle(
                        color: context.appColors.textMuted, fontSize: 12)),
              ),
              Expanded(child: Divider(color: context.appColors.cardBgLight)),
            ]),
          ),
        ),

        // Rest of list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final u = rest[i];
                return LeaderboardTile(
                  rank: i + 4,
                  name: u['name'] ?? '',
                  points: u['total_points'] ?? 0,
                  quizzesTaken: u['quizzes_taken'] ?? 0,
                  accuracy: (u['accuracy'] as num?)?.toDouble() ?? 0.0,
                );
              },
              childCount: rest.length,
            ),
          ),
        ),
      ],
    );
  }
}
