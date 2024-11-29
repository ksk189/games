import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:games/spin/spin_model.dart';

class SpinRepository {
  final String userId;
  final CollectionReference _userPointsCollection;
  final CollectionReference _spinsCollection;

  SpinRepository({required this.userId})
      : _userPointsCollection = FirebaseFirestore.instance.collection('points'),
        _spinsCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('spins');

  // Fetch all spins for today
  Future<List<Spin>> fetchTodaySpins() async {
    DateTime today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final querySnapshot = await _spinsCollection
        .where('spinDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    return querySnapshot.docs.map((doc) => Spin.fromDocument(doc)).toList();
  }

  // Add a spin result to Firestore and update user points if applicable
  Future<void> addSpinResult({required int points, required bool isExtraSpin}) async {
    final spin = Spin(
      points: points,
      isExtraSpin: isExtraSpin,
      spinDate: DateTime.now(),
    );

    // Add spin result to the user's spins collection
    await _spinsCollection.add(spin.toMap());

    // Update user points if spin awarded points
    if (points > 0) {
      await _updateUserPoints(points);
    }
  }

  // Update user points in Firestore
  Future<void> _updateUserPoints(int points) async {
    final userPointsDoc = _userPointsCollection.doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userPointsDoc);
      final currentPoints = snapshot.exists ? snapshot['totalPoints'] as int : 0;

      transaction.set(
        userPointsDoc,
        {
          'totalPoints': currentPoints + points,
        },
        SetOptions(merge: true),
      );
    });
  }

  // Check if the user has daily spins left
Future<bool> hasDailySpinAvailable() async {
  final todaySpins = await fetchTodaySpins();
  // Adjust the max spins per day logic if needed
  const maxDailySpins = 1; // Maximum daily spins
  final todaySpinCount = todaySpins.where((spin) => !spin.isExtraSpin).length;
  return todaySpinCount < maxDailySpins;
}
  // Fetch the total spin count for the user
  Future<int> fetchTotalSpinCount() async {
    final querySnapshot = await _spinsCollection.get();
    return querySnapshot.docs.length;
  }

  // Fetch the number of extra spins used today
  Future<int> fetchExtraSpinsCountForToday() async {
    final todaySpins = await fetchTodaySpins();
    return todaySpins.where((spin) => spin.isExtraSpin).length;
  }
}