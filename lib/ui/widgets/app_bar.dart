import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuizAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Color? backgroundColor;
  final double elevation;
  final Widget? bottom;
  final double bottomHeight;

  const QuizAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = false,
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
    this.bottomHeight = 0,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + bottomHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? context.appColors.bg,
      elevation: elevation,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBack
          ? GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.appColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: context.appColors.textPrimary),
              ),
            )
          : leading,
      title: Text(
        title,
        style: TextStyle(
          color: context.appColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          fontFamily: 'Nunito',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: actions,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight),
              child: bottom!,
            )
          : null,
    );
  }
}

// Sliver version for scrolling screens
class SliverQuizAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool pinned;
  final double expandedHeight;
  final Widget? flexibleContent;

  const SliverQuizAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.pinned = true,
    this.expandedHeight = 120,
    this.flexibleContent,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: context.appColors.bg,
      elevation: 0,
      pinned: pinned,
      expandedHeight: expandedHeight,
      automaticallyImplyLeading: false,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  color: context.appColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        background: flexibleContent,
      ),
    );
  }
}
