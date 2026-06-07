// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatListNotifierHash() => r'e1a4d6846e21eeb858979ec1f5c990f5bccd4204';

/// يخزن آخر رسالة لكل محادثة: Map<contactId, Message>
/// منفصل عن messageNotifierProvider اللي للـ ChatScreen
///
/// Copied from [ChatListNotifier].
@ProviderFor(ChatListNotifier)
final chatListNotifierProvider =
    AutoDisposeNotifierProvider<
      ChatListNotifier,
      Map<String, Message>
    >.internal(
      ChatListNotifier.new,
      name: r'chatListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatListNotifier = AutoDisposeNotifier<Map<String, Message>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
