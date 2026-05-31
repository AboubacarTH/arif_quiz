import 'package:arif_quiz/features/daily_challenge/presentation/screens/daily_challenge_screen.dart';
import 'package:arif_quiz/features/home/bloc/home_controller.dart';
import 'package:arif_quiz/features/home/data/home_repository.dart';
import 'package:arif_quiz/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/category_card.dart';
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _ctrl.load,
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
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(child: CategoryRowSkeleton()),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: QuizListSkeleton(count: 3))),
      ]);
    }

    if (_ctrl.error != null) {
      return ListView(children: [
        const SizedBox(height: 200),
        ErrorState(message: _ctrl.error!, onRetry: _ctrl.load),
      ]);
    }

    final d = _ctrl.data!;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _header(d.user)),
        SliverToBoxAdapter(child: _xpSection(d.user)),
        SliverToBoxAdapter(child: _dailyChallengeCard()),
        _sectionTitle('Catégories', topPad: 20),
        SliverToBoxAdapter(child: _categoriesRow(d.categories)),
        _sectionTitle('🔥 Quiz populaires'),
        SliverToBoxAdapter(child: _featuredHorizontal(d.featured)),
        _sectionTitle('Tous les quiz en vedette'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuizCard(
                  quiz: d.featured[i],
                  style: QuizCardStyle.list,
                  onTap: () => _openQuiz(d.featured[i].id),
                ),
              ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.1),
              childCount: d.featured.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(UserModel? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${user?.name.split(' ').first ?? '...'} 👋',
                  style: TextStyle(color: context.appColors.textSecondary, fontSize: 14),
                ),
                Text(
                  'Prêt à jouer ?',
                  style: TextStyle(color: context.appColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          // Notifications icon
          IconButton(
            onPressed: () => Navigator.push(context, SlideRightRoute(page: const NotificationsScreen())),
            icon: Icon(Icons.notifications_outlined, color: context.appColors.textSecondary),
          ),
          // Points badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                const SizedBox(width: 5),
                Text(
                  '${user?.totalPoints ?? 0}',
                  style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _xpSection(UserModel? user) {
    if (user == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
    );
  }

  Widget _dailyChallengeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, SlideRightRoute(page: const DailyChallengeScreen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accent.withValues(alpha: 0.3), AppColors.primary.withValues(alpha: 0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Text('🌟', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DÉFI QUOTIDIEN', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    SizedBox(height: 2),
                    Text('Un quiz spécial chaque jour', style: TextStyle(color: context.appColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('+30 XP bonus · Maintient ton streak', style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05),
      ),
    );
  }

  SliverToBoxAdapter _sectionTitle(String title, {double topPad = 24}) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, topPad, 20, 14),
          child: Text(
            title,
            style: TextStyle(color: context.appColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
      );

  Widget _categoriesRow(List<CategoryModel> cats) => SizedBox(
        height: 140,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => CategoryCard(category: cats[i], onTap: () {}).animate().fadeIn(delay: (i * 50).ms),
        ),
      );

  Widget _featuredHorizontal(List<QuizModel> quizzes) => SizedBox(
        height: 210,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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

  void _openQuiz(int id) => Navigator.push(
        context,
        SlideRightRoute(page: QuizDetailScreen(quizId: id)),
      );
}
