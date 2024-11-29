import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  final bool isMusicPlaying;
  final Function(bool) toggleMusic;

  const SettingsPage({
    super.key,
    required this.toggleMusic,
    required this.isMusicPlaying,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isSoundOn = true;
  late bool isMusicOn;

  @override
  void initState() {
    super.initState();
    isMusicOn = widget.isMusicPlaying; // Set initial state of music based on input
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color.fromARGB(255, 158, 218, 232),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 142, 203, 231), // Light blue
              Color(0xFFE1F5FE), // Very light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsCard(
                title: "Sound",
                value: isSoundOn,
                onChanged: (bool value) {
                  setState(() {
                    isSoundOn = value;
                  });
                },
                icon: isSoundOn ? Icons.volume_up : Icons.volume_off,
                iconColor: isSoundOn ? Colors.green : Colors.red,
              ),
              const Divider(color: Colors.white54),
              _buildSettingsCard(
                title: "Music",
                value: isMusicOn,
                onChanged: (bool value) {
                  setState(() {
                    isMusicOn = value;
                    widget.toggleMusic(isMusicOn); // Call toggleMusic function to start/stop music
                  });
                },
                icon: isMusicOn ? FontAwesomeIcons.music : Icons.music_off,
                iconColor: isMusicOn ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: iconColor,
        ),
      ),
    );
  }
}