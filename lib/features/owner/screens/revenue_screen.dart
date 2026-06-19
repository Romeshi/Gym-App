import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RevenueScreen extends StatelessWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    final Stream<QuerySnapshot>? paymentsStream = uid != null
        ? FirebaseFirestore.instance
            .collection('gyms')
            .doc(uid)
            .collection('payments')
            .orderBy('timestamp', descending: true)
            .snapshots()
        : null;
    final Stream<QuerySnapshot>? membersStream = uid != null ? FirebaseFirestore.instance.collection('gyms').doc(uid).collection('members').snapshots() : null;
    final Stream<QuerySnapshot>? plansStream = uid != null ? FirebaseFirestore.instance.collection('gyms').doc(uid).collection('plans').snapshots() : null;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: membersStream,
        builder: (context, membersSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: plansStream,
            builder: (context, plansSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: paymentsStream,
                builder: (context, paymentsSnapshot) {
                  if (membersSnapshot.connectionState == ConnectionState.waiting || 
                      plansSnapshot.connectionState == ConnectionState.waiting ||
                      paymentsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = paymentsSnapshot.data?.docs ?? [];
                  
                  double totalRevenue = 0.0;
                  
                  // Calculate Estimated Monthly Revenue
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

                  double regRevenue = 0.0;
                  double changeRevenue = 0.0;

                  for (var doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final amount = (data['amount'] ?? 0.0).toDouble();
                    if (data['type'] == 'registration') {
                      regRevenue += amount;
                    } else {
                      changeRevenue += amount;
                    }
                  }

          final currencyFormatter = NumberFormat.currency(locale: 'en_LK', symbol: 'LKR ');

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Total Revenue Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withAlpha((0.3 * 255).toInt()),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Monthly Revenue',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currencyFormatter.format(totalRevenue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniStat('Registration', currencyFormatter.format(regRevenue), Colors.blueAccent),
                            _buildMiniStat('Plan Changes', currencyFormatter.format(changeRevenue), Colors.greenAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${docs.length} Payments',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  if (docs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.payments_outlined, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 15),
                            Text(
                              'No payment records found',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final memberName = data['memberName'] ?? 'Unknown Member';
                        final planName = data['planName'] ?? 'No Plan';
                        final amount = (data['amount'] ?? 0.0).toDouble();
                        final type = data['type'] ?? 'registration';
                        final timestamp = data['timestamp'] as Timestamp?;
                        
                        String formattedDate = 'N/A';
                        if (timestamp != null) {
                          formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
                        }

                        final bool isReg = type == 'registration';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.02 * 255).toInt()),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.withAlpha((0.08 * 255).toInt()),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (isReg ? Colors.blue : Colors.green).withAlpha((0.1 * 255).toInt()),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isReg ? Icons.person_add_alt_1_rounded : Icons.swap_horiz_rounded,
                                  color: isReg ? Colors.blue : Colors.green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memberName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Plan: $planName • ${isReg ? "New Sign Up" : "Upgrade"}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currencyFormatter.format(amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      );
     },
    );
   },
  ),
 );
}

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
