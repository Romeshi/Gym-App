import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fithub_gym/core/theme/app_theme.dart';
import 'package:fithub_gym/core/providers/navigation_provider.dart';
import 'package:fithub_gym/core/providers/gym_provider.dart';
import 'package:fithub_gym/features/auth/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // The file the CLI just made

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        // Manages user roles and bottom navigation
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // Manages gym registration and specific gym data
        ChangeNotifierProvider(create: (_) => GymProvider()),
      ],
      child: const FitHubApp(),
    ),
  );
}

class FitHubApp extends StatelessWidget {
  const FitHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitHub Gym',
      debugShowCheckedModeBanner: false,
      // Uses the professional theme Romeshi set up
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
