class Message {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;

  final bool isMe;
  final bool isEdited;
  final bool isSent;
  final bool isDelivered;
  final bool isRead;
  final int unreadCount;
  final String? replyToMessageId;
  final String? imageUrl;
  final String? voiceUrl;
  final int? voiceDuration;
  final bool isVoice;

  const Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.isMe,
    this.isEdited = false,
    this.isSent = false,
    this.isDelivered = false,
    this.isRead = false,
    this.unreadCount = 0,
    this.replyToMessageId,
    this.imageUrl,
    this.voiceUrl,
    this.voiceDuration,
    this.isVoice = false,
  });

  static String _extractId(dynamic field) {
    if (field == null) return '';
    if (field is Map) {
      return field['id']?.toString() ?? field['_id']?.toString() ?? '';
    }
    return field.toString();
  }

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderId = _extractId(json['senderId'] ?? json['sender']);
    final receiverId = _extractId(json['receiverId'] ?? json['receiver']);

    return Message(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      text: json['message'] ?? json['text'] ?? '',
      senderId: senderId,
      receiverId: receiverId,
      timestamp: DateTime.parse(
        json['createdAt'] ??
            json['timestamp'] ??
            DateTime.now().toIso8601String(),
      ),
      isMe: senderId == currentUserId,
      isEdited: json['isEdited'] ?? false,
      isSent: json['isSent'] ?? true,
      isDelivered: json['isDelivered'] ?? json['delivered'] ?? false,
      isRead: json['isRead'] ?? json['read'] ?? false,
      replyToMessageId: json['replyToMessageId'],
      imageUrl: json['imageUrl'],
      voiceUrl: json['voiceUrl'],
      voiceDuration: json['voiceDuration'],
      isVoice: json['isVoice'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
      'isEdited': isEdited,
      'isSent': isSent,
      'isDelivered': isDelivered,
      'isRead': isRead,
      'replyToMessageId': replyToMessageId,
      'imageUrl': imageUrl,
      'voiceUrl': voiceUrl,
      'voiceDuration': voiceDuration,
      'isVoice': isVoice,
    };
  }

  factory Message.fromSocket(Map<String, dynamic> json, String currentUserId) {
    String senderId = '';
    if (json['sender'] is Map) {
      senderId = json['sender']['id'] ?? json['sender']['_id'] ?? '';
    } else {
      senderId = json['senderId'] ?? json['sender'] ?? '';
    }

    String receiverId = '';
    if (json['receiver'] is Map) {
      receiverId = json['receiver']['id'] ?? json['receiver']['_id'] ?? '';
    } else {
      receiverId = json['receiverId'] ?? json['receiver'] ?? '';
    }

    final text = (json['message'] ?? json['text'] ?? '').toString();

    final id =
        (json['_id'] ??
                json['id'] ??
                'soc_${DateTime.now().microsecondsSinceEpoch}')
            .toString();

    return Message(
      id: id,
      text: text,
      senderId: senderId,
      receiverId: receiverId,
      isMe: senderId == currentUserId,
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isSent: true,
      isDelivered: json['delivered'] ?? false,
      isRead: json['read'] ?? false,
    );
  }

  Message copyWith({
    String? id,
    String? text,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
    bool? isMe,
    bool? isEdited,
    bool? isSent,
    bool? isDelivered,
    bool? isRead,
    int? unreadCount,
    String? replyToMessageId,
    String? imageUrl,
    String? voiceUrl,
    int? voiceDuration,
    bool? isVoice,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      isEdited: isEdited ?? this.isEdited,
      isSent: isSent ?? this.isSent,
      isDelivered: isDelivered ?? this.isDelivered,
      isRead: isRead ?? this.isRead,
      unreadCount: unreadCount ?? this.unreadCount,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      imageUrl: imageUrl ?? this.imageUrl,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      isVoice: isVoice ?? this.isVoice,
    );
  }
}
