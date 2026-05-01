import 'package:talcove/models/user.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthinticated;
  final String? errorMessage;
  final User? user;
  AuthState({
    this.isLoading = false,
    this.isAuthinticated = false,
    this.errorMessage,
    this.user,
  });
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isAuthinticated: isAuthinticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
