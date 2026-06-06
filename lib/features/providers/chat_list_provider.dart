import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/models/message.dart';

part 'chat_list_provider.g.dart';

@riverpod
class ChatListNotifier extends _$ChatListNotifier {
  final ApiService _apiService = ApiService();
  String? _currentUserId;
  bool _isFetching = false;

  @override
  Map<String, Message> build() => {};

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  bool get isFetching => _isFetching;

  Future<void> fetchLastMessages(List<String> contactIds) async {
    if (contactIds.isEmpty || _currentUserId == null) return;
    if (_isFetching) return;

    _isFetching = true;

    try {
      final futures = contactIds.map((contactId) async {
        try {
          final response = await _apiService.dio.get(
            "/api/v1/messages/$contactId/?limit=1&page=1",
          );
          if (response.statusCode == 200) {
            final List<dynamic> data = response.data['data']['messages'];
            if (data.isNotEmpty) {
              final json = data.first;
              return MapEntry(
                contactId,
                Message(
                  id: json['_id'],
                  text: json['message'] ?? "",
                  senderId: json['senderId'],
                  receiverId: json['receiverId'],
                  isMe: json['senderId'] == _currentUserId,
                  timestamp: DateTime.parse(json['createdAt']),
                  isSent: true,
                  isDelivered: json['delivered'] ?? false,
                  isRead: json['read'] ?? false,
                ),
              );
            }
          }
        } catch (e) {
          print(" Error fetching for $contactId: $e");
        }
        return null;
      }).toList();

      final results = await Future.wait(futures);

      final newMap = Map<String, Message>.from(state);
      for (final entry in results) {
        if (entry != null) {
          newMap[entry.key] = entry.value;
        }
      }
      state = newMap;
    } finally {
      _isFetching = false;
    }
  }

  void updateLastMessage({
    required String contactId,
    required Message message,
  }) {
    state = {...state, contactId: message};
  }
}
