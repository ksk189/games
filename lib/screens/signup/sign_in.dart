import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:games/screens/login/loginscreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import your LoginScreen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: screenHeight * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Input fields
              _buildTextField(nicknameController, "Nickname", Icons.person),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField(ageController, "Age", Icons.cake, inputType: TextInputType.number),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField(phoneController, "Phone Number", Icons.phone, inputType: TextInputType.phone),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField(emailController, "Email", Icons.email),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField(passwordController, "Password", Icons.lock, isPassword: true),

              SizedBox(height: screenHeight * 0.03),

              // Sign-Up button
              ElevatedButton(
                onPressed: () async {
                  await _registerWithEmailPassword();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.25, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  shadowColor: Colors.blueAccent,
                  elevation: 5,
                ),
                child: Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),

              SizedBox(height: screenHeight * 0.02),
              Text("Or continue with", style: TextStyle(color: Colors.grey, fontSize: 16)),
              SizedBox(height: screenHeight * 0.02),

              // Social Login Option
              _buildSocialLoginOption(FontAwesomeIcons.google, "Google", _registerWithGoogle),

              SizedBox(height: screenHeight * 0.04),
              Text("Already have an account?", style: TextStyle(color: Colors.white, fontSize: 16)),

              // Log In button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  shadowColor: Colors.blueAccent,
                  elevation: 5,
                ),
                child: Text("Log In", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSocialLoginOption(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Future<void> _registerWithEmailPassword() async {
    try {
      // Check if the email already exists
      final signInMethods = await _auth.fetchSignInMethodsForEmail(emailController.text);
      if (signInMethods.isNotEmpty) {
        // Email already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email is already registered.")),
        );
        return;
      }

      // Create the user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Save user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'nickname': nicknameController.text,
        'age': ageController.text,
        'phone': phoneController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful!")),
      );

      // Redirect to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _registerWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final UserCredential userCredential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );

      // Show dialog to enter additional user info
      _showUserInfoDialog(userCredential.user!.uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showUserInfoDialog(String uid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Complete your profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nicknameController, "Nickname", Icons.person),
              SizedBox(height: 10),
              _buildTextField(ageController, "Age", Icons.cake, inputType: TextInputType.number),
              SizedBox(height: 10),
              _buildTextField(phoneController, "Phone Number", Icons.phone, inputType: TextInputType.phone),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Save user details in Firestore
                await _firestore.collection('users').doc(uid).set({
                  'nickname': nicknameController.text,
                  'age': ageController.text,
                  'phone': phoneController.text,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Profile updated successfully!")),
                );

                // Redirect to Login Screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}