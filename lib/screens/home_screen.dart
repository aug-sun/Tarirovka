import 'package:flutter/material.dart';
import 'work_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const WorkScreen(),
      const ProfileScreen(),
      SettingsScreen(onThemeChanged: widget.onThemeChanged),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.play_arrow_rounded), label: 'Рабочая'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Настройки'),
        ],
      ),
    );
  }
}
