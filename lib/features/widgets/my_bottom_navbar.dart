import 'package:flutter/material.dart';
import 'package:talcove/generated/l10n.dart';

class MyBottomNavBar extends StatelessWidget {
  const MyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onTap,
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble),
          label: S.of(context).chats,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: S.of(context).people,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.group_add),
          label: S.of(context).groups,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: S.of(context).settings,
        ),
      ],
    );
  }
}
