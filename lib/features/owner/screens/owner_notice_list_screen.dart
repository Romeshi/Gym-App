import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/gym_provider.dart';
import '../../../core/services/database_service.dart';
import 'post_notice_screen.dart';

class OwnerNoticeListScreen extends StatelessWidget {
  const OwnerNoticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gymId = FirebaseAuth.instance.currentUser?.uid;

    if (gymId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notices')),
        body: const Center(child: Text('No gym selected.')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notices'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: DatabaseService().getNotices(gymId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];
            final now = DateTime.now();
            final todayStart = DateTime(now.year, now.month, now.day);

            final todayNotices = <QueryDocumentSnapshot>[];
            final historyNotices = <QueryDocumentSnapshot>[];

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;
              if (timestamp != null) {
                final date = timestamp.toDate();
                if (date.isAfter(todayStart) || date.isAtSameMomentAs(todayStart)) {
                  todayNotices.add(doc);
                } else {
                  historyNotices.add(doc);
                }
              } else {
                // Server timestamp pending or null, assume it's created just now (Today)
                todayNotices.add(doc);
              }
            }

            return TabBarView(
              children: [
                _buildNoticeList(context, todayNotices, isToday: true, gymId: gymId),
                _buildNoticeList(context, historyNotices, isToday: false, gymId: gymId),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostNoticeScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildNoticeList(BuildContext context, List<QueryDocumentSnapshot> notices, {required bool isToday, required String gymId}) {
    if (notices.isEmpty) {
      return Center(child: Text(isToday ? 'No notices posted today.' : 'No older notices.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: notices.length,
      itemBuilder: (context, index) {
        final doc = notices[index];
        final data = doc.data() as Map<String, dynamic>;
        final title = data['title'] ?? 'No Title';
        final content = data['content'] ?? 'No Content';
        final timestamp = data['timestamp'] as Timestamp?;
        
        String timeString = 'Just now';
        if (timestamp != null) {
          final date = timestamp.toDate();
          if (isToday) {
            timeString = DateFormat('h:mm a').format(date);
          } else {
            timeString = DateFormat('MMM d, yyyy h:mm a').format(date);
          }
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Text(
                      timeString,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(content),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isToday)
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostNoticeScreen(
                                noticeId: doc.id,
                                title: title,
                                content: content,
                              ),
                            ),
                          );
                        },
                      ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _confirmDelete(context, gymId, doc.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String gymId, String noticeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice?'),
        content: const Text('Are you sure you want to delete this notice? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService().deleteNotice(gymId, noticeId);
    }
  }
}
