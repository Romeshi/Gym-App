import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MemberDashboard extends StatelessWidget {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 25, backgroundColor: Color(0xFFE5E7EB), child: Icon(Icons.person, color: Color(0xFF9CA3AF))),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, Romeshi!', style: Theme.of(context).textTheme.titleLarge),
                    const Text('Keep pushing your limits!'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildDailyProgress(context),
            const SizedBox(height: 25),
            Text('Your Assignments', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildPlanCard(context, 'Workout', 'Chest & Triceps', const FaIcon(FontAwesomeIcons.dumbbell, color: Color(0xFF2D62ED), size: 28), const Color(0xFFEFF6FF), const Color(0xFF2D62ED))),
                const SizedBox(width: 15),
                Expanded(child: _buildPlanCard(context, 'Diet', 'High Protein', const Icon(Icons.restaurant_rounded, color: Color(0xFF10B981), size: 28), const Color(0xFFECFDF5), const Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 30),
            Text('Weekly Progress', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 15),
            _buildActivityChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Goal', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 5),
                const Text('75% Completed', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('3 exercises left for today', style: TextStyle(color: Colors.white.withAlpha((0.8 * 255).toInt()))),
              ],
            ),
          ),
          const SizedBox(height: 80, width: 80, child: CircularProgressIndicator(value: 0.75, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 10, strokeCap: StrokeCap.round)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String label, String value, Widget iconWidget, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withAlpha((0.1 * 255).toInt()))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          const SizedBox(height: 15),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).toInt()), blurRadius: 10)]),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 3), FlSpot(2, 5), FlSpot(4, 4), FlSpot(6, 8)],
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt())),
            ),
          ],
        ),
      ),
    );
  }
}
