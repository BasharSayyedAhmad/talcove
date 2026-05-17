/// أسماء أحداث Socket.IO بين الـ Frontend والـ Backend
abstract class SocketEvents {
  // ============= أحداث الاتصال =============
  /// عندما ينجح الاتصال بالـ Socket
  static const String connect = 'connect';

  /// عندما يفقد الاتصال بالـ Socket
  static const String disconnect = 'disconnect';

  /// عندما يحاول إعادة الاتصال
  static const String reconnectAttempt = 'reconnect_attempt';

  /// عندما يعيد الاتصال بنجاح
  static const String reconnect = 'reconnect';

  // ============= أحداث الغرف والمستخدمين =============
  /// انضمام المستخدم لغرفته الخاصة (يُرسل بعد الاتصال)
  static const String join = 'join';

  /// خروج المستخدم (عند تسجيل الخروج)
  static const String leave = 'leave';

  /// مستخدم أصبح متصل (يصله الأصدقاء)
  static const String userOnline = 'user_online';

  /// مستخدم أصبح غير متصل
  static const String userOffline = 'user_offline';

  // ============= أحداث الرسائل =============
  /// إرسال رسالة جديدة (يُرسل من العميل)
  static const String sendMessage = 'send_message';

  /// استقبال رسالة جديدة (يصله من السيرفر)
  static const String newMessage = 'new_message';

  /// شخص يكتب... (Typing indicator)
  static const String typing = 'typing';

  /// شخص توقف عن الكتابة
  static const String stopTyping = 'stop_typing';

  // ============= أحداث قراءة الرسائل =============
  /// إشعار بقراءة الرسائل (Mark as read)
  static const String markAsRead = 'mark_as_read';

  /// إشعار بأن الرسائل قُرأت
  static const String messagesRead = 'messages_read';

  // ============= أحداث الأخطاء =============
  /// خطأ في الـ Socket
  static const String error = 'error';
}
