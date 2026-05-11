import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GrowthHistoryScreen extends StatelessWidget {
  const GrowthHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Growth Analytics', style: Theme.of(context).textTheme.titleLarge),
            const Text('Your progress over the last 6 months'),
            const SizedBox(height: 30),
            _buildChartCard(context, 'Weight (kg)', 'Current: 65.2 kg', _buildWeightChart(context)),
            const SizedBox(height: 20),
            _buildChartCard(context, 'Muscle vs Body Fat', 'Muscle up by 2%', _buildMuscleFatChart(context)),
            const SizedBox(height: 20),
            _buildChartCard(context, 'Workout Intensity', 'Avg: 4.5 sessions/week', _buildIntensityChart(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, String subtitle, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.02 * 255).toInt()), blurRadius: 10, spreadRadius: 5)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(subtitle, style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 25),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context) {
    return LineChart(LineChartData(gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: const [FlSpot(0, 68), FlSpot(1, 67.5), FlSpot(2, 66.8), FlSpot(3, 66.2), FlSpot(4, 65.8), FlSpot(5, 65.2)], isCurved: true, color: Colors.blue, barWidth: 4, isStrokeCapRound: true, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.blue.withAlpha((0.1 * 255).toInt())))]));
  }

  Widget _buildMuscleFatChart(BuildContext context) {
    return BarChart(BarChartData(gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), barGroups: [_makeGroupData(0, 40, 20), _makeGroupData(1, 42, 18), _makeGroupData(2, 43, 17), _makeGroupData(3, 45, 15)]));
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [BarChartRodData(toY: y1, color: Colors.blue, width: 8), BarChartRodData(toY: y2, color: Colors.orange, width: 8)]);
  }

  Widget _buildIntensityChart(BuildContext context) {
    return LineChart(LineChartData(gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: const [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5), FlSpot(4, 3), FlSpot(5, 4)], isCurved: false, color: Colors.green, barWidth: 3, dotData: const FlDotData(show: true))]));
  }
}
