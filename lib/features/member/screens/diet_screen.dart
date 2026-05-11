import 'package:flutter/material.dart';
import 'package:fithub_gym/features/assignments/models/diet_model.dart';

class MemberDietScreen extends StatelessWidget {
  const MemberDietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diet = DietPlan(
      id: 'd1',
      memberId: 'm1',
      title: 'Lean Muscle Gain Diet',
      meals: [
        Meal(time: 'Breakfast', description: 'Oats & Berries', calories: 450),
        Meal(time: 'Lunch', description: 'Chicken & Quinoa', calories: 600),
      ],
    );

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(diet.title, style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: diet.meals.length,
              itemBuilder: (context, index) {
                final meal = diet.meals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
                    title: Text(meal.time, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(meal.description),
                    trailing: Text('${meal.calories} kcal'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
