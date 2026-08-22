import 'package:arif_quiz/core/i18n/locale_controller.dart';
import 'package:arif_quiz/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:arif_quiz/features/auth/presentation/screens/login_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/features/badges/presentation/screens/badges_screen.dart';
import 'package:arif_quiz/features/profile/data/profile_repository.dart';
import 'package:arif_quiz/features/profile/presentation/screens/attempt_history_screen.dart';
import 'package:arif_quiz/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/paywall_sheet.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
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

  Future<void> _deleteAccount(String password) async {
    try {
      await apiService.deleteAccount(password);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        FadeScaleRoute(page: const LoginScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).wrongPasswordOrNetwork),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmDeleteAccount() {
    final passwordCtrl = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: context.appColors.cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text(
            AppLocalizations.of(context).deleteAccountTitle,
            style: TextStyle(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).deleteAccountWarning,
                style: TextStyle(color: context.appColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordCtrl,
                obscureText: obscure,
                style: TextStyle(color: context.appColors.textPrimary),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).password,
                  labelStyle:
                      TextStyle(color: context.appColors.textSecondary),
                  filled: true,
                  fillColor: context.appColors.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: context.appColors.border),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: context.appColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () =>
                        setStateDialog(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppLocalizations.of(context).cancel,
                style: TextStyle(color: context.appColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                final password = passwordCtrl.text;
                Navigator.pop(ctx);
                _deleteAccount(password);
              },
              child: Text(
                AppLocalizations.of(context).deleteBtn,
                style: const TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(
          AppLocalizations.of(context).logoutTitle,
          style: TextStyle(
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppLocalizations.of(context).logoutBody,
          style: TextStyle(color: context.appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logout();
            },
            child: Text(
              AppLocalizations.of(context).logoutBtn,
              style: const TextStyle(
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
        // `load` levait le squelette : la page entiere disparaissait le temps
        // de l'appel, alors qu'elle a deja tout ce qu'il faut a l'ecran.
        onRefresh: _ctrl.refresh,
        color: AppColors.primary,
        backgroundColor: context.appColors.cardBg,
        // Une seule entrée pour tout l'écran (voir _buildBody).
        child: _buildBody().animate().fadeIn(duration: 260.ms),
      ),
    );
  }

  Widget _buildBody() {
    if (_ctrl.isLoading) {
      return const SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.gutter),
                child: ProfileSkeleton(),
              ),
            ),
          ],
        ),
      );
    }

    if (_ctrl.error != null) {
      return SafeArea(
        bottom: false,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 160),
            ErrorState(
                message: AppLocalizations.of(context).loadProfileFailed,
                onRetry: _ctrl.load),
          ],
        ),
      );
    }

    final d = _ctrl.data!;
    final user = d.user;

    const gap = SizedBox(height: AppSpacing.xxl);
    final l10n = AppLocalizations.of(context);

    // La page etait une pile continue : identite, chiffres, reglages, historique
    // et boutons de compte se suivaient sans qu'on sache ou l'un finissait. Elle
    // se lit maintenant par sections — trois d'entre elles en avaient deja un
    // titre, les autres flottaient.
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(user)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xxxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(user, d.rank),
                  const SizedBox(height: AppSpacing.lg),
                  _buildXpBar(user),
                  gap,
                  _SectionTitle(title: l10n.statisticsSection),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatsCard(user),
                  gap,
                  _buildBadgesButton(),
                  gap,
                  _buildPremiumSection(),
                  gap,
                  _buildThemeSection(),
                  gap,
                  _buildLanguageSection(),
                  // Ne s'affiche que là où la loi l'exige (EEE, UK, États US
                  // régulés) : ailleurs, le widget ne rend rien.
                  const _PrivacyOptionsTile(),
                  gap,
                  _buildRecentActivity(d.recentAttempts),
                  gap,
                  _SectionTitle(title: l10n.accountSection),
                  const SizedBox(height: AppSpacing.md),
                  if (user.role == 'admin') ...[
                    _buildAdminButton(),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _buildLogoutButton(),
                  const SizedBox(height: AppSpacing.md),
                  _buildDeleteAccountButton(),
                ],
              ),
            ),
          ),
        ],
      ),
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
              AppLocalizations.of(context).myProfile,
              style: context.type.headlineLarge.copyWith(color: context.appColors.textPrimary),
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
                    color: context.cardElevated,
                    borderRadius: AppRadius.rMd,
                    boxShadow: AppShadows.card(context),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          color: context.appColors.textSecondary, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context).editBtn,
                        style: context.type.bodyMedium.copyWith(color: context.appColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Hero card ───────────────────────────────────────────────────────────────

  Widget _buildHero(UserModel user, int rank) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.cardElevated,
        borderRadius: AppRadius.rXl,
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: AlignmentDirectional.bottomEnd,
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
                    style: AppType.score.copyWith(color: AppColors.primary),
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
                    style: context.type.labelSmall.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: context.type.headlineMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
          ),
          if (user.username != null && user.username!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '@${user.username}',
              style: context.type.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            user.email,
            style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary),
          ),
          const SizedBox(height: 14),
          // Rank + Points badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroBadge(
                icon: Icons.emoji_events_rounded,
                label: AppLocalizations.of(context).rankLabel(rank),
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
    );
  }

  // ─── XP bar ──────────────────────────────────────────────────────────────────

  Widget _buildXpBar(UserModel user) {
    final percent = user.xpPercent;
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  AppLocalizations.of(context).levelLabel(user.level),
                  style: context.type.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              Text(
                '${user.xpProgress} / ${user.xpNeeded} XP',
                style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
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
            AppLocalizations.of(context).nextLevelIn(user.level + 1, user.xpNeeded - user.xpProgress),
            style: context.type.labelSmall.copyWith(color: context.appColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ─── Stats row ───────────────────────────────────────────────────────────────

  /// Les cinq chiffres du joueur dans une seule carte.
  ///
  /// Ils vivaient dans deux blocs qui ne se ressemblaient pas — trois valeurs
  /// nues d'un côté, deux cartes teintées de l'autre, l'une beige et l'autre
  /// orange sans que la différence veuille dire quoi que ce soit. Ce sont les
  /// mêmes chiffres sur le même joueur : une seule carte, un seul trait pour
  /// séparer ce qu'on cumule de ce qu'on tient d'affilée.
  Widget _buildStatsCard(UserModel user) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardElevated,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Figure(
                  value: '${user.quizzesTaken}',
                  label: l10n.quizzesPlayed,
                ),
              ),
              Expanded(
                child: _Figure(
                  value: '${user.correctAnswers}',
                  label: l10n.goodAnswers,
                ),
              ),
              Expanded(
                child: _Figure(
                  value: '${user.accuracy.toStringAsFixed(0)}%',
                  label: l10n.accuracy,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            child: Divider(color: context.appColors.border, height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _Figure(
                  value: '${user.streak}',
                  label: l10n.currentStreak,
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: _Figure(
                  value: '${user.longestStreak}',
                  label: l10n.bestStreak,
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Succès / badges ─────────────────────────────────────────────────────────

  Widget _buildBadgesButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlideRightRoute(page: const BadgesScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.military_tech_rounded,
              size: 22, color: AppColors.secondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).achievements,
                    style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    AppLocalizations.of(context).unlockBadgesByPlaying,
                    style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.secondary, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Premium ────────────────────────────────────────────────────────────────

  Widget _buildPremiumSection() {
    return ListenableBuilder(
      listenable: monetizationController,
      builder: (_, __) => monetizationController.isPremium
          ? _PremiumBadge()
          : Column(
              children: [
                // Solde de parties gagnées en pub : l'utilisateur doit pouvoir
                // le consulter sans lancer une partie pour le découvrir.
                if (monetizationController.adsRequired) ...[
                  _CreditsRow(credits: monetizationController.credits),
                  const SizedBox(height: 10),
                ],
                _GetPremiumCard(
                  // Hors partie : pas de `onGranted`, la pub crédite seulement.
                  onTap: () => PaywallSheet.show(
                    context,
                    ctrl: monetizationController,
                  ),
                ),
              ],
            ),
    );
  }

  // ─── Theme ──────────────────────────────────────────────────────────────────

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: AppLocalizations.of(context).appearance),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: context.cardElevated,
            borderRadius: AppRadius.rLg,
            boxShadow: AppShadows.card(context),
          ),
          child: ListenableBuilder(
            listenable: themeController,
            builder: (_, __) => Column(
              children: [
                _ThemeTile(
                  icon: Icons.smartphone_rounded,
                  label: AppLocalizations.of(context).themeSystem,
                  subtitle: AppLocalizations.of(context).themeSystemDesc,
                  selected: themeController.isSystem,
                  onTap: () => themeController.setMode(ThemeMode.system),
                ),
                Divider(height: 1, color: context.appColors.border),
                _ThemeTile(
                  icon: Icons.dark_mode_rounded,
                  label: AppLocalizations.of(context).themeDark,
                  subtitle: AppLocalizations.of(context).themeDarkDesc,
                  selected: themeController.isDark,
                  onTap: () => themeController.setMode(ThemeMode.dark),
                ),
                Divider(height: 1, color: context.appColors.border),
                _ThemeTile(
                  icon: Icons.light_mode_rounded,
                  label: AppLocalizations.of(context).themeLight,
                  subtitle: AppLocalizations.of(context).themeLightDesc,
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

  // ─── Langue ──────────────────────────────────────────────────────────────────

  Widget _buildLanguageSection() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.language),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: context.cardElevated,
            borderRadius: AppRadius.rLg,
            boxShadow: AppShadows.card(context),
          ),
          child: ListenableBuilder(
            listenable: localeController,
            builder: (_, __) => Column(
              children: [
                for (final (i, code)
                    in LocaleController.supportedCodes.indexed) ...[
                  if (i > 0)
                    Divider(height: 1, color: context.appColors.border),
                  _ThemeTile(
                    icon: Icons.language_rounded,
                    label: LocaleController.labels[code] ?? code,
                    subtitle: code == localeController.code
                        ? l10n.languageSystemNote
                        : null,
                    selected: code == localeController.code,
                    onTap: () => localeController.setLocale(code),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Recent activity ─────────────────────────────────────────────────────────

  Widget _buildRecentActivity(List<dynamic> attempts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionTitle(title: AppLocalizations.of(context).recentActivity),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                SlideRightRoute(page: const AttemptHistoryScreen()),
              ),
              child: Text(
                AppLocalizations.of(context).seeAll,
                style: context.type.labelLarge.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (attempts.isEmpty)
          EmptyState(
            title: AppLocalizations.of(context).noQuizPlayed,
            subtitle: AppLocalizations.of(context).playFirstQuiz,
            icon: Icons.quiz_rounded,
            actionLabel: AppLocalizations.of(context).playBtn,
            onAction: () {},
          )
        else
          ...attempts.take(5).map((a) => _AttemptTile(attempt: a)),
      ],
    );
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
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: AppColors.info, size: 18),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).adminPanel,
              style: context.type.titleMedium.copyWith(color: AppColors.info),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Logout / Delete ────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border:
              Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).logOutAction,
              style: context.type.titleMedium.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return GestureDetector(
      onTap: _confirmDeleteAccount,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.appColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_rounded,
                color: context.appColors.textMuted, size: 18),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).deleteMyAccount,
              style: context.type.titleMedium.copyWith(color: context.appColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: context.type.labelLarge.copyWith(color: color),
            ),
          ],
        ),
      );
}

// ─── Streak card ─────────────────────────────────────────────────────────────

class _Figure extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  const _Figure({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.appColors.textPrimary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: tint),
              const SizedBox(width: 6),
            ],
            Text(
              value,
              style: context.type.headlineMedium
                  .copyWith(color: tint, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.type.labelMedium
                .copyWith(color: context.appColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: context.type.titleLarge.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardElevated,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          // Grade
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Text(
              grade,
              style: context.type.headlineMedium.copyWith(color: color, fontWeight: FontWeight.w800),
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
                  style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary),
                  // Les titres de quiz finissent par ce qui les distingue
                  // (« … — Niveau avancé ») : coupés à une ligne, cinq parties
                  // differentes s'affichaient a l'identique.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${score.toStringAsFixed(0)}%',
                      style: context.type.labelMedium.copyWith(color: color),
                    ),
                    Text(
                      '  ·  ${AppLocalizations.of(context).correctOutOf(correct, total)}',
                      style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary),
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
                      style: context.type.labelMedium.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
                    ),
                    if (date != null) ...[
                      Text(
                        '  ·  ${_formatDate(date)}',
                        style: context.type.labelSmall.copyWith(color: context.appColors.textMuted),
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
          borderRadius: BorderRadius.circular(AppRadius.md),
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
                borderRadius: BorderRadius.circular(AppRadius.md),
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
                    'Arif Quiz Premium',
                    style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Merci pour ton soutien — sans pub !',
                    style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─── Get premium card ────────────────────────────────────────────────────────

/// Point d'entrée « Confidentialité » imposé par Google là où le consentement
/// publicitaire est requis : l'utilisateur doit pouvoir revenir sur son choix
/// à tout moment. Invisible partout ailleurs.
class _PrivacyOptionsTile extends StatefulWidget {
  const _PrivacyOptionsTile();

  @override
  State<_PrivacyOptionsTile> createState() => _PrivacyOptionsTileState();
}

class _PrivacyOptionsTileState extends State<_PrivacyOptionsTile> {
  bool _required = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final required = await monetizationController.isPrivacyOptionsRequired();
    if (mounted) setState(() => _required = required);
  }

  @override
  Widget build(BuildContext context) {
    if (!_required) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: l10n.privacyOptions),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: context.cardElevated,
              borderRadius: AppRadius.rLg,
              boxShadow: AppShadows.card(context),
            ),
            child: _ThemeTile(
              icon: Icons.privacy_tip_outlined,
              label: l10n.privacyOptions,
              subtitle: l10n.privacyOptionsSubtitle,
              selected: false,
              onTap: () async {
                await monetizationController.showPrivacyOptions();
                if (mounted) _check();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Solde de parties sans publicité, affiché sous le profil.
class _CreditsRow extends StatelessWidget {
  final int credits;
  const _CreditsRow({required this.credits});

  @override
  Widget build(BuildContext context) {
    final empty = credits <= 0;
    final color = empty ? context.appColors.textMuted : AppColors.success;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardElevated,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          Icon(Icons.play_circle_outline_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).freePlaysTitle,
              style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary),
            ),
          ),
          Text(
            AppLocalizations.of(context).creditsRemaining(credits),
            style: context.type.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _GetPremiumCard extends StatelessWidget {
  final VoidCallback onTap;
  const _GetPremiumCard({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.cardElevated,
            borderRadius: AppRadius.rLg,
            boxShadow: AppShadows.card(context),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
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
                      AppLocalizations.of(context).goPremium,
                      style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      AppLocalizations.of(context).goPremiumSubtitle,
                      style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary),
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
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  borderRadius: BorderRadius.circular(AppRadius.sm),
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
                      style: context.type.titleMedium.copyWith(color: selected
                            ? AppColors.primary
                            : context.appColors.textPrimary),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: context.type.labelMedium.copyWith(color: context.appColors.textMuted),
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
