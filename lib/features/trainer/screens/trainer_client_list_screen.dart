import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/gym_provider.dart';
import '../../owner/screens/member_details_screen.dart';

class Client {
  final String uid; // Real Firestore document ID
  final String id; // Short Display ID
  final String name;
  final String phone;
  final String planEndDate;

  Client({
    required this.uid,
    required this.id,
    required this.name,
    required this.phone,
    required this.planEndDate,
  });
}

class TrainerClientListScreen extends StatefulWidget {
  const TrainerClientListScreen({super.key});

  @override
  State<TrainerClientListScreen> createState() => _TrainerClientListScreenState();
}

class _TrainerClientListScreenState extends State<TrainerClientListScreen> {
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

  void _markAttendance(Client client) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance marked for ${client.name}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                        .where('role', isEqualTo: 'member')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      List<Client> clientList = [];

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        clientList = snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final uid = data['uid'] ?? doc.id;
                          
                          // Estimate plan end date (assuming 1 year for now if startDate is present)
                          String planEndDateStr = 'Unknown';
                          if (data['startDate'] != null) {
                            try {
                              DateTime startDate = (data['startDate'] as Timestamp).toDate();
                              // Adding a year arbitrarily for UI purposes
                              planEndDateStr = "${startDate.year + 1}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
                            } catch (e) {
                              planEndDateStr = 'Invalid Date';
                            }
                          }

                          return Client(
                            uid: uid,
                            id: uid.toString().length >= 8 ? uid.toString().substring(0, 8).toUpperCase() : uid.toString().toUpperCase(),
                            name: data['name'] ?? 'Unknown User',
                            phone: data['phone'] ?? 'N/A',
                            planEndDate: planEndDateStr,
                          );
                        }).toList();
                      }

                      // Filter locally by search query
                      if (_searchQuery.isNotEmpty) {
                        clientList = clientList.where((c) {
                          final name = c.name.toLowerCase();
                          final phone = c.phone.toLowerCase();
                          final id = c.id.toLowerCase();
                          return name.contains(_searchQuery) || phone.contains(_searchQuery) || id.contains(_searchQuery);
                        }).toList();
                      }

                      if (clientList.isEmpty) {
                        return const Center(
                          child: Text(
                            'No clients found.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: clientList.length,
                        itemBuilder: (context, index) {
                          return _buildClientCard(clientList[index]);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(Client client) {
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
                backgroundColor: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
                child: Text(client.name.isNotEmpty ? client.name.substring(0, 1) : '?', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('ID: ${client.id}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MemberDetailsScreen(uid: client.uid, shortId: client.id))),
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
                  Text(client.phone, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _isPlanExpiring(client.planEndDate) ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Plan Ends: ${client.planEndDate}',
                  style: TextStyle(
                    color: _isPlanExpiring(client.planEndDate) ? Colors.red : Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionIcon(Icons.phone_rounded, Colors.blue, () => _makePhoneCall(client.phone)),
              const SizedBox(width: 10),
              _buildActionIcon(Icons.chat_bubble_rounded, Colors.green, () => _openWhatsApp(client.phone)),
              const SizedBox(width: 10),
              _buildActionIcon(Icons.how_to_reg_rounded, Colors.orange, () => _markAttendance(client)),
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

  bool _isPlanExpiring(String dateStr) {
    if (dateStr == 'Unknown' || dateStr == 'Invalid Date') return false;
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return date.difference(now).inDays < 7;
    } catch (e) {
      return false;
    }
  }
}
