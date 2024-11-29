import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:games/streak/streak_model.dart';

class StreakRepository {
  final String userId;
  final CollectionReference _streaksCollection;

  StreakRepository({required this.userId})
      : _streaksCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('streaks');

  // Fetch all streaks from Firestore
  Future<List<Streak>> fetchStreaks() async {
    final querySnapshot = await _streaksCollection.get();
    return querySnapshot.docs.map((doc) => Streak.fromDocument(doc)).toList();
  }

  // Add or update a streak in Firestore
  Future<void> addOrUpdateStreak(DateTime date) async {
    final formattedDate = DateTime(date.year, date.month, date.day);
    final streak = Streak(
      id: formattedDate.toString(),
      date: formattedDate,
      isMarked: true,
    );
    await _streaksCollection.doc(streak.id).set(streak.toMap());
  }

  // Check if a streak exists for a specific day
  Future<bool> isStreakAddedForDay(DateTime date) async {
    final formattedDate = DateTime(date.year, date.month, date.day);
    final docSnapshot = await _streaksCollection.doc(formattedDate.toString()).get();

    // Check if the document exists and has data
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>?; // Cast data to Map<String, dynamic>?
      return data != null && (data['isMarked'] ?? false) == true; // Check if 'isMarked' is true
    }

    // If the document does not exist or data is null, return false
    return false;
  }

  // Fetch streak count from Firestore
  Future<int> fetchStreakCount() async {
    final querySnapshot = await _streaksCollection.where('isMarked', isEqualTo: true).get();
    return querySnapshot.size; // Return the number of streaks marked as true
  }
}