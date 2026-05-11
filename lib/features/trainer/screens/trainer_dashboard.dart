import 'package:flutter/material.dart';

class TrainerDashboard extends StatelessWidget {
  const TrainerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Coach Alex!', style: Theme.of(context).textTheme.titleLarge),
            const Text('You have 4 sessions today.'),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: _buildStatCard(context, 'Active Clients', '24', Icons.people_outline, Colors.blue)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard(context, 'Pending Plans', '5', Icons.assignment_outlined, Colors.orange)),
              ],
            ),
            const SizedBox(height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Recent Clients', style: Theme.of(context).textTheme.titleLarge), TextButton(onPressed: () {}, child: const Text('View All'))]),
            const SizedBox(height: 10),
            _buildClientCard(context, 'Romeshi Perera', 'Chest & Triceps', '10:00 AM'),
            _buildClientCard(context, 'Kasun Silva', 'Leg Day', '02:30 PM'),
            _buildClientCard(context, 'Dilini Gamage', 'Cardio + Abs', '04:00 PM'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withAlpha((0.05 * 255).toInt()), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withAlpha((0.1 * 255).toInt()))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, String name, String focus, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(backgroundColor: Colors.blue[50], child: const Icon(Icons.person, color: Colors.blue)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$focus • $time'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
