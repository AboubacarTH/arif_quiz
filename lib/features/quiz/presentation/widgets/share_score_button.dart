import 'dart:io';
import 'dart:ui' as ui;

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
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'J\'ai décroché un grade $grade ($pct%) sur « ${widget.quiz.title} » 🎯 '
            'Défie-moi sur ArifQuiz !',
      );
    } catch (e) {
      debugPrint('Share score error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Partage impossible'),
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
          label: 'Partager mon score',
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
              const Text('🎯', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text(
                'ARIFQUIZ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  fontFamily: 'Nunito',
                ),
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
                  style: TextStyle(
                    color: gradeColor,
                    fontSize: 56,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  '${result.score.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: gradeColor.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
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
            style: const TextStyle(
              color: _ink,
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
            ),
          ),
          if (challenge != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Défi · ${_modeLabel(challenge!.mode)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('${result.correctCount}/${result.totalQuestions}',
                    'Bonnes', AppColors.success),
                _sep(),
                _stat('${result.pointsEarned}', 'Points', AppColors.warning),
                _sep(),
                _stat(_fmtTime(result.timeTaken), 'Temps', AppColors.info),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Défie tes amis sur ArifQuiz 🚀',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) => Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
        ],
      );

  Widget _sep() => Container(width: 1, height: 34, color: _border);

  String _fmtTime(int s) => s < 60 ? '${s}s' : '${s ~/ 60}m ${s % 60}s';

  String _modeLabel(String mode) => switch (mode) {
        'survival' => 'Survie',
        'speed' => 'Speed',
        _ => 'Classique',
      };
}
