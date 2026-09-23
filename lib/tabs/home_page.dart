import 'package:flutter/material.dart';

import 'learn_page.dart';
import 'practice_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    LearnPage(),
    PracticePage(),
    LearnPage(),
    LearnPage(),
    LearnPage(),
  ];

  void changeTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget navItem({required String asset, required int index}) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => changeTab(index),
      child: Opacity(
        opacity: isSelected ? 1 : 0.45,
        child: Image.asset(asset, height: 34),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),

      body: pages[selectedIndex],

      bottomNavigationBar: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF20272B),
          border: Border(
            top: BorderSide(color: Color.fromARGB(40, 255, 255, 255)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            navItem(asset: 'assets/icons/home.png', index: 0),
            navItem(asset: 'assets/icons/dumbell.png', index: 1),
            navItem(asset: 'assets/icons/leaderboard.png', index: 2),
            navItem(asset: 'assets/icons/quests.png', index: 3),
            navItem(asset: 'assets/icons/profile.png', index: 4),
          ],
        ),
      ),
    );
  }
}
