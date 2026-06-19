import 'package:flutter/material.dart';
import 'package:fithub_gym/features/dashboard/screens/info_detail_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/about_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/contact_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/privacy_policy_screen.dart';
// ---------------------------------------------------------------------------
// Light-themed footer — matches the app's light scaffold background
// ---------------------------------------------------------------------------
class LightFooter extends StatelessWidget {
  const LightFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withAlpha((0.45 * 255).toInt())),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        children: [
          // Nav links row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(
                label: 'About Us',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              const _FooterDivider(),
              _FooterLink(
                label: 'Contact',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactScreen(),
                    ),
                  );
                },
              ),
              const _FooterDivider(),
              _FooterLink(
                label: 'Privacy Policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Divider
          Divider(color: Colors.grey.withAlpha((0.15 * 255).toInt()), height: 1),

          const SizedBox(height: 12),

          // Copyright
          Text(
            '© 2026 FitHub Gym. All rights reserved.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _openInfo(
    BuildContext context, {
    required String title,
    required List<InfoSection> sections,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoDetailScreen(title: title, sections: sections),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2D62ED),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FooterDivider extends StatelessWidget {
  const _FooterDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        '·',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
    );
  }
}
