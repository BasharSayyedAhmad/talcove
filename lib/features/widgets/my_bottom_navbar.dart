import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/providers/ordered_contacts_provider.dart';
import 'package:talcove/generated/l10n.dart';

class MyBottomNavBar extends ConsumerWidget {
  const MyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUnread = ref.watch(totalUnreadMessagesProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: BottomNavigationBar(
            onTap: onTap,
            currentIndex: selectedIndex,
            items: [
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: totalUnread > 0,
                  label: Text('$totalUnread'),
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                ),
                activeIcon: Badge(
                  isLabelVisible: totalUnread > 0,
                  label: Text('$totalUnread'),
                  child: const Icon(Icons.chat_bubble_rounded),
                ),
                label: S.of(context).chats,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline_rounded),
                activeIcon: const Icon(Icons.people_rounded),
                label: S.of(context).people,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings_rounded),
                label: S.of(context).settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
