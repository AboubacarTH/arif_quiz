import 'package:arif_quiz/features/quiz/presentation/screens/category_quizzes_screen.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/ui/animations/page_transitions.dart';
import 'package:arif_quiz/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Page « toutes les catégories » — grille complète, atteinte via le bouton
/// « Voir tout » de la section Catégories sur la Home. Réutilise l'endpoint
/// `GET /categories` (déjà exhaustif) et navigue vers [CategoryQuizzesScreen].
class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  List<CategoryModel> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await apiService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = raw.map((c) => CategoryModel.fromJson(c)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger les catégories';
        _loading = false;
      });
    }
  }

  void _openCategory(CategoryModel category) => Navigator.push(
        context,
        SlideRightRoute(page: CategoryQuizzesScreen(category: category)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.cardElevated,
                  borderRadius: AppRadius.rMd,
                  boxShadow: AppShadows.card(context),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: context.appColors.textSecondary, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Catégories',
                style: TextStyle(
                  color: context.appColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.primary, strokeWidth: 2),
      );
    }
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _load);
    }
    if (_categories.isEmpty) {
      return const EmptyState(
        title: 'Aucune catégorie',
        subtitle: 'Reviens plus tard, du contenu arrive bientôt',
        emoji: '📚',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      backgroundColor: context.appColors.cardBg,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
        ),
        itemCount: _categories.length,
        itemBuilder: (_, i) => _CategoryGridTile(
          category: _categories[i],
          onTap: () => _openCategory(_categories[i]),
        ).animate().fadeIn(delay: (i * 40).ms).slideY(begin: 0.06),
      ),
    );
  }
}

// ─── Grid tile ────────────────────────────────────────────────────────────────

class _CategoryGridTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryGridTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(category.color.replaceFirst('#', 'FF'), radix: 16));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardElevated,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: context.appColors.border),
          boxShadow: AppShadows.card(context),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(category.icon ?? '📚',
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.quizCount} quiz${category.quizCount != 1 ? 'zes' : ''}',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
