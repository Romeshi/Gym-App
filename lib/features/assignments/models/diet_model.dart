class Meal {
  String time;
  String description;
  int calories;
  int protein;
  Meal({required this.time, required this.description, this.calories = 0, this.protein = 0});
}

class DietPlan {
  final String id;
  final String memberId;
  final String title;
  final List<Meal> meals;
  final String totalMacros;
  DietPlan({required this.id, required this.memberId, required this.title, required this.meals, this.totalMacros = ''});
}
