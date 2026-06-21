import 'package:arif_quiz/features/auth/presentation/screens/login_screen.dart';
import 'package:arif_quiz/features/auth/presentation/screens/register_screen.dart';
import 'package:arif_quiz/features/daily_challenge/presentation/screens/daily_challenge_screen.dart';
import 'package:arif_quiz/features/home/bloc/home_controller.dart';
import 'package:arif_quiz/features/home/data/home_repository.dart';
import 'package:arif_quiz/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/category_quizzes_screen.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/quiz_card.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:arif_quiz/ui/widgets/streak_badge.dart';
import 'package:arif_quiz/ui/widgets/xp_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = HomeController(HomeRepository(apiService));
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _loadData();
  }

  Future<void> _loadData() =>
      isGuest.value ? _ctrl.loadGuest() : _ctrl.load();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          backgroundColor: context.appColors.cardBg,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_ctrl.isLoading) {
      return CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _header(null)),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CategoryRowSkeleton(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: QuizListSkeleton(count: 3),
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
    final guest = isGuest.value;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _header(d.user)),
        if (guest)
          SliverToBoxAdapter(child: _guestBanner())
        else ...[
          SliverToBoxAdapter(child: _xpSection(d.user)),
          SliverToBoxAdapter(child: _dailyChallengeCard()),
        ],
        _sectionTitle('Catégories', topPad: 24),
        SliverToBoxAdapter(child: _categoriesRow(d.categories)),
        _sectionTitle('🔥 Populaires', actionLabel: 'Voir tout', onAction: _openAllQuizzes),
        SliverToBoxAdapter(child: _featuredHorizontal(d.featured)),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _header(UserModel? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${user?.name.split(' ').first ?? 'Invité'} 👋',
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Prêt à jouer ?',
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Points badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                const SizedBox(width: 5),
                Text(
                  '${user?.totalPoints ?? 0}',
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Notifications
          GestureDetector(
            onTap: () => Navigator.push(
                context, SlideRightRoute(page: const NotificationsScreen())),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.cardElevated,
                borderRadius: AppRadius.rMd,
                boxShadow: AppShadows.card(context),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: context.appColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─── Guest banner ────────────────────────────────────────────────────────────

  Widget _guestBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.tinted(context, AppColors.primary),
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sauvegarde ta progression !',
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Crée un compte pour débloquer XP, streak et classement.',
                    style: TextStyle(color: context.appColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    isGuest.value = false;
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'S\'inscrire',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    isGuest.value = false;
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  child: Text(
                    'Se connecter',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }

  // ─── XP + Streak ────────────────────────────────────────────────────────────

  Widget _xpSection(UserModel? user) {
    if (user == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
        child: Row(
          children: [
            Expanded(
              child: XpProgressBar(
                level: user.level,
                percent: user.xpPercent,
                xpProgress: user.xpProgress,
                xpNeeded: user.xpNeeded,
              ),
            ),
            const SizedBox(width: 12),
            StreakBadge(streak: user.streak),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }

  // ─── Daily challenge ────────────────────────────────────────────────────────

  Widget _dailyChallengeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, SlideRightRoute(page: const DailyChallengeScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.cardElevated,
            borderRadius: AppRadius.rLg,
            boxShadow: AppShadows.tinted(context, AppColors.primary),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('🌟', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DÉFI QUOTIDIEN',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Un quiz spécial chaque jour',
                      style: TextStyle(
                        color: context.appColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+30 XP bonus · Maintient ton streak',
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.04),
      ),
    );
  }

  // ─── Section title ───────────────────────────────────────────────────────────

  SliverToBoxAdapter _sectionTitle(
    String title, {
    double topPad = 24,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, topPad, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  // ─── Categories ──────────────────────────────────────────────────────────────

  Widget _categoriesRow(List<CategoryModel> cats) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _CategoryTile(
          category: cats[i],
          onTap: () => _openCategory(cats[i]),
        ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.05),
      ),
    );
  }

  // ─── Featured horizontal ─────────────────────────────────────────────────────

  Widget _featuredHorizontal(List<QuizModel> quizzes) => SizedBox(
        height: 222,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: quizzes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => QuizCard(
            quiz: quizzes[i],
            style: QuizCardStyle.featured,
            onTap: () => _openQuiz(quizzes[i].id),
          ).animate().fadeIn(delay: (i * 60).ms),
        ),
      );

  // ─── Navigation ──────────────────────────────────────────────────────────────

  void _openQuiz(int id) => Navigator.push(
        context,
        SlideRightRoute(page: QuizDetailScreen(quizId: id)),
      );

  void _openCategory(CategoryModel category) => Navigator.push(
        context,
        SlideRightRoute(page: CategoryQuizzesScreen(category: category)),
      );

  void _openAllQuizzes() => Navigator.push(
        context,
        SlideRightRoute(page: const QuizListScreen()),
      );
}

// ─── Category tile ───────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(category.color.replaceFirst('#', 'FF'), radix: 16));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: context.appColors.border),
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(category.icon ?? '📚',
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              '${category.quizCount} quiz',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
