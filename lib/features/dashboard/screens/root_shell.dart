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
import 'package:fithub_gym/features/dashboard/screens/info_detail_screen.dart';

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

      // --- Custom Mobile Side Drawer UI ---
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF111424),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF1A237E)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FH',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FITHUB GYM PRO',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade300,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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

                    // About FitHub Section Link
                    _buildDrawerItem(Icons.info_outline, 'About FitHub', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoDetailScreen(
                            title: 'About FitHub',
                            sections: [
                              InfoSection(
                                icon: Icons.fitness_center,
                                heading: 'Our Vision',
                                body:
                                    'FitHub Gym Pro is engineered to bridge the operational gap between gym administrations, fitness personal trainers, and active gym members, providing a cohesive ecosystem for biometric tracking and workflow automations.',
                              ),
                              InfoSection(
                                icon: Icons.analytics_outlined,
                                heading: 'Key Modules',
                                body:
                                    'The architecture targets distinct user experiences, supporting precise business accounting reporting models for Owners, streamlined scheduling configurations for Trainers, and workout telemetry tools for Members.',
                              ),
                              InfoSection(
                                icon: Icons.security,
                                heading: 'Platform Integrity',
                                body:
                                    'Leveraging secure distributed database logic, the platform ensures highly safe transaction processing, persistent identity parsing, and continuous availability across all systems nodes.',
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Contact Support Section Link
                    _buildDrawerItem(Icons.phone_outlined, 'Contact Support', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoDetailScreen(
                            title: 'Contact Support',
                            sections: [
                              InfoSection(
                                icon: Icons.email_outlined,
                                heading: 'FitHub Help Desk',
                                body:
                                    'Need help? You can reach the FitHub development support network via email at support@fithubgym.com or speak to system administrators for institution access.',
                              ),
                              InfoSection(
                                icon: Icons.admin_panel_settings_outlined,
                                heading: 'System Administrator Access',
                                body:
                                    'For institutional permissions requests or database profile verification tracking updates, please contact your university system coordinator directly.',
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const Divider(color: Colors.white10, height: 20),

                    // Privacy Policy Section Link
                    _buildDrawerItem(Icons.shield_outlined, 'Privacy Policy', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoDetailScreen(
                            title: 'Privacy Policy',
                            sections: [
                              InfoSection(
                                icon: Icons.lock_outline,
                                heading: 'Data Collection & Encryption',
                                body:
                                    'FitHub Gym Pro strictly protects user credentials, transactional metrics profiles, and health records telemetry. All data vectors undergo strict encryption layers before database parsing executions.',
                              ),
                              InfoSection(
                                icon: Icons.gavel,
                                heading: 'Regulatory Security Rules',
                                body:
                                    'The database system adheres to zero-trust structural architecture. Fine-grained security permission vectors ensure data documents remain completely isolated, blockading external unauthorized entry vectors.',
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Terms & Conditions Section Link
                    _buildDrawerItem(
                      Icons.gavel_outlined,
                      'Terms & Conditions',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InfoDetailScreen(
                              title: 'Terms & Conditions',
                              sections: [
                                InfoSection(
                                  icon: Icons.assignment_turned_in_outlined,
                                  heading: 'Acceptable Platform Utilization',
                                  body:
                                      'By creating an authorized account, platform users agree to interact with gym operations tools purely for legitimate scheduling, management tracking, and physical biometric input tasks.',
                                ),
                                InfoSection(
                                  icon: Icons.report_gmailerrorred_outlined,
                                  heading:
                                      'System Security Integrity Obligations',
                                  body:
                                      'Executing malicious runtime requests, tampering with authorization headers, or testing platform limitations with invalid credential injection parameters will result in sudden administrative profile terminations.',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

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
            icon: Icon(Icons.campaign_rounded),
            label: 'Notices',
          ),
        ];
    }
  }
}
