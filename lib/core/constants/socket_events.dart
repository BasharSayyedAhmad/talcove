abstract class SocketEvents {
  // ============= أحداث الاتصال =============
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String reconnectAttempt = 'reconnect_attempt';
  static const String reconnect = 'reconnect';
  // ============= أحداث الغرف والمستخدمين  لبعدين=============
  static const String join = 'join';
  static const String leave = 'leave';
  static const String userOnline = 'user_online';
  static const String userOffline = 'user_offline';

  // ============= أحداث الرسائل يلي موجودين حاليا=============
  static const String sendMessage = 'sendMessage';
  static const String messageSent = 'messageSent';
  static const String newMessage = 'newMessage';
  //================ احداث الكتابة لبعدين كمان ==================
  static const String typing = 'typing';
  static const String stopTyping = 'stop_typing';

  // ============= أحداث قراءة الرسائل لبعدين=============
  static const String markAsRead = 'mark_as_read';
  static const String messagesRead = 'messages_read';

  // ============= أحداث الأخطاء =============
  static const String error = 'error';
}
