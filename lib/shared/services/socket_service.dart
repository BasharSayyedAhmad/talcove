import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:talcove/core/constants/api_constants.dart';
import 'package:talcove/core/constants/socket_events.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  late IO.Socket _socket;
  bool _isConnected = false;
  String? _currentUserId;
  final List<void Function(Map<String, dynamic>)> _messageSentCallbacks = [];
  final List<void Function(Map<String, dynamic>)> _newMessageCallbacks = [];
  void connect(String token) {
    print(" Connecting to socket with token: ${token.substring(0, 20)}...");
    if (_isConnected) {
      print(" Already connected, skipping...");
      return;
    }
    // _currentUserId = userId;
    _socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .build(),
    );
    _socket.on(SocketEvents.connect, (_) {
      print("Socket connected");
      _isConnected = true;
    });
    _socket.on(SocketEvents.disconnect, (_) {
      print("Socket disconnected");
      _isConnected = false;
    });
    _socket.on(SocketEvents.error, (error) {
      print("Error happened $error");
    });

    _socket.on(SocketEvents.messageSent, (data) {
      print("Message sent $data");
      for (var callback in _messageSentCallbacks) {
        callback(data);
      }
    });
    _socket.on(SocketEvents.newMessage, (data) {
      print("new message received $data");
      for (var callback in _newMessageCallbacks) {
        callback(data);
      }
    });
    _socket.onAny((event, data) {
      print("⚡ ALL EVENT: $event, data: $data");
    });
  }

  void sendMessage(String message, String receiverId) {
    print("📤 Sending message: '$message' to $receiverId");
    print("🔌 Socket connected: $_isConnected");
    if (!_isConnected) {
      print("Failed to send message");
      return;
    }
    _socket.emit(SocketEvents.sendMessage, {
      'message': message,
      'receiverUserName': receiverId,
    });
  }

  void onMessageSent(void Function(Map<String, dynamic>) callback) {
    print("on Message sent");
    _messageSentCallbacks.add(callback);
  }

  void onNewMessage(void Function(Map<String, dynamic>) callback) {
    print("On new message");
    _newMessageCallbacks.add(callback);
  }

  void disconnect() {
    try {
      if (_socket.connected) {
        _socket.disconnect();
        _socket.dispose();
      }
    } catch (e) {
      print(" Socket already disposed or not initialized: $e");
    }
    _isConnected = false;
    _currentUserId = null;
    _messageSentCallbacks.clear();
    _newMessageCallbacks.clear();
  }

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;
}
