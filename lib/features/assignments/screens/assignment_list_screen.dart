import 'package:flutter/material.dart';
import 'package:fithub_gym/features/assignments/models/workout_model.dart';
import 'package:fithub_gym/features/assignments/screens/create_workout_screen.dart';
import 'package:fithub_gym/features/assignments/screens/create_diet_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});
  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final members = [
      Member(id: '1', name: 'Romeshi Perera', currentGoal: 'Weight Loss', weight: 65.0),
      Member(id: '2', name: 'Kasun Silva', currentGoal: 'Muscle Gain', weight: 72.5),
      Member(id: '3', name: 'Dilini Gamage', currentGoal: 'Fitness', weight: 58.0),
    ];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: TabBar(controller: _tabController, labelColor: Theme.of(context).primaryColor, unselectedLabelColor: Colors.grey, tabs: const [Tab(text: 'Workout Assignment'), Tab(text: 'Diet Assignment')]),
      ),
      body: TabBarView(controller: _tabController, children: [_buildMemberList(context, members, isWorkout: true), _buildMemberList(context, members, isWorkout: false)]),
    );
  }

  Widget _buildMemberList(BuildContext context, List<Member> members, {required bool isWorkout}) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: CircleAvatar(child: Text(member.name[0])),
            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Goal: ${member.currentGoal}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => isWorkout ? CreateWorkoutPlanScreen(member: member) : CreateDietPlanScreen(member: member))),
          ),
        );
      },
    );
  }
}
