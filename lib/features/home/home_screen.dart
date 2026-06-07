import 'package:flutter/material.dart';
import 'package:talcove/features/chat/chat_list_screen.dart';
import 'package:talcove/features/groups/groups_screen.dart';
import 'package:talcove/features/people/people_screen.dart';
import 'package:talcove/features/settings/settings_screen.dart';
import 'package:talcove/features/widgets/my_bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
          GroupsScreen(),
          SettingsScreen(),
        ],
      ),
    );
  }
}
