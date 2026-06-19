import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/gym_provider.dart';
import 'dart:math';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedRole;
  DateTime? _birthday;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Future<void> _sendWhatsAppMessage(String phone, String name, String gymId, String gymName, String password, String staffId) async {
    String formattedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    String message = '''Hi $name,

Welcome to $gymName.
Your have been added as a new staff to our gym.Thank you for choosing us for your fitness journey!
Here are your Gym Staff login details:

Gym ID: $gymId
Password: $password
Staff ID: $staffId

Download the FitHub App:
Android - https://fithubgymapp.com

Open the FitHub app and choose "I am a Trainer / Staff".

We are here to support you in your fitness journey. Stay consistent, stay dedicated, and you'll achieve your goals! 💪

Best regards,
$gymName Team''';

    String encodedMessage = Uri.encodeComponent(message);
    Uri whatsappUri = Uri.parse("whatsapp://send?phone=$formattedPhone&text=$encodedMessage");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        Uri webUri = Uri.parse("https://wa.me/$formattedPhone?text=$encodedMessage");
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch WhatsApp')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("WhatsApp Launch Error: $e");
    }
  }

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthday == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all role and date fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final gymProvider = context.read<GymProvider>();
      final gymId = gymProvider.currentGymId;
      final gymName = gymProvider.currentGymName ?? 'FitHub Gym';
      
      if (gymId == null) throw Exception("Gym ID not found.");

      String password = _generateRandomPassword();
      String email = _emailController.text.trim();

      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp_Staff_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      UserCredential credential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);
      
      String newUid = credential.user!.uid;
      await secondaryApp.delete();

      await FirebaseFirestore.instance.collection('users').doc(newUid).set({
        'uid': newUid,
        'role': _selectedRole!.toLowerCase(), // trainer, manager, receptionist
        'name': _nameController.text.trim(),
        'email': email,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'birthday': _birthday,
        'gymId': gymId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('gyms').doc(FirebaseAuth.instance.currentUser!.uid).collection('staff').doc(newUid).set({
        'uid': newUid,
        'name': _nameController.text.trim(),
        'role': _selectedRole,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff registered successfully!'), backgroundColor: Colors.green),
      );

      await _sendWhatsAppMessage(
        _phoneController.text.trim(),
        _nameController.text.trim(),
        gymId,
        gymName,
        password,
        newUid.substring(0, 8).toUpperCase(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Staff'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Staff Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email required' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number (incl. country code)', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Home Address', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Staff Role', border: OutlineInputBorder()),
                    value: _selectedRole,
                    items: ['Trainer', 'Receptionist', 'Manager'].map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedRole = val),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () => _selectBirthday(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Birthday', border: OutlineInputBorder()),
                      child: Text(_birthday == null ? 'Select Date' : "${_birthday!.toLocal()}".split(' ')[0]),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _saveStaff,
                    child: const Text('Save Staff & Send Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
