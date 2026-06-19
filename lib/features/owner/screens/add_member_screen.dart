import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/gym_provider.dart';
import 'dart:math';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedPlan;
  DateTime? _startDate;
  DateTime? _birthday;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<void> _selectDate(BuildContext context, bool isBirthday) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isBirthday) {
          _birthday = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _sendWhatsAppMessage(String phone, String name, String gymId, String password, String memberId) async {
    // Format phone number (remove +, spaces, etc for URL)
    String formattedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Get gym name from provider
    final String gymName = Provider.of<GymProvider>(context, listen: false).currentGymName ?? 'FitHub Gym';
    
    String message = '''Hi $name,

Welcome to $gymName.
Your have been added as a new member to our gym.Thank you for choosing us for your fitness journey!
Here are your Gym login details:

Gym ID: $gymId
Password: $password
Member ID: $memberId

Download the FitHub App:
Android - https://fithubgymapp.com

Open the FitHub app and choose "I am a Gym Member".

We are here to support you in your fitness journey. Stay consistent, stay dedicated, and you'll achieve your goals! 💪

Best regards,
$gymName Team''';

    // Encode message for URL
    String encodedMessage = Uri.encodeComponent(message);
    
    // WhatsApp URI
    Uri whatsappUri = Uri.parse("whatsapp://send?phone=$formattedPhone&text=$encodedMessage");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web WhatsApp if app is not installed
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

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _birthday == null || _selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all date and plan fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final gymProvider = context.read<GymProvider>();
      final gymId = gymProvider.currentGymId;
      
      if (gymId == null) throw Exception("Gym ID not found. Please log in again.");

      String password = _generateRandomPassword();
      String email = _emailController.text.trim();

      // Create secondary app to avoid logging out the current owner
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      UserCredential credential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);
      
      String newUid = credential.user!.uid;
      
      // Clean up secondary app
      await secondaryApp.delete();

      // Save to Firestore 'users' collection (global member profile)
      await FirebaseFirestore.instance.collection('users').doc(newUid).set({
        'uid': newUid,
        'role': 'member',
        'name': _nameController.text.trim(),
        'email': email,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'birthday': _birthday,
        'age': int.tryParse(_ageController.text) ?? 0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'gymId': gymId, // Link to current gym
        'activePlan': _selectedPlan,
        'startDate': _startDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final ownerUid = FirebaseAuth.instance.currentUser!.uid;

      // Also save a reference in the gym's members subcollection for easy querying
      await FirebaseFirestore.instance.collection('gyms').doc(ownerUid).collection('members').doc(newUid).set({
        'uid': newUid,
        'name': _nameController.text.trim(),
        'plan': _selectedPlan,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Get plan details (like price) for revenue tracking
      double planPrice = 0.0;
      final planQuery = await FirebaseFirestore.instance
          .collection('gyms')
          .doc(ownerUid)
          .collection('plans')
          .where('name', isEqualTo: _selectedPlan)
          .limit(1)
          .get();
      
      if (planQuery.docs.isNotEmpty) {
        final planData = planQuery.docs.first.data();
        planPrice = (planData['price'] ?? 0.0).toDouble();
      }

      // Save a payment transaction
      await FirebaseFirestore.instance
          .collection('gyms')
          .doc(ownerUid)
          .collection('payments')
          .add({
        'amount': planPrice,
        'memberUid': newUid,
        'memberName': _nameController.text.trim(),
        'planName': _selectedPlan,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'registration',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member registered successfully!'), backgroundColor: Colors.green),
      );

      // Trigger WhatsApp Message
      await _sendWhatsAppMessage(
        _phoneController.text.trim(),
        _nameController.text.trim(),
        gymId,
        password,
        newUid.substring(0, 8).toUpperCase(), // Shortened member ID
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
        title: const Text('Add New Member'),
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
                  const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
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
                    decoration: const InputDecoration(labelText: 'Phone Number (incl. country code e.g. +94)', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Home Address', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 25),
                  
                  const Text('Physical Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Birthday', border: OutlineInputBorder()),
                            child: Text(_birthday == null ? 'Select Date' : "${_birthday!.toLocal()}".split(' ')[0]),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Text('Membership Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 15),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('gyms')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('plans')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Membership Plan', border: OutlineInputBorder()),
                          items: const [],
                          onChanged: null,
                          hint: const Text('No plans available. Create one first.'),
                        );
                      }

                      List<String> planNames = snapshot.data!.docs
                          .map((doc) => doc['name'] as String)
                          .toList();

                      // Ensure _selectedPlan is valid or set it to null
                      if (_selectedPlan != null && !planNames.contains(_selectedPlan)) {
                        _selectedPlan = null;
                      }

                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Membership Plan', border: OutlineInputBorder()),
                        value: _selectedPlan,
                        hint: const Text('Select a Plan'),
                        items: planNames.map((plan) {
                          return DropdownMenuItem(value: plan, child: Text(plan));
                        }).toList(),
                        validator: (v) => v == null ? 'Please select a plan' : null,
                        onChanged: (val) => setState(() => _selectedPlan = val),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Start Date', border: OutlineInputBorder()),
                      child: Text(_startDate == null ? 'Select Date' : "${_startDate!.toLocal()}".split(' ')[0]),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _saveMember,
                    child: const Text('Save Member & Send Login', style: TextStyle(fontSize: 16, color: Colors.white)),
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
