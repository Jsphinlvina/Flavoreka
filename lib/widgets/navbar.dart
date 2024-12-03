import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navbar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: "My Recipes",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Favorites",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: "Account",
        ),
      ],
    );
  }
}
