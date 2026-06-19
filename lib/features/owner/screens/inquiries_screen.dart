import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/providers/gym_provider.dart';

class InquiriesScreen extends StatelessWidget {
  const InquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gymProvider = context.watch<GymProvider>();
    final gymId = gymProvider.currentGymId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Inquiries'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: gymId == null
          ? const Center(child: Text('Please log in again.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('gyms')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('inquiries')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No inquiries yet.', style: TextStyle(color: Colors.grey)),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unknown User';
                    final message = data['message'] ?? 'No message';
                    final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      color: Colors.white,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF2962FF).withOpacity(0.1),
                          child: const Icon(Icons.person, color: Color(0xFF2962FF)),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          "${date.day}/${date.month}/${date.year}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text("Email: ${data['email'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 5),
                                Text("Phone: ${data['phone'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Divider(height: 20),
                                Text(message),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
