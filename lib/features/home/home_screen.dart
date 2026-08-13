import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/chat/chat_list_screen.dart';
import 'package:talcove/features/people/people_screen.dart';
import 'package:talcove/features/providers/internet_monitor_provider.dart';
import 'package:talcove/features/settings/settings_screen.dart';
import 'package:talcove/features/widgets/my_bottom_navbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    ref.watch(internetMonitorProvider);
    return Scaffold(
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (val) {
          setState(() {
            _selectedIndex = val;
          });
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ChatListScreen(),
          PeopleScreen(),
          // GroupsScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }
}
