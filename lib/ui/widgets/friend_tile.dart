import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
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
        style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              AppLocalizations.of(context).levelShort(user.level),
              style: context.type.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 6),
          if (user.streak > 0) ...[
            const Icon(Icons.local_fire_department_rounded,
                size: 13, color: AppColors.warning),
            const SizedBox(width: 2),
            Text('${user.streak}',
                style: context.type.labelSmall
                    .copyWith(color: AppColors.warning)),
            const SizedBox(width: 6),
          ],
          Text(
            AppLocalizations.of(context).pointsTotal(user.totalPoints),
            style: context.type.labelSmall.copyWith(color: context.appColors.textMuted),
          ),
        ],
      ),
      trailing: trailing ??
          (trailingText != null
              ? Text(
                  trailingText!,
                  style: context.type.labelMedium.copyWith(color: context.appColors.textMuted),
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
        style: context.type.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
      ),
    );
  }
}
