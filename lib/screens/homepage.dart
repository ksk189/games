import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:games/learning_activity/selection.dart';
import 'package:games/music_service.dart';
import 'package:games/pages/profile.dart';
import 'package:games/pages/reward.dart';
import 'package:games/pages/settings.dart';
import 'package:games/puzzles/puzzling.dart';
import 'package:games/spin/spin.dart';
import 'package:games/copy%20spelling/puzzle.dart';
import 'package:games/regular_activites/selection.dart';
import 'package:games/streak/streak.dart';
import 'package:games/widgets/custom_navbar.dart';

class LevelSelectionScreen extends StatefulWidget {
  final String userId;

  const LevelSelectionScreen({super.key, required this.userId});

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final MusicService _musicService = MusicService(); // Initialize MusicService
  bool isMusicPlaying = true; // Track music state

  @override
  void initState() {
    super.initState();
    _musicService.playBackgroundMusic(); // Start music on screen load
  }

  @override
  void dispose() {
    _musicService.stopMusic(); // Stop music when leaving this screen
    super.dispose();
  }

  void toggleMusic(bool play) {
    setState(() {
      isMusicPlaying = play;
      play ? _musicService.playBackgroundMusic() : _musicService.stopMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 150, 248, 253),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Level Selection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            PointsCard(userId: widget.userId), // Dynamic points card
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          iconSize: 40,
          color: Colors.black87,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(
                  toggleMusic: toggleMusic,
                  isMusicPlaying: isMusicPlaying,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            iconSize: 40,
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'SELECT GAME TYPE',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 50),
                  LevelButton(
                    text: 'Regular Activities',
                    color: const Color.fromARGB(255, 20, 206, 159),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RegularActivityLevelSelectionScreen(
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                  LevelButton(
                    text: 'Learning Activities',
                    color: const Color.fromARGB(255, 247, 73, 131),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LearningLevelSelectionScreen(
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                  LevelButton(
                    text: 'Copy Spelling',
                    color: const Color.fromARGB(255, 74, 120, 248),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameLevelSelectionScreen(
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                  LevelButton(
                    text: 'Puzzle Solving',
                    color: const Color.fromARGB(255, 235, 75, 237),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PuzzlePage(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(userId: widget.userId),
    );
  }
}

class PointsCard extends StatelessWidget {
  final String userId;

  const PointsCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('points').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Loading indicator while fetching points
        }

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data()!;
          final points = data['totalPoints'] ?? 0; // Safely access 'totalPoints'
          return Container(
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
                  '$points',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }

        return const Text(
          'No Points',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ); // Fallback if no data exists
      },
    );
  }
}

class LevelButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const LevelButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );
  }
}