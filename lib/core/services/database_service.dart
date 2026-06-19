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

  Future<void> addNotice(String gymId, String title, String content) async {
    await _db.collection('gyms').doc(gymId).collection('notices').add({
      'title': title,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNotice(String gymId, String noticeId, String title, String content) async {
    await _db.collection('gyms').doc(gymId).collection('notices').doc(noticeId).update({
      'title': title,
      'content': content,
    });
  }

  Future<void> deleteNotice(String gymId, String noticeId) async {
    await _db.collection('gyms').doc(gymId).collection('notices').doc(noticeId).delete();
  }

  Stream<QuerySnapshot> getPlans(String gymId) {
    return _db.collection('gyms').doc(gymId).collection('plans').snapshots();
  }

  Future<void> addPlan(String gymId, Map<String, dynamic> planData) async {
    planData['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection('gyms').doc(gymId).collection('plans').add(planData);
  }

  Future<void> updatePlan(String gymId, String planId, Map<String, dynamic> planData) async {
    await _db.collection('gyms').doc(gymId).collection('plans').doc(planId).update(planData);
  }

  Future<void> deletePlan(String gymId, String planId) async {
    await _db.collection('gyms').doc(gymId).collection('plans').doc(planId).delete();
  }
}
