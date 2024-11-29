import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchProgress(String userId) async {
    try {
      final userDoc = await _firestore.collection('userProgress').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['puzzleProgress'] ?? {};
      }
      return {};
    } catch (e) {
      print('Error fetching progress: $e');
      return {};
    }
  }

  Future<void> saveProgress(String userId, String levelKey, int puzzleIndex) async {
    try {
      final userDoc = _firestore.collection('userProgress').doc(userId);
      await userDoc.set({
        'puzzleProgress': {
          levelKey: FieldValue.arrayUnion([puzzleIndex])
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving progress: $e');
    }
  }
}