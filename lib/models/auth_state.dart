import 'package:talcove/core/constants/auth_method.dart';
import 'package:talcove/models/user.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  final User? user;
  final AuthMethod? authMethod;
  final bool hasInternet;
  AuthState({
    this.isLoading = false,
    this.hasInternet = true,
    this.isAuthenticated = false,
    this.errorMessage,
    this.user,
    this.authMethod,
  });
  AuthState copyWith({
    bool? isLoading,
    bool? hasInternet,
    String? errorMessage,
    bool? isAuthenticated,
    User? user,
    AuthMethod? authMethod,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      hasInternet: hasInternet ?? this.hasInternet,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      authMethod: authMethod ?? this.authMethod,
    );
  }
}
