import 'package:flutter/material.dart';
import 'package:fithub_gym/features/dashboard/screens/light_footer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                    'Revolutionizing Gym Management',
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
                    child: const Icon(Icons.fitness_center_rounded, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bridging the operational gap between gym administrations, trainers, and members.',
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
                  // Mission Section
                  const Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We aim to provide a cohesive ecosystem for biometric tracking and workflow automations, ensuring seamless gym management and enhanced fitness journeys for everyone involved.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDarkTheme ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Key Features Grid
                  const Text(
                    'Key Modules',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.business,
                    title: 'Owner Dashboard',
                    description: 'Precise business accounting and reporting models for gym owners.',
                    color: const Color(0xFF2962FF),
                  ),
                  const SizedBox(height: 15),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.sports_gymnastics,
                    title: 'Trainer Tools',
                    description: 'Streamlined scheduling configurations and client management for trainers.',
                    color: const Color(0xFFF97316),
                  ),
                  const SizedBox(height: 15),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Member Experience',
                    description: 'Workout telemetry, diet tracking, and progress monitoring for members.',
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 30),

                  // Security Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkTheme ? const Color(0xFF161B22) : const Color(0xFF1A237E).withAlpha((0.05 * 255).toInt()),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDarkTheme ? Colors.white10 : const Color(0xFF1A237E).withAlpha((0.1 * 255).toInt())),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.security, color: Color(0xFF2962FF), size: 30),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Platform Integrity',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDarkTheme ? Colors.white : const Color(0xFF1A237E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Leveraging secure distributed database logic, the platform ensures highly safe transaction processing, persistent identity parsing, and continuous availability across all systems nodes.',
                                style: TextStyle(
                                  height: 1.5,
                                  color: isDarkTheme ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade700,
                    height: 1.4,
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
