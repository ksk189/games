import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  _RewardPageState createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final List<int> rewards = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
  late StreamController<int> spinController;
  final User? user = FirebaseAuth.instance.currentUser;
  bool isSpinning = false;
  int selectedRewardIndex = 0; // Track the selected reward index

  @override
  void initState() {
    super.initState();
    spinController = StreamController<int>.broadcast();
  }

  Future<void> _claimFreeSpin(int currentPoints) async {
    if (isSpinning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Spin is already in progress. Please wait."),
        ),
      );
      return;
    }

    if (currentPoints >= 100) {
      // Deduct 100 points
      await FirebaseFirestore.instance
          .collection('points')
          .doc(user?.uid)
          .update({'totalPoints': FieldValue.increment(-100)});

      // Trigger the spin
      _startSpin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Not enough points to claim this reward!"),
        ),
      );
    }
  }

  void _startSpin() {
    setState(() {
      isSpinning = true;
      spinController.close();
      spinController = StreamController<int>.broadcast();
    });

    // Simulate spinning
    selectedRewardIndex = Random().nextInt(rewards.length);
    spinController.add(selectedRewardIndex);

    Future.delayed(const Duration(seconds: 5), () async {
      setState(() {
        isSpinning = false;
      });

      // Get the reward points based on the stopping index
      final pointsWon = rewards[selectedRewardIndex];
      await FirebaseFirestore.instance
          .collection('points')
          .doc(user?.uid)
          .update({'totalPoints': FieldValue.increment(pointsWon)});

      // Show result in a dialog
      _showResultDialog(pointsWon);
    });
  }

  void _showResultDialog(int pointsWon) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: Text('You won $pointsWon points!'),
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

  @override
  void dispose() {
    spinController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: const Color.fromARGB(255, 157, 251, 246),
        centerTitle: true,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Points Display
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('points')
                    .doc(user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    final int totalPoints =
                        snapshot.data?.data()?['totalPoints'] ?? 0;

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[900],
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Points',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.yellowAccent, size: 30),
                                  const SizedBox(width: 10),
                                  Text(
                                    '$totalPoints',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellowAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // First Reward (Free Spin)
                        GestureDetector(
                          onTap: () => _claimFreeSpin(totalPoints),
                          child: Card(
                            color: Colors.blueGrey[800],
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15.0),
                              leading: const Icon(
                                Icons.card_giftcard,
                                color: Colors.tealAccent,
                                size: 36,
                              ),
                              title: const Text(
                                '100 Points - Free Spin',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              trailing: totalPoints >= 100
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.greenAccent,
                                      size: 28,
                                    )
                                  : const Icon(
                                      Icons.lock,
                                      color: Colors.redAccent,
                                      size: 28,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Points',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.star,
                                color: Colors.yellowAccent, size: 30),
                            SizedBox(width: 10),
                            Text(
                              '0',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellowAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Spin Wheel
              if (isSpinning)
                Center(
                  child: SizedBox(
                    height: 300,
                    child: FortuneWheel(
                      selected: spinController.stream,
                      items: rewards.map((reward) {
                        return FortuneItem(
                          child: Text(
                            '$reward Points',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
