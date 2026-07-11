import 'package:arif_quiz/features/friends/bloc/friends_controller.dart';
import 'package:arif_quiz/features/friends/data/friends_repository.dart';
import 'package:arif_quiz/features/friends/presentation/screens/add_friend_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/widgets/friend_tile.dart';
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
    _ctrl.loadFriends();
    _ctrl.loadActivity();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: const Text('Amis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: AppColors.secondary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddFriendScreen(ctrl: _ctrl)),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.appColors.textMuted,
          tabs: [
            const Tab(text: 'Amis'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Demandes'),
                  if (_ctrl.pendingRequestsCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_ctrl.pendingRequestsCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Activité'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildFriendsList(),
          _buildRequests(),
          _buildActivity(),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_ctrl.friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👥', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Pas encore d\'amis', style: TextStyle(color: context.appColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Recherche des joueurs à ajouter !', style: TextStyle(color: context.appColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddFriendScreen(ctrl: _ctrl))),
              icon: const Icon(Icons.person_add),
              label: const Text('Ajouter des amis'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _ctrl.loadFriends,
      color: AppColors.primary,
      child: ListView.separated(
        itemCount: _ctrl.friends.length,
        separatorBuilder: (_, __) => Divider(color: context.appColors.border, height: 1),
        itemBuilder: (_, i) {
          final f = _ctrl.friends[i];
          return FriendTile(
            user: f.friend,
            trailingText: f.since != null ? 'Depuis ${timeago.format(f.since!)}' : null,
            trailing: IconButton(
              icon: Icon(Icons.more_vert, color: context.appColors.textMuted, size: 18),
              onPressed: () => _showFriendOptions(f),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequests() {
    if (_ctrl.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📬', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Aucune demande en attente', style: TextStyle(color: context.appColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: _ctrl.requests.length,
      separatorBuilder: (_, __) => Divider(color: context.appColors.border, height: 1),
      itemBuilder: (_, i) {
        final req = _ctrl.requests[i];
        return FriendTile(
          user: req.sender,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                onPressed: () async {
                  final ok = await _ctrl.acceptRequest(req.id);
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${req.sender.name} ajouté !'), backgroundColor: AppColors.success),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                onPressed: () => _ctrl.declineRequest(req.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivity() {
    if (_ctrl.activity.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📊', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Pas d\'activité récente', style: TextStyle(color: context.appColors.textSecondary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _ctrl.loadActivity,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _ctrl.activity.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final a = _ctrl.activity[i];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.cardElevated,
              borderRadius: AppRadius.rMd,
              boxShadow: AppShadows.card(context),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    a.user.name.isNotEmpty ? a.user.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${a.user.name} • ${a.quiz.title}',
                        style: TextStyle(color: context.appColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        a.completedAt != null ? timeago.format(a.completedAt!) : '',
                        style: TextStyle(color: context.appColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${a.score.toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFriendOptions(FriendModel friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(friend.friend.name,
                style: TextStyle(color: context.appColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined, color: AppColors.error),
              title: const Text('Supprimer cet ami', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                await _ctrl.removeFriend(friend.friendshipId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
