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
        final contacts = contactsData.map((json) {
          return User.fromJson(Map<String, dynamic>.from(json));
        }).toList();

        for (var c in contacts) {
          print(" Loaded: ${c.userName} -> ID: '${c.id}'");
        }
        return contacts;
      }
      return [];
    } catch (e) {
      print(" Failed to load contacts: $e");
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
    print(" Adding contact: ${user.userName} with ID: '${user.id}'");

    final existingIndex = state.indexWhere(
      (contact) => contact.userName == user.userName,
    );

    if (existingIndex != -1) {
      final existing = state[existingIndex];

      if (existing.id.isEmpty && user.id.isNotEmpty) {
        print(" Updating existing contact with ID: ${user.id}");
        final updatedUser = existing.copyWith(id: user.id);
        state = [
          ...state.sublist(0, existingIndex),
          updatedUser,
          ...state.sublist(existingIndex + 1),
        ];
        _saveContactsToHive();
      } else {
        print(" Contact already exists: ${user.userName}");
      }
      return;
    }

    // إضافة contact جديد
    state = [...state, user];
    _saveContactsToHive();
    print(" Contact added: ${user.userName} (ID: ${user.id})");
  }

  void updateContactId(String userName, String newId) {
    final index = state.indexWhere((contact) => contact.userName == userName);

    if (index != -1 && state[index].id.isEmpty && newId.isNotEmpty) {
      final updatedUser = state[index].copyWith(id: newId);
      state = [
        ...state.sublist(0, index),
        updatedUser,
        ...state.sublist(index + 1),
      ];
      _saveContactsToHive();
      print(" Updated contact $userName with ID: $newId");
    }
  }

  void removeContact(String userId) {
    final removedUser = state.firstWhere((contact) => contact.id == userId);
    state = state.where((contact) => contact.id != userId).toList();
    _saveContactsToHive();
    print(" Contact removed: ${removedUser.userName}");
  }

  void clearContacts() {
    state = [];
    _saveContactsToHive();
    print(" All contacts cleared");
  }

  User? getContactById(String userId) {
    try {
      return state.firstWhere((contact) => contact.id == userId);
    } catch (_) {
      return null;
    }
  }
}
