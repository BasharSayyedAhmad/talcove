import 'package:flutter/material.dart';

class Message {
  final String id;
  // final String chatId;
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
    // required this.chatId,
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

  factory Message.fromSocket(Map<String, dynamic> json, String currentUserId) {
    final senderId = json['senderUserName'].toString();
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      // chatId: "", // سيتم تعيينه لاحقاً
      text: json['message'],
      senderId: senderId,
      receiverId: json['receiverUserName'].toString(),
      isMe: senderId == currentUserId,
      timestamp: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toSendJson() {
    return {'message': text, 'receiverUserName': receiverId};
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      // chatId: json['chatId'] ?? '',
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
      image: null, // الصورة لا تُخزن في Hive، ستُعاد تحميلها لاحقاً
      voiceUrl: json['voiceUrl'],
      voiceDuration: json['voiceDuration'],
      isVoice: json['isVoice'] ?? false,
    );
  }

  // ✅ toJson لحفظ البيانات في Hive
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // 'chatId': chatId,
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
      // chatId: chatId ?? this.chatId,
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
