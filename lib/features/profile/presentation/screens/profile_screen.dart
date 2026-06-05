import 'package:arif_quiz/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:arif_quiz/features/auth/presentation/screens/login_screen.dart';
import 'package:arif_quiz/features/profile/data/profile_repository.dart';
import 'package:arif_quiz/features/profile/presentation/screens/attempt_history_screen.dart';
import 'package:arif_quiz/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/theme_controller.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/paywall_sheet.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:arif_quiz/ui/widgets/stats_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        title: Text(
          'Se déconnecter ?',
          style: TextStyle(
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Tu devras te reconnecter pour accéder à ton compte.',
          style: TextStyle(color: context.appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Annuler',
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout();
            },
            child: const Text(
              'Déconnexion',
              style: TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
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
      return CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _buildHeader(null)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: ProfileSkeleton(),
          ),
        ),
      ]);
    }

    if (_ctrl.error != null) {
      return ListView(children: [
        const SizedBox(height: 200),
        ErrorState(message: _ctrl.error!, onRetry: _ctrl.load),
      ]);
    }

    final d = _ctrl.data!;
    final user = d.user;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(user)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(user, d.rank),
                const SizedBox(height: 16),
                _buildXpBar(user),
                const SizedBox(height: 20),
                _buildStatsRow(user),
                const SizedBox(height: 20),
                _buildStreakRow(user),
                const SizedBox(height: 24),
                _buildPremiumSection(),
                const SizedBox(height: 24),
                _buildThemeSection(),
                const SizedBox(height: 28),
                _buildRecentActivity(d.recentAttempts),
                if (user.role == 'admin') ...[
                  const SizedBox(height: 24),
                  _buildAdminButton(),
                ],
                const SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(UserModel? user) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
        child: Row(
          children: [
            Text(
              'Mon Profil',
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            if (user != null)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  SlideRightRoute(page: EditProfileScreen(user: user)),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.appColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          color: context.appColors.textSecondary, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'Modifier',
                        style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ─── Hero card ───────────────────────────────────────────────────────────────

  Widget _buildHero(UserModel user, int rank) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: context.appColors.bg, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${user.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (user.username != null && user.username!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '@${user.username}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            user.email,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          // Rank + Points badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroBadge(
                icon: Icons.emoji_events_rounded,
                label: 'Rang #$rank',
                color: AppColors.warning,
              ),
              const SizedBox(width: 10),
              _HeroBadge(
                icon: Icons.star_rounded,
                label: '${user.totalPoints} pts',
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05);
  }

  // ─── XP bar ──────────────────────────────────────────────────────────────────

  Widget _buildXpBar(UserModel user) {
    final percent = user.xpPercent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Niveau ${user.level}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${user.xpProgress} / ${user.xpNeeded} XP',
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: context.appColors.cardBgLight,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Niveau ${user.level + 1} dans ${user.xpNeeded - user.xpProgress} XP',
            style: TextStyle(
              color: context.appColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  // ─── Stats row ───────────────────────────────────────────────────────────────

  Widget _buildStatsRow(UserModel user) {
    return StatsRow(
      stats: [
        StatItem('${user.quizzesTaken}', 'Quiz joués', AppColors.primary),
        StatItem('${user.correctAnswers}', 'Bonnes rép.', AppColors.success),
        StatItem('${user.accuracy.toStringAsFixed(0)}%', 'Précision', AppColors.info),
      ],
    ).animate().fadeIn(delay: 150.ms);
  }

  // ─── Streak row ──────────────────────────────────────────────────────────────

  Widget _buildStreakRow(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _StreakCard(
            emoji: '🔥',
            value: '${user.streak}',
            label: 'Streak actuel',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StreakCard(
            emoji: '🏆',
            value: '${user.longestStreak}',
            label: 'Meilleur streak',
            color: AppColors.warning,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  // ─── Premium ────────────────────────────────────────────────────────────────

  Widget _buildPremiumSection() {
    return ListenableBuilder(
      listenable: monetizationController,
      builder: (_, __) => monetizationController.isPremium
          ? _PremiumBadge()
          : _GetPremiumCard(
              onTap: () => PaywallSheet.show(
                context,
                ctrl: monetizationController,
                onGranted: () {},
              ),
            ),
    ).animate().fadeIn(delay: 250.ms);
  }

  // ─── Theme ──────────────────────────────────────────────────────────────────

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Apparence'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: context.appColors.cardBg,
            borderRadius: BorderRadius.circular(18),
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
                  subtitle: 'Interface lumineuse',
                  selected: themeController.isLight,
                  onTap: () => themeController.setMode(ThemeMode.light),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  // ─── Recent activity ─────────────────────────────────────────────────────────

  Widget _buildRecentActivity(List<dynamic> attempts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionTitle(title: 'Activité récente'),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                SlideRightRoute(page: const AttemptHistoryScreen()),
              ),
              child: const Text(
                'Voir tout',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (attempts.isEmpty)
          EmptyState(
            title: 'Aucun quiz joué',
            subtitle: 'Lance ton premier quiz pour voir tes résultats ici !',
            emoji: '🎯',
            actionLabel: 'Jouer',
            onAction: () {},
          )
        else
          ...attempts.take(5).map((a) => _AttemptTile(attempt: a)),
      ],
    ).animate().fadeIn(delay: 350.ms);
  }

  // ─── Admin ──────────────────────────────────────────────────────────────────

  Widget _buildAdminButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: AppColors.info, size: 18),
            SizedBox(width: 8),
            Text(
              'Panneau Admin',
              style: TextStyle(
                color: AppColors.info,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 380.ms);
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
            SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

// ─── Hero badge ──────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeroBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

// ─── Streak card ─────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StreakCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

// ─── Section title ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: TextStyle(
          color: context.appColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      );
}

// ─── Attempt tile ────────────────────────────────────────────────────────────

class _AttemptTile extends StatelessWidget {
  final dynamic attempt;
  const _AttemptTile({required this.attempt});

  double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final score = _asDouble(attempt['score']);
    final grade = attempt['grade']?.toString() ?? 'F';
    final color = AppColors.gradeColor(grade);
    final title = attempt['quiz']?['title']?.toString() ?? 'Quiz';
    final points = _asInt(attempt['points_earned']);
    final correct = _asInt(attempt['correct_count']);
    final total = _asInt(attempt['total_questions']);
    final rawDate = attempt['completed_at'] ?? attempt['created_at'];
    final date = rawDate != null ? DateTime.tryParse(rawDate.toString())?.toLocal() : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          // Grade
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              grade,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${score.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '  ·  $correct/$total bonnes',
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.warning, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      '+$points pts',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    if (date != null) ...[
                      Text(
                        '  ·  ${_formatDate(date)}',
                        style: TextStyle(
                          color: context.appColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: context.appColors.textMuted, size: 18),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

// ─── Premium badge ───────────────────────────────────────────────────────────

class _PremiumBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arif Quiz Premium ✨',
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Merci pour ton soutien — sans pub !',
                    style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─── Get premium card ────────────────────────────────────────────────────────

class _GetPremiumCard extends StatelessWidget {
  final VoidCallback onTap;
  const _GetPremiumCard({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passer Premium',
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Jouez sans pub · Toutes les fonctionnalités',
                      style: TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.primary, size: 20),
            ],
          ),
        ),
      );
}

// ─── Theme tile ──────────────────────────────────────────────────────────────

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
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                  color: selected
                      ? AppColors.primary
                      : context.appColors.textMuted,
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : context.appColors.border,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
            ],
          ),
        ),
      );
}
