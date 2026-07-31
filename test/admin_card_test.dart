import 'package:arif_quiz/features/admin/presentation/widgets/admin_card.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le débordement horizontal des barres d'action admin était le défaut d'origine :
/// ces tests figent la garantie « quelle que soit la largeur, la locale ou la
/// longueur des libellés, rien ne sort de l'écran ».

Widget _wrap(Widget child, {Locale locale = const Locale('fr')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [child],
        ),
      ),
    );

/// Simule un petit téléphone (320 dp de large), le pire cas du parc Android.
void _useNarrowScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('l\'en-tête absorbe un titre long, des badges et un menu',
      (tester) async {
    _useNarrowScreen(tester);
    await tester.pumpWidget(_wrap(
      AdminCard(
        onTap: () {},
        child: AdminCardHeader(
          leading: const AdminLeadingBox(
              color: AppColors.primary, child: Text('12')),
          title:
              'Un titre de quiz vraiment très long qui doit s\'ellipser proprement',
          subtitle: const Text('Catégorie avec un nom lui aussi interminable'),
          badges: const [
            AdminTag(label: 'Brouillon', color: AppColors.warning, strong: true),
            AdminTag(label: 'Inactif', color: AppColors.error),
          ],
          menuActions: [
            AdminAction(
                icon: Icons.edit_rounded, label: 'Modifier', onPressed: () {}),
            AdminAction(
                icon: Icons.delete_rounded,
                label: 'Supprimer',
                destructive: true,
                onPressed: () {}),
          ],
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
  });

  testWidgets('un badge court ne vole pas la largeur du titre', (tester) async {
    _useNarrowScreen(tester);
    await tester.pumpWidget(_wrap(
      AdminCard(
        child: AdminCardHeader(
          title: 'Un titre de quiz assez long pour occuper toute la ligne',
          badges: const [AdminTag(label: 'Publié', color: AppColors.success)],
          menuActions: [
            AdminAction(
                icon: Icons.edit_rounded, label: 'Modifier', onPressed: () {}),
          ],
        ),
      ),
    ));

    // 320 - 32 (marge liste) - 32 (padding carte) = 256 dp utiles. Le titre
    // récupère tout ce que le badge et le menu ne prennent pas ; un `Flexible`
    // sur le badge le limiterait à la moitié de l'espace libre, soit ~106 dp.
    final titleBlockWidth = tester
        .getSize(find
            .descendant(
                of: find.byType(AdminCardHeader), matching: find.byType(Padding))
            .first)
        .width;
    expect(titleBlockWidth, greaterThan(120));
    expect(tester.takeException(), isNull);
  });

  testWidgets('les puces d\'action passent à la ligne au lieu de déborder',
      (tester) async {
    _useNarrowScreen(tester);
    await tester.pumpWidget(_wrap(
      AdminCard(
        child: AdminActionBar(
          actions: [
            AdminAction(
                icon: Icons.upload_file_rounded,
                label: 'Importer des questions',
                onPressed: () {}),
            AdminAction(
                icon: Icons.download_rounded,
                label: 'Exporter les questions',
                onPressed: () {}),
            AdminAction(
                icon: Icons.help_outline_rounded,
                label: 'Questions',
                onPressed: () {}),
          ],
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.byType(AdminActionChip), findsNWidgets(3));
    // Rien ne dépasse de la largeur de l'écran.
    for (final chip in tester.widgetList<AdminActionChip>(
        find.byType(AdminActionChip))) {
      final rect = tester.getRect(find.byWidget(chip));
      expect(rect.right, lessThanOrEqualTo(320));
      expect(rect.left, greaterThanOrEqualTo(0));
    }
  });

  testWidgets('le menu expose toutes les actions et grise les indisponibles',
      (tester) async {
    _useNarrowScreen(tester);
    var edited = 0;
    await tester.pumpWidget(_wrap(
      AdminCard(
        child: AdminCardHeader(
          title: 'Palier 3',
          menuActions: [
            AdminAction(
                icon: Icons.edit_rounded,
                label: 'Modifier',
                onPressed: () => edited++),
            const AdminAction(
                icon: Icons.keyboard_arrow_up_rounded,
                label: 'Monter',
                onPressed: null),
          ],
        ),
      ),
    ));

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Modifier'), findsOneWidget);
    expect(find.text('Monter'), findsOneWidget);

    // Action désactivée : le tap ne referme rien et ne déclenche rien.
    await tester.tap(find.text('Monter'));
    await tester.pumpAndSettle();
    expect(edited, 0);

    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    expect(edited, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rend correctement en arabe (RTL)', (tester) async {
    _useNarrowScreen(tester);
    await tester.pumpWidget(_wrap(
      AdminCard(
        child: Column(
          children: [
            AdminCardHeader(
              title: 'ما هي عاصمة فرنسا وما عدد سكانها اليوم بالضبط؟',
              badges: const [
                AdminTag(label: 'مسودة', color: AppColors.warning, strong: true)
              ],
              menuActions: [
                AdminAction(
                    icon: Icons.edit_rounded, label: 'تعديل', onPressed: () {}),
              ],
            ),
            const SizedBox(height: 12),
            AdminActionBar(actions: [
              AdminAction(
                  icon: Icons.upload_file_rounded,
                  label: 'استيراد الأسئلة',
                  onPressed: () {}),
              AdminAction(
                  icon: Icons.download_rounded,
                  label: 'تصدير الأسئلة',
                  onPressed: () {}),
            ]),
          ],
        ),
      ),
      locale: const Locale('ar'),
    ));

    expect(tester.takeException(), isNull);
    expect(find.byType(Directionality), findsWidgets);
  });
}
