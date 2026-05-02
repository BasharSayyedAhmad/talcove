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
      if (idToken != null) {
        print("idToken: ${idToken}");
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: "No idToken found",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // serverClientId is the "Web Client ID" from Google Cloud Console
  serverClientId:
      '879638281684-9d22bo358d6j6mtspfgao8711q6qj6p6.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
);
