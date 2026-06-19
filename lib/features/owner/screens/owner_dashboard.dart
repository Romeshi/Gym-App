import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/gym_provider.dart';
import '../../../core/services/database_service.dart';
import 'post_notice_screen.dart';
import 'owner_notice_list_screen.dart';
import 'add_member_screen.dart';
import 'add_staff_screen.dart';
import 'add_plan_screen.dart';
import 'inquiries_screen.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final gymProvider = Provider.of<GymProvider>(context);
    final gymName = gymProvider.currentGymName ?? 'Your Gym';
    
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    final Stream<QuerySnapshot>? staffStream = uid != null ? FirebaseFirestore.instance.collection('gyms').doc(uid).collection('staff').snapshots() : null;
    final Stream<QuerySnapshot>? membersStream = uid != null ? FirebaseFirestore.instance.collection('gyms').doc(uid).collection('members').snapshots() : null;
    final Stream<QuerySnapshot>? plansStream = uid != null ? FirebaseFirestore.instance.collection('gyms').doc(uid).collection('plans').snapshots() : null;
    final Stream<QuerySnapshot>? inquiriesStream = uid != null ? FirebaseFirestore.instance.collection('gyms').doc(uid).collection('inquiries').snapshots() : null;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Standard padding block for your core dashboard widgets
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          gymName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withAlpha((0.2 * 255).toInt()),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings_rounded,
                                size: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Welcome, ${gymProvider.ownerName ?? 'Owner'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Gym Management Overview',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Total Revenue Banner Card
                  StreamBuilder<QuerySnapshot>(
                    stream: uid != null
                        ? FirebaseFirestore.instance.collection('gyms').doc(uid).collection('members').snapshots()
                        : null,
                    builder: (context, membersSnapshot) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: uid != null
                            ? FirebaseFirestore.instance.collection('gyms').doc(uid).collection('plans').snapshots()
                            : null,
                        builder: (context, plansSnapshot) {
                          double totalRevenue = 0.0;
                          if (membersSnapshot.hasData && plansSnapshot.hasData) {
                            Map<String, double> planPrices = {};
                            for (var planDoc in plansSnapshot.data!.docs) {
                              final planData = planDoc.data() as Map<String, dynamic>;
                              planPrices[planData['name'] ?? ''] = (planData['price'] ?? 0.0).toDouble();
                            }
                            
                            for (var memberDoc in membersSnapshot.data!.docs) {
                              final memberData = memberDoc.data() as Map<String, dynamic>;
                              final planName = memberData['plan'];
                              if (planName != null && planPrices.containsKey(planName)) {
                                totalRevenue += planPrices[planName]!;
                              }
                            }
                          }
                          
                          final formattedRevenue = NumberFormat.currency(locale: 'en_LK', symbol: 'LKR ').format(totalRevenue);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Estimated Monthly Revenue',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  formattedRevenue,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.trending_up,
                                      color: Colors.greenAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Based on active plans',
                                      style: TextStyle(color: Colors.greenAccent[400]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // Metrics Overview Grid Panel
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.5,
                    children: [
                      _buildDynamicActionCard(context, 'Total Staff', Icons.badge, staffStream),
                      _buildDynamicActionCard(context, 'Total Members', Icons.people, membersStream),
                      _buildDynamicActionCard(context, 'Active Plans', Icons.card_membership, plansStream),
                      _buildDynamicActionCard(context, 'New Inquiries', Icons.question_answer, inquiriesStream),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Quick Actions Bar Section Layout
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.03 * 255).toInt()),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                         _buildQuickAction(
                          context,
                          'Add Plan',
                          Icons.add_card_rounded,
                          Colors.green,
                          () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPlanScreen()));
                          },
                        ),
                        _buildQuickAction(
                          context,
                          'Add Staff',
                          Icons.badge_rounded,
                          Colors.orange,
                          () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddStaffScreen()));
                          },
                        ),
                       _buildQuickAction(
                          context,
                          'Add Member',
                          Icons.person_add_rounded,
                          Colors.blue,
                          () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMemberScreen()));
                          },
                        ),
                        _buildQuickAction(
                          context,
                          'Inquiries',
                          Icons.mark_chat_read_rounded,
                          Colors.purple,
                          () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const InquiriesScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Recent Notices Section Row Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Notices',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PostNoticeScreen(),
                              ),
                            ),
                            child: const Text('Post New'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OwnerNoticeListScreen(),
                              ),
                            ),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (uid != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: DatabaseService().getNotices(uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No recent notices.'),
                          );
                        }
                        
                        final docs = snapshot.data!.docs.take(3).toList();
                        return Column(
                          children: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final title = data['title'] ?? 'No Title';
                            final content = data['content'] ?? 'No Content';
                            final timestamp = data['timestamp'] as Timestamp?;
                            
                            String timeString = 'Just now';
                            if (timestamp != null) {
                              final date = timestamp.toDate();
                              final now = DateTime.now();
                              final difference = now.difference(date);
                              
                              if (difference.inHours < 24) {
                                if (difference.inHours > 0) {
                                  timeString = '${difference.inHours}h ago';
                                } else if (difference.inMinutes > 0) {
                                  timeString = '${difference.inMinutes}m ago';
                                }
                              } else {
                                timeString = '${difference.inDays}d ago';
                              }
                            }
                            
                            return _buildNoticeItem(context, title, content, timeString);
                          }).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),

            // Separation spacing baseline buffer matching design guidelines
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _navigateToPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(
            child: Text(
              '$title Screen\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withAlpha((0.1 * 255).toInt())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).toInt()),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDynamicActionCard(
    BuildContext context,
    String label,
    IconData icon,
    Stream<QuerySnapshot>? stream,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        String value = '...';
        if (snapshot.hasError) {
          value = 'Err';
        } else if (snapshot.hasData) {
          value = snapshot.data!.docs.length.toString();
        } else if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
          value = '0';
        }
        return _buildActionCard(context, label, value, icon);
      },
    );
  }

  Widget _buildNoticeItem(
    BuildContext context,
    String title,
    String preview,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
