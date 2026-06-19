import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/providers/gym_provider.dart';
import '../../../core/services/database_service.dart';

class AddPlanScreen extends StatefulWidget {
  final String? planId;
  final Map<String, dynamic>? initialData;

  const AddPlanScreen({super.key, this.planId, this.initialData});

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool get _isEditing => widget.planId != null;

  final _planNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  
  // Dynamic list of feature controllers
  final List<TextEditingController> _featureControllers = [];

  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.initialData != null) {
      final data = widget.initialData!;
      _planNameController.text = data['name'] ?? '';
      _priceController.text = (data['price'] ?? 0).toString();
      _durationController.text = (data['durationMonths'] ?? 1).toString();
      
      if (data['features'] != null && data['features'] is List) {
        final featuresList = data['features'] as List;
        for (var feature in featuresList) {
          _featureControllers.add(TextEditingController(text: feature.toString()));
        }
      }
    }
    
    // Add one empty feature field by default if empty
    if (_featureControllers.isEmpty) {
      _featureControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addFeatureField() {
    setState(() {
      _featureControllers.add(TextEditingController());
    });
  }

  void _removeFeatureField(int index) {
    setState(() {
      if (_featureControllers.length > 1) {
        _featureControllers[index].dispose();
        _featureControllers.removeAt(index);
      } else {
        _featureControllers[0].clear();
      }
    });
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      List<String> features = _featureControllers
          .map((c) => c.text.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      
      final ownerUid = FirebaseAuth.instance.currentUser?.uid;
      
      if (ownerUid == null) throw Exception("Gym ID not found.");

      final planData = {
        'name': _planNameController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'durationMonths': int.tryParse(_durationController.text) ?? 1,
        'features': features,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final dbService = DatabaseService();

      if (widget.planId == null) {
        planData['createdAt'] = FieldValue.serverTimestamp();
        await dbService.addPlan(ownerUid, planData);
      } else {
        await dbService.updatePlan(ownerUid, widget.planId!, planData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Plan updated successfully!' : 'Plan created successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Membership Plan' : 'Create Membership Plan'),
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
                  TextFormField(
                    controller: _planNameController,
                    decoration: const InputDecoration(labelText: 'Plan Name (e.g. Annual VIP)', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Price (LKR)', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Duration (Months)', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  
                  // Dynamic Features Section
                  const Text(
                    'Plan Features',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _featureControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _featureControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Feature ${index + 1}',
                                  hintText: 'e.g. 24/7 Access',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removeFeatureField(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  TextButton.icon(
                    onPressed: _addFeatureField,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Feature'),
                  ),
                  
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _savePlan,
                    child: Text(_isEditing ? 'Update Plan' : 'Create Plan', style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
