import 'package:talcove/models/user.dart';

class SearchState {
  final List<User> results;
  final bool isLoading;
  final String? errorMessage;
  final String query;

  SearchState({
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
    this.query = '',
  });

  SearchState copyWith({
    List<User>? results,
    bool? isLoading,
    String? errorMessage,
    String? query,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
    );
  }
}
