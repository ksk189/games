import 'package:flutter/material.dart';
import 'package:games/firebase/points_repository.dart';

class PointsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userId;
  final String title;

  const PointsAppBar({
    super.key,
    required this.userId,
    required this.title,
  });

  @override
  State<PointsAppBar> createState() => _PointsAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70); // Height of the AppBar
}

class _PointsAppBarState extends State<PointsAppBar> {
  final PointsRepository _pointsRepository = PointsRepository();
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchPoints();
  }

  /// Fetches the user's total points from Firebase
  Future<void> _fetchPoints() async {
    try {
      int points = await _pointsRepository.getTotalPoints(widget.userId);
      setState(() {
        totalPoints = points;
      });
    } catch (e) {
      debugPrint('Error fetching points: $e');
    }
  }

  /// Updates the user's points and refreshes the total points
  Future<void> updatePoints(int pointsToAdd) async {
    try {
      await _pointsRepository.updatePoints(widget.userId, pointsToAdd);
      await _fetchPoints(); // Refresh points after update
    } catch (e) {
      debugPrint('Error updating points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
       backgroundColor: const Color.fromARGB(255, 157, 251, 246),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  '$totalPoints',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }
}