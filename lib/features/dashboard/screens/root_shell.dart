import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fithub_gym/core/providers/navigation_provider.dart';
import 'package:fithub_gym/features/member/screens/member_dashboard.dart';
import 'package:fithub_gym/features/trainer/screens/trainer_dashboard.dart';
import 'package:fithub_gym/features/owner/screens/owner_dashboard.dart';
import 'package:fithub_gym/features/owner/screens/register_gym_screen.dart';
import 'package:fithub_gym/features/auth/screens/welcome_screen.dart';
import 'package:fithub_gym/features/assignments/screens/assignment_list_screen.dart';
import 'package:fithub_gym/features/member/screens/workout_list_screen.dart';
import 'package:fithub_gym/features/member/screens/diet_screen.dart';
import 'package:fithub_gym/features/member/screens/growth_history_screen.dart';
import 'package:fithub_gym/features/member/screens/notice_list_screen.dart';
import 'package:fithub_gym/features/owner/screens/member_management_screen.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    ),
  );
}

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final role = navProvider.currentRole;

    final navItems = _getNavItems(role);

    return Scaffold(
      appBar: AppBar(
        title: Text(navItems[navProvider.selectedIndex].label ?? ''),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              } else if (value == 'register' && role == UserRole.owner) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterGymScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              if (role == UserRole.owner)
                const PopupMenuItem(
                  value: 'register',
                  child: Text('Register Gym'),
                ),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text('Switch View (Dev)'),
              ),
              PopupMenuItem(
                onTap: () => navProvider.setRole(UserRole.member),
                child: const Text('  • Member View'),
              ),
              PopupMenuItem(
                onTap: () => navProvider.setRole(UserRole.trainer),
                child: const Text('  • Trainer View'),
              ),
              PopupMenuItem(
                onTap: () => navProvider.setRole(UserRole.owner),
                child: const Text('  • Owner View'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _getScreens(role),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.selectedIndex,
        onTap: (index) => navProvider.setIndex(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: navItems,
      ),
    );
  }

  List<Widget> _getScreens(UserRole role) {
    switch (role) {
      case UserRole.member:
        return [
          const MemberDashboard(),
          const MemberWorkoutListScreen(),
          const MemberDietScreen(),
          const GrowthHistoryScreen(),
          const MemberNoticeScreen(),
        ];
      case UserRole.trainer:
        return [
          const TrainerDashboard(),
          const PlaceholderScreen('My Clients'),
          const AssignmentListScreen(),
          const PlaceholderScreen('Schedules'),
        ];
      case UserRole.owner:
        return [
          const OwnerDashboard(),
          const MemberManagementScreen(),
          const PlaceholderScreen('Staff Management'),
          const PlaceholderScreen('Gym Revenue'),
          const PlaceholderScreen('Notices'),
        ];
    }
  }

  List<BottomNavigationBarItem> _getNavItems(UserRole role) {
    switch (role) {
      case UserRole.member:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.dumbbell),
            label: 'Workouts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Diet',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Growth',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.campaign_rounded),
            label: 'Notices',
          ),
        ];
      case UserRole.trainer:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Clients',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Assign',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Schedule',
          ),
        ];
      case UserRole.owner:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.badge_rounded), label: 'Members'),
          const BottomNavigationBarItem(icon: Icon(Icons.badge_rounded), label: 'Staff'),
          const BottomNavigationBarItem(icon: Icon(Icons.payments_rounded), label: 'Revenue'),
          const BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Notices'),
        ];
    }
  }
}
