import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/features/friends/bloc/friends_controller.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  final FriendsController ctrl;

  const AddFriendScreen({super.key, required this.ctrl});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: Text(AppLocalizations.of(context).addFriends),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: TextStyle(color: context.appColors.textPrimary),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchByNameHint,
                prefixIcon: Icon(Icons.search, color: context.appColors.textMuted),
                suffixIcon: widget.ctrl.isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      )
                    : null,
              ),
              onChanged: (q) => widget.ctrl.searchUsers(q),
            ),
          ),
          Expanded(
            child: widget.ctrl.searchResults.isEmpty && _searchCtrl.text.length >= 2
                ? Center(child: Text(AppLocalizations.of(context).noPlayerFound, style: TextStyle(color: context.appColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.ctrl.searchResults.length,
                    separatorBuilder: (_, __) => Divider(color: context.appColors.border, height: 1),
                    itemBuilder: (_, i) => _UserResultTile(
                      user: widget.ctrl.searchResults[i],
                      onSendRequest: () async {
                        final ok = await widget.ctrl.sendRequest(widget.ctrl.searchResults[i].id);
                        if (ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context).requestSent), backgroundColor: AppColors.success),
                          );
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserResultTile extends StatelessWidget {
  final UserSearchResult user;
  final VoidCallback onSendRequest;

  const _UserResultTile({required this.user, required this.onSendRequest});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
        backgroundImage: user.avatar != null && user.avatar!.startsWith('http')
            ? CachedNetworkImageProvider(user.avatar!)
            : null,
        child: user.avatar == null
            ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))
            : null,
      ),
      title: Text(user.name, style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w700)),
      subtitle: Text(
        user.username != null ? '@${user.username} • Niv. ${user.level}' : AppLocalizations.of(context).levelShort(user.level),
        style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
      ),
      trailing: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final status = user.friendshipStatus;
    if (status == 'accepted') {
      return const Chip(
        label: Text('Ami', style: TextStyle(color: AppColors.success, fontSize: 12)),
        backgroundColor: Color(0xFF0D2B1F),
        side: BorderSide(color: AppColors.success, width: 1),
      );
    }
    if (status == 'pending') {
      return Chip(
        label: Text(
          user.isSender == true ? AppLocalizations.of(context).sentLabel : AppLocalizations.of(context).receivedLabel,
          style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
        ),
        backgroundColor: context.appColors.cardBgLight,
        side: BorderSide(color: context.appColors.border),
      );
    }
    return ElevatedButton.icon(
      onPressed: onSendRequest,
      icon: const Icon(Icons.person_add, size: 14),
      label: Text(AppLocalizations.of(context).addBtn, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
