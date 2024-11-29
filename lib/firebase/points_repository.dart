import 'package:cloud_firestore/cloud_firestore.dart';

class PointsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalPoints(String userId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('points').doc(userId).get();
      if (snapshot.exists) {
        return snapshot['totalPoints'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching total points: $e');
      return 0;
    }
  }

  Future<void> updatePoints(String userId, int pointsToAdd) async {
    try {
      DocumentReference docRef = _firestore.collection('points').doc(userId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        int currentPoints = snapshot.exists ? snapshot['totalPoints'] ?? 0 : 0;
        transaction.set(docRef, {'totalPoints': currentPoints + pointsToAdd}, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error updating points: $e');
    }
  }
}