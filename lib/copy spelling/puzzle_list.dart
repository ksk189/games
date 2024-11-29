import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:games/copy%20spelling/puzzle_game.dart';
import 'package:games/firebase/points_repository.dart';

class PuzzleListScreen extends StatefulWidget {
  final int level;
  final String userId; // User ID to track points and progress

  const PuzzleListScreen({
    super.key,
    required this.level,
    required this.userId,
  });

  @override
  _PuzzleListScreenState createState() => _PuzzleListScreenState();
}

class _PuzzleListScreenState extends State<PuzzleListScreen> {
  final PointsRepository _pointsRepository = PointsRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<bool> puzzleCompletionStatus = [];
  int totalPoints = 0; // User's total points

  @override
  void initState() {
    super.initState();
    _initializePuzzleStatus();
    _fetchUserPoints();
  }

  // Fetch the user's progress from Firestore
  Future<void> _initializePuzzleStatus() async {
    try {
      final progressDoc = await _firestore
          .collection('progress')
          .doc(widget.userId)
          .get();

      if (progressDoc.exists) {
        final progressData = progressDoc.data();
        final levelKey = 'level${widget.level}';
        if (progressData != null && progressData.containsKey(levelKey)) {
          final completedIndex = progressData[levelKey];
          setState(() {
            puzzleCompletionStatus = List.generate(10, (index) => index <= completedIndex);
          });
        } else {
          setState(() {
            puzzleCompletionStatus = List.generate(10, (index) => index == 0);
          });
        }
      } else {
        setState(() {
          puzzleCompletionStatus = List.generate(10, (index) => index == 0);
        });
      }
    } catch (e) {
      debugPrint('Error fetching progress: $e');
      setState(() {
        puzzleCompletionStatus = List.generate(10, (index) => index == 0);
      });
    }
  }

  // Fetch the user's total points from the database
  Future<void> _fetchUserPoints() async {
    int points = await _pointsRepository.getTotalPoints(widget.userId);
    setState(() {
      totalPoints = points;
    });
  }

  // Update the user's progress in Firestore
  Future<void> _updateProgress(int completedIndex) async {
    try {
      final levelKey = 'level${widget.level}';
      await _firestore.collection('progress').doc(widget.userId).set(
        {
          levelKey: completedIndex,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error updating progress: $e');
    }
  }

  // Shows a dialog if the user tries to access a locked puzzle
  void _showCompletionDialog(int puzzleIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Locked Puzzle'),
          content: Text('Complete Puzzle ${puzzleIndex} to unlock this one.'),
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

  // Marks the current puzzle as complete and unlocks the next one
  void _markPuzzleAsComplete(int puzzleIndex) {
    if (puzzleIndex < puzzleCompletionStatus.length - 1) {
      setState(() {
        puzzleCompletionStatus[puzzleIndex + 1] = true; // Unlock the next puzzle
      });
      _updateProgress(puzzleIndex); // Save progress in Firestore
    }
  }

  // Returns the title for the current level
  String getLevelTitle() {
    switch (widget.level) {
      case 1:
        return 'Easy - Copy Spelling';
      case 2:
        return 'Medium - Copy Spelling';
      case 3:
        return 'Hard - Copy Spelling';
      default:
        return 'Level ${widget.level} - Copy Spelling';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(getLevelTitle()),
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
         backgroundColor: const Color.fromARGB(255, 157, 251, 246),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of items per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 10, // Adjust this based on the number of puzzles per level
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (puzzleCompletionStatus[index]) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PuzzleGameScreen(
                      level: widget.level,
                      puzzleIndex: index,
                      userId: widget.userId,
                      onComplete: () {
                        _markPuzzleAsComplete(index);
                        _fetchUserPoints(); // Refresh points after puzzle completion
                      },
                    ),
                  ),
                );
              } else {
                _showCompletionDialog(index);
              }
            },
            child: Card(
              color: puzzleCompletionStatus[index]
                  ? Colors.amber // Completed or unlocked puzzles
                  : const Color.fromARGB(255, 0, 0, 0), // Locked puzzles
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}', // Display puzzle numbers starting from 1
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: puzzleCompletionStatus[index]
                        ? Colors.white
                        : Colors.black45,
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