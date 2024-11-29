import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:games/firebase/user/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:games/screens/login/loginscreen.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  String nickname = "User";
  String profileImageUrl = '';
  String gender = "Male";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  

  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userData.exists && userData.data() != null) {
          UserModel userModel = UserModel.fromMap(userData.data()!);
          setState(() {
            nickname = userModel.nickname;
            profileImageUrl = userData.data()?['profileImageUrl'] ?? '';
            gender = userData.data()?['gender'] ?? 'Male';
          });
        } else {
          setState(() {
            nickname = "User";
            profileImageUrl = '';
          });
        }
      } catch (e) {
        debugPrint("Error fetching user data: ${e.toString()}");
      }
    }
  }

  Future<void> _updateGender(String newGender) async {
  if (user != null) {
    try {
      // Update gender in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'gender': newGender,
      });

      // Update the UI
      setState(() {
        gender = newGender;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gender updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating gender: ${e.toString()}")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No user is logged in.")),
    );
  }
}

  Future<int> _fetchStreakCount() async {
    if (user == null) return 0;
    try {
      final streaksCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('streaks');
      final querySnapshot = await streaksCollection.where('isMarked', isEqualTo: true).get();
      return querySnapshot.size;
    } catch (e) {
      debugPrint('Error fetching streak count: $e');
      return 0;
    }
  }

  Future<int> _fetchTotalSpins() async {
    if (user == null) return 0;
    try {
      final spinsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('spins');
      final querySnapshot = await spinsCollection.get();
      return querySnapshot.size;
    } catch (e) {
      debugPrint('Error fetching spins count: $e');
      return 0;
    }
  }

  Future<void> _sendSupportEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@app.com',
      query: 'subject=Support Request&body=Describe your issue here.',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open email app.")),
      );
    }
  }

  void _navigateToAboutUs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutUsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color.fromARGB(255, 162, 225, 242),
        centerTitle: true,
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             Stack(
  alignment: Alignment.bottomRight,
  children: [
    CircleAvatar(
      radius: 60,
      backgroundImage: _pickedImage != null
          ? FileImage(_pickedImage!)
          : (profileImageUrl.isNotEmpty
              ? NetworkImage(profileImageUrl)
              : AssetImage(
                  gender == "Male"
                      ? 'assets/male_avatar.png'
                      : 'assets/girl_avatar.png')) as ImageProvider,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    ),
    IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue, size: 24),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Edit Profile"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Select Gender:"),
                  DropdownButton<String>(
                    value: gender,
                    items: <String>["Male", "Female"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _updateGender(newValue);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  ],
),
              const SizedBox(height: 15),
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),

              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('points').doc(user?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final int totalPoints = snapshot.data?.data()?['totalPoints'] ?? 0;
                  return ProfileItem(
                    
                    icon: Icons.star,
                    iconColor: Colors.yellow,
                    title: "Points",
                    value: "$totalPoints",
                  );
                },
              ),
              StreamBuilder<int>(
                stream: Stream.fromFuture(_fetchStreakCount()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final streakCount = snapshot.data ?? 0;
                  return ProfileItem(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    title: "Streak",
                    value: "$streakCount days",
                  );
                },
              ),
              StreamBuilder<int>(
                stream: Stream.fromFuture(_fetchTotalSpins()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final totalSpins = snapshot.data ?? 0;
                  return ProfileItem(
                    icon: FontAwesomeIcons.spinner,
                    iconColor: Colors.blue,
                    title: "Spins",
                    value: "$totalSpins",
                  );
                },
              ),

              // About Us List Item
            Card(
  margin: const EdgeInsets.symmetric(vertical: 10),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 5,
  child: ListTile(
    leading: const Icon(Icons.info, color: Colors.teal),
    title: const Text('About Us'),
    subtitle: const Text('Learn more about our app and features.'),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: _navigateToAboutUs,
  ),
),

              // Support Section
             
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((_) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.redAccent,
                  elevation: 5,
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Us Title
              const Text(
                "About Us",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // About the app
              const Text(
                "This app is designed to help you track progress, complete tasks, and unlock challenges while earning points.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Game Types Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.videogame_asset, color: Colors.purple),
                  title: const Text(
                    'Game Types',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Engage in multiple games like puzzles, challenges, and learning activities.',
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Levels Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.orange),
                  title: const Text(
                    'Levels',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Progress through Easy, Medium, and Hard levels to test your skills.',
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Streaks Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.local_fire_department, color: Colors.red),
                  title: const Text(
                    'Streaks',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Maintain daily streaks to unlock special rewards and boost your progress.',
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Spins Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.casino, color: Colors.green),
                  title: const Text(
                    'Spins',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Use your earned points to spin the wheel and win exciting rewards.',
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Points System Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.yellow),
                  title: const Text(
                    'Points System',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Earn points by completing tasks, challenges, and maintaining streaks.',
                  ),
                ),
              ),
              const Spacer(),

              // Support Card
            
            ],
          ),
        ),
      ),
    );
  }
}