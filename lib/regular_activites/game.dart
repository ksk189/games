import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:games/games_model/regular_activity.dart';
import 'package:games/widgets/appbar.dart'; // Ensure this is the updated dynamic points AppBar widget

class RegularActivityGameScreen extends StatefulWidget {
  final int level;
  final int puzzleIndex;
  final String userId;
  final VoidCallback onComplete;

  const RegularActivityGameScreen({
    super.key,
    required this.level,
    required this.puzzleIndex,
    required this.userId,
    required this.onComplete,
  });

  @override
  _RegularActivityGameScreenState createState() =>
      _RegularActivityGameScreenState();
}

class _RegularActivityGameScreenState extends State<RegularActivityGameScreen> {
  late List<String> tiles;
  late List<String?> targetBoxes;
  late RegularActivityItem currentItem;
  int totalPoints = 0;
  int lastCompletedPuzzleIndex = -1; // To track the last completed puzzle

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _fetchUserPoints(); // Fetch total points on screen load
    _fetchProgress(); // Fetch user progress
  }

  void _initializeGame() {
    currentItem = regularActivities[widget.level - 1][widget.puzzleIndex];
    tiles = List.from(currentItem.imageUrls)..shuffle();
    targetBoxes = List.filled(currentItem.imageUrls.length, null);
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

  Future<void> _updateUserPoints(int pointsToAdd) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('points').doc(widget.userId);
      await userDoc.set({
        'totalPoints': FieldValue.increment(pointsToAdd),
      }, SetOptions(merge: true));
      await _fetchUserPoints(); // Refresh total points
    } catch (e) {
      debugPrint('Error updating user points: $e');
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
        });
      }
    } catch (e) {
      debugPrint('Error fetching progress: $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      final progressDoc = FirebaseFirestore.instance
          .collection('progress')
          .doc(widget.userId);
      await progressDoc.set({
        'regularActivitiesLevel${widget.level}': widget.puzzleIndex,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  String getLevelTitle() {
    switch (widget.level) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Level';
    }
  }

  bool _checkOrder() {
    return targetBoxes.join() == currentItem.correctOrder.join();
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
    });
  }

  void _navigateToNextPuzzle() {
    if (widget.puzzleIndex + 1 < regularActivities[widget.level - 1].length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegularActivityGameScreen(
            level: widget.level,
            puzzleIndex: widget.puzzleIndex + 1,
            userId: widget.userId,
            onComplete: widget.onComplete,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You have completed all puzzles in this level!')),
      );
    }
  }
void _showHintDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Hint',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currentItem.correctOrder.map((imagePath) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
            ),
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
        userId: widget.userId,
        title: '${getLevelTitle()} - Regular Activity ${widget.puzzleIndex + 1}',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Jumbled tiles grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
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
            const SizedBox(height: 20), // Space between grids

            // Target boxes grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: targetBoxes.length,
              itemBuilder: (context, index) {
                return DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                  onAccept: (imageUrl) {
                    setState(() {
                      targetBoxes[index] = imageUrl;
                      tiles.remove(imageUrl); // Remove the tile from the draggable list
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_checkOrder()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Correct!')),
                      );
                      await _updateUserPoints(25); // Add points for solving
                      await _saveProgress(); // Save the progress
                      widget.onComplete(); // Call the onComplete callback
                      _navigateToNextPuzzle(); // Navigate to the next puzzle if correct
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Try again!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: _resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showHintDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.help_outline),
      ),
    );
  }

  Widget _buildTile(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}