// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordered_contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$totalUnreadMessagesHash() =>
    r'7387560d7e26a9494f91db35faaf217ae7e4a893';

/// See also [totalUnreadMessages].
@ProviderFor(totalUnreadMessages)
final totalUnreadMessagesProvider = AutoDisposeProvider<int>.internal(
  totalUnreadMessages,
  name: r'totalUnreadMessagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalUnreadMessagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalUnreadMessagesRef = AutoDisposeProviderRef<int>;
String _$orderedContactsNotifierHash() =>
    r'2497ae191abed95f0264ab478ecf6cfdf115e6af';

/// See also [OrderedContactsNotifier].
@ProviderFor(OrderedContactsNotifier)
final orderedContactsNotifierProvider =
    AutoDisposeNotifierProvider<
      OrderedContactsNotifier,
      List<ChatContact>
    >.internal(
      OrderedContactsNotifier.new,
      name: r'orderedContactsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderedContactsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderedContactsNotifier = AutoDisposeNotifier<List<ChatContact>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
