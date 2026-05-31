import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FriendTile extends StatelessWidget {
  final UserModel user;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback? onTap;

  const FriendTile({
    super.key,
    required this.user,
    this.trailingText,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _avatar(context),
      title: Text(
        user.name,
        style: TextStyle(
          color: context.appColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Niv. ${user.level}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (user.streak > 0) ...[
            Text('🔥 ${user.streak}',
                style: const TextStyle(fontSize: 11, color: AppColors.warning)),
            const SizedBox(width: 6),
          ],
          Text(
            '${user.totalPoints} pts',
            style: TextStyle(color: context.appColors.textMuted, fontSize: 11),
          ),
        ],
      ),
      trailing: trailing ??
          (trailingText != null
              ? Text(
                  trailingText!,
                  style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
                )
              : null),
    );
  }

  Widget _avatar(BuildContext context) {
    if (user.avatar != null && user.avatar!.startsWith('http')) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: context.appColors.cardBgLight,
        backgroundImage: CachedNetworkImageProvider(user.avatar!),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}
