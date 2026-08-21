import 'package:cached_network_image/cached_network_image.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/core/i18n/challenge_status_l10n.dart';
import 'package:arif_quiz/core/i18n/game_mode_l10n.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onTap;
  final bool showShareCode;

  /// Dans un fil de découverte, la première question est « qui me défie ? ».
  /// Sur mes propres défis, la réponse est moi : inutile de l'afficher.
  final bool showCreator;

  /// Le geste principal de la carte quand elle vit dans un fil.
  final String? actionLabel;
  final VoidCallback? onAction;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.showShareCode = false,
    this.showCreator = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final modeColor = AppColors.modeColor(challenge.mode);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    border: Border.all(color: modeColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(GameMode.fromApi(challenge.mode).icon,
                          size: 12, color: modeColor),
                      const SizedBox(width: 4),
                      Text(
                        GameMode.fromApi(challenge.mode).localizedLabel(context),
                        style: context.type.labelSmall.copyWith(
                            color: modeColor, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _statusPill(context),
              ],
            ),
            if (showCreator) ...[
              const SizedBox(height: 10),
              _creatorLine(context),
            ],
            const SizedBox(height: 10),
            Text(
              challenge.title,
              style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              challenge.sourceLabel,
              style: context.type.bodyMedium.copyWith(color: context.appColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.group_outlined, size: 14, color: context.appColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${challenge.participantsCount} participant${challenge.participantsCount > 1 ? 's' : ''}',
                  style: context.type.labelMedium.copyWith(color: context.appColors.textMuted),
                ),
                const SizedBox(width: 12),
                Icon(Icons.quiz_outlined, size: 14, color: context.appColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${challenge.questionsCount} questions',
                  style: context.type.labelMedium.copyWith(color: context.appColors.textMuted),
                ),
                if (challenge.myCompleted) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      AppLocalizations.of(context).alreadyPlayedTag,
                      style: context.type.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
            if (onAction != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel ??
                      AppLocalizations.of(context).joinChallengeAction),
                ),
              ),
            ],
            if (showShareCode) ...[
              const SizedBox(height: 12),
              Divider(color: context.appColors.border, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.appColors.cardBgLight,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tag, size: 14, color: context.appColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            challenge.code,
                            style: context.type.titleLarge.copyWith(color: AppColors.accent, fontWeight: FontWeight.w800, letterSpacing: 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: challenge.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text(AppLocalizations.of(context).codeCopied),
                            duration: const Duration(seconds: 1)),
                      );
                    },
                    icon: Icon(Icons.copy_rounded, size: 18, color: context.appColors.textSecondary),
                  ),
                  IconButton(
                    onPressed: () {
                      Share.share(
                        AppLocalizations.of(context).shareChallengeText(
                            challenge.title, challenge.code),
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.secondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Un défi annoncé n'a que 24 h à vivre : le temps restant dit plus que
  /// « ouvert », qui va de soi tant qu'il est là.
  Widget _statusPill(BuildContext context) {
    final hours = challenge.isAnnounced ? challenge.hoursLeft : null;

    if (hours != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded,
                size: 12, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).expiresIn(hours),
              style: context.type.labelSmall.copyWith(
                  color: AppColors.warning, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: challenge.isOpen
            ? AppColors.success.withValues(alpha: 0.15)
            : context.appColors.textMuted.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        ChallengeStatusL10n.label(context, challenge),
        style: context.type.labelSmall.copyWith(
            color: challenge.isOpen
                ? AppColors.success
                : context.appColors.textMuted,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _creatorLine(BuildContext context) {
    final creator = challenge.creator;
    final hasPhoto = creator.avatar != null && creator.avatar!.startsWith('http');

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: hasPhoto
              ? context.appColors.cardBgLight
              : AppColors.primary.withValues(alpha: 0.2),
          backgroundImage:
              hasPhoto ? CachedNetworkImageProvider(creator.avatar!) : null,
          child: hasPhoto
              ? null
              : Text(
                  creator.name.isNotEmpty ? creator.name[0].toUpperCase() : '?',
                  style: context.type.labelSmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            creator.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.labelMedium
                .copyWith(color: context.appColors.textSecondary),
          ),
        ),
      ],
    );
  }

}
