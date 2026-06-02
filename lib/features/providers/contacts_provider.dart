import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/constants/app_settings_keys.dart';
import 'package:talcove/models/user.dart';
import 'package:talcove/shared/services/local_storage_service.dart';
part 'contacts_provider.g.dart';

@riverpod
class ContactsNotifier extends _$ContactsNotifier {
  @override
  List<User> build() {
    return _loadContactsFromHive();
  }

  List<User> _loadContactsFromHive() {
    try {
      final contactsData = LocalStorageService.box.get(contactsKey);
      if (contactsData != null && contactsData is List) {
        return contactsData.map((json) {
          return User.fromJson(Map<String, dynamic>.from(json));
        }).toList();
      }
      return [];
    } catch (e) {
      print("❌ Failed to load contacts: $e");
      return [];
    }
  }

  void _saveContactsToHive() {
    try {
      final contactsList = state.map((user) => user.toJson()).toList();
      LocalStorageService.box.put(contactsKey, contactsList);
      print(" Contacts saved: ${contactsList.length} contacts");
    } catch (e) {
      print(" Failed to save contacts: $e");
    }
  }

  void addContact(User user) {
    //ما بصير ينضاف المستخدم نفسو مرتين
    if (!state.any((contact) => contact.userName == user.userName)) {
      state = [...state, user];
      _saveContactsToHive(); // حفظ بعد الإضافة
      print(" Contact added: ${user.userName}");
    } else {
      print(" Contact already exists: ${user.userName}");
    }
  }

  void removeContact(String userId) {
    final removedUser = state.firstWhere((contact) => contact.id == userId);
    state = state.where((contact) => contact.id != userId).toList();
    _saveContactsToHive(); // حفظ بعد الحذف
    print(" Contact removed: ${removedUser.userName}");
  }

  void clearContacts() {
    state = [];
    _saveContactsToHive(); // حفظ بعد المسح
    print(" All contacts cleared");
  }
}
