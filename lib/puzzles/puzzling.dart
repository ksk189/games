import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

void main() {
  runApp(const PuzzleApp());
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuzzlePage(
          userId: 'user_id'), // Replace 'user_id' with actual user ID
    );
  }
}

class PuzzlePage extends StatefulWidget {
  final String userId; // Pass user ID to identify the user

  const PuzzlePage({super.key, required this.userId});

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  List<Image> imageParts = [];
  List<String> puzzleImages = [
    'assets/rah111.jpg',
    'assets/rah222.jpg',
    'assets/rah333.jpg',
    'assets/rah444.jpg',
    'assets/puzzle1.jpeg',
    'assets/puzzle2.jpeg',
    'assets/puzzle3.jpeg',
    'assets/puzzle4.jpeg',
    'assets/puzzle5.png',
  ];
  int currentPuzzleIndex = 0;
  String currentImagePath = 'assets/rah111.jpg';
  List<int> tileOrder = [0, 1, 2, 3]; // Initial order of tiles
  final double tileSize = 150.0;
  bool showNextPuzzleButton = false;

  int totalPoints = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
    _fetchTotalPoints();
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
      debugPrint('Error fetching total points: $e');
    }
  }

  Future<void> _updatePoints(int pointsToAdd) async {
    try {
      final userDoc = _firestore.collection('points').doc(widget.userId);
      await userDoc.set({
        'totalPoints': FieldValue.increment(pointsToAdd),
      }, SetOptions(merge: true));
      _fetchTotalPoints(); // Refresh points after updating
    } catch (e) {
      debugPrint('Error updating points: $e');
    }
  }

  Future<void> _loadPuzzle() async {
    currentImagePath = puzzleImages[currentPuzzleIndex];
    imageParts.clear();

    final ByteData imageData = await rootBundle.load(currentImagePath);
    final Uint8List bytes = imageData.buffer.asUint8List();
    final img.Image image = img.decodeImage(bytes)!;

    int width = (image.width / 2).round();
    int height = (image.height / 2).round();

    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        img.Image part =
            img.copyCrop(image, j * width, i * height, width, height);
        Uint8List partBytes = Uint8List.fromList(img.encodeJpg(part));
        imageParts.add(Image.memory(partBytes));
      }
    }

    setState(() {
      tileOrder.shuffle();
      showNextPuzzleButton = false;
    });
  }

  void swapTiles(int fromIndex, int toIndex) {
    setState(() {
      int temp = tileOrder[fromIndex];
      tileOrder[fromIndex] = tileOrder[toIndex];
      tileOrder[toIndex] = temp;
    });
  }

  bool checkIfSolved() {
    for (int i = 0; i < tileOrder.length; i++) {
      if (tileOrder[i] != i) {
        return false;
      }
    }
    return true;
  }

  void resetPuzzle() {
    setState(() {
      tileOrder.shuffle();
      showNextPuzzleButton = false;
    });
  }

  void showHint(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          content: SizedBox(
            width: tileSize * 2,
            height: tileSize * 2,
            child: Image.asset(currentImagePath),
          ),
        );
      },
    );
  }

  void nextPuzzle() {
    setState(() {
      currentPuzzleIndex = (currentPuzzleIndex + 1) % puzzleImages.length;
      _loadPuzzle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 127, 219, 239),
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Puzzle Game',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    '$totalPoints',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageParts.isEmpty
                ? const CircularProgressIndicator()
                : Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        width: tileSize * 2,
                        height: tileSize * 2,
                        child: Stack(
                          children: List.generate(4, (index) {
                            return Positioned(
                              left: (index % 2) * tileSize,
                              top: (index ~/ 2) * tileSize,
                              child: DragTarget<int>(
                                onWillAccept: (data) => true,
                                onAccept: (draggedIndex) {
                                  swapTiles(
                                      tileOrder.indexOf(draggedIndex), index);
                                },
                                builder:
                                    (context, candidateData, rejectedData) {
                                  return Draggable<int>(
                                    data: tileOrder[index],
                                    feedback: Material(
                                      child: Container(
                                        width: tileSize,
                                        height: tileSize,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 1),
                                        ),
                                        child: imageParts[tileOrder[index]],
                                      ),
                                    ),
                                    childWhenDragging: Container(
                                      width: tileSize,
                                      height: tileSize,
                                      color: Colors.transparent,
                                    ),
                                    child: Container(
                                      width: tileSize,
                                      height: tileSize,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                      ),
                                      child: imageParts[tileOrder[index]],
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            if (showNextPuzzleButton)
              ElevatedButton.icon(
                onPressed: nextPuzzle,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text(
                  'Next Puzzle',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (checkIfSolved()) {
                          setState(() {
                            showNextPuzzleButton = true;
                          });
                          await _updatePoints(
                              25); // Award 25 points for solving
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Congratulations!'),
                              content: const Text(
                                  'You have solved the puzzle and earned 25 points!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Try Again'),
                              content: const Text(
                                  'The puzzle is not solved correctly.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: resetPuzzle,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 140),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showHint(context),
        tooltip: 'Show Hint',
        child: const Icon(Icons.help),
      ),
    );
  }
}
