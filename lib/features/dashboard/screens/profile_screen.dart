import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fithub_gym/core/providers/gym_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gymProvider = context.watch<GymProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 30, bottom: 40),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withAlpha(50),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    gymProvider.ownerName ?? 'Gym Owner',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    gymProvider.ownerEmail ?? 'No email provided',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Profile Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildProfileItem(
                    icon: Icons.person_outline,
                    title: 'Full Name',
                    value: gymProvider.ownerName ?? 'Not set',
                  ),
                  _buildProfileItem(
                    icon: Icons.email_outlined,
                    title: 'Email Address',
                    value: gymProvider.ownerEmail ?? 'Not set',
                  ),
                  _buildProfileItem(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    value: gymProvider.phoneNumber ?? 'Not set',
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Gym Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildProfileItem(
                    icon: Icons.fitness_center,
                    title: 'Gym Name',
                    value: gymProvider.currentGymName ?? 'Not set',
                  ),
                  _buildProfileItem(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    value: gymProvider.currentLocation ?? 'Not set',
                  ),
                  _buildProfileItem(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Gym ID',
                    value: gymProvider.currentGymId ?? 'Not set',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha((0.1 * 255).toInt())),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withAlpha((0.1 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1A237E), size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
