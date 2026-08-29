import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// ─── Briques communes des cartes d'administration ────────────────────────────
///
/// Une seule grammaire pour toutes les listes admin (catégories, quiz,
/// questions, paliers, signalements) :
///   • le corps de la carte est cliquable → action principale (éditer/ouvrir) ;
///   • toutes les actions sont accessibles depuis le menu « ⋮ » de l'en-tête ;
///   • les actions fréquentes s'affichent en plus sous forme de puces dans un
///     [Wrap] : elles passent à la ligne au lieu de déborder de l'écran, quelle
///     que soit la largeur du device ou la longueur du libellé traduit.

/// Une action de carte, déclarée une fois et rendue indifféremment en entrée de
/// menu ou en puce. `onPressed` à `null` = action indisponible (grisée).
@immutable
class AdminAction {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onPressed;
  final bool destructive;

  const AdminAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.destructive = false,
  });

  Color resolveColor(BuildContext context) => destructive
      ? AppColors.error
      : (color ?? context.appColors.textSecondary);
}

/// Coque de carte : surface surélevée, ombre douce, corps cliquable.
class AdminCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// Atténue la carte (ex. palier non jouable) sans toucher à ses couleurs.
  final double opacity;

  const AdminCard({
    super.key,
    required this.child,
    this.onTap,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: context.cardElevated,
        borderRadius: AppRadius.rLg,
        boxShadow: AppShadows.card(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.rLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
    return opacity == 1 ? card : Opacity(opacity: opacity, child: card);
  }
}

/// En-tête normalisé : vignette, titre + sous-titre extensibles, badges et menu.
///
/// Le bloc texte est le seul élément extensible : badges et menu gardent leur
/// largeur naturelle, le titre s'ellipse. Rien ne peut donc sortir de la carte.
class AdminCardHeader extends StatelessWidget {
  final Widget? leading;
  final String title;
  final int titleMaxLines;
  final Widget? subtitle;
  final List<Widget> badges;

  /// Contrôle compact placé juste avant le menu (ex. flèches de réordonnancement).
  final Widget? trailing;
  final List<AdminAction> menuActions;

  const AdminCardHeader({
    super.key,
    this.leading,
    required this.title,
    this.titleMaxLines = 2,
    this.subtitle,
    this.badges = const [],
    this.trailing,
    this.menuActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Les badges sont inflexibles mais plafonnés : ils prennent leur largeur
      // naturelle sans jamais manger plus de 40 % de l'en-tête, et tout le
      // reste revient au titre (un `Flexible` partagerait l'espace 50/50 et
      // écraserait le titre même face à un badge minuscule).
      final maxBadgesWidth = constraints.maxWidth * 0.40;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Padding(
              // Aligne le texte sur l'axe optique du menu (icône 20 dans 40).
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.titleMedium.copyWith(color: context.appColors.textPrimary, fontWeight: FontWeight.w800, height: 1.25),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    DefaultTextStyle.merge(
                      style: context.type.labelMedium.copyWith(color: context.appColors.textSecondary),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBadgesWidth),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: badges,
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            trailing!,
          ],
          if (menuActions.isNotEmpty) AdminMenuButton(actions: menuActions),
        ],
      );
    });
  }
}

/// Menu « ⋮ » : point d'entrée unique et exhaustif vers les actions d'une carte.
class AdminMenuButton extends StatelessWidget {
  final List<AdminAction> actions;

  const AdminMenuButton({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: PopupMenuButton<int>(
        tooltip: AppLocalizations.of(context).moreActions,
        color: context.appColors.cardBg,
        elevation: 8,
        padding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        icon: Icon(Icons.more_vert_rounded,
            size: 20, color: context.appColors.textSecondary),
        onSelected: (i) => actions[i].onPressed?.call(),
        itemBuilder: (_) => [
          for (var i = 0; i < actions.length; i++)
            PopupMenuItem<int>(
              value: i,
              enabled: actions[i].onPressed != null,
              height: 44,
              child: _MenuRow(action: actions[i]),
            ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final AdminAction action;
  const _MenuRow({required this.action});

  @override
  Widget build(BuildContext context) {
    final enabled = action.onPressed != null;
    final color = enabled
        ? action.resolveColor(context)
        : context.appColors.textMuted.withValues(alpha: 0.5);
    return Row(
      children: [
        Icon(action.icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            action.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.labelLarge.copyWith(color: enabled ? context.appColors.textPrimary : color),
          ),
        ),
      ],
    );
  }
}

/// Barre d'actions rapides : puces tactiles qui passent à la ligne (jamais de
/// débordement horizontal, y compris en arabe ou sur petit écran).
class AdminActionBar extends StatelessWidget {
  final List<AdminAction> actions;

  const AdminActionBar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final a in actions) AdminActionChip(action: a),
      ],
    );
  }
}

/// Puce d'action : fond teinté à 10 %, icône + libellé ellipsable.
class AdminActionChip extends StatelessWidget {
  final AdminAction action;

  const AdminActionChip({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final enabled = action.onPressed != null;
    final color = enabled
        ? action.resolveColor(context)
        : context.appColors.textMuted.withValues(alpha: 0.6);
    return Material(
      color: color.withValues(alpha: enabled ? 0.10 : 0.05),
      borderRadius: AppRadius.rMd,
      child: InkWell(
        onTap: action.onPressed,
        borderRadius: AppRadius.rMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.labelMedium.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Étiquette d'information (catégorie, difficulté, compteurs, statut…).
class AdminTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool strong;
  final VoidCallback? onTap;

  const AdminTag({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.strong = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: EdgeInsets.symmetric(horizontal: strong ? 9 : 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.labelSmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
    return Material(
      color: color.withValues(alpha: strong ? 0.14 : 0.10),
      borderRadius: AppRadius.rSm,
      child: onTap == null
          ? body
          : InkWell(
              onTap: onTap,
              borderRadius: AppRadius.rSm,
              child: body,
            ),
    );
  }
}

/// Vignette carrée d'en-tête (emoji de catégorie, icône de type, position…).
class AdminLeadingBox extends StatelessWidget {
  final Color color;
  final Widget child;
  final double size;
  final bool filled;

  const AdminLeadingBox({
    super.key,
    required this.color,
    required this.child,
    this.size = 44,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.14),
          borderRadius: AppRadius.rMd,
        ),
        child: child,
      );
}
