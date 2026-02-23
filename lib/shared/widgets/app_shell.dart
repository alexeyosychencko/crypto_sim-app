import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/lobby/screens/lobby_screen.dart';
import '../../features/trading/screens/trading_screen.dart';
import '../../features/academy/screens/academy_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../providers/navigation_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);

    final screens = const [
      LobbyScreen(),
      TradingScreen(),
      AcademyScreen(),
      ProfileScreen(),
    ];

    final titles = const ['Lobby', 'Trading', 'Academy', 'Profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).setIndex(index);
        },
        type: BottomNavigationBarType.fixed, // Needed for >3 items
        selectedItemColor: const Color(0xFFFFD700), // Gold
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black, // Dark background
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Lobby'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart,
            ), // Using bar_chart as requested alternative
            label: 'Trading',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Academy'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
