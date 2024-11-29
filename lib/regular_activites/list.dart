import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:games/regular_activites/game.dart';
import 'package:games/games_model/regular_activity.dart';
import 'package:games/widgets/appbar.dart';

class RegularActivityLevelListScreen extends StatefulWidget {
  final int level;
  final String userId;

  const RegularActivityLevelListScreen({
    super.key,
    required this.level,
    required this.userId,
  });

  @override
  _RegularActivityLevelListScreenState createState() =>
      _RegularActivityLevelListScreenState();
}

class _RegularActivityLevelListScreenState
    extends State<RegularActivityLevelListScreen> {
  late List<bool> completedPuzzles;
  int totalPoints = 0;
  int lastCompletedPuzzleIndex = -1; // To track progress from Firestore

  @override
  void initState() {
    super.initState();
    // Initialize the puzzle completion status with the first puzzle unlocked
    completedPuzzles = List.generate(
      regularActivities[widget.level - 1].length,
      (index) => index == 0,
    );
    _fetchUserPoints();
    _fetchProgress(); // Fetch progress to unlock puzzles based on the user's progress
  }

  Future<void> _fetchUserPoints() async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('points').doc(widget.userId);
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        setState(() {
          totalPoints = snapshot.data()?['totalPoints'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user points: $e');
    }
  }

  Future<void> _fetchProgress() async {
    try {
      final progressDoc = FirebaseFirestore.instance
          .collection('progress')
          .doc(widget.userId);
      final snapshot = await progressDoc.get();
      if (snapshot.exists) {
        setState(() {
          final progressData = snapshot.data() ?? {};
          lastCompletedPuzzleIndex =
              progressData['regularActivitiesLevel${widget.level}'] ?? -1;

          // Unlock puzzles based on progress
          for (int i = 0; i <= lastCompletedPuzzleIndex + 1; i++) {
            completedPuzzles[i] = true;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching progress: $e');
    }
  }

  Future<void> _saveProgress(int puzzleIndex) async {
    try {
      final progressDoc = FirebaseFirestore.instance
          .collection('progress')
          .doc(widget.userId);
      await progressDoc.set({
        'regularActivitiesLevel${widget.level}': puzzleIndex,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  String getLevelTitle() {
    switch (widget.level) {
      case 1:
        return 'Easy - Regular Activity';
      case 2:
        return 'Medium - Regular Activity';
      case 3:
        return 'Hard - Regular Activity';
      default:
        return 'Level ${widget.level} - Regular Activity';
    }
  }

  void _markPuzzleAsCompleted(int index) {
    setState(() {
      completedPuzzles[index] = true;
      if (index + 1 < completedPuzzles.length) {
        completedPuzzles[index + 1] = true; // Unlock the next puzzle
      }
    });
    _saveProgress(index); // Save progress to Firestore
  }

  void _showCompletePreviousDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Previous Puzzle'),
          content: const Text('Please complete the previous puzzle to unlock this one.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PointsAppBar(
        userId: widget.userId, // Pass user ID to the dynamic points AppBar
        title: getLevelTitle(),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: regularActivities[widget.level - 1].length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (completedPuzzles[index]) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegularActivityGameScreen(
                      level: widget.level,
                      puzzleIndex: index,
                      userId: widget.userId, // Pass user ID to the game screen
                      onComplete: () => _markPuzzleAsCompleted(index),
                    ),
                  ),
                );
              } else {
                _showCompletePreviousDialog();
              }
            },
            child: Card(
              color: completedPuzzles[index]
                  ? Colors.amber
                  : const Color.fromARGB(255, 2, 2, 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}