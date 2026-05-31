import 'package:arif_quiz/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:arif_quiz/features/friends/presentation/screens/friends_screen.dart';
import 'package:arif_quiz/features/home/presentation/screens/home_screen.dart';
import 'package:arif_quiz/features/profile/presentation/screens/profile_screen.dart';
import 'package:arif_quiz/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:arif_quiz/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _index;

  final _screens = const [
    HomeScreen(),
    QuizListScreen(),
    ChallengesScreen(),
    FriendsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.appColors.cardBg,
          border: Border(top: BorderSide(color: context.appColors.border, width: 1)),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            backgroundColor: context.appColors.cardBg,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: context.appColors.textMuted,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Quiz',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_esports_outlined),
                activeIcon: Icon(Icons.sports_esports_rounded),
                label: 'Défis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                activeIcon: Icon(Icons.group_rounded),
                label: 'Amis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
