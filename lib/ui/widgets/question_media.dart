import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Média d'une question pendant le jeu : image illustrative et/ou lecteur audio.
/// Ne rend rien si aucune URL n'est fournie.
class QuestionMedia extends StatelessWidget {
  final String? imageUrl;
  final String? audioUrl;

  const QuestionMedia({super.key, this.imageUrl, this.audioUrl});

  bool get _hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
  bool get _hasAudio => audioUrl != null && audioUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasImage && !_hasAudio) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasImage) _image(context),
        if (_hasImage && _hasAudio) const SizedBox(height: 12),
        if (_hasAudio) _AudioPlayerBar(url: audioUrl!.trim()),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _image(BuildContext context) {
    // Hauteur optimale : ~28 % de l'écran, bornée pour rester lisible partout.
    final maxH =
        (MediaQuery.sizeOf(context).height * 0.28).clamp(140.0, 260.0);
    return ClipRRect(
      borderRadius: AppRadius.rLg,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        color: context.appColors.cardBg,
        child: CachedNetworkImage(
          imageUrl: imageUrl!.trim(),
          fit: BoxFit.contain,
          width: double.infinity,
          placeholder: (_, __) => const SizedBox(
            height: 140,
            child: Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            ),
          ),
          errorWidget: (_, __, ___) => SizedBox(
            height: 120,
            child: Center(
              child: Icon(Icons.broken_image_rounded,
                  color: context.appColors.textMuted, size: 34),
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioPlayerBar extends StatefulWidget {
  final String url;
  const _AudioPlayerBar({required this.url});

  @override
  State<_AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<_AudioPlayerBar> {
  late final AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _playing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    // Précharge la source pour connaître la durée sans jouer.
    _player.setSourceUrl(widget.url).catchError((_) {});
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _playing = s == PlayerState.playing);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playing = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
    } else {
      setState(() => _loading = true);
      try {
        await _player.play(UrlSource(widget.url));
      } catch (_) {}
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final total = _duration.inMilliseconds;
    final pos = _position.inMilliseconds.clamp(0, total == 0 ? 1 : total);
    final progress = total == 0 ? 0.0 : pos / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardElevated,
        borderRadius: AppRadius.rMd,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _loading ? null : _toggle,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryLight]),
                shape: BoxShape.circle,
              ),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(
                      _playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded,
                        color: AppColors.secondary, size: 15),
                    const SizedBox(width: 6),
                    Text('Écouter l\'extrait',
                        style: TextStyle(
                            color: context.appColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${_fmt(_position)} / ${_fmt(_duration)}',
                        style: TextStyle(
                            color: context.appColors.textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: context.appColors.cardBgLight,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.secondaryLight),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
