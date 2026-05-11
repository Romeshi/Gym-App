import 'package:flutter/material.dart';

class MemberNoticeScreen extends StatelessWidget {
  const MemberNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Gym Announcements', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          _buildNoticeCard(
            context,
            'New Equipment Arrived!',
            'We just installed 3 new squat racks in the main area. Enjoy!',
            'Today, 10:30 AM',
            Icons.new_releases,
            Colors.blue,
          ),
          _buildNoticeCard(
            context,
            'Poya Day Schedule',
            'The gym will be open from 6:00 AM to 12:00 PM only on Poya day.',
            'Yesterday',
            Icons.calendar_today,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(BuildContext context, String title, String content, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 15),
            Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
