import 'package:cloud_firestore/cloud_firestore.dart';

class PointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> fetchTotalPoints(String userId) async {
    final userDoc = _firestore.collection('points').doc(userId);
    final snapshot = await userDoc.get();
    if (snapshot.exists) {
      return snapshot.data()?['totalPoints'] ?? 0;
    }
    return 0;
  }

  Future<void> updatePoints(String userId, int pointsToAdd) async {
    final userDoc = _firestore.collection('points').doc(userId);
    await userDoc.set(
      {'totalPoints': FieldValue.increment(pointsToAdd)},
      SetOptions(merge: true),
    );
  }
}