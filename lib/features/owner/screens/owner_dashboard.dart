import 'package:flutter/material.dart';
import 'post_notice_screen.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gold\'s Gym Colombo', style: Theme.of(context).textTheme.titleLarge),
            const Text('Gym Management Overview'),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Revenue (May)', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 10),
                  Text('LKR 450,000.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Row(children: [Icon(Icons.trending_up, color: Colors.greenAccent, size: 20), SizedBox(width: 5), Text('+12.5% from last month', style: TextStyle(color: Colors.greenAccent))]),
                ],
              ),
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(context, 'Total Staff', '12', Icons.badge),
                _buildActionCard(context, 'Total Members', '156', Icons.people),
                _buildActionCard(context, 'Active Plans', '8', Icons.card_membership),
                _buildActionCard(context, 'New Inquiries', '5', Icons.question_answer),
              ],
            ),
            const SizedBox(height: 30),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                  _buildQuickAction(context, 'Add Member', Icons.person_add_rounded, Colors.blue, () {
                    _navigateToPlaceholder(context, 'Add New Member');
                  }),
                  _buildQuickAction(context, 'Add Staff', Icons.badge_rounded, Colors.orange, () {
                    _navigateToPlaceholder(context, 'Add New Staff');
                  }),
                  _buildQuickAction(context, 'Add Plan', Icons.add_card_rounded, Colors.green, () {
                    _navigateToPlaceholder(context, 'Create Membership Plan');
                  }),
                  _buildQuickAction(context, 'Inquiries', Icons.mark_chat_read_rounded, Colors.purple, () {
                    _navigateToPlaceholder(context, 'Resolve Inquiries');
                  }),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Notices', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PostNoticeScreen())), child: const Text('Post New')),
              ],
            ),
            const SizedBox(height: 10),
            _buildNoticeItem(context, 'Holiday Notice', 'Gym will be closed for Poya day...', '2h ago'),
            _buildNoticeItem(context, 'Maintenance', 'Equipment maintenance on Sunday...', '1d ago'),
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
          body: Center(child: Text('$title Screen\n(Coming Soon)', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
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

  Widget _buildActionCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withAlpha((0.1 * 255).toInt())), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Theme.of(context).primaryColor, size: 20), const SizedBox(height: 5), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
    );
  }

  Widget _buildNoticeItem(BuildContext context, String title, String preview, String time) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)), child: Row(children: [const Icon(Icons.info_outline, color: Colors.orange), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13))])), Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12))]));
  }
}
