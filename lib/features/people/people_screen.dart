import 'package:flutter/material.dart';
import 'package:talcove/features/people/search_screen.dart';

//ابو كلب بدا تعديل
class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const Center(child: Text("HI")),
    );
  }
}
