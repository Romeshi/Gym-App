import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registerGym(String name, String ownerId) async {
    await _db.collection('gyms').add({'name': name, 'ownerId': ownerId, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  Future<void> assignWorkout(String memberId, Map<String, dynamic> plan) async {
    await _db.collection('users').doc(memberId).collection('workouts').add({...plan, 'timestamp': FieldValue.serverTimestamp()});
  }

  Stream<QuerySnapshot> getNotices(String gymId) {
    return _db.collection('gyms').doc(gymId).collection('notices').orderBy('timestamp', descending: true).snapshots();
  }
}
