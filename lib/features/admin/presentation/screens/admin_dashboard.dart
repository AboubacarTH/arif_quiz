import 'package:arif_quiz/features/admin/data/admin_repository.dart';
import 'package:arif_quiz/features/admin/presentation/screens/admin_categories_screen.dart';
import 'package:arif_quiz/features/admin/presentation/screens/admin_import_screen.dart';
import 'package:arif_quiz/features/admin/presentation/screens/admin_questions_screen.dart';
import 'package:arif_quiz/features/admin/presentation/screens/admin_quizzes_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminRepository _repo;
  AdminStatsModel? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = AdminRepository(apiService);
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _loading = true; _error = null; });
    try {
      _stats = await _repo.getStats();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      appBar: AppBar(
        backgroundColor: context.appColors.bg,
        title: const Text('Admin', style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: AppColors.primary,
        backgroundColor: context.appColors.cardBg,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsSection(),
                    const SizedBox(height: 28),
                    _buildNavSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_loading) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: List.generate(4, (_) => _StatCardSkeleton()),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, style: TextStyle(color: context.appColors.textSecondary)),
        ),
      );
    }
    final s = _stats!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatCard(label: 'Catégories', value: s.totalCategories, icon: Icons.category_rounded, color: AppColors.info),
        _StatCard(label: 'Quiz total', value: s.totalQuizzes, icon: Icons.quiz_rounded, color: AppColors.primary),
        _StatCard(label: 'Publiés', value: s.publishedQuizzes, icon: Icons.published_with_changes_rounded, color: AppColors.success),
        _StatCard(label: 'Questions', value: s.totalQuestions, icon: Icons.help_outline_rounded, color: AppColors.secondary),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildNavSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestion',
          style: TextStyle(
            color: context.appColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.cardElevated,
            borderRadius: AppRadius.rXl,
            boxShadow: AppShadows.card(context),
          ),
          child: Column(
            children: [
              _NavTile(
                icon: Icons.category_rounded,
                color: AppColors.info,
                label: 'Catégories',
                subtitle: 'Ajouter, modifier, supprimer',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCategoriesScreen()),
                ).then((_) => _loadStats()),
              ),
              _divider(),
              _NavTile(
                icon: Icons.quiz_rounded,
                color: AppColors.primary,
                label: 'Quiz',
                subtitle: 'Gérer les quiz et leur statut',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminQuizzesScreen()),
                ).then((_) => _loadStats()),
              ),
              _divider(),
              _NavTile(
                icon: Icons.help_outline_rounded,
                color: AppColors.secondary,
                label: 'Questions',
                subtitle: 'Ajouter et modifier les questions',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminQuestionsScreen()),
                ).then((_) => _loadStats()),
              ),
              _divider(),
              _NavTile(
                icon: Icons.upload_file_rounded,
                color: AppColors.success,
                label: 'Import Excel',
                subtitle: 'Importer un quiz depuis un fichier',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminImportScreen()),
                ).then((_) => _loadStats()),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _divider() => Divider(height: 1, color: context.appColors.border);
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: context.appColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      );
}

class _StatCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          boxShadow: AppShadows.card(context),
        ),
      );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({required this.icon, required this.color, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(color: context.appColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(subtitle, style: TextStyle(color: context.appColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.appColors.textMuted),
            ],
          ),
        ),
      );
}
