import 'package:flutter/material.dart';
import 'package:games/pages/reward.dart';
import 'package:games/spin/spin.dart';
import 'package:games/streak/streak.dart';
class CustomBottomNavBar extends StatelessWidget {
  
  final String userId;

  const CustomBottomNavBar({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(178, 150, 215, 230),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(168, 85, 237, 242),
            blurRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.local_fire_department,
            label: 'Streak',
            iconColor: const Color.fromARGB(255, 255, 157, 9),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreakPage(userId: userId),
                ),
              );
            },
          ),
          _BottomNavItem(
            icon: Icons.casino,
            label: 'Spin',
            iconColor: const Color.fromARGB(255, 255, 62, 62),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpinWheelPage(userId: userId),
                ),
              );
            },
          ),
          _BottomNavItem(
            icon: Icons.card_giftcard,
            label: 'Reward',
            iconColor: const Color.fromARGB(255, 190, 12, 255),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RewardPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: iconColor.withOpacity(0.05),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 42,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}