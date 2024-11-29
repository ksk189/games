import 'package:flutter/material.dart';
import 'package:games/regular_activites/list.dart';
// Adjust the path as necessary

class RegularActivityLevelSelectionScreen extends StatelessWidget {
  final String userId; // Add userId to pass to subsequent screens

  const RegularActivityLevelSelectionScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Regular Activity Level'),
         backgroundColor: const Color.fromARGB(255, 127, 219, 239),
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
              levelNumber: 1,
              label: 'Easy',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegularActivityLevelListScreen(
                      level: 1,
                      userId: userId, // Pass userId to the list screen
                    ),
                  ),
                );
              },
            ),
            LevelButton(
              levelNumber: 2,
              label: 'Medium',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegularActivityLevelListScreen(
                      level: 2,
                      userId: userId, // Pass userId to the list screen
                    ),
                  ),
                );
              },
            ),
            LevelButton(
              levelNumber: 3,
              label: 'Hard',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegularActivityLevelListScreen(
                      level: 3,
                      userId: userId, // Pass userId to the list screen
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
  final int levelNumber;
  final String label;
  final VoidCallback onPressed;

  const LevelButton({
    super.key,
    required this.levelNumber,
    required this.label,
    required this.onPressed,
  });

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