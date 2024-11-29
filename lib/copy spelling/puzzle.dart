import 'package:flutter/material.dart';
import 'package:games/copy%20spelling/puzzle_list.dart'; // Ensure the import path is correct

class GameLevelSelectionScreen extends StatelessWidget {
  final String userId; // Add userId to track points and progress

  const GameLevelSelectionScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
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
                label: 'Easy',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PuzzleListScreen(level: 1, userId: userId),
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
                      builder: (context) =>
                          PuzzleListScreen(level: 2, userId: userId),
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
                      builder: (context) =>
                          PuzzleListScreen(level: 3, userId: userId),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          elevation: 5, // Add shadow effect
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}