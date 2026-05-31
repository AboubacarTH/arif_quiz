import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onTap;
  final bool showShareCode;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.showShareCode = false,
  });

  @override
  Widget build(BuildContext context) {
    final modeColor = AppColors.modeColor(challenge.mode);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A4A)),
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: modeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _modeLabel(challenge.mode),
                    style: TextStyle(
                      color: modeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: challenge.isOpen
                        ? AppColors.success.withValues(alpha: 0.15)
                        : context.appColors.textMuted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    challenge.isOpen ? 'Ouvert' : challenge.status,
                    style: TextStyle(
                      color: challenge.isOpen ? AppColors.success : context.appColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              challenge.title,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              challenge.quiz.title,
              style: TextStyle(color: context.appColors.textSecondary, fontSize: 13),
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
                  style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Icon(Icons.quiz_outlined, size: 14, color: context.appColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${challenge.quiz.totalQuestions} q.',
                  style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
                ),
              ],
            ),
            if (showShareCode) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF2A2A4A), height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.appColors.cardBgLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tag, size: 14, color: context.appColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            challenge.code,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
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
                        const SnackBar(content: Text('Code copié !'), duration: Duration(seconds: 1)),
                      );
                    },
                    icon: Icon(Icons.copy_rounded, size: 18, color: context.appColors.textSecondary),
                  ),
                  IconButton(
                    onPressed: () {
                      Share.share(
                        'Je te défie sur Arif Quiz ! Rejoins mon défi "${challenge.title}" avec le code : ${challenge.code}',
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

  String _modeLabel(String mode) => switch (mode) {
        'survival' => '❤️ Survie',
        'speed' => '⚡ Speed',
        _ => '🎮 Classique',
      };
}
