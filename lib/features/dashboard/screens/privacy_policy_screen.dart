import 'package:flutter/material.dart';
import 'package:fithub_gym/features/dashboard/screens/light_footer.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                    'Privacy Policy',
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
                    child: const Icon(Icons.privacy_tip_outlined, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your privacy and data security are our top priorities.',
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
                    'Data Protection & Security',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicyCard(
                    context: context,
                    icon: Icons.lock_outline,
                    title: 'Data Collection & Encryption',
                    description: 'FitHub Gym strictly protects user credentials, transactional metrics profiles, and health records telemetry. All data vectors undergo strict encryption layers before database parsing executions.',
                  ),
                  const SizedBox(height: 15),
                  
                  _buildPolicyCard(
                    context: context,
                    icon: Icons.gavel,
                    title: 'Regulatory Security Rules',
                    description: 'The database system adheres to zero-trust structural architecture. Fine-grained security permission vectors ensure data documents remain completely isolated.',
                  ),
                  const SizedBox(height: 15),

                  _buildPolicyCard(
                    context: context,
                    icon: Icons.visibility_off_outlined,
                    title: 'Third-Party Data Sharing',
                    description: 'We do not sell, trade, or otherwise transfer your personally identifiable information to outside parties without your explicit consent, except to provide requested services.',
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

  Widget _buildPolicyCard({
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
              color: const Color(0xFF10B981).withAlpha((0.1 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 28),
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
