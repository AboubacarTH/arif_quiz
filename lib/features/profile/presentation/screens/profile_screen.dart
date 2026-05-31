import 'package:arif_quiz/features/auth/presentation/screens/login_screen.dart';
import 'package:arif_quiz/features/profile/data/profile_repository.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/theme_controller.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/app_bar.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:arif_quiz/ui/widgets/stats_card.dart';
import 'package:flutter/material.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ProfileController(ProfileRepository(apiService));
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

  Future<void> _logout() async {
    await _ctrl.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      FadeScaleRoute(page: const LoginScreen()),
      (_) => false,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?',
            style: TextStyle(
                color: context.appColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('You will need to sign in again.',
            style: TextStyle(color: context.appColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _logout();
              },
              child: const Text('Sign Out',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: QuizAppBar(
        title: 'My Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.error, size: 22),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _ctrl.load,
        color: AppColors.primary,
        backgroundColor: context.appColors.cardBg,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_ctrl.isLoading) return const ProfileSkeleton();
    if (_ctrl.error != null) {
      return ErrorState(message: _ctrl.error!, onRetry: _ctrl.load);
    }

    final d = _ctrl.data!;
    final user = d.user;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primaryDark.withValues(alpha: 0.1)
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                      child: Text(user.name[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 36,
                              fontWeight: FontWeight.w800)),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: context.appColors.bg, width: 2)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(user.name,
                    style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito')),
                const SizedBox(height: 2),
                Text(user.email,
                    style: TextStyle(
                        color: context.appColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 14),
                // Rank badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events_rounded,
                          color: AppColors.warning, size: 18),
                      const SizedBox(width: 6),
                      Text('Rank #${d.rank}',
                          style: const TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats grid
          Row(children: [
            Expanded(
                child: StatsCard(
                    value: '${user.totalPoints}',
                    label: 'Total Points',
                    icon: Icons.star_rounded,
                    color: AppColors.warning)),
            const SizedBox(width: 12),
            Expanded(
                child: StatsCard(
                    value: '${user.quizzesTaken}',
                    label: 'Quizzes Taken',
                    icon: Icons.quiz_rounded,
                    color: AppColors.primary)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: StatsCard(
                    value: '${user.correctAnswers}',
                    label: 'Correct Answers',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success)),
            const SizedBox(width: 12),
            Expanded(
                child: StatsCard(
                    value: '${user.accuracy}%',
                    label: 'Accuracy',
                    icon: Icons.track_changes_rounded,
                    color: AppColors.info)),
          ]),

          // Theme settings
          const SizedBox(height: 24),
          _ThemeSection(),

          // Recent attempts
          if (d.recentAttempts.isNotEmpty) ...[
            const SizedBox(height: 28),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent Activity',
                    style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700))),
            const SizedBox(height: 14),
            ...d.recentAttempts.map((a) => _AttemptTile(attempt: a)),
          ] else ...[
            const SizedBox(height: 40),
            const EmptyState(
                title: 'No quizzes yet',
                subtitle: 'Complete your first quiz to see results here!',
                emoji: '🎯'),
          ],
        ],
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  final dynamic attempt;
  const _AttemptTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final score = (attempt['score'] as num?)?.toDouble() ?? 0;
    final grade = attempt['grade'] ?? 'F';
    final color = AppColors.gradeColor(grade);
    final title = attempt['quiz']?['title'] ?? 'Quiz';
    final points = attempt['points_earned'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.cardBgLight),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(grade,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    fontFamily: 'Nunito')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  Text('${score.toStringAsFixed(1)}%',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                  Text(' · ',
                      style: TextStyle(color: context.appColors.textMuted)),
                  const Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 13),
                  const SizedBox(width: 2),
                  Text('+$points pts',
                      style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ]),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: context.appColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apparence',
          style: TextStyle(
            color: context.appColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: context.appColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.border),
          ),
          child: ListenableBuilder(
            listenable: themeController,
            builder: (_, __) => Column(
              children: [
                _ThemeTile(
                  icon: Icons.smartphone_rounded,
                  label: 'Système',
                  subtitle: 'Suit le thème de l\'appareil',
                  selected: themeController.isSystem,
                  onTap: () => themeController.setMode(ThemeMode.system),
                ),
                Divider(height: 1, color: context.appColors.border),
                _ThemeTile(
                  icon: Icons.dark_mode_rounded,
                  label: 'Sombre',
                  subtitle: 'Interface gaming dark',
                  selected: themeController.isDark,
                  onTap: () => themeController.setMode(ThemeMode.dark),
                ),
                Divider(height: 1, color: context.appColors.border),
                _ThemeTile(
                  icon: Icons.light_mode_rounded,
                  label: 'Clair',
                  subtitle: 'Interface lumineuse violet',
                  selected: themeController.isLight,
                  onTap: () => themeController.setMode(ThemeMode.light),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : context.appColors.cardBgLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : context.appColors.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : context.appColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.appColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
          ],
        ),
      ),
    );
  }
}
