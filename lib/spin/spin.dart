import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:games/firebase/spin_repository.dart';

class SpinWheelPage extends StatefulWidget {
  final String userId;

  const SpinWheelPage({super.key, required this.userId});

  @override
  _SpinWheelPageState createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage> {
  final List<int> rewards = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, -1]; // -1 for extra spin
  final StreamController<int> controller = StreamController<int>.broadcast();
  late ConfettiController _confettiController;
  late SpinRepository _spinRepository;
  bool isSpinning = false;
  int extraSpins = 0;
  int totalSpins = 0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _spinRepository = SpinRepository(userId: widget.userId);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadSpinData();
  }

  @override
  void dispose() {
    controller.close();
    _confettiController.dispose();
    super.dispose();
  }

Future<void> _loadSpinData() async {
  final hasDailySpin = await _spinRepository.hasDailySpinAvailable(); // Remove the argument
  final extraSpinCount = await _spinRepository.fetchExtraSpinsCountForToday();
  final totalSpinCount = await _spinRepository.fetchTotalSpinCount();

  setState(() {
    extraSpins = hasDailySpin ? (1 + extraSpinCount) : extraSpinCount;
    totalSpins = totalSpinCount;
  });
}
  void _spinWheel() {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
    });
    selectedIndex = Random().nextInt(rewards.length);
    controller.add(selectedIndex);
  }

  Future<void> _handleResult(BuildContext context) async {
    final result = rewards[selectedIndex];
    bool isExtraSpin = result == -1;

    if (isExtraSpin) {
      setState(() {
        extraSpins++;
      });
    } else {
      await _spinRepository.addSpinResult(points: result, isExtraSpin: false);
    }

    setState(() {
      isSpinning = false;
    });

    _confettiController.play();

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reward Dialog',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: _rewardDialog(result),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: child,
        );
      },
    );

    await _loadSpinData();
  }

  Widget _rewardDialog(int result) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 320,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.yellow.shade700, width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'CONGRATULATIONS!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.yellow),
              ),
              Text(
                result == -1 ? 'Extra Spin!' : '$result Points',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [Colors.yellow, Colors.red, Colors.blue, Colors.green],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin & Win'),
        backgroundColor: const Color.fromARGB(255, 158, 218, 232),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 142, 203, 231),
              Color(0xFFE1F5FE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total Spins: $totalSpins',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              if (extraSpins > 0)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'You have $extraSpins extra spin${extraSpins > 1 ? 's' : ''} left!',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FortuneWheel(
                      selected: controller.stream,
                      animateFirst: false,
                      items: rewards.map((reward) {
                        return FortuneItem(
                          child: Text(
                            reward == -1 ? 'Extra Spin' : '$reward Points',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: FortuneItemStyle(
                            color: reward == -1 ? Colors.orange : Colors.primaries[Random().nextInt(Colors.primaries.length)],
                            borderColor: Colors.white,
                            borderWidth: 3.0,
                          ),
                        );
                      }).toList(),
                      onAnimationEnd: () => _handleResult(context),
                    ),
                    const Positioned(
                      top: 0,
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 50,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isSpinning || extraSpins <= 0
                    ? null
                    : () {
                        if (extraSpins > 0) {
                          setState(() => extraSpins--);
                        }
                        _spinWheel();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Spin Now!', style: TextStyle(fontSize: 20, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}