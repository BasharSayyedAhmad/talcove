class SocketState {
  final bool isConnected;
  final bool isConnecting;
  final String? error;

  const SocketState({
    this.isConnected = false,
    this.isConnecting = false,
    this.error,
  });

  SocketState copyWith({bool? isConnected, bool? isConnecting, String? error}) {
    return SocketState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error ?? this.error,
    );
  }
}
