import 'package:arif_quiz/features/auth/presentation/screens/guest_screen.dart';
import 'package:arif_quiz/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:arif_quiz/features/friends/presentation/screens/friends_screen.dart';
import 'package:arif_quiz/features/home/presentation/screens/home_screen.dart';
import 'package:arif_quiz/features/profile/presentation/screens/profile_screen.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:arif_quiz/l10n/gen/app_localizations.dart';
import 'package:arif_quiz/main.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:arif_quiz/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _index;

  static const _allScreens = [
    HomeScreen(),
    QuizListScreen(),
    ChallengesScreen(),
    FriendsScreen(),
    ProfileScreen(),
  ];

  static const _guestScreens = [
    HomeScreen(),
    QuizListScreen(),
    GuestScreen(),
    GuestScreen(),
    GuestScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isGuest,
      builder: (context, guest, _) {
        final screens = guest ? _guestScreens : _allScreens;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: context.appColors.cardBg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text(
                  AppLocalizations.of(context).exitAppTitle,
                  style: TextStyle(
                      color: context.appColors.textPrimary,
                      fontWeight: FontWeight.w700),
                ),
                content: Text(
                  AppLocalizations.of(context).exitAppBody,
                  style: TextStyle(color: context.appColors.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(AppLocalizations.of(context).cancel,
                        style: TextStyle(color: context.appColors.textMuted)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(AppLocalizations.of(context).quit,
                        style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
            if (shouldExit == true) SystemNavigator.pop();
          },
          child: Scaffold(
          body: IndexedStack(index: _index, children: screens),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: context.cardElevated,
              boxShadow: AppShadows.bottomBar(context),
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                backgroundColor: Colors.transparent,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: context.appColors.textMuted,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedFontSize: 10,
                unselectedFontSize: 10,
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: const Icon(Icons.home_rounded),
                    label: AppLocalizations.of(context).homeLabel,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.grid_view_outlined),
                    activeIcon: const Icon(Icons.grid_view_rounded),
                    label: 'Quiz',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.sports_esports_outlined),
                    activeIcon: const Icon(Icons.sports_esports_rounded),
                    label: AppLocalizations.of(context).challengesTitle,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.group_outlined),
                    activeIcon: const Icon(Icons.group_rounded),
                    label: AppLocalizations.of(context).friends,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline_rounded),
                    activeIcon: const Icon(Icons.person_rounded),
                    label: AppLocalizations.of(context).profileTab,
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}


