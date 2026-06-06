import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/chat/chat_screen.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/features/providers/search_provider.dart';
import 'package:talcove/generated/l10n.dart';
import 'package:talcove/models/search_state.dart';
import 'package:talcove/shared/widgets/app_snackbar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final searchNotifier = ref.read(searchNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).searchUsers)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: S.of(context).searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          searchNotifier.clearResults();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              onSubmitted: (query) => searchNotifier.search(query),
              onChanged: (query) {
                if (query.isEmpty) {
                  searchNotifier.clearResults();
                }
              },
            ),
          ),
          Expanded(child: _buildBody(searchState, searchNotifier, context)),
        ],
      ),
    );
  }

  Widget _buildBody(
    SearchState state,
    SearchNotifier notifier,
    BuildContext context,
  ) {
    // حالة التحميل
    if (state.isLoading) {
      return Center(
        child: Transform.scale(
          scale: 2,
          child: const CupertinoActivityIndicator(),
        ),
      );
    }

    // حالة الخطأ
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(S.of(context).errorOccurred(state.errorMessage!)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                notifier.clearError();
                if (_searchController.text.isNotEmpty) {
                  notifier.search(_searchController.text);
                }
              },
              child: Text(S.of(context).retry),
            ),
          ],
        ),
      );
    }

    // لا توجد نتائج
    if (state.results.isEmpty && state.query.isNotEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(S.of(context).noResultsFound),
            const SizedBox(height: 8),
            Text(S.of(context).tryDifferentKeyword),
          ],
        ),
      );
    }

    // حالة البحث الأولي (لم يتم البحث بعد)
    if (state.query.isEmpty && state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              S.of(context).searchForUsers,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).enterUsernameToSearch,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // عرض النتائج
    return ListView.builder(
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final user = state.results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            user.userName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: user.email != null && user.email!.isNotEmpty
              ? Text(
                  user.email!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                )
              : null,
          trailing: const SizedBox(
            width: 40,
            child: Icon(Icons.chat_bubble_outline, color: Colors.blue),
          ),
          onTap: () {
            print(
              " BEFORE ADD - Current contacts: ${ref.read(contactsNotifierProvider).length}",
            );
            print(" Adding: ${user.userName} (ID: ${user.id})");
            ref.read(contactsNotifierProvider.notifier).addContact(user);
            print(
              " AFTER ADD - Contacts: ${ref.read(contactsNotifierProvider).length}",
            );
            print(
              "Contacts list: ${ref.read(contactsNotifierProvider).map((u) => u.userName).toList()}",
            );
            AppSnackBar.show(
              context,
              message: "${user.userName} added to your contacts",
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: "",
                  otherUserId: user.id,
                  otherUserName: user.userName,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
