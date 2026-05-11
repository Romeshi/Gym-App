import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fithub_gym/core/providers/navigation_provider.dart';
import 'package:fithub_gym/features/dashboard/screens/root_shell.dart';

class LoginScreen extends StatelessWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Login as ${_roleToString(role)}', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
            const SizedBox(height: 10),
            const Text('Enter your credentials to continue.'),
            const SizedBox(height: 40),
            const TextField(decoration: InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 20),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot Password?'))),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const RootShell()), (route) => false);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account?'),
                TextButton(onPressed: () {}, child: const Text('Sign Up')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.owner: return 'Owner';
      case UserRole.trainer: return 'Trainer';
      case UserRole.member: return 'Member';
    }
  }
}
