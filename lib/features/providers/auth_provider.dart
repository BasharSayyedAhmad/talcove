import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/models/auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return AuthState();
  }

  Future<void> loginWithGoogle() async {
    state = AuthState(isLoading: true, errorMessage: null);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      String userName = googleUser.displayName?.trim() ?? '';
      if (userName.isEmpty && googleUser.email.isNotEmpty) {
        userName = googleUser.email.split('@').first;
      }
      if (idToken != null) {
        final url = Uri.parse(
          "https://chat-app-nfr1.onrender.com/api/v1/auth/google",
        );
        final body = jsonEncode({'idToken': idToken});
        print("🔥 FULL ID TOKEN (copy this):");
        print(idToken);
        print("ZBY");
        print("🔥 END TOKEN");
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        print("response body: ${response.body}");
        print("response status code: ${response.statusCode}");

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          state = state.copyWith(isLoading: false, isAuthenticated: true);
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: "Login failed: ${response.body}",
          );
        }
      }
    } on PlatformException catch (e) {
      print("GOOGLE ERROR CODE: ${e.code}");
      print("GOOGLE ERROR MESSAGE: ${e.message}");
      if (e.code == "network_error" || e.message?.contains("7") == true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "No internet connection or Google servers unreachable",
        );
        return;
      }

      if (e.code == "12501") {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "Sign-in cancelled",
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: "Google Sign-In failed",
      );
      return;
    } catch (e, stack) {
      print(e);
      print(stack);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // serverClientId is the "Web Client ID" from Google Cloud Console
  serverClientId:
      '879638281684-c7b5ou43o5579ns0c8lbaq82p1ahja6j.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);
