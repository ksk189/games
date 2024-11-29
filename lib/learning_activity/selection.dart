import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:games/learning_activity/list.dart';

class LearningLevelSelectionScreen extends StatefulWidget {
  final String userId; // Accept userId as a parameter

  const LearningLevelSelectionScreen({super.key, required this.userId});

  @override
  _LearningLevelSelectionScreenState createState() =>
      _LearningLevelSelectionScreenState();
}

class _LearningLevelSelectionScreenState
    extends State<LearningLevelSelectionScreen> {
  int totalPoints = 0; // Store user's total points

  @override
  void initState() {
    super.initState();
    _fetchUserPoints(); // Fetch user points when screen loads
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: const Color.fromARGB(255, 127, 219, 239),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Activity Level'),
            // Points display card
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
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
       body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
          ),
        ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LevelButton(
              label: 'Easy',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LearningLevelListScreen(
                      level: 1,
                      userId: widget.userId, // Pass userId to the next screen
                    ),
                  ),
                );
              },
            ),
            LevelButton(
              label: 'Medium',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LearningLevelListScreen(
                      level: 2,
                      userId: widget.userId, // Pass userId to the next screen
                    ),
                  ),
                );
              },
            ),
            LevelButton(
              label: 'Hard',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LearningLevelListScreen(
                      level: 3,
                      userId: widget.userId, // Pass userId to the next screen
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ));
  }
}

class LevelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const LevelButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
          backgroundColor: const Color.fromARGB(255, 2, 124, 148),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}