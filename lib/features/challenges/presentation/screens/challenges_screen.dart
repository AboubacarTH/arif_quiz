import 'package:arif_quiz/features/challenges/bloc/challenge_controller.dart';
import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/features/challenges/presentation/screens/challenge_detail_screen.dart';
import 'package:arif_quiz/features/challenges/presentation/screens/create_challenge_screen.dart';
import 'package:arif_quiz/features/challenges/presentation/screens/join_challenge_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/ui/widgets/challenge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  late final ChallengeController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ChallengeController(ChallengeRepository(apiService));
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.loadMyChallenges();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: const Text('Défis'),
        actions: [
          TextButton.icon(
            onPressed: () => _openJoin(),
            icon: const Icon(Icons.qr_code_scanner, size: 18, color: AppColors.secondary),
            label: const Text('Rejoindre', style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _ctrl.loadMyChallenges,
        color: AppColors.primary,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Créer un défi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildBody() {
    if (_ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final hasAny = _ctrl.created.isNotEmpty || _ctrl.joined.isNotEmpty;

    if (!hasAny) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text('Pas encore de défis', style: TextStyle(color: context.appColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Crée ou rejoins un défi !', style: TextStyle(color: context.appColors.textSecondary)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openCreate,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Créer'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _openJoin,
                      icon: const Icon(Icons.link, size: 18, color: AppColors.secondary),
                      label: const Text('Rejoindre', style: TextStyle(color: AppColors.secondary)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.secondary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (_ctrl.created.isNotEmpty) ...[
          _sectionHeader('Mes défis créés', _ctrl.created.length),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final c = _ctrl.created[i];
                  final card = Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ChallengeCard(
                      challenge: c,
                      showShareCode: true,
                      onTap: () => _openDetail(c),
                    ),
                  ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.1);

                  if (!c.canDelete) return card;

                  return Dismissible(
                    key: Key('challenge-${c.id}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(c),
                    onDismissed: (_) => _deleteChallenge(c),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
                          SizedBox(height: 4),
                          Text('Supprimer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    child: card,
                  );
                },
                childCount: _ctrl.created.length,
              ),
            ),
          ),
        ],
        if (_ctrl.joined.isNotEmpty) ...[
          _sectionHeader('Défis rejoints', _ctrl.joined.length),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ChallengeCard(
                    challenge: _ctrl.joined[i],
                    onTap: () => _openDetail(_ctrl.joined[i]),
                  ),
                ).animate().fadeIn(delay: (i * 60).ms).slideY(begin: 0.1),
                childCount: _ctrl.joined.length,
              ),
            ),
          ),
        ],
      ],
    );
  }

  SliverToBoxAdapter _sectionHeader(String title, int count) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              Text(title, style: TextStyle(color: context.appColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.appColors.cardBgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$count', style: TextStyle(color: context.appColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );

  void _openCreate() async {
    final result = await Navigator.push<ChallengeModel>(
      context,
      MaterialPageRoute(builder: (_) => CreateChallengeScreen(ctrl: _ctrl)),
    );
    if (result != null) {
      _openDetail(result);
    }
  }

  void _openJoin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JoinChallengeScreen(ctrl: _ctrl)),
    );
  }

  void _openDetail(ChallengeModel challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChallengeDetailScreen(challenge: challenge)),
    );
  }

  Future<bool> _confirmDelete(ChallengeModel challenge) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.appColors.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Supprimer le défi ?',
              style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Le défi "${challenge.title}" sera définitivement supprimé.',
              style: TextStyle(color: context.appColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Annuler', style: TextStyle(color: context.appColors.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Supprimer', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteChallenge(ChallengeModel challenge) async {
    final success = await _ctrl.deleteChallenge(challenge.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Défi supprimé' : 'Erreur lors de la suppression'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}
