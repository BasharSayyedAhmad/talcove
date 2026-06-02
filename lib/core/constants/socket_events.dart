/// أسماء أحداث Socket.IO بين الـ Frontend والـ Backend
abstract class SocketEvents {
  // ============= أحداث الاتصال =============
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String reconnectAttempt = 'reconnect_attempt';
  static const String reconnect = 'reconnect';
  // ============= أحداث الغرف والمستخدمين =============
  static const String join = 'join';
  static const String leave = 'leave';
  static const String userOnline = 'user_online';
  static const String userOffline = 'user_offline';

  // ============= أحداث الرسائل =============
  static const String sendMessage = 'sendMessage';
  static const String messageSent = 'messageSent';
  static const String newMessage = 'newMessage';

  static const String typing = 'typing';
  static const String stopTyping = 'stop_typing';

  // ============= أحداث قراءة الرسائل =============
  static const String markAsRead = 'mark_as_read';
  static const String messagesRead = 'messages_read';

  // ============= أحداث الأخطاء =============
  static const String error = 'error';
}
