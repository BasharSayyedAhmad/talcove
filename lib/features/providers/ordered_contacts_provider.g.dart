// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordered_contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderedContactsNotifierHash() =>
    r'ef7b98c174b3845fbcf1152546df02399fd4ef9b';

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
