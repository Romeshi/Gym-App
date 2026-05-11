import 'package:flutter/material.dart';
import 'package:fithub_gym/features/assignments/models/workout_model.dart';
import 'package:fithub_gym/features/member/screens/workout_detail_screen.dart';

class MemberWorkoutListScreen extends StatelessWidget {
  const MemberWorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignedPlans = [
      WorkoutPlan(
        id: 'w1',
        memberId: 'm1',
        trainerId: 't1',
        title: 'Chest & Triceps (AI Suggested)',
        exercises: [
          Exercise(name: 'Bench Press', sets: 4, reps: 10),
          Exercise(name: 'Dumbbell Flys', sets: 3, reps: 12),
        ],
        assignedAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Your Assigned Workouts', style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: assignedPlans.isEmpty
                ? const Center(child: Text('No plans assigned yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: assignedPlans.length,
                    itemBuilder: (context, index) => _buildPlanCard(context, assignedPlans[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WorkoutPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutDetailScreen(plan: plan))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))), const Icon(Icons.arrow_forward_ios, size: 14)]),
              const SizedBox(height: 10),
              Row(children: [const Icon(Icons.fitness_center, size: 16, color: Colors.blue), const SizedBox(width: 8), Text('${plan.exercises.length} Exercises'), const SizedBox(width: 15), const Icon(Icons.person, size: 16, color: Colors.green), const SizedBox(width: 8), const Text('Coach Alex')]),
            ],
          ),
        ),
      ),
    );
  }
}
