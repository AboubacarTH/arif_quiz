import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/core/monetization/monetization_controller.dart';
import 'package:arif_quiz/core/subscriptions/subscription_service.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Affiche le paywall quand l'utilisateur n'est pas premium
/// et qu'il n'y a pas de pub disponible.
///
/// Usage :
/// ```dart
/// await PaywallSheet.show(context, ctrl: monetizationController, onGranted: () { ... });
/// ```
class PaywallSheet extends StatefulWidget {
  final MonetizationController ctrl;

  /// Partie à lancer une fois l'accès obtenu. `null` = feuille ouverte hors
  /// partie (depuis le profil) : la publicité crédite alors le solde **sans**
  /// en consommer une, sinon le crédit gagné serait aussitôt perdu.
  final VoidCallback? onGranted;

  const PaywallSheet({
    super.key,
    required this.ctrl,
    this.onGranted,
  });

  static Future<void> show(
    BuildContext context, {
    required MonetizationController ctrl,
    VoidCallback? onGranted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallSheet(ctrl: ctrl, onGranted: onGranted),
    );
  }

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  final _subs = SubscriptionService();
  bool _loadingAd = false;
  bool _buyingMonthly = false;
  bool _buyingYearly = false;

  @override
  void initState() {
    super.initState();
    // La feuille s'ouvre justement quand aucune pub n'était disponible :
    // sans cette relance, elle attendrait une pub que personne ne demande.
    if (!widget.ctrl.isAdReady) widget.ctrl.prepareAd();
  }

  @override
  Widget build(BuildContext context) {
    // Le contrôleur prévient dès qu'une pub arrive (ou échoue) : la feuille se
    // reconstruit alors seule. Sans cela, elle restait figée sur
    // « chargement » jusqu'à sa fermeture, même une pub prête.
    return ListenableBuilder(
      listenable: widget.ctrl,
      builder: (context, _) => _buildSheet(context),
    );
  }

  Widget _buildSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.appColors.border,
              borderRadius: BorderRadius.circular(AppRadius.xxs),
            ),
          ),
          const SizedBox(height: 24),

          // Titre
          const Icon(Icons.videogame_asset_rounded,
              size: 48, color: AppColors.primary)
              .animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).keepPlayingTitle,
            style: context.type.headlineLarge.copyWith(color: context.appColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)
                .paywallBodyCredits(widget.ctrl.creditsPerAd),
            textAlign: TextAlign.center,
            style: context.type.bodyLarge.copyWith(color: context.appColors.textSecondary, height: 1.5),
          ),
          if (widget.ctrl.credits > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(
                AppLocalizations.of(context)
                    .creditsRemaining(widget.ctrl.credits),
                style: context.type.labelMedium.copyWith(color: AppColors.success),
              ),
            ),
          ],
          const SizedBox(height: 28),

          // ── Bouton Pub ──────────────────────────────────────────────────
          if (widget.ctrl.isAdReady)
            _AdButton(
              loading: _loadingAd,
              label: AppLocalizations.of(context)
                  .watchAdForCredits(widget.ctrl.creditsPerAd),
              onTap: _watchAd,
            )
          else if (widget.ctrl.isAdLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.appColors.cardBgLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_empty_rounded,
                      color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).adLoading,
                      style: context.type.bodyMedium.copyWith(color: context.appColors.textMuted),
                    ),
                  ),
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                ],
              ),
            )
          else
            // Chargement terminé sans publicité (hors ligne, inventaire vide) :
            // proposer une relance explicite plutôt qu'un spinner éternel.
            _RetryAdButton(onTap: () => widget.ctrl.prepareAd()),

          const SizedBox(height: 16),

          // ── Séparateur ──────────────────────────────────────────────────
          Row(children: [
            Expanded(child: Divider(color: context.appColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(AppLocalizations.of(context).orSeparator,
                  style: context.type.labelMedium.copyWith(color: context.appColors.textMuted)),
            ),
            Expanded(child: Divider(color: context.appColors.border)),
          ]),

          const SizedBox(height: 16),

          // ── Abonnement Premium ───────────────────────────────────────────
          _PremiumBanner(),
          const SizedBox(height: 12),

          if (_subs.yearlyProduct != null)
            _SubscribeButton(
              product: _subs.yearlyProduct!,
              label: AppLocalizations.of(context).yearly,
              badge: '-50%',
              badgeColor: AppColors.error,
              loading: _buyingYearly,
              onTap: () => _buy(_subs.yearlyProduct!, yearly: true),
            ),
          if (_subs.yearlyProduct != null) const SizedBox(height: 8),
          if (_subs.monthlyProduct != null)
            _SubscribeButton(
              product: _subs.monthlyProduct!,
              label: AppLocalizations.of(context).monthly,
              loading: _buyingMonthly,
              onTap: () => _buy(_subs.monthlyProduct!, yearly: false),
            ),

          if (_subs.products.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).premiumBanner,
                    style: context.type.bodyMedium.copyWith(color: context.appColors.textPrimary),
                  ),
                ),
              ]),
            ),

          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              await _subs.restorePurchases();
              if (!mounted) return;
              if (_subs.isPremium) nav.pop();
            },
            child: Text(AppLocalizations.of(context).restorePurchases,
                style: context.type.labelMedium.copyWith(color: context.appColors.textMuted)),
          ),
        ],
      ),
    );
  }

  Future<void> _watchAd() async {
    setState(() => _loadingAd = true);
    final onGranted = widget.onGranted;

    if (onGranted == null) {
      await widget.ctrl.watchAdForCredits(
        onRewarded: () {
          if (mounted) Navigator.pop(context);
        },
        onFailed: () {
          if (mounted) setState(() => _loadingAd = false);
        },
      );
    } else {
      await widget.ctrl.requestPlay(
        onGranted: () {
          if (mounted) {
            Navigator.pop(context);
            onGranted();
          }
        },
        onNoAd: () {
          if (mounted) setState(() => _loadingAd = false);
        },
      );
    }
    if (mounted) setState(() => _loadingAd = false);
  }

  Future<void> _buy(ProductDetails product, {required bool yearly}) async {
    setState(() {
      if (yearly) {
        _buyingYearly = true;
      } else {
        _buyingMonthly = true;
      }
    });
    final ok = await _subs.buySubscription(product);
    if (mounted) {
      setState(() {
        _buyingYearly = false;
        _buyingMonthly = false;
      });
      if (ok && _subs.isPremium) {
        widget.ctrl.refresh();
        Navigator.pop(context);
        widget.onGranted?.call();
      }
    }
  }
}

// ── Widgets internes ────────────────────────────────────────────────────────

class _AdButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback onTap;

  const _AdButton(
      {required this.loading, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_outline_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.titleMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Sortie de secours : aucune publicité n'a pu être chargée et plus rien ne
/// tourne en tâche de fond. L'utilisateur garde la main.
class _RetryAdButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RetryAdButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.appColors.cardBgLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.appColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded,
                color: context.appColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                AppLocalizations.of(context).adUnavailableRetry,
                textAlign: TextAlign.center,
                style: context.type.labelLarge.copyWith(color: context.appColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.workspace_premium_rounded,
                color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Arif Quiz Premium',
              style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800),
            ),
          ]),
          const SizedBox(height: 8),
          // Ne lister que des avantages réellement livrés : un paywall qui
          // promet un classement ou des XP boostés inexistants est une
          // publicité mensongère (et un motif de rejet Play Store).
          ...[
            AppLocalizations.of(context).premiumFeatureNoAds,
            AppLocalizations.of(context).premiumFeatureAllModes,
            AppLocalizations.of(context).premiumFeatureSupport,
          ].map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                // Les libellés portaient leur puce en emoji ; la coche est
                // maintenant une icône, alignée sur la première ligne du texte.
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_rounded,
                          size: 14, color: AppColors.success),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(f,
                          style: context.type.labelMedium.copyWith(
                              color: context.appColors.textSecondary)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  final ProductDetails product;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final bool loading;
  final VoidCallback onTap;

  const _SubscribeButton({
    required this.product,
    required this.label,
    this.badge,
    this.badgeColor,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium $label',
                          style: context.type.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          product.price,
                          style: context.type.labelMedium.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.accent,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(badge!,
                          style: context.type.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
      ),
    );
  }
}
