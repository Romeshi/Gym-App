import 'package:flutter/material.dart';
import 'package:fithub_gym/features/assignments/models/workout_model.dart';

class CreateWorkoutPlanScreen extends StatefulWidget {
  final Member member;
  const CreateWorkoutPlanScreen({super.key, required this.member});
  @override
  State<CreateWorkoutPlanScreen> createState() => _CreateWorkoutPlanScreenState();
}

class _CreateWorkoutPlanScreenState extends State<CreateWorkoutPlanScreen> {
  final List<Exercise> _exercises = [];
  final _titleController = TextEditingController();

  void _addExercise() => setState(() => _exercises.add(Exercise(name: 'New Exercise', sets: 3, reps: 12)));

  void _simulateAISuggest() {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {
        _exercises.clear();
        _exercises.addAll([Exercise(name: 'Bench Press', sets: 4, reps: 10, notes: 'Focus on form'), Exercise(name: 'Dumbbell Flys', sets: 3, reps: 12), Exercise(name: 'Tricep Pushdowns', sets: 3, reps: 15)]);
        _titleController.text = 'Chest & Triceps (AI Suggested)';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI generated a personalized plan based on goals!')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign to ${widget.member.name.split(' ')[0]}'), actions: [TextButton.icon(onPressed: _simulateAISuggest, icon: const Icon(Icons.auto_awesome, size: 18), label: const Text('AI Suggest')), const SizedBox(width: 10)]),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(20), child: TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Plan Title', border: OutlineInputBorder()))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Row(children: [Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))])),
          Expanded(child: _exercises.isEmpty ? const Center(child: Text('No exercises added yet.')) : ListView.builder(padding: const EdgeInsets.all(20), itemCount: _exercises.length, itemBuilder: (context, index) => _buildExerciseTile(_exercises[index], index))),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addExercise, icon: const Icon(Icons.add), label: const Text('Add Exercise')),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: ElevatedButton(onPressed: _exercises.isEmpty ? null : () => Navigator.pop(context), child: const Text('Confirm & Assign Plan')))),
    );
  }

  Widget _buildExerciseTile(Exercise ex, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(children: [Expanded(child: TextFormField(initialValue: ex.name, decoration: const InputDecoration(labelText: 'Exercise Name', isDense: true), onChanged: (val) => ex.name = val)), IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() => _exercises.removeAt(index)))]),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: TextFormField(initialValue: ex.sets.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sets', isDense: true), onChanged: (val) => ex.sets = int.tryParse(val) ?? 0)), const SizedBox(width: 20), Expanded(child: TextFormField(initialValue: ex.reps.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps', isDense: true), onChanged: (val) => ex.reps = int.tryParse(val) ?? 0))]),
          ],
        ),
      ),
    );
  }
}
