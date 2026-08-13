// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:talcove/core/constants/api_constants.dart';
// import 'package:talcove/core/constants/socket_events.dart';

// class SocketService {
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;
//   SocketService._internal();
//   late IO.Socket _socket;
//   bool _isConnected = false;
//   String? _currentUserId;
//   String? _lastToken;
//   String? _lastUserId;
//   final List<void Function(Map<String, dynamic>)> _messageSentCallbacks = [];
//   final List<void Function(Map<String, dynamic>)> _newMessageCallbacks = [];
//   void connect(String token, String userId) {
//     _lastToken = token;
//     _lastUserId = userId;
//     print(" Connecting to socket with token: ${token.substring(0, 20)}...");
//     if (_isConnected) {
//       print(" Already connected, skipping...");
//       return;
//     }
//     _currentUserId = userId;
//     _socket = IO.io(
//       ApiConstants.baseUrl,
//       IO.OptionBuilder()
//           .setTransports(['websocket'])
//           .setQuery({'token': token})
//           .enableReconnection()
//           .setReconnectionAttempts(5)
//           .build(),
//     );
//     _socket.on(SocketEvents.connect, (_) {
//       print("Socket connected");
//       _isConnected = true;

//       if (_currentUserId != null) {
//         _socket.emit('join', {'userId': _currentUserId});
//         print(" Joined with userId: $_currentUserId");
//       }
//     });
//     _socket.on(SocketEvents.disconnect, (_) {
//       print("Socket disconnected");
//       _isConnected = false;
//     });
//     _socket.on(SocketEvents.error, (error) {
//       print("Error happened $error");
//     });

//     _socket.on(SocketEvents.messageSent, (data) {
//       print("Message sent $data");
//       for (var callback in _messageSentCallbacks) {
//         callback(data);
//       }
//     });
//     _socket.on(SocketEvents.newMessage, (data) {
//       print("new message received $data");
//       for (var callback in _newMessageCallbacks) {
//         callback(data);
//       }
//     });
//     _socket.onAny((event, data) {
//       print("⚡ ALL EVENT: $event, data: $data");
//     });
//   }

//   void reconnect() {
//     if (_lastToken != null && _lastUserId != null) {
//       connect(_lastToken!, _lastUserId!);
//     }
//   }

//   void sendMessage(String message, String receiverId) {
//     print(" Sending message: '$message' to '$receiverId'");
//     print("receiverId length: ${receiverId.length}");
//     print("receiverId is empty: ${receiverId.isEmpty}");
//     print("Sending message: '$message' to $receiverId");
//     print(" Socket connected: $_isConnected");

//     if (!_isConnected) {
//       print("Failed to send message");
//       return;
//     }
//     _socket.emit(SocketEvents.sendMessage, {
//       'message': message,
//       'receiverId': receiverId,
//     });
//   }

//   void onMessageSent(void Function(Map<String, dynamic>) callback) {
//     print("on Message sent");
//     _messageSentCallbacks.clear();
//     _messageSentCallbacks.add(callback);
//   }

//   void onNewMessage(void Function(Map<String, dynamic>) callback) {
//     print("On new message");
//     _newMessageCallbacks.clear();
//     _newMessageCallbacks.add(callback);
//   }

//   void offNewMessage(void Function(dynamic p1) onNewMessageHandler) {
//     _newMessageCallbacks.clear();
//   }

//   void offMessageSent(void Function(dynamic p1) onMessageSentHandler) {
//     _messageSentCallbacks.clear();
//   }

//   void disconnect() {
//     try {
//       if (_socket.connected) {
//         _socket.disconnect();
//         _socket.dispose();
//       }
//     } catch (e) {
//       print(" Socket already disposed or not initialized: $e");
//     }
//     _isConnected = false;
//     _currentUserId = null;
//     _messageSentCallbacks.clear();
//     _newMessageCallbacks.clear();
//   }

//   bool get isConnected => _isConnected;
//   String? get currentUserId => _currentUserId;
// }
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:talcove/core/constants/api_constants.dart';
import 'package:talcove/core/constants/socket_events.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;
  String? _lastToken;
  String? _lastUserId;

  final List<void Function(Map<String, dynamic>)> _messageSentCallbacks = [];
  final List<void Function(Map<String, dynamic>)> _newMessageCallbacks = [];

  void connect(String token, String userId) {
    _lastToken = token;
    _lastUserId = userId;

    print(" Connecting to socket with token: ${token.substring(0, 20)}...");

    if (_socket != null) {
      print(
        "⚠️ Found an existing socket instance. Disconnecting and disposing before creating a new one...",
      );
      try {
        _socket!.off(SocketEvents.connect);
        _socket!.off(SocketEvents.disconnect);
        _socket!.off(SocketEvents.error);
        _socket!.disconnect();
        _socket!.dispose();
      } catch (e) {
        print("Error during clearing old socket: $e");
      }
      _socket = null;
      _isConnected = false;
    }

    _currentUserId = userId;

    // بناء السوكيت الجديد على ساحة نظيفة تماماً
    _socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .enableForceNew()
          .build(),
    );

    _socket!.on(SocketEvents.connect, (_) {
      print("Socket connected");
      _isConnected = true;

      if (_currentUserId != null) {
        _socket!.emit('join', {'userId': _currentUserId});
        print(" Joined with userId: $_currentUserId");
      }
    });

    _socket!.on(SocketEvents.disconnect, (_) {
      print("Socket disconnected");
      _isConnected = false;
    });

    _socket!.on(SocketEvents.error, (error) {
      print("Error happened $error");
    });

    Map<String, dynamic> normalizeSocketPayload(dynamic rawData) {
      if (rawData is! Map) return {};

      final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);

      if (data['sender'] is Map) {
        final senderMap = Map<String, dynamic>.from(data['sender']);
        data['senderId'] = senderMap['id'] ?? senderMap['_id'] ?? '';
        data['senderUserName'] =
            senderMap['senderUserName'] ?? senderMap['userName'] ?? '';
      } else if (data['senderId'] == null && data['sender'] is String) {
        data['senderId'] = data['sender'];
      }

      if (data['receiver'] is Map) {
        final receiverMap = Map<String, dynamic>.from(data['receiver']);
        data['receiverId'] = receiverMap['id'] ?? receiverMap['_id'] ?? '';
        data['receiverUserName'] =
            receiverMap['receiverUserName'] ?? receiverMap['userName'] ?? '';
      } else if (data['receiverId'] == null && data['receiver'] is String) {
        data['receiverId'] = data['receiver'];
      }

      return data;
    }

    _socket!.on(SocketEvents.messageSent, (data) {
      print("Message sent raw: $data");
      final normalizedData = normalizeSocketPayload(data);
      for (var callback in _messageSentCallbacks) {
        callback(normalizedData);
      }
    });

    _socket!.on(SocketEvents.newMessage, (data) {
      print("new message received raw: $data");
      final normalizedData = normalizeSocketPayload(data);
      for (var callback in _newMessageCallbacks) {
        callback(normalizedData);
      }
    });

    // _socket!.on(SocketEvents.messageSent, (data) {
    //   print("Message sent $data");
    //   for (var callback in _messageSentCallbacks) {
    //     callback(data);
    //   }
    // });

    // _socket!.on(SocketEvents.newMessage, (data) {
    //   print("new message received $data");
    //   for (var callback in _newMessageCallbacks) {
    //     callback(data);
    //   }
    // });

    _socket!.onAny((event, data) {
      print("⚡ ALL EVENT: $event, data: $data");
    });
  }

  void reconnect() {
    if (_lastToken != null && _lastUserId != null) {
      connect(_lastToken!, _lastUserId!);
    }
  }

  void sendMessage(String message, String receiverId) {
    print(" Sending message: '$message' to '$receiverId'");
    print(" Socket connected: $_isConnected");

    if (!_isConnected || _socket == null) {
      print("Failed to send message: Socket is not connected");
      return;
    }

    _socket!.emit(SocketEvents.sendMessage, {
      'message': message,
      'receiverId': receiverId,
    });
  }

  void onMessageSent(void Function(Map<String, dynamic>) callback) {
    print("on Message sent");
    _messageSentCallbacks.clear();
    _messageSentCallbacks.add(callback);
  }

  void onNewMessage(void Function(Map<String, dynamic>) callback) {
    print("On new message");
    _newMessageCallbacks.clear();
    _newMessageCallbacks.add(callback);
  }

  void offNewMessage(void Function(dynamic p1) onNewMessageHandler) {
    _newMessageCallbacks.clear();
  }

  void offMessageSent(void Function(dynamic p1) onMessageSentHandler) {
    _messageSentCallbacks.clear();
  }

  void disconnect() {
    print("🔌 Manual disconnect called on SocketService");
    try {
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null; // تصفير الكائن تماماً
      }
    } catch (e) {
      print(" Socket error during disconnect: $e");
    }
    _isConnected = false;
    _currentUserId = null;
    _messageSentCallbacks.clear();
    _newMessageCallbacks.clear();
  }

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;
}
