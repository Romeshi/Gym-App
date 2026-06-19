import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:fithub_gym/core/providers/navigation_provider.dart';
import 'package:fithub_gym/features/auth/screens/login_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/info_detail_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/light_footer.dart';
import 'package:fithub_gym/features/dashboard/screens/about_screen.dart';
import 'package:fithub_gym/features/dashboard/screens/terms_and_conditions_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Existing Layout (untouched) inside Expanded ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.fitness_center_rounded, size: 80, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 30),
                    Text('Welcome to FitHub', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
                    const SizedBox(height: 20),
                    const Text('Your complete gym management ecosystem.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const Spacer(),
                    Text('I am a...', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    _buildRoleButton(context, 'Gym Member', UserRole.member, Icons.person),
                    const SizedBox(height: 20),
                    _buildRoleButton(context, 'Trainer / Staff', UserRole.trainer, Icons.badge),
                    const SizedBox(height: 20),
                    _buildRoleButton(context, 'Gym Owner', UserRole.owner, Icons.business),
                    const Spacer(),
                  ],
                ),
              ),
            ),


            // --- Light-Themed Footer ---
            const LightFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String label, UserRole role, IconData icon) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey.withAlpha((0.2 * 255).toInt())),
        elevation: 0,
      ),
      onPressed: () {
        context.read<NavigationProvider>().setRole(role);
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(role: role)));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
