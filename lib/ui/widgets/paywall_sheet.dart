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
  final VoidCallback onGranted;

  const PaywallSheet({
    super.key,
    required this.ctrl,
    required this.onGranted,
  });

  static Future<void> show(
    BuildContext context, {
    required MonetizationController ctrl,
    required VoidCallback onGranted,
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
  Widget build(BuildContext context) {
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
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Titre
          const Text('🎮', style: TextStyle(fontSize: 48))
              .animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Text(
            'Continuez à jouer',
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Regardez une courte publicité ou passez Premium\npour jouer sans interruption.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // ── Bouton Pub ──────────────────────────────────────────────────
          if (widget.ctrl.isAdReady)
            _AdButton(
              loading: _loadingAd,
              onTap: _watchAd,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.appColors.cardBgLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_empty_rounded,
                      color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Publicité en cours de chargement…',
                      style: TextStyle(
                          color: context.appColors.textMuted, fontSize: 13),
                    ),
                  ),
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // ── Séparateur ──────────────────────────────────────────────────
          Row(children: [
            Expanded(child: Divider(color: context.appColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('OU', style: TextStyle(
                color: context.appColors.textMuted, fontSize: 12)),
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
              label: 'Annuel',
              badge: '🔥 -50%',
              badgeColor: AppColors.error,
              loading: _buyingYearly,
              onTap: () => _buy(_subs.yearlyProduct!, yearly: true),
            ),
          if (_subs.yearlyProduct != null) const SizedBox(height: 8),
          if (_subs.monthlyProduct != null)
            _SubscribeButton(
              product: _subs.monthlyProduct!,
              label: 'Mensuel',
              loading: _buyingMonthly,
              onTap: () => _buy(_subs.monthlyProduct!, yearly: false),
            ),

          if (_subs.products.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Arif Quiz Premium\nSans publicité · Toutes fonctionnalités',
                    style: TextStyle(
                        color: context.appColors.textPrimary, fontSize: 13),
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
            child: Text('Restaurer les achats',
                style: TextStyle(
                    color: context.appColors.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _watchAd() async {
    setState(() => _loadingAd = true);
    await widget.ctrl.requestPlay(
      onGranted: () {
        if (mounted) {
          Navigator.pop(context);
          widget.onGranted();
        }
      },
      onNoAd: () {
        if (mounted) setState(() => _loadingAd = false);
      },
    );
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
        widget.onGranted();
      }
    }
  }
}

// ── Widgets internes ────────────────────────────────────────────────────────

class _AdButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _AdButton({required this.loading, required this.onTap});

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
          borderRadius: BorderRadius.circular(16),
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline_rounded,
                      color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Regarder une publicité (≈30s)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(14),
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
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          ...[
            '✅ Quiz illimités sans pub',
            '⚡ Accès à tous les modes de jeu',
            '🏆 Classement premium exclusif',
            '🔥 Streaks et XP boostés',
          ].map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(f,
                    style: TextStyle(
                        color: context.appColors.textSecondary, fontSize: 12)),
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
          borderRadius: BorderRadius.circular(14),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          product.price,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(badge!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
      ),
    );
  }
}
