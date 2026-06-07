import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talcove/core/services/auth_service.dart';
import 'package:talcove/models/search_state.dart';
import 'package:talcove/models/user.dart';

part 'search_provider.g.dart';

@riverpod
class SearchNotifier extends _$SearchNotifier {
  late final AuthService _authService;

  @override
  SearchState build() {
    _authService = AuthService();
    return SearchState();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], errorMessage: null, query: '');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, query: query);

    try {
      final result = await _authService.searchUsers(query);

      print(" Search result from AuthService: $result");

      if (result['success'] == true) {
        final userData = result['user'];
        List<User> users = [];

        if (userData != null) {
          final user = User(
            id: userData['userId'].toString(),
            userName: userData['userName']?.toString() ?? '',
            email: userData['email']?.toString() ?? '',
            phoneNumber: userData['phoneNumber']?.toString() ?? '',
          );
          users = [user];
        }

        state = state.copyWith(
          results: users,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          results: [],
          isLoading: false,
          errorMessage: 'Search failed',
        );
      }
    } catch (e) {
      print("Search error: $e");
      state = state.copyWith(
        results: [],
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearResults() {
    state = SearchState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
