import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.15),
          ),
        ],
      ),
      child: GNav(
        gap: 8,
        activeColor: Colors.black,
        color: Colors.black,
        backgroundColor: Colors.white,
        tabActiveBorder: Border.all(color: Colors.black, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        tabs: const [
          GButton(
            icon: Icons.home_rounded,
            text: 'Dashboard',
          ),
          GButton(
            icon: Icons.book_rounded,
            text: 'Records',
          ),
          GButton(
            icon: Icons.info_rounded,
            text: 'Information',
          ),
        ],
        selectedIndex: selectedIndex,
        onTabChange: onTabChange,
      ),
    );
  }
}
