import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/gym_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../dashboard/screens/root_shell.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;

  const OTPVerificationScreen({super.key, required this.verificationId});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    
    // Verify the SMS code with Firebase
    bool success = await context.read<GymProvider>().verifySmsCode(
      widget.verificationId,
      _otpController.text.trim(),
    );

    if (success && mounted) {
      final actualRole = context.read<GymProvider>().role;
      if (actualRole != null) {
        context.read<NavigationProvider>().setRole(actualRole);
      }
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RootShell()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP code. Please try again.")),
      );
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Two-Step Verification")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text("Enter the 6-digit code sent to your phone."),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "123456"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading ? const CircularProgressIndicator() : const Text("Verify & Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}