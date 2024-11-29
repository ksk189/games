import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:games/firebase/user/progress_repository.dart';
import 'package:games/games_model/puzzle_model.dart';
import 'package:games/widgets/appbar.dart';


class PuzzleGameScreen extends StatefulWidget {
  final int level;
  final int puzzleIndex;
  final String userId;
  final VoidCallback onComplete;

  const PuzzleGameScreen({
    Key? key,
    required this.level,
    required this.puzzleIndex,
    required this.userId,
    required this.onComplete,
  }) : super(key: key);

  @override
  _PuzzleGameScreenState createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  late List<String> jumbledLetters;
  late List<String?> targetBoxes;
  late PuzzleItem currentItem;
  late int pointsPerLevel;
  int totalPoints = 0;
  final UserProgressRepository _progressRepository = UserProgressRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    currentItem = _getPuzzleItem();
    _shuffleLetters();
    targetBoxes = List.filled(currentItem.correctWord.length, null);
    pointsPerLevel = _getPointsForLevel(widget.level);
    _fetchTotalPoints();
  }

  PuzzleItem _getPuzzleItem() {
    switch (widget.level) {
      case 1:
        return level1Puzzles[widget.puzzleIndex];
      case 2:
        return level2Puzzles[widget.puzzleIndex];
      case 3:
        return level3Puzzles[widget.puzzleIndex];
      default:
        throw Exception('Invalid level');
    }
  }

  int _getPointsForLevel(int level) {
    switch (level) {
      case 1:
        return 25; // Easy
      case 2:
        return 50; // Medium
      case 3:
        return 75; // Hard
      default:
        return 0;
    }
  }

  Future<void> _fetchTotalPoints() async {
    try {
      final userDoc = _firestore.collection('points').doc(widget.userId);
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        setState(() {
          totalPoints = snapshot.data()?['totalPoints'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching points: $e');
    }
  }

  Future<void> _updatePoints(int points) async {
    try {
      final userDoc = _firestore.collection('points').doc(widget.userId);
      await userDoc.set(
        {
          'totalPoints': FieldValue.increment(points),
        },
        SetOptions(merge: true),
      );
      await _fetchTotalPoints();
    } catch (e) {
      debugPrint('Error updating points: $e');
    }
  }

  Future<void> _saveProgress() async {
    final levelKey = 'level${widget.level}';
    await _progressRepository.saveProgress(widget.userId, levelKey, widget.puzzleIndex);
  }

  void _shuffleLetters() {
    setState(() {
      jumbledLetters = currentItem.correctWord.split('')..shuffle();
    });
  }

  void _resetPuzzle() {
    setState(() {
      _shuffleLetters();
      targetBoxes = List.filled(currentItem.correctWord.length, null);
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hint'),
          content: Text('The correct sequence is: "${currentItem.correctWord.toUpperCase()}"'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _submitPuzzle() async {
    if (targetBoxes.join() == currentItem.correctWord) {
      await _updatePoints(pointsPerLevel);
      await _saveProgress(); // Save progress on successful completion

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: Text('You earned $pointsPerLevel points!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onComplete();
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect! Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PointsAppBar(
        userId: widget.userId,
        title: 'Puzzle Game',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  currentItem.imageUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Arrange the letters:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: List.generate(
                targetBoxes.length,
                (index) => DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: targetBoxes[index] != null
                          ? Text(
                              targetBoxes[index]!,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            )
                          : null,
                    );
                  },
                  onWillAccept: (data) => targetBoxes[index] == null,
                  onAccept: (letter) {
                    setState(() {
                      targetBoxes[index] = letter;
                      jumbledLetters.remove(letter);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: jumbledLetters.map((letter) {
                return Draggable<String>(
                  data: letter,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _buildLetterTile(letter),
                  ),
                  childWhenDragging: _buildLetterTile(''),
                  child: _buildLetterTile(letter),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _submitPuzzle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Submit'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetPuzzle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showHelpDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.help_outline),
      ),
    );
  }

  Widget _buildLetterTile(String letter) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        letter,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}