import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fithub_gym/core/providers/navigation_provider.dart';
import 'package:fithub_gym/core/providers/gym_provider.dart';
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
import 'package:fithub_gym/features/owner/screens/staff_management_screen.dart';
import 'package:fithub_gym/features/owner/screens/plan_management_screen.dart';
import 'package:fithub_gym/features/owner/screens/post_notice_screen.dart';
import 'package:fithub_gym/features/owner/screens/owner_notice_list_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/info_detail_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/about_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/contact_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/privacy_policy_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/terms_and_conditions_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/profile_screen.dart';
import 'package:fithub_gym/features/owner/screens/revenue_screen.dart';
import 'package:fithub_gym/features/trainer/screens/trainer_client_list_screen.dart';

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
      // --- AppBar Configuration with explicit Hamburger Trigger ---
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () {
              Scaffold.of(
                context,
              ).openDrawer(); // Triggers drawer open explicitly
            },
          ),
        ),
        title: Text(navItems[navProvider.selectedIndex].label ?? ''),
        actions: [

          IconButton(
            icon: const Icon(Icons.campaign_rounded),
            onPressed: () {
              if (role == UserRole.owner) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OwnerNoticeListScreen()),
                );
              } else if (role == UserRole.member) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MemberNoticeScreen()),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await Provider.of<GymProvider>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      // --- Custom Mobile Side Drawer UI ---
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF111424),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF1A237E)),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha((0.15 * 255).toInt()),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              'FitHub',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Gym Management App',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade300,
                            letterSpacing: 2.4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Home Route Dashboard Link
                    _buildDrawerItem(Icons.home_outlined, 'Home', () {
                      Navigator.pop(context); // Close drawer
                      navProvider.setIndex(
                        0,
                      ); // Snap index back to home dashboard view
                    }),

                    const SizedBox(height: 10),

                    // About FitHub Section Link
                    _buildDrawerItem(Icons.info_outline, 'About Us', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    // Contact Support Section Link
                    _buildDrawerItem(Icons.phone_outlined, 'Contact Us', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactScreen(),
                        ),
                      );
                    }),

                    const Divider(color: Colors.white10, height: 40),

                    // Privacy Policy Section Link
                    _buildDrawerItem(Icons.shield_outlined, 'Privacy Policy', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    // Terms & Conditions Section Link
                    _buildDrawerItem(
                      Icons.gavel_outlined,
                      'Terms & Conditions',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsAndConditionsScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // FAQ Section Link
                    _buildDrawerItem(Icons.help_outline_rounded, 'FAQ', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoDetailScreen(
                            title: 'Frequently Asked Questions',
                            sections: [
                              InfoSection(
                                icon: Icons.switch_account_outlined,
                                heading:
                                    'How do I alternate system views during assessment testing?',
                                body:
                                    'Utilize the custom Dev Option pop menu accessible via the top-right vertical settings dots item inside the primary app bar shell container.',
                              ),
                              InfoSection(
                                icon: Icons.sms_failed_outlined,
                                heading:
                                    'Why is SMS verification blocked for active phone numbers?',
                                body:
                                    'The live international SMS delivery engine enforces strict anti-spam billing requirements. To optimize resource allocation for project evaluation pipelines, the app enforces whitelisted secure testing shortcuts.',
                              ),
                              InfoSection(
                                icon: Icons.refresh,
                                heading:
                                    'How often do dashboard caching pipelines refresh data metrics?',
                                body:
                                    'FitHub Gym Pro utilizes active streaming listeners connected directly to your Cloud Firestore cluster instances, triggering precise view repopulations instantly when state data mutates.',
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const Divider(color: Colors.white10, height: 40),

                    // Profile Section Link
                    _buildDrawerItem(Icons.person_outline, 'My Account', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    // Logout Section Link
                    _buildDrawerItem(Icons.logout_rounded, 'Logout', () async {
                      Navigator.pop(context); // Close drawer
                      
                      // Perform logout logic through GymProvider
                      await Provider.of<GymProvider>(context, listen: false).signOut();
                      
                      // Navigate back to the Welcome Screen, clearing the route stack
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  // Helper function to render drawer items cleanly
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      dense: true,
      onTap: onTap,
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
          const TrainerClientListScreen(),
          const AssignmentListScreen(),
          const PlaceholderScreen('Schedules'),
        ];
      case UserRole.owner:
        return [
          const OwnerDashboard(),
          const MemberManagementScreen(),
          const StaffManagementScreen(),
          const RevenueScreen(),
          const PlanManagementScreen(),
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.insights_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.badge_rounded),
            label: 'Members',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.badge_rounded),
            label: 'Staff',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payments_rounded),
            label: 'Revenue',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.card_membership_rounded),
            label: 'Plans',
          ),
        ];
    }
  }
}
