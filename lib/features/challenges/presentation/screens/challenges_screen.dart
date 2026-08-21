import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/features/challenges/bloc/challenge_controller.dart';
import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/features/challenges/presentation/screens/challenge_detail_screen.dart';
import 'package:arif_quiz/features/challenges/presentation/screens/create_challenge_screen.dart';
import 'package:arif_quiz/features/challenges/presentation/screens/join_challenge_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/widgets/challenge_card.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late final ChallengeController _ctrl;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _ctrl = ChallengeController(ChallengeRepository(apiService));
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.loadMyChallenges();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Text(l10n.challengesTitle),
        actions: [
          TextButton.icon(
            onPressed: _openJoin,
            icon: const Icon(Icons.qr_code_scanner,
                size: 18, color: AppColors.secondary),
            label: Text(l10n.joinBtn,
                style: const TextStyle(color: AppColors.secondary)),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.appColors.textMuted,
          tabs: [
            Tab(text: l10n.myChallengesTab),
            Tab(text: l10n.friendsChallengesTab),
            Tab(text: l10n.globalChallengesTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _refreshable(_buildMine()),
          _refreshable(_buildFeed(
            challenges: _ctrl.friendsFeed,
            emptyTitle: l10n.noFriendChallenges,
            emptyHint: l10n.noFriendChallengesHint,
            emptyIcon: Icons.group_rounded,
          )),
          _refreshable(_buildFeed(
            challenges: _ctrl.globalFeed,
            emptyTitle: l10n.noGlobalChallenges,
            emptyHint: l10n.noGlobalChallengesHint,
            emptyIcon: Icons.public_rounded,
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.createChallenge,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  /// Le rafraîchissement ne vide plus l'onglet : les listes restent en place
  /// pendant le rechargement.
  Widget _refreshable(Widget child) => RefreshIndicator(
        onRefresh: _ctrl.refresh,
        color: AppColors.primary,
        backgroundColor: context.appColors.cardBg,
        child: child,
      );

  // ─── Onglet « les miens » ────────────────────────────────────────────────

  Widget _buildMine() {
    if (_ctrl.isLoading) return const QuizListSkeleton(count: 4);

    final l10n = AppLocalizations.of(context);
    if (_ctrl.created.isEmpty && _ctrl.joined.isEmpty) {
      return _emptyList(
        icon: Icons.sports_kabaddi_rounded,
        title: l10n.noChallengesYet,
        hint: l10n.createOrJoin,
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (_ctrl.created.isNotEmpty) ...[
          _sectionHeader(l10n.myCreatedChallenges, _ctrl.created.length),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            sliver: SliverList.builder(
              itemCount: _ctrl.created.length,
              itemBuilder: (_, i) => _createdCard(_ctrl.created[i]),
            ),
          ),
        ],
        if (_ctrl.joined.isNotEmpty) ...[
          _sectionHeader(l10n.joinedChallenges, _ctrl.joined.length),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            sliver: SliverList.builder(
              itemCount: _ctrl.joined.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ChallengeCard(
                  challenge: _ctrl.joined[i],
                  showCreator: true,
                  onTap: () => _openDetail(_ctrl.joined[i]),
                ),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 90)),
      ],
    );
  }

  Widget _createdCard(ChallengeModel c) {
    final card = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ChallengeCard(
        challenge: c,
        // Un défi annoncé se rejoint depuis le fil : son code ne sert plus à
        // rien, et la carte porte déjà le compte à rebours.
        showShareCode: !c.isAnnounced,
        onTap: () => _openDetail(c),
      ),
    );

    if (!c.canDelete) return card;

    return Dismissible(
      key: Key('challenge-${c.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(c),
      onDismissed: (_) => _deleteChallenge(c),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.gutter),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppRadius.rMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 26),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context).deleteBtn,
                style: context.type.labelSmall.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      child: card,
    );
  }

  // ─── Fils de découverte ──────────────────────────────────────────────────

  /// Amis et global partagent la même liste : ce sont deux vues du même geste
  /// — un défi annoncé qu'on rejoint sans code.
  Widget _buildFeed({
    required List<ChallengeModel> challenges,
    required String emptyTitle,
    required String emptyHint,
    required IconData emptyIcon,
  }) {
    if (_ctrl.isLoading) return const QuizListSkeleton(count: 4);

    if (challenges.isEmpty) {
      return _emptyList(
        icon: emptyIcon,
        title: emptyTitle,
        hint: emptyHint,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, 100),
      itemCount: challenges.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => ChallengeCard(
        challenge: challenges[i],
        showCreator: true,
        // Seul le bouton engage : un tap sur la carte, en plein défilement,
        // ne doit pas inscrire quelqu'un à un défi.
        onAction: () => _joinAnnounced(challenges[i]),
      ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.1),
    );
  }

  /// Un défi annoncé se rejoint d'un tap : il porte déjà son code, inutile de
  /// demander au joueur de le retaper.
  Future<void> _joinAnnounced(ChallengeModel challenge) async {
    final joined = await _ctrl.joinChallenge(challenge.code);
    if (!mounted) return;

    if (joined == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).joinChallengeError),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    // Il quitte le fil pour rejoindre « mes défis » : un fil de découverte ne
    // propose que ce qui reste à faire.
    _ctrl.refresh();
    _openDetail(joined);
  }

  /// L'état vide reste défilable : sans quoi on ne peut pas tirer pour
  /// rafraîchir depuis un onglet vide, qui est précisément celui qu'on a le
  /// plus envie de rafraîchir.
  Widget _emptyList({
    required IconData icon,
    required String title,
    required String hint,
  }) =>
      ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.10),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StateGlyph(icon: icon, tint: AppColors.primary),
                const SizedBox(height: AppSpacing.lg),
                Text(title,
                    textAlign: TextAlign.center,
                    style: context.type.headlineMedium
                        .copyWith(color: context.appColors.textPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                  child: Text(hint,
                      textAlign: TextAlign.center,
                      style: context.type.bodyLarge
                          .copyWith(color: context.appColors.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      );

  SliverToBoxAdapter _sectionHeader(String title, int count) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              Text(title, style: context.type.titleLarge.copyWith(color: context.appColors.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.appColors.cardBgLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text('$count', style: context.type.labelMedium.copyWith(color: context.appColors.textMuted, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );

  void _openCreate() async {
    final result = await Navigator.push<ChallengeModel>(
      context,
      MaterialPageRoute(builder: (_) => CreateChallengeScreen(ctrl: _ctrl)),
    );
    if (result != null) {
      _openDetail(result);
    }
  }

  void _openJoin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JoinChallengeScreen(ctrl: _ctrl)),
    );
  }

  void _openDetail(ChallengeModel challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChallengeDetailScreen(challenge: challenge)),
    );
  }

  Future<bool> _confirmDelete(ChallengeModel challenge) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.appColors.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            title: Text(
              AppLocalizations.of(context).deleteChallengeTitle,
              style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w700),
            ),
            content: Text(
              AppLocalizations.of(context).deleteChallengeBody(challenge.title),
              style: TextStyle(color: context.appColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: context.appColors.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppLocalizations.of(context).deleteBtn, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteChallenge(ChallengeModel challenge) async {
    final success = await _ctrl.deleteChallenge(challenge.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? AppLocalizations.of(context).challengeDeleted : AppLocalizations.of(context).deleteError),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}
