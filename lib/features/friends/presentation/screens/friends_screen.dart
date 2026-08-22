import 'package:arif_quiz/features/friends/bloc/friends_controller.dart';
import 'package:arif_quiz/features/friends/data/friends_repository.dart';
import 'package:arif_quiz/features/friends/presentation/screens/add_friend_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:arif_quiz/ui/widgets/friend_tile.dart';
import 'package:arif_quiz/ui/widgets/shimmer_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final FriendsController _ctrl;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _ctrl = FriendsController(FriendsRepository(apiService));
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Text(l10n.friends),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined,
                color: AppColors.secondary),
            onPressed: _openAddFriend,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.appColors.textMuted,
          tabs: [
            Tab(text: l10n.friends),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.requestsTab),
                  if (_ctrl.pendingRequestsCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_ctrl.pendingRequestsCount}',
                        style: context.type.labelSmall.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: l10n.activityTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _refreshable(_buildFriends()),
          _refreshable(_buildRequests()),
          _refreshable(_buildActivity()),
        ],
      ),
    );
  }

  /// Le rafraîchissement ne vide plus l'onglet, et il recharge les trois : un
  /// même écran, dont les onglets se répondent — accepter une demande change
  /// aussi la liste d'amis.
  Widget _refreshable(Widget child) => RefreshIndicator(
        onRefresh: _ctrl.refresh,
        color: AppColors.primary,
        backgroundColor: context.appColors.cardBg,
        child: child,
      );

  // ─── Amis ─────────────────────────────────────────────────────────────────

  Widget _buildFriends() {
    if (_ctrl.isLoading) return const QuizListSkeleton(count: 5);

    final l10n = AppLocalizations.of(context);
    if (_ctrl.friends.isEmpty) {
      return _emptyList(
        icon: Icons.group_rounded,
        title: l10n.noFriendsYet,
        hint: l10n.searchPlayersToAdd,
        action: ElevatedButton.icon(
          onPressed: _openAddFriend,
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
          label: Text(l10n.addFriends),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.xxl),
      itemCount: _ctrl.friends.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              l10n.friendsCount(_ctrl.friends.length),
              style: context.type.labelMedium
                  .copyWith(color: context.appColors.textMuted),
            ),
          );
        }

        final friend = _ctrl.friends[i - 1];
        return _card(
          child: FriendTile(
            user: friend.friend,
            trailingText: friend.since != null
                ? l10n.sinceLabel(timeago.format(friend.since!))
                : null,
            trailing: IconButton(
              icon: Icon(Icons.more_vert,
                  color: context.appColors.textMuted, size: 18),
              onPressed: () => _showFriendOptions(friend),
            ),
          ),
        );
      },
    );
  }

  // ─── Demandes ─────────────────────────────────────────────────────────────

  Widget _buildRequests() {
    if (_ctrl.isLoading || !_ctrl.requestsLoaded) {
      return const QuizListSkeleton(count: 3);
    }

    final l10n = AppLocalizations.of(context);
    if (_ctrl.requests.isEmpty) {
      return _emptyList(
        icon: Icons.mark_email_unread_rounded,
        title: l10n.noPendingRequests,
        hint: l10n.noPendingRequestsHint,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.xxl),
      itemCount: _ctrl.requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final request = _ctrl.requests[i];

        return _card(
          child: Column(
            children: [
              FriendTile(user: request.sender),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                // Deux icônes nues, une verte et une rouge, laissaient deviner
                // laquelle acceptait : ce sont des boutons nommés, maintenant.
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _ctrl.declineRequest(request.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.appColors.textSecondary,
                          side: BorderSide(color: context.appColors.border),
                        ),
                        child: Text(l10n.declineLabel),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _accept(request),
                        child: Text(l10n.acceptLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _accept(FriendRequest request) async {
    final ok = await _ctrl.acceptRequest(request.id);
    if (!ok || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            AppLocalizations.of(context).friendAdded(request.sender.name)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // ─── Activité ─────────────────────────────────────────────────────────────

  Widget _buildActivity() {
    if (_ctrl.isLoading || !_ctrl.activityLoaded) {
      return const QuizListSkeleton(count: 4);
    }

    final l10n = AppLocalizations.of(context);
    if (_ctrl.activity.isEmpty) {
      return _emptyList(
        icon: Icons.insights_rounded,
        title: l10n.noRecentActivity,
        hint: l10n.noRecentActivityHint,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.xxl),
      itemCount: _ctrl.activity.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _activityCard(_ctrl.activity[i]),
    );
  }

  Widget _activityCard(FriendActivity activity) {
    // La note dit déjà si la partie s'est bien passée : la pastille prend la
    // couleur du grade au lieu du rouille de l'app, qui ne disait rien.
    final gradeColor = AppColors.gradeColor(gradeForScore(activity.score));

    return _card(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _avatar(activity.user),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.titleMedium
                      .copyWith(color: context.appColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.quiz.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.bodyMedium
                      .copyWith(color: context.appColors.textSecondary),
                ),
                if (activity.completedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    timeago.format(activity.completedAt!),
                    style: context.type.labelSmall
                        .copyWith(color: context.appColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 6),
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.15),
              borderRadius: AppRadius.rPill,
            ),
            child: Text(
              '${activity.score.toStringAsFixed(0)}%',
              style: context.type.labelLarge
                  .copyWith(color: gradeColor, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(UserModel user) {
    final hasPhoto = user.avatar != null && user.avatar!.startsWith('http');

    return CircleAvatar(
      radius: 20,
      backgroundColor: hasPhoto
          ? context.appColors.cardBgLight
          : AppColors.primary.withValues(alpha: 0.2),
      backgroundImage:
          hasPhoto ? CachedNetworkImageProvider(user.avatar!) : null,
      child: hasPhoto
          ? null
          : Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: context.type.titleMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w800),
            ),
    );
  }

  // ─── Pièces communes ──────────────────────────────────────────────────────

  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
        child: child,
      );

  /// L'état vide reste défilable : sans quoi on ne peut pas tirer pour
  /// rafraîchir depuis un onglet vide, qui est précisément celui qu'on a le
  /// plus envie de rafraîchir.
  Widget _emptyList({
    required IconData icon,
    required String title,
    required String hint,
    Widget? action,
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
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  action,
                ],
              ],
            ),
          ),
        ],
      );

  void _openAddFriend() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddFriendScreen(ctrl: _ctrl)),
      );

  void _showFriendOptions(FriendModel friend) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friend.friend.name,
                  style: context.type.titleLarge
                      .copyWith(color: context.appColors.textPrimary)),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Icon(Icons.person_remove_outlined,
                    color: AppColors.error),
                title: Text(AppLocalizations.of(context).removeFriend,
                    style: const TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(context);
                  await _ctrl.removeFriend(friend.friendshipId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
