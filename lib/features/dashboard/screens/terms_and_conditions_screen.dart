import 'package:flutter/material.dart';
import 'package:fithub_gym/features/dashboard/screens/light_footer.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkTheme ? const Color(0xFF111424) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
              ),
              child: Column(
                children: [
                  const Text(
                    'Terms & Conditions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.1 * 255).toInt()),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_outlined, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please read these terms carefully before using FitHub Gym Pro.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha((0.9 * 255).toInt()),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agreement to Terms',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTermCard(
                    context: context,
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'Acceptable Platform Utilization',
                    description: 'By creating an authorized account, platform users agree to interact with gym operations tools purely for legitimate scheduling, management tracking, and physical biometric input tasks. Any unauthorized manipulation of platform features will result in immediate suspension.',
                  ),
                  const SizedBox(height: 15),
                  
                  _buildTermCard(
                    context: context,
                    icon: Icons.security_outlined,
                    title: 'System Security Integrity Obligations',
                    description: 'Executing malicious runtime requests, tampering with authorization headers, or testing platform limitations with invalid credential injection parameters will result in sudden administrative profile terminations and potential legal actions.',
                  ),
                  const SizedBox(height: 15),

                  _buildTermCard(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Account Responsibilities',
                    description: 'Users are fully responsible for safeguarding their login credentials. Any activity conducted under a user\'s account is deemed authorized by the account holder. FitHub Gym assumes no liability for unauthorized access due to user negligence.',
                  ),
                  const SizedBox(height: 15),

                  _buildTermCard(
                    context: context,
                    icon: Icons.payment_outlined,
                    title: 'Payment and Billing Terms',
                    description: 'All subscription fees, one-time purchases, and automated recurring billing must be handled through our certified secure payment gateways. Failure to maintain a valid payment method will lead to restricted platform access within 7 days of a failed transaction.',
                  ),
                  const SizedBox(height: 15),

                  _buildTermCard(
                    context: context,
                    icon: Icons.block_outlined,
                    title: 'Termination of Service',
                    description: 'FitHub Gym reserves the right to modify, suspend, or terminate services at any time, with or without notice, if these terms are violated or if continued service poses a risk to other users or the platform infrastructure.',
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
            const LightFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTermCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDarkTheme ? Colors.white10 : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2962FF).withAlpha((0.1 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2962FF), size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
