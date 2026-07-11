import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// Saisie des traductions dans les formulaires admin Flutter.
/// Les champs principaux du formulaire = anglais (langue par défaut) ;
/// cette section gère les langues additionnelles (fr / ar / es).

typedef TranslationsMap = Map<String, Map<String, dynamic>>;

const kTranslationLocales = [
  (code: 'fr', label: 'Français', rtl: false),
  (code: 'ar', label: 'العربية', rtl: true),
  (code: 'es', label: 'Español', rtl: false),
];

/// Copie profonde (les modèles exposent des maps immuables `const {}`).
TranslationsMap copyTranslations(TranslationsMap src) =>
    src.map((l, v) => MapEntry(l, Map<String, dynamic>.from(v)));

String trGet(TranslationsMap t, String locale, String field) {
  final v = t[locale]?[field];
  return v is String ? v : '';
}

List<String> trGetList(TranslationsMap t, String locale, String field) {
  final v = t[locale]?[field];
  return v is List ? v.map((e) => e.toString()).toList() : <String>[];
}

void trSet(TranslationsMap t, String locale, String field, dynamic value) {
  (t[locale] ??= <String, dynamic>{})[field] = value;
}

class TranslationsSection extends StatefulWidget {
  /// Construit les champs de la locale active (isRtl déjà appliqué via Directionality).
  final Widget Function(BuildContext context, String locale) builder;

  /// Locale considérée « remplie » (pastille verte sur l'onglet).
  final bool Function(String locale)? filled;

  const TranslationsSection({super.key, required this.builder, this.filled});

  @override
  State<TranslationsSection> createState() => _TranslationsSectionState();
}

class _TranslationsSectionState extends State<TranslationsSection> {
  String _active = 'fr';

  @override
  Widget build(BuildContext context) {
    final active =
        kTranslationLocales.firstWhere((l) => l.code == _active);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.translate_rounded,
                color: AppColors.secondary, size: 16),
            const SizedBox(width: 6),
            Text(AppLocalizations.of(context).translationsLabel,
                style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 2),
        Text(AppLocalizations.of(context).mainFieldsEnglish,
            style: TextStyle(
                color: context.appColors.textMuted, fontSize: 11)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final l in kTranslationLocales) ...[
              GestureDetector(
                onTap: () => setState(() => _active = l.code),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _active == l.code
                            ? AppColors.secondary
                            : context.appColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _active == l.code
                                ? AppColors.secondary
                                : context.appColors.border),
                      ),
                      child: Text(
                        l.label,
                        style: TextStyle(
                          color: _active == l.code
                              ? Colors.white
                              : context.appColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (widget.filled?.call(l.code) ?? false)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Directionality(
          textDirection: active.rtl ? TextDirection.rtl : TextDirection.ltr,
          // Clé par locale : force la reconstruction des TextFormField
          // (initialValue) quand on change d'onglet.
          child: KeyedSubtree(
            key: ValueKey('tr-${active.code}'),
            child: widget.builder(context, active.code),
          ),
        ),
      ],
    );
  }
}
