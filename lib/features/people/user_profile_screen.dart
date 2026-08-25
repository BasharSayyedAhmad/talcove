import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:talcove/features/chat/chat_screen.dart';
import 'package:talcove/features/providers/contacts_provider.dart';
import 'package:talcove/models/user.dart';
import 'package:talcove/shared/widgets/app_snackbar.dart';

class UserProfileScreen extends ConsumerWidget {
  final User user;

  const UserProfileScreen({super.key, required this.user});

  String _formatLastSeen(DateTime? lastSeenDate) {
    if (lastSeenDate == null) return "غير نشط مؤخراً";
    try {
      final localDateTime = lastSeenDate.toLocal();
      return DateFormat('yyyy/MM/dd - hh:mm a').format(localDateTime);
    } catch (_) {
      return "غير نشط مؤخراً";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsNotifierProvider);
    final isAlreadyContact = contacts.any((c) => c.id == user.id);

    // final cleanUserName = user.userName.trim();

    return Scaffold(
      appBar: AppBar(title: const Text("الملف الشخصي"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Container(
                      width: 120,
                      height: 120,
                      color: Colors.blue.shade50,
                      child: () {
                        String? rawUrl = user.photoUrl;

                        debugPrint("📸 [UI DEBUG] User: ${user.userName}");
                        debugPrint("📸 [UI DEBUG] rawUrl value is: '$rawUrl'");

                        if (rawUrl != null && rawUrl.isNotEmpty) {
                          if (rawUrl.startsWith('http://')) {
                            rawUrl = rawUrl.replaceFirst('http://', 'https://');
                          }

                          debugPrint(
                            "📸 [UI DEBUG] Attempting to load modified URL: '$rawUrl'",
                          );

                          return Image.network(
                            rawUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                "🚨 [UI DEBUG] ERROR loading image: $error",
                              );
                              return Center(
                                child: Text(
                                  user.userName.isNotEmpty
                                      ? user.userName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 48,
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        debugPrint(
                          "📸 [UI DEBUG] rawUrl is NULL or EMPTY! Showing fallback character.",
                        );
                        return Center(
                          child: Text(
                            user.userName.isNotEmpty
                                ? user.userName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 48,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }(),
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.green, // مؤشر الحالة
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              user.userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            if (user.lastSeen != null) ...[
              const SizedBox(height: 6),
              Text(
                "آخر ظهور: ${_formatLastSeen(user.lastSeen)}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        title: "الاسم الكامل",
                        value: (user.firstName != null || user.lastName != null)
                            ? "${user.firstName ?? ''} ${user.lastName ?? ''}"
                                  .trim()
                            : "لم يحدد بعد",
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        title: "البريد الإلكتروني",
                        value: user.email != null && user.email!.isNotEmpty
                            ? user.email!
                            : "غير متوفر",
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.phone_android_outlined,
                        title: "رقم الهاتف",
                        value:
                            user.phoneNumber != null &&
                                user.phoneNumber!.isNotEmpty
                            ? user.phoneNumber!
                            : "غير متوفر",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (!isAlreadyContact)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(contactsNotifierProvider.notifier)
                              .addContact(user);
                          AppSnackBar.show(
                            context,
                            message:
                                "تم إضافة ${user.userName} لجهات الاتصال بنجاح",
                          );
                        },
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text(
                          "إضافة لجهات الاتصال",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "هذا المستخدم موجود في جهات اتصالك",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (!isAlreadyContact) {
                          ref
                              .read(contactsNotifierProvider.notifier)
                              .addContact(user);
                        }

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
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text(
                        "بدء محادثة فورية",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
