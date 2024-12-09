import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'CartUI.dart';
import 'HomeUI.dart';
import 'MainProfileUI.dart';
import 'app_colors.dart';
import 'package:badges/badges.dart' as badges;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<IconData> _iconList = [
    Icons.home, // Home Icon
    Icons.person, // Profile Icon
  ];

  // Get the corresponding page for the selected tab
  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return HomeUI();
      case 1:
        return profileUI(showBackButton: false);
      default:
        return HomeUI();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Extend the body behind the navigation bar
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: _getSelectedPage(_currentIndex), // Display selected page
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          // Navigate to Cart Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartUI()), // Replace with your Cart UI
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: Stack(
          clipBehavior: Clip.none, // Ensure the badge is not clipped
          children: [
            badges.Badge(
              child: Icon(Icons.shopping_cart, color: Colors.white, size: 24),
              position: badges.BadgePosition.topEnd(top: -15, end: -10),
              badgeContent: Text(
                '5', // Replace with dynamic count
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.black,
                elevation: 0, // Remove shadow
                padding: EdgeInsets.all(6),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // FAB centered and docked
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _iconList,
        activeIndex: _currentIndex, // Active tab index
        gapLocation: GapLocation.center, // FAB gap at the center
        notchSmoothness: NotchSmoothness.softEdge, // Smoothness of the notch
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        activeColor: AppColors.primaryColor, // Active icon color
        inactiveColor: Colors.grey, // Inactive icon color
        backgroundColor: Colors.white, // Background color of the bar
      ),
    );
  }
}

