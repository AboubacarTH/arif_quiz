import 'package:arif_quiz/features/challenges/bloc/challenge_controller.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/widgets/game_mode_card.dart';
import 'package:arif_quiz/ui/widgets/neon_button.dart';
import 'package:flutter/material.dart';

class CreateChallengeScreen extends StatefulWidget {
  final ChallengeController ctrl;

  const CreateChallengeScreen({super.key, required this.ctrl});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _titleCtrl = TextEditingController();
  GameMode _selectedMode = GameMode.classic;
  QuizModel? _selectedQuiz;
  List<QuizModel> _quizzes = [];
  bool _loadingQuizzes = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
    widget.ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadQuizzes() async {
    try {
      final data = await apiService.getFeaturedQuizzes();
      final list = data['quizzes'] as List? ?? data['data'] as List? ?? [];
      setState(() {
        _quizzes = list.map((e) => QuizModel.fromJson(e)).toList();
        _loadingQuizzes = false;
      });
    } catch (_) {
      setState(() => _loadingQuizzes = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(backgroundColor: context.appColors.bg, title: const Text('Créer un défi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Titre du défi'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              style: TextStyle(color: context.appColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Ex: Qui connaît l\'aviation ?'),
            ),
            const SizedBox(height: 24),
            _label('Choisir un quiz'),
            const SizedBox(height: 8),
            if (_loadingQuizzes)
              const Center(child: CircularProgressIndicator(color: AppColors.primary))
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quizzes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final q = _quizzes[i];
                    final selected = _selectedQuiz?.id == q.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedQuiz = q),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 160,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary.withValues(alpha: 0.15) : context.appColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.primary : const Color(0xFF2A2A4A),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q.title, style: TextStyle(color: selected ? AppColors.primary : context.appColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            Text('${q.totalQuestions} questions • ${q.difficulty}', style: TextStyle(color: context.appColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            _label('Mode de jeu'),
            const SizedBox(height: 8),
            ...GameMode.values.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GameModeCard(
                    mode: m,
                    selected: _selectedMode == m,
                    onTap: () => setState(() => _selectedMode = m),
                  ),
                )),
            const SizedBox(height: 24),
            NeonButton(
              label: widget.ctrl.isCreating ? 'Création...' : 'Créer le défi',
              width: double.infinity,
              icon: Icons.sports_esports,
              onTap: widget.ctrl.isCreating ? null : _create,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(color: context.appColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
      );

  Future<void> _create() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un titre pour le défi')),
      );
      return;
    }
    if (_selectedQuiz == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un quiz')),
      );
      return;
    }

    final challenge = await widget.ctrl.createChallenge(
      quizId: _selectedQuiz!.id,
      mode: _selectedMode.apiValue,
      title: _titleCtrl.text.trim(),
    );

    if (challenge != null && mounted) {
      Navigator.pop(context, challenge);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la création'), backgroundColor: AppColors.error),
      );
    }
  }
}
