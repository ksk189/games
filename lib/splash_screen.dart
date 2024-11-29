import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:games/screens/login/loginscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay to move to Login Screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Stack(
        children: [
          // Full-Screen Moving Globe Animation
          Lottie.asset(
            'assets/globe.json', // Replace with your globe animation Lottie file
            fit: BoxFit.cover,
            repeat: true,
            width: double.infinity,
            height: double.infinity,
          ),
          // Overlay Text
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 100),
                // Animated Text
                AnimatedText(
                  text: 'WELCOME  TO \n AUTISM WORLD',
                  textStyle: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color to white
                  ),
                  duration: Duration(seconds: 4), // Increase duration to 4 seconds
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Text Widget with Typewriter Effect
class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration duration;

  const AnimatedText({super.key, 
    required this.text,
    required this.textStyle,
    required this.duration,
  });

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charCount;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for text
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward();

    // Set up character count animation
    _charCount = StepTween(begin: 0, end: widget.text.length)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _charCount,
      builder: (context, child) {
        String visibleText = widget.text.substring(0, _charCount.value);
        return Text(
          visibleText,
          style: widget.textStyle,
        );
      },
    );
  }
}