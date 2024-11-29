import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:games/games_model/learning_activity.dart';
import 'package:games/learning_activity/game.dart';
import 'package:games/widgets/appbar.dart';

class LearningLevelListScreen extends StatefulWidget {
  final int level;
  final String userId;

  const LearningLevelListScreen({
    super.key,
    required this.level,
    required this.userId,
  });

  @override
  _LearningLevelListScreenState createState() =>
      _LearningLevelListScreenState();
}

class _LearningLevelListScreenState extends State<LearningLevelListScreen> {
  late List<bool> puzzleCompletionStatus;
  int totalPoints = 0;
  int lastUnlockedPuzzle = 0; // Store the last unlocked puzzle index

  @override
  void initState() {
    super.initState();
    // Initialize puzzleCompletionStatus with the first puzzle unlocked
    puzzleCompletionStatus =
        List.generate(learningActivities[widget.level - 1].length, (index) => index == 0);
    _fetchUserPoints();
    _fetchUserProgress();
  }

  Future<void> _fetchUserPoints() async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('points').doc(widget.userId);
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        setState(() {
          totalPoints = (snapshot.data()?['totalPoints'] ?? 0) as int;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user points: $e');
    }
  }

  Future<void> _fetchUserProgress() async {
    try {
      final progressDoc =
          FirebaseFirestore.instance.collection('progress').doc(widget.userId);
      final snapshot = await progressDoc.get();
      if (snapshot.exists) {
        final data = snapshot.data();
        final levelKey = 'level${widget.level}';
        setState(() {
          lastUnlockedPuzzle = data?[levelKey] ?? 0; // Default to the first puzzle
          _updateCompletionStatus();
        });
      }
    } catch (e) {
      debugPrint('Error fetching user progress: $e');
    }
  }

  Future<void> _updateUserProgress(int puzzleIndex) async {
    try {
      final progressDoc =
          FirebaseFirestore.instance.collection('progress').doc(widget.userId);
      final levelKey = 'level${widget.level}';

      await progressDoc.set(
        {
          levelKey: puzzleIndex,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error updating user progress: $e');
    }
  }

  void _updateCompletionStatus() {
    for (int i = 0; i <= lastUnlockedPuzzle; i++) {
      puzzleCompletionStatus[i] = true;
    }
  }

  void _markPuzzleAsCompleted(int index) {
    setState(() {
      puzzleCompletionStatus[index] = true;
      if (index + 1 < puzzleCompletionStatus.length) {
        puzzleCompletionStatus[index + 1] = true; // Unlock the next puzzle
      }
      lastUnlockedPuzzle = index;
    });
    _updateUserProgress(index);
  }

  String getLevelTitle() {
    switch (widget.level) {
      case 1:
        return 'Easy - Learning Activities';
      case 2:
        return 'Medium - Activities';
      case 3:
        return 'Hard - Learning Activities';
      default:
        return 'Learning Activities';
    }
  }

  void _onPuzzleTap(int index) {
    if (puzzleCompletionStatus[index]) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LearningGameScreen(
            level: widget.level,
            puzzleIndex: index,
            userId: widget.userId,
          ),
        ),
      ).then((result) {
        if (result == true) {
          _markPuzzleAsCompleted(index);
          _fetchUserPoints();
        }
      });
    } else {
      _showIncompleteDialog();
    }
  }

  void _showIncompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Puzzle Locked'),
        content: const Text('Complete the previous puzzle to unlock this one.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PointsAppBar(
        userId: widget.userId,
        title: getLevelTitle(),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of items per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: learningActivities[widget.level - 1].length,
        itemBuilder: (context, index) {
          Color cardColor;
          if (puzzleCompletionStatus[index]) {
            cardColor = Colors.amber; // Unlocked puzzles
          } else {
            cardColor = Colors.black; // Locked puzzles
          }

          return GestureDetector(
            onTap: () => _onPuzzleTap(index),
            child: Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}