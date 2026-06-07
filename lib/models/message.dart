import 'dart:ui';

class Message {
  final String id;
  // final String chatId; // ✅ أضف هذا
  final String text;
  final String senderId;
  final String receiverId;
  final bool isEdited;
  final bool isMe;
  final Message? replyTo;
  final String? imageUrl;
  final Image? image;
  final DateTime timestamp;
  final String? voiceUrl;
  final int? voiceDuration;
  final bool isVoice;
  final bool isSent;
  final bool isDelivered;
  final bool isRead;

  const Message({
    required this.id,
    // required this.chatId, // ✅ أضف هذا
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.isMe,
    this.isEdited = false,
    this.replyTo,
    this.imageUrl,
    this.image,
    required this.timestamp,
    this.voiceUrl,
    this.voiceDuration,
    this.isVoice = false,
    this.isSent = false,
    this.isDelivered = false,
    this.isRead = false,
  });

  // ✅ دالة مساعدة لتوليد chatId
  static String generateChatId(String userId1, String userId2) {
    // رتب الأرقام عشان تكون المحادثة نفسها للطرفين
    final ids = [userId1, userId2]..sort();
    return "${ids[0]}_${ids[1]}";
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      // chatId: json['chatId'] ?? '', // ✅ أضف هذا
      text: json['text'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      isMe: json['isMe'],
      isEdited: json['isEdited'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      isSent: json['isSent'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      isRead: json['isRead'] ?? false,
      replyTo: json['replyTo'] != null
          ? Message.fromJson(Map<String, dynamic>.from(json['replyTo']))
          : null,
      imageUrl: json['imageUrl'],
      image: null,
      voiceUrl: json['voiceUrl'],
      voiceDuration: json['voiceDuration'],
      isVoice: json['isVoice'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // 'chatId': chatId, // ✅ أضف هذا
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'isMe': isMe,
      'isEdited': isEdited,
      'timestamp': timestamp.toIso8601String(),
      'isSent': isSent,
      'isDelivered': isDelivered,
      'isRead': isRead,
      'replyTo': replyTo?.toJson(),
      'imageUrl': imageUrl,
      'voiceUrl': voiceUrl,
      'voiceDuration': voiceDuration,
      'isVoice': isVoice,
    };
  }

  factory Message.fromSocket(
    Map<String, dynamic> json,
    String currentUserId,
    String chatId,
  ) {
    final senderId = json['senderId'] ?? json['senderUserName'].toString();
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      // chatId: chatId, // ✅ أضف chatId من الخارج
      text: json['message'],
      senderId: senderId,
      receiverId: json['receiverId'] ?? json['receiverUserName'].toString(),
      isMe: senderId == currentUserId,
      timestamp: DateTime.parse(json['createdAt']),
      isSent: true,
      isDelivered: json['delivered'] ?? false,
    );
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? text,
    String? senderId,
    String? receiverId,
    bool? isEdited,
    bool? isMe,
    Message? replyTo,
    String? imageUrl,
    Image? image,
    DateTime? timestamp,
    String? voiceUrl,
    int? voiceDuration,
    bool? isVoice,
    bool? isSent,
    bool? isDelivered,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      // chatId: chatId ?? this.chatId, // ✅ أضف هذا
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      isMe: isMe ?? this.isMe,
      isEdited: isEdited ?? this.isEdited,
      replyTo: replyTo ?? this.replyTo,
      imageUrl: imageUrl ?? this.imageUrl,
      image: image ?? this.image,
      timestamp: timestamp ?? this.timestamp,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      isVoice: isVoice ?? this.isVoice,
      isSent: isSent ?? this.isSent,
      isDelivered: isDelivered ?? this.isDelivered,
      isRead: isRead ?? this.isRead,
    );
  }
}
