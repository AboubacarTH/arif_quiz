import 'dart:io';

import 'package:arif_quiz/core/i18n/locale_controller.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Choix de la langue puis export des questions vers un fichier Excel partagé.
///
/// Le fichier produit reprend le format du modèle d'import : il est donc
/// directement réimportable (édition en masse, sauvegarde, ou base de travail
/// pour traduire un quiz dans une autre langue).
class ExportQuestionsSheet {
  const ExportQuestionsSheet._();

  /// [download] reçoit la locale choisie et rend le fichier écrit sur disque.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required Future<File> Function(String locale) download,
  }) async {
    final locale = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.appColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _LocalePicker(title: title),
    );

    if (locale == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.exportInProgress)),
    );

    try {
      final file = await download(locale);
      await Share.shareXFiles([XFile(file.path)], text: title);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }
}

class _LocalePicker extends StatelessWidget {
  final String title;
  const _LocalePicker({required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.exportQuestions,
                style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: context.appColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Text(l10n.exportLocaleHint,
                style: TextStyle(
                    color: context.appColors.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            for (final code in LocaleController.supportedCodes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.table_chart_rounded,
                    color: AppColors.secondary),
                title: Text(LocaleController.labels[code] ?? code,
                    style: TextStyle(color: context.appColors.textPrimary)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context, code),
              ),
          ],
        ),
      ),
    );
  }
}
