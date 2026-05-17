import 'package:flutter/material.dart';
import 'package:talcove/shared/widgets/custom_text.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(
          top: 50,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        children: [
          CustomText(
            controller: searchController,
            hintText: "Search conversations...",
            prefixIcon: const Icon(Icons.search),
          ),
          const SizedBox(height: 10),
          const Text("People", style: TextStyle(fontSize: 20)),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: const [
                CircleAvatar(child: Icon(Icons.add)),
                SizedBox(width: 10),
                CircleAvatar(),
                SizedBox(width: 10),
                CircleAvatar(),
                SizedBox(width: 10),
                CircleAvatar(),
                SizedBox(width: 10),
                CircleAvatar(),
                SizedBox(width: 10),
                CircleAvatar(),
                SizedBox(width: 10),
                CircleAvatar(),
                SizedBox(width: 10),
                CircleAvatar(),
                SizedBox(width: 10),
                CircleAvatar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
