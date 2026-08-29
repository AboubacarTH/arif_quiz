import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:arif_quiz/core/i18n/game_mode_l10n.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Bouton « Partager mon score » : rend une carte de résultat brandée
/// hors-écran, la capture en PNG et la partage via le sélecteur système.
class ShareScoreButton extends StatefulWidget {
  final QuizAttemptResult result;
  final QuizModel quiz;
  final ChallengeModel? challenge;

  const ShareScoreButton({
    super.key,
    required this.result,
    required this.quiz,
    this.challenge,
  });

  @override
  State<ShareScoreButton> createState() => _ShareScoreButtonState();
}

class _ShareScoreButtonState extends State<ShareScoreButton> {
  final _boundaryKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    // Résolu avant tout await : le texte partagé doit suivre la langue de
    // l'interface, et le context n'est plus sûr après les sauts asynchrones.
    final l10n = AppLocalizations.of(context);
    setState(() => _sharing = true);
    try {
      // Laisse un frame se peindre pour garantir un RepaintBoundary prêt.
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('RepaintBoundary indisponible');

      final image = await boundary.toImage(pixelRatio: 3);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      if (png == null) throw StateError('Encodage PNG échoué');

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/arifquiz_score_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(png.buffer.asUint8List());

      final grade = widget.result.grade;
      final pct = widget.result.score.toStringAsFixed(0);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: l10n.shareScoreText(grade, pct, widget.quiz.title),
        ),
      );
    } catch (e) {
      debugPrint('Share score error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.shareFailed),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Carte hors-écran (peinte mais non visible) capturée à la demande.
        Positioned(
          left: -10000,
          top: 0,
          child: RepaintBoundary(
            key: _boundaryKey,
            child: ShareResultCard(
              result: widget.result,
              quiz: widget.quiz,
              challenge: widget.challenge,
            ),
          ),
        ),
        AppButton(
          label: AppLocalizations.of(context).shareMyScore,
          icon: Icons.ios_share_rounded,
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          loading: _sharing,
          onPressed: _sharing ? null : _share,
        ),
      ],
    );
  }
}

/// Carte de résultat autonome et brandée, à palette fixe (indépendante du
/// thème de l'app) pour un rendu partagé cohérent.
class ShareResultCard extends StatelessWidget {
  final QuizAttemptResult result;
  final QuizModel quiz;
  final ChallengeModel? challenge;

  const ShareResultCard({
    super.key,
    required this.result,
    required this.quiz,
    this.challenge,
  });

  static const _ivory = Color(0xFFFFF7E6);
  static const _card = Color(0xFFFFFFFF);
  static const _border = Color(0xFFEFE3CC);
  static const _ink = Color(0xFF1C1917);
  static const _muted = Color(0xFF797060);

  @override
  Widget build(BuildContext context) {
    final grade = result.grade;
    final gradeColor = AppColors.gradeColor(grade);

    return Container(
      width: 380,
      color: _ivory,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.my_location_rounded, size: 22, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'ARIFQUIZ',
                style: context.type.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, letterSpacing: 2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: gradeColor, width: 4),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  grade,
                  style: AppType.scoreHero.copyWith(color: gradeColor, height: 1),
                ),
                Text(
                  '${result.score.toStringAsFixed(0)}%',
                  style: context.type.titleMedium.copyWith(color: gradeColor.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            quiz.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.type.headlineMedium.copyWith(color: _ink, height: 1.2, fontWeight: FontWeight.w800),
          ),
          if (challenge != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '${AppLocalizations.of(context).challengeLabel} · '
                '${GameMode.fromApi(challenge!.mode).localizedLabel(context)}',
                style: context.type.labelMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat(
                    context,
                    '${result.correctCount}/${result.totalQuestions}',
                    AppLocalizations.of(context).correctLabel,
                    AppColors.success),
                _sep(),
                _stat(context, '${result.pointsEarned}',
                    AppLocalizations.of(context).points, AppColors.warning),
                _sep(),
                _stat(context, _fmtTime(result.timeTaken),
                    AppLocalizations.of(context).timeLabel, AppColors.info),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).shareCardTagline,
            style: context.type.bodyMedium.copyWith(color: _muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label, Color color) =>
      Column(
        children: [
          Text(
            value,
            style: context.type.headlineMedium.copyWith(color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(label, style: context.type.labelMedium.copyWith(color: _muted)),
        ],
      );

  Widget _sep() => Container(width: 1, height: 34, color: _border);

  String _fmtTime(int s) => s < 60 ? '${s}s' : '${s ~/ 60}m ${s % 60}s';

}
