import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/gym_provider.dart';
import 'add_staff_screen.dart';
import 'staff_details_screen.dart';

class StaffMember {
  final String uid; // Real Firestore document ID
  final String id; // Short Display ID
  final String name;
  final String phone;
  final String role;

  StaffMember({
    required this.uid,
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
  });
}

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '94${cleanPhone.substring(1)}';
    }
    final Uri url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  void _confirmDelete(StaffMember staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to remove ${staff.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final ownerUid = FirebaseAuth.instance.currentUser?.uid;
              if (ownerUid != null) {
                // Remove from global users collection
                await FirebaseFirestore.instance.collection('users').doc(staff.uid).delete();
                // Remove from local gym staff subcollection
                await FirebaseFirestore.instance.collection('gyms').doc(ownerUid).collection('staff').doc(staff.uid).delete();
              }
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAttendance(StaffMember staff) async {
    try {
      final now = DateTime.now();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(staff.uid)
          .collection('attendance')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance marked for ${staff.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final String? gymId = gymProvider.currentGymId; // GYM-1234

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID or phone...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          Expanded(
            child: gymId == null
                ? const Center(child: Text('Please log in again.'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('gymId', isEqualTo: gymId)
                        .where('role', whereIn: ['trainer', 'manager', 'receptionist'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      List<StaffMember> staffList = [];

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        staffList = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final uid = data['uid'] ?? doc.id;
                          
                          return StaffMember(
                            uid: uid,
                            id: uid.toString().length >= 8 ? uid.toString().substring(0, 8).toUpperCase() : uid.toString().toUpperCase(),
                            name: data['name'] ?? 'Unknown Staff',
                            phone: data['phone'] ?? 'N/A',
                            role: data['role'] ?? 'Staff',
                          );
                        }).toList();
                      }

                      // Filter locally by search query
                      if (_searchQuery.isNotEmpty) {
                        staffList = staffList.where((m) {
                          final name = m.name.toLowerCase();
                          final phone = m.phone.toLowerCase();
                          final id = m.id.toLowerCase();
                          return name.contains(_searchQuery) || phone.contains(_searchQuery) || id.contains(_searchQuery);
                        }).toList();
                      }

                      if (staffList.isEmpty) {
                        return const Center(
                          child: Text(
                            'No staff found.\nClick the + button to add one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: staffList.length,
                        itemBuilder: (context, index) {
                          return _buildStaffCard(staffList[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStaffScreen()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStaffCard(StaffMember staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withAlpha((0.1 * 255).toInt())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.withAlpha((0.1 * 255).toInt()),
                child: Text(staff.name.isNotEmpty ? staff.name[0] : '?', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(staff.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('ID: ${staff.id}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  staff.role.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetailsScreen(uid: staff.uid, shortId: staff.id))),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.phone_android_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(staff.phone, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionIcon(Icons.how_to_reg_rounded, Colors.orange, () => _markAttendance(staff)),
              const SizedBox(width: 10),
              _buildActionIcon(Icons.phone_rounded, Colors.blue, () => _makePhoneCall(staff.phone)),
              const SizedBox(width: 10),
              _buildActionIcon(Icons.chat_bubble_rounded, Colors.green, () => _openWhatsApp(staff.phone)),
              const SizedBox(width: 10),
              _buildActionIcon(Icons.delete_outline_rounded, Colors.red, () => _confirmDelete(staff)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
