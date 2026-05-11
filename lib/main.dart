import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fithub_gym/core/theme/app_theme.dart';
import 'package:fithub_gym/core/providers/navigation_provider.dart';
import 'package:fithub_gym/core/providers/gym_provider.dart';
import 'package:fithub_gym/features/auth/screens/welcome_screen.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
