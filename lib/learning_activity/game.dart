import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:games/games_model/learning_activity.dart';
import 'package:games/widgets/appbar.dart';

class LearningGameScreen extends StatefulWidget {
  final int level;
  final int puzzleIndex;
  final String userId;

  const LearningGameScreen({
    super.key,
    required this.level,
    required this.puzzleIndex,
    required this.userId,
  });

  @override
  _LearningGameScreenState createState() => _LearningGameScreenState();
}

class _LearningGameScreenState extends State<LearningGameScreen> {
  late List<String> tiles;
  late List<String?> targetBoxes;
  late LearningActivityItem currentItem;
  final double tileSize = 80.0;
  bool isCompleted = false;
  List<TextEditingController> textControllers = [];
  int totalPoints = 0;
  int pointsForCurrentLevel = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _fetchUserPoints();
    pointsForCurrentLevel = _getPointsForLevel(widget.level);
  }

  Future<void> _fetchUserPoints() async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('points').doc(widget.userId);
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

  Future<void> _updateUserPoints(int points) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('points').doc(widget.userId);
      await userDoc.set({
        'totalPoints': FieldValue.increment(points),
      }, SetOptions(merge: true));
      await _fetchUserPoints(); // Refresh points after update
    } catch (e) {
      debugPrint('Error updating user points: $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      final progressDoc = FirebaseFirestore.instance.collection('progress').doc(widget.userId);
      final levelKey = 'level${widget.level}';

      await progressDoc.set(
        {
          levelKey: widget.puzzleIndex,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  Future<void> _initializeProgress() async {
    try {
      final progressDoc = FirebaseFirestore.instance.collection('progress').doc(widget.userId);
      final snapshot = await progressDoc.get();

      if (snapshot.exists) {
        final progressData = snapshot.data();
        final levelKey = 'level${widget.level}';

        if (progressData != null && progressData.containsKey(levelKey)) {
          final completedIndex = progressData[levelKey];
          if (widget.puzzleIndex <= completedIndex) {
            setState(() {
              isCompleted = true;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing progress: $e');
    }
  }

  void _initializeGame() {
    currentItem = learningActivities[widget.level - 1][widget.puzzleIndex];

    if (widget.level == 3) {
      textControllers = List.generate(4, (_) => TextEditingController());
      targetBoxes = List<String?>.from(currentItem.imageUrls);
    } else {
      tiles = List.from(currentItem.imageUrls)..shuffle();
      targetBoxes = List<String?>.filled(currentItem.imageUrls.length, null);
    }

    _initializeProgress(); // Initialize progress
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

  bool _checkOrder() {
    if (widget.level == 3) {
      for (int i = 0; i < textControllers.length; i++) {
        int? enteredValue = int.tryParse(textControllers[i].text.trim());
        if (enteredValue == null || enteredValue != currentItem.correctOrder[i]) {
          return false;
        }
      }
    } else {
      for (int i = 0; i < targetBoxes.length; i++) {
        if (targetBoxes[i] != currentItem.correctOrder[i]) {
          return false;
        }
      }
    }
    return true;
  }

  void _resetGame() {
    setState(() {
      if (widget.level == 3) {
        for (var controller in textControllers) {
          controller.clear();
        }
        targetBoxes = List<String?>.from(currentItem.imageUrls);
      } else {
        _initializeGame();
      }
      isCompleted = false;
    });
  }
void _showHelpDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Hint'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currentItem.correctOrder.map<Widget>((element) {
              if (widget.level == 3) {
                // For hard levels, display the text hints
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    element.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              } else {
                // For other levels, display image hints
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    element,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.red,
                        size: 80,
                      );
                    },
                  ),
                );
              }
            }).toList(),
          ),
        ),
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

  void _submitGame() async {
    if (_checkOrder()) {
      await _updateUserPoints(pointsForCurrentLevel);
      await _saveProgress();

      setState(() {
        isCompleted = true;
      });

      // Show dialog with points awarded
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: Text('You earned $pointsForCurrentLevel points!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigateToNextPuzzle();
                },
                child: const Text('Next'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect order! Try again.')),
      );
    }
  }

  void _navigateToNextPuzzle() {
    if (widget.puzzleIndex + 1 < learningActivities[widget.level - 1].length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LearningGameScreen(
            level: widget.level,
            puzzleIndex: widget.puzzleIndex + 1,
            userId: widget.userId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have completed all puzzles in this level!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PointsAppBar(
        userId: widget.userId,
        title: 'Learning Game',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.level == 3)
              Expanded(
                child: Column(
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: TextField(
                        controller: textControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter number ${index + 1}',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(4.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: tiles.length,
                  itemBuilder: (context, index) {
                    return Draggable<String>(
                      data: tiles[index],
                      feedback: Material(
                        color: Colors.transparent,
                        child: _buildTile(tiles[index]),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: _buildTile(tiles[index]),
                      ),
                      child: _buildTile(tiles[index]),
                    );
                  },
                ),
              ),
            Expanded(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: List.generate(
                  targetBoxes.length,
                  (index) => DragTarget<String>(
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: tileSize,
                        height: tileSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: targetBoxes[index] != null
                            ? Image.asset(
                                targetBoxes[index]!,
                                fit: BoxFit.cover,
                              )
                            : null,
                      );
                    },
                    onWillAccept: (data) => targetBoxes[index] == null,
                    onAccept: (data) {
                      setState(() {
                        targetBoxes[index] = data;
                        tiles.remove(data);
                      });
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _submitGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: _resetGame,
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

  Widget _buildTile(String imageUrl) {
    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: imageUrl.isNotEmpty
            ? Image.asset(
                imageUrl,
                fit: BoxFit.cover,
              )
            : null,
      ),
    );
  }
}