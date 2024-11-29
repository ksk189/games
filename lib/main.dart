import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:games/screens/login/loginscreen.dart';
import 'package:games/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: SplashScreen(), // Show splash screen initially
    );
  }
}