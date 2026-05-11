import 'package:flutter/material.dart';
import 'package:fithub_gym/features/assignments/models/diet_model.dart';
import 'package:fithub_gym/features/assignments/models/workout_model.dart';

class CreateDietPlanScreen extends StatefulWidget {
  final Member member;
  const CreateDietPlanScreen({super.key, required this.member});
  @override
  State<CreateDietPlanScreen> createState() => _CreateDietPlanScreenState();
}

class _CreateDietPlanScreenState extends State<CreateDietPlanScreen> {
  final List<Meal> _meals = [];
  final _titleController = TextEditingController();

  void _simulateAIDietSuggest() {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {
        _meals.clear();
        _meals.addAll([Meal(time: 'Breakfast', description: 'Oatmeal with protein powder & berries', calories: 450, protein: 30), Meal(time: 'Lunch', description: 'Grilled chicken breast with quinoa and broccoli', calories: 600, protein: 50), Meal(time: 'Dinner', description: 'Baked salmon with sweet potato', calories: 550, protein: 40)]);
        _titleController.text = 'Lean Muscle Gain Diet (AI Suggest)';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diet for ${widget.member.name.split(' ')[0]}'), actions: [IconButton(onPressed: _simulateAIDietSuggest, icon: const Icon(Icons.auto_awesome, color: Colors.purple))]),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(20), child: TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Diet Plan Title', border: OutlineInputBorder()))),
          Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: _meals.length, itemBuilder: (context, index) { final meal = _meals[index]; return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(title: Text(meal.time, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(meal.description), trailing: Text('${meal.calories} kcal'))); })),
        ],
      ),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: ElevatedButton(onPressed: _meals.isEmpty ? null : () => Navigator.pop(context), child: const Text('Assign Diet Plan')))),
    );
  }
}
