import 'package:dio/dio.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/models/user.dart';

class UserService {
  final Dio _dio = ApiService().dio;

  Future<List<User>> fetchUserContacts() async {
    try {
      final response = await _dio.get('/api/v1/users');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic>? contactsJson = response.data['data']['contacts'];

        if (contactsJson != null) {
          return contactsJson.map((json) => User.fromJson(json)).toList();
        }
      }
    } on DioException catch (e) {
      print("❌ Dio Error: ${e.response?.data ?? e.message}");
    } catch (e) {
      print("❌ Error: $e");
    }
    return [];
  }
}
