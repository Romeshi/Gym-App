import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditStaffScreen extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> initialData;

  const EditStaffScreen({super.key, required this.uid, required this.initialData});

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  String? _selectedRole;
  DateTime? _birthday;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.initialData['address'] ?? '');
    
    // Parse role
    String roleStr = (widget.initialData['role'] ?? 'Trainer').toString();
    // Capitalize first letter for matching Dropdown
    if (roleStr.isNotEmpty) {
      roleStr = roleStr[0].toUpperCase() + roleStr.substring(1).toLowerCase();
    }
    if (['Trainer', 'Receptionist', 'Manager'].contains(roleStr)) {
      _selectedRole = roleStr;
    } else {
      _selectedRole = 'Trainer';
    }

    // Parse birthday
    if (widget.initialData['birthday'] != null) {
      if (widget.initialData['birthday'] is Timestamp) {
        _birthday = (widget.initialData['birthday'] as Timestamp).toDate();
      } else if (widget.initialData['birthday'] is String) {
        _birthday = DateTime.tryParse(widget.initialData['birthday']);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Future<void> _updateStaff() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthday == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all role and date fields')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'role': _selectedRole!.toLowerCase(),
        'birthday': _birthday,
      };

      // Update global user document
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update(updateData);

      // Also update name and role in the owner's local staff subcollection
      final ownerUid = FirebaseAuth.instance.currentUser?.uid;
      if (ownerUid != null) {
        final localDoc = FirebaseFirestore.instance.collection('gyms').doc(ownerUid).collection('staff').doc(widget.uid);
        final docSnapshot = await localDoc.get();
        if (docSnapshot.exists) {
          await localDoc.update({
            'name': updateData['name'],
            'role': updateData['role'],
          });
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff details updated successfully!'), backgroundColor: Colors.green));
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
      appBar: AppBar(title: const Text('Edit Staff Details')),
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
              
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Staff Role',
                  prefixIcon: const Icon(Icons.work, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
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
                  decoration: InputDecoration(
                    labelText: 'Birthday',
                    prefixIcon: const Icon(Icons.cake, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  child: Text(_birthday == null ? 'Select Date' : "${_birthday!.toLocal()}".split(' ')[0]),
                ),
              ),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _updateStaff,
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
