import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/features/challenges/bloc/challenge_controller.dart';
import 'package:arif_quiz/features/challenges/presentation/screens/challenge_detail_screen.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/widgets/neon_button.dart';
import 'package:flutter/material.dart';

class JoinChallengeScreen extends StatefulWidget {
  final ChallengeController ctrl;

  const JoinChallengeScreen({super.key, required this.ctrl});

  @override
  State<JoinChallengeScreen> createState() => _JoinChallengeScreenState();
}

class _JoinChallengeScreenState extends State<JoinChallengeScreen> {
  final _codeCtrl = TextEditingController();
  ChallengeModel? _preview;
  bool _isPreviewing = false;

  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(backgroundColor: context.appColors.bg, title: Text(AppLocalizations.of(context).joinChallengeTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).enterChallengeCode,
              style: TextStyle(color: context.appColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).codeHelp,
              style: TextStyle(color: context.appColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeCtrl,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              decoration: InputDecoration(
                hintText: 'EX: X7K2PQ4R',
                hintStyle: TextStyle(color: context.appColors.textMuted, letterSpacing: 2, fontSize: 18),
                counterText: '',
              ),
              onChanged: (val) {
                if (val.length == 8) {
                  _previewChallenge(val);
                } else {
                  setState(() => _preview = null);
                }
              },
            ),
            const SizedBox(height: 20),
            if (_isPreviewing)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else if (_preview != null)
              _buildPreview(_preview!),
            if (widget.ctrl.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(widget.ctrl.error!, style: const TextStyle(color: AppColors.error)),
              ),
            const Spacer(),
            NeonButton(
              label: widget.ctrl.isJoining ? AppLocalizations.of(context).loadingEllipsis : AppLocalizations.of(context).joinChallengeBtn,
              width: double.infinity,
              icon: Icons.sports_esports,
              onTap: widget.ctrl.isJoining ? null : _join,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(ChallengeModel c) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardElevated,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadows.tinted(context, AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).challengeFound, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          Text(c.title, style: TextStyle(color: context.appColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(c.sourceLabel, style: TextStyle(color: context.appColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            _chip(AppColors.modeColor(c.mode), _modeLabel(c.mode)),
            const SizedBox(width: 8),
            _chip(context.appColors.textMuted, AppLocalizations.of(context).byCreator(c.creator.name)),
          ]),
        ],
      ),
    );
  }

  Widget _chip(Color color, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );

  String _modeLabel(String mode) => switch (mode) {
        'survival' => '❤️ ${AppLocalizations.of(context).modeSurvivalShort}',
        'speed' => '⚡ ${AppLocalizations.of(context).modeSpeedShort}',
        _ => '🎮 Classique',
      };

  Future<void> _previewChallenge(String code) async {
    setState(() => _isPreviewing = true);
    _preview = await widget.ctrl.getChallengeByCode(code.toUpperCase());
    setState(() => _isPreviewing = false);
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).codeLengthError)),
      );
      return;
    }

    final challenge = await widget.ctrl.joinChallenge(code);
    if (challenge != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChallengeDetailScreen(challenge: challenge)),
      );
    }
  }
}
