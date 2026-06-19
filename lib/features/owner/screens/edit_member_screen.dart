import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditMemberScreen extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> initialData;

  const EditMemberScreen({super.key, required this.uid, required this.initialData});

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.initialData['address'] ?? '');
    _ageController = TextEditingController(text: widget.initialData['age']?.toString() ?? '');
    _heightController = TextEditingController(text: widget.initialData['height']?.toString() ?? '');
    _weightController = TextEditingController(text: widget.initialData['weight']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _updateMember() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
      };

      // Update global user document
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update(updateData);

      // Also update name in the owner's local members subcollection if owner is logged in
      final ownerUid = FirebaseAuth.instance.currentUser?.uid;
      if (ownerUid != null) {
        final localDoc = FirebaseFirestore.instance.collection('gyms').doc(ownerUid).collection('members').doc(widget.uid);
        final docSnapshot = await localDoc.get();
        if (docSnapshot.exists) {
          await localDoc.update({
            'name': updateData['name'],
          });
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member details updated successfully!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Member Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Full Name', _nameController, Icons.person, true),
              const SizedBox(height: 15),
              _buildTextField('Phone Number', _phoneController, Icons.phone, true, TextInputType.phone),
              const SizedBox(height: 15),
              _buildTextField('Address', _addressController, Icons.location_on, false),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildTextField('Age', _ageController, Icons.cake, false, TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField('Height (cm)', _heightController, Icons.height, false, TextInputType.number)),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField('Weight (kg)', _weightController, Icons.monitor_weight, false, TextInputType.number),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _updateMember,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isRequired, [TextInputType type = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: isRequired ? (value) {
        if (value == null || value.trim().isEmpty) return '$label is required';
        return null;
      } : null,
    );
  }
}
