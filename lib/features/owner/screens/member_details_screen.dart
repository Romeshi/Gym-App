import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/services/database_service.dart';
import 'edit_member_screen.dart';

class MemberDetailsScreen extends StatefulWidget {
  final String uid;
  final String shortId;

  const MemberDetailsScreen({super.key, required this.uid, required this.shortId});

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Personal Details'),
            Tab(text: 'Membership Plan'),
            Tab(text: 'Attendance'),
            Tab(text: 'Workout Plans'),
            Tab(text: 'Diet Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalDetailsTab(),
          _buildMembershipPlanTab(),
          _buildAttendanceTab(),
          _buildWorkoutPlansTab(),
          _buildDietPlansTab(),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading details:\n${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Member not found.'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        
        String formatSafeDate(dynamic dateVal) {
          if (dateVal == null) return 'N/A';
          if (dateVal is Timestamp) return DateFormat('yyyy-MM-dd').format(dateVal.toDate());
          if (dateVal is String) return dateVal;
          return 'Unknown';
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
                child: Text(
                  (data['name'] != null && data['name'].toString().trim().isNotEmpty) 
                      ? data['name'].toString().trim().substring(0, 1).toUpperCase() 
                      : '?',
                  style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Text(data['name'] ?? 'Unknown', style: Theme.of(context).textTheme.headlineMedium),
              Text('ID: ${widget.shortId}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      _buildDetailRow('Email', data['email']),
                      const Divider(),
                      _buildDetailRow('Phone', data['phone']),
                      const Divider(),
                      _buildDetailRow('Address', data['address']),
                      const Divider(),
                      _buildDetailRow('Age', data['age']?.toString()),
                      const Divider(),
                      _buildDetailRow('Height', '${data['height'] ?? '--'} cm'),
                      const Divider(),
                      _buildDetailRow('Weight', '${data['weight'] ?? '--'} kg'),
                      const Divider(),
                      _buildDetailRow('Active Plan', data['activePlan'] ?? data['plan']),
                      const Divider(),
                      _buildDetailRow('Start Date', formatSafeDate(data['startDate'])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMemberScreen(
                            uid: widget.uid,
                            initialData: data,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Edit Details', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _confirmDelete(context, data['name']),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete Member', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(child: Text(value ?? 'N/A', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String? name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to completely remove ${name ?? 'this member'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ownerUid = FirebaseAuth.instance.currentUser?.uid;
      
      // Delete from global users collection
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).delete();
      
      // Delete from local gym members subcollection
      if (ownerUid != null) {
        await FirebaseFirestore.instance.collection('gyms').doc(ownerUid).collection('members').doc(widget.uid).delete();
      }
      
      if (mounted) {
        Navigator.pop(context); // Close the details screen
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member deleted successfully')));
      }
    }
  }

  // --- TAB 2: Membership Plan History ---
  Widget _buildMembershipPlanTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('membership_history').orderBy('assignedAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showChangePlanDialog(context),
                icon: const Icon(Icons.card_membership, color: Colors.white),
                label: const Text('Change Membership Plan', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
            Expanded(
              child: (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  ? const Center(child: Text('No membership history found. Assign a plan first!'))
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        final bool isActive = data['isActive'] ?? false;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(data['planName'] ?? 'Unknown Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Start: ${data['startDate'] != null ? DateFormat('yyyy-MM-dd').format((data['startDate'] as Timestamp).toDate()) : 'N/A'}\nEnd: ${data['endDate'] != null ? DateFormat('yyyy-MM-dd').format((data['endDate'] as Timestamp).toDate()) : 'N/A'}'),
                            trailing: isActive ? const Chip(label: Text('Active'), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white)) : const Chip(label: Text('Expired')),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePlanDialog(BuildContext context) async {
    final gymDocId = FirebaseAuth.instance.currentUser?.uid;
    if (gymDocId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select New Plan'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<QuerySnapshot>(
            stream: DatabaseService().getPlans(gymDocId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No plans available in this gym.'));

              final plans = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final planDoc = plans[index];
                  final planData = planDoc.data() as Map<String, dynamic>;
                  final name = planData['name'] ?? 'Unknown';
                  final durationMonths = planData['durationMonths'] ?? 1;

                  return ListTile(
                    title: Text(name),
                    subtitle: Text('$durationMonths Months'),
                    onTap: () {
                      Navigator.pop(context);
                      _assignNewPlan(name, durationMonths, gymDocId);
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Future<void> _assignNewPlan(String planName, int durationMonths, String gymDocId) async {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month + durationMonths, now.day);
    final historyRef = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('membership_history');

    // Fetch plan details (like price) for revenue tracking
    double planPrice = 0.0;
    final planQuery = await FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymDocId)
        .collection('plans')
        .where('name', isEqualTo: planName)
        .limit(1)
        .get();
    
    if (planQuery.docs.isNotEmpty) {
      planPrice = (planQuery.docs.first.data()['price'] ?? 0.0).toDouble();
    }

    // Fetch member name for payment record
    String memberName = 'Unknown Member';
    final memberDoc = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    if (memberDoc.exists) {
      memberName = (memberDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Unknown Member';
    }

    // 1. Mark existing active plans as inactive
    final activePlansQuery = await historyRef.where('isActive', isEqualTo: true).get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in activePlansQuery.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    // 2. Add new active plan
    final newPlanRef = historyRef.doc();
    batch.set(newPlanRef, {
      'planName': planName,
      'durationMonths': durationMonths,
      'startDate': Timestamp.fromDate(now),
      'endDate': Timestamp.fromDate(endDate),
      'assignedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });

    // 3. Update main user document
    batch.update(FirebaseFirestore.instance.collection('users').doc(widget.uid), {
      'activePlan': planName,
      'startDate': Timestamp.fromDate(now),
    });

    // 4. Update owner's members subcollection
    batch.update(FirebaseFirestore.instance.collection('gyms').doc(gymDocId).collection('members').doc(widget.uid), {
      'plan': planName,
    });

    // 5. Add new payment document for revenue tracking
    final newPaymentRef = FirebaseFirestore.instance.collection('gyms').doc(gymDocId).collection('payments').doc();
    batch.set(newPaymentRef, {
      'amount': planPrice,
      'memberUid': widget.uid,
      'memberName': memberName,
      'planName': planName,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'plan_change',
    });

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Plan changed to $planName successfully!'), backgroundColor: Colors.green));
    }
  }

  // --- TAB 3: Attendance History ---
  Widget _buildAttendanceTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('attendance').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No attendance records.'));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp?;
            if (timestamp == null) return const SizedBox.shrink();
            
            return ListTile(
              leading: const Icon(Icons.how_to_reg, color: Colors.green),
              title: Text(DateFormat('EEEE, MMMM d, yyyy').format(timestamp.toDate())),
              subtitle: Text('Time: ${DateFormat('hh:mm a').format(timestamp.toDate())}'),
            );
          },
        );
      },
    );
  }

  // --- TAB 4: Workout Plans History ---
  Widget _buildWorkoutPlansTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('workout_plans').orderBy('assignedAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No workout plans assigned.'));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final assignedAt = data['assignedAt'] as Timestamp?;
            final exercises = data['exercises'] as List<dynamic>? ?? [];
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.blue),
                title: Text(data['title'] ?? 'Workout Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Assigned: ${assignedAt != null ? DateFormat('yyyy-MM-dd').format(assignedAt.toDate()) : 'N/A'}\nExercises: ${exercises.length}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 5: Diet Plans History ---
  Widget _buildDietPlansTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('diet_plans').orderBy('assignedAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No diet plans assigned.'));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final assignedAt = data['assignedAt'] as Timestamp?;
            final meals = data['meals'] as List<dynamic>? ?? [];
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.orange),
                title: Text(data['title'] ?? 'Diet Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Assigned: ${assignedAt != null ? DateFormat('yyyy-MM-dd').format(assignedAt.toDate()) : 'N/A'}\nMeals: ${meals.length}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
