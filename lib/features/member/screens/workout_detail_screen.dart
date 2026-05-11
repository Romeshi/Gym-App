import 'package:flutter/material.dart';
import 'package:fithub_gym/features/assignments/models/workout_model.dart';
import 'package:fithub_gym/features/member/screens/ai_vision_lab.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutPlan plan;
  const WorkoutDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Details')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            color: Theme.of(context).primaryColor.withAlpha((0.05 * 255).toInt()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.title, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
                const SizedBox(height: 5),
                Text('Assigned by Coach Alex • ${plan.exercises.length} Exercises', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: plan.exercises.length,
              separatorBuilder: (_, __) => const Divider(height: 30),
              itemBuilder: (context, index) {
                final ex = plan.exercises[index];
                return Row(
                  children: [
                    Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)), child: Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)))),
                    const SizedBox(width: 20),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('${ex.sets} Sets x ${ex.reps} Reps')])),
                  ],
                );
              },
            ),
          ),
          SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AIVisionLab())), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Start Workout with AI Vision')))),
        ],
      ),
    );
  }
}
