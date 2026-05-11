class Member {
  final String id;
  final String name;
  final String currentGoal;
  final double weight;
  final String photoUrl;
  Member({required this.id, required this.name, required this.currentGoal, required this.weight, this.photoUrl = ''});
}

class Exercise {
  String name;
  int sets;
  int reps;
  String notes;
  Exercise({required this.name, required this.sets, required this.reps, this.notes = ''});
}

class WorkoutPlan {
  final String id;
  final String memberId;
  final String trainerId;
  final String title;
  final List<Exercise> exercises;
  final DateTime assignedAt;
  WorkoutPlan({required this.id, required this.memberId, required this.trainerId, required this.title, required this.exercises, required this.assignedAt});
}
