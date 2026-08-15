import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talcove/features/people/search_screen.dart';
import 'package:talcove/features/people/user_profile_screen.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/generated/l10n.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تحديد ألوان الأيقونات والنصوص بناءً على الخلفية المتدرجة للـ AppBar (لتكون بيضاء دائماً كالشاشة السابقة)
    const appBarContentColor = Colors.white;

    return Scaffold(
      // التكيف مع الخلفية العامة للتطبيق في الوضعين الداكن والفاتح
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          S.of(context).people, // استخدام ملف الـ localization المتطابق
          style: const TextStyle(
            color: appBarContentColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // تطبيق نفس التدرج اللوني (Gradient) بحذافيره من الـ ChatListScreen
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: !isDark
                  ? [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ]
                  : const [
                      Color.fromARGB(255, 26, 35, 126),
                      Color.fromARGB(255, 57, 73, 171),
                    ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              icon: const Icon(
                CupertinoIcons.search,
                color: appBarContentColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: contacts.isEmpty
          ? _buildEmptyState(context, isDark)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Text(
                    "جميع جهات الاتصال (${contacts.length})",
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    itemCount: contacts.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: isDark ? Colors.white24 : Colors.grey.shade200,
                      indent: 70,
                    ),
                    itemBuilder: (context, index) {
                      final user = contacts[index];

                      final firstChar = user.userName.isNotEmpty
                          ? user.userName[0].toUpperCase()
                          : '?';

                      String? finalPhotoUrl = user.photoUrl;
                      if (finalPhotoUrl != null) {
                        if (finalPhotoUrl.startsWith('http://')) {
                          finalPhotoUrl = finalPhotoUrl.replaceFirst(
                            'http://',
                            'https://',
                          );
                        }
                      }

                      // تخصيص لون الـ Card بناءً على الـ Theme
                      return Card(
                        elevation: 0,
                        color: isDark
                            ? Theme.of(context).cardColor
                            : Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            radius: 25,
                            // استخدام لون الـ primary المخفف كخلفية بديلة للحرف الأول
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            backgroundImage: finalPhotoUrl?.isNotEmpty == true
                                ? NetworkImage(finalPhotoUrl!)
                                : null,
                            child: finalPhotoUrl?.isEmpty == true
                                ? Text(
                                    firstChar,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            user.userName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            user.status ??
                                user.bio ??
                                S.of(context).startAConversation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade500,
                            ),
                          ),
                          trailing: Icon(
                            CupertinoIcons.chevron_forward,
                            color: isDark
                                ? Colors.white30
                                : Colors.grey.shade400,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => UserProfileScreen(user: user),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    // لون الثيم الرئيسي للمساعدة في الحفاظ على التناسق داخل الـ Empty State
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.person_3,
                size: 70,
                color: isDark ? Colors.white70 : primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "لا توجد جهات اتصال بعد",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "ابدأ بالبحث عن أصدقائك وإضافتهم لبدء المحادثات الفورية المشفرة.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color.fromARGB(255, 57, 73, 171)
                    : primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              icon: const Icon(CupertinoIcons.search, size: 18),
              label: const Text(
                "ابحث عن أشخاص",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
