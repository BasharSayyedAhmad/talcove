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
    this.replyToMessageId,
    this.imageUrl,
    this.voiceUrl,
    this.voiceDuration,
    this.isVoice = false,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Message(
      id: json['_id'] ?? json['id'],
      text: json['message'] ?? json['text'] ?? '',
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      timestamp: DateTime.parse(json['createdAt'] ?? json['timestamp']),
      isMe: json['senderId'] == currentUserId,
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
    final senderId =
        json['senderId'] ?? json['senderUserName']?.toString() ?? '';
    final receiverId =
        json['receiverId'] ?? json['receiverUserName']?.toString() ?? '';

    return Message(
      id:
          json['_id'] ??
          json['id'] ??
          "srv_${DateTime.now().microsecondsSinceEpoch}",
      text: json['message'] ?? '',
      senderId: senderId,
      receiverId: receiverId,
      isMe: senderId == currentUserId,
      timestamp: DateTime.parse(json['createdAt']),
      isSent: true,
      isDelivered: json['delivered'] ?? false,
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
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      imageUrl: imageUrl ?? this.imageUrl,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      isVoice: isVoice ?? this.isVoice,
    );
  }
}
