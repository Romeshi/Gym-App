import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fithub_gym/core/providers/gym_provider.dart';

class RegisterGymScreen extends StatefulWidget {
  const RegisterGymScreen({super.key});

  @override
  State<RegisterGymScreen> createState() => _RegisterGymScreenState();
}

class _RegisterGymScreenState extends State<RegisterGymScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Your Gym')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create your professional gym ecosystem in seconds.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Gym Name', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location / City', border: OutlineInputBorder())),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  context.read<GymProvider>().setGym('GYM-99', _nameController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_nameController.text} Registered Successfully!')));
                }
              },
              child: const Text('Complete Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
