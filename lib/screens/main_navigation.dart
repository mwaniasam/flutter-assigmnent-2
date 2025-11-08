import 'package:flutter/material.dart';
import 'package:bookswap_app/widgets/custom_bottom_nav_bar.dart';
import 'package:bookswap_app/screens/home_screen.dart';
import 'package:bookswap_app/screens/my_listings_screen.dart';
import 'package:bookswap_app/screens/my_offers_screen.dart';
import 'package:bookswap_app/screens/chats_screen.dart';
import 'package:bookswap_app/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MyListingsScreen(),
    MyOffersScreen(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
