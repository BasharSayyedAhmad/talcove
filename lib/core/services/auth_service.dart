import 'package:dio/dio.dart';
import 'package:talcove/core/extensions/http_extensions.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiService.dio.post(
        '/api/v1/auth/google',
        data: {'idToken': idToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print("Response data : ${response.data}");
      print("Statue code ${response.statusCode}");
      if (response.statusCode.isSuccess()) {
        final userData = response.data['data'];
        final accessToken = userData['accessToken'];
        _apiService.setAccessToken(accessToken);
        return {'success': true, 'user': userData, 'accessToken': accessToken};
      }

      return {
        'success': false,
        'error': 'Login failed with status: ${response.statusCode}',
      };
    } on DioException catch (e) {
      String errorMessage = 'Network error';
      if (e.response != null) {
        if (e.response!.statusCode.isUnauthorized()) {
          errorMessage = 'Invalid credentials';
        } else if (e.response!.statusCode.isServerError()) {
          errorMessage = 'Server error, please try again later';
        } else {
          errorMessage = e.response?.data['message'] ?? 'Unknown error';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Receive timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> registerWithUsernamePassword({
    required String userName,
    required String password,
    String? email,
  }) async {
    try {
      final formData = FormData.fromMap({
        'userName': userName,
        'password': password,
      });

      final response = await _apiService.dio.post(
        '/api/v1/users/register',
        data: formData,
      );
      print("Full data : ${response.data}");

      if (response.statusCode.isSuccess()) {
        final userData = response.data['data'];
        _apiService.setAccessToken(userData['accessToken']);
        return {'success': true, 'user': userData};
      }
      return {'success': false, 'error': 'Registration failed'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['message'] ?? e.message,
      };
    }
  }

  //login معطوب
  Future<Map<String, dynamic>> loginWithUsernamePassword({
    required String userName,
    required String password,
  }) async {
    try {
      final encodedUserName = Uri.encodeComponent(userName);
      final encodedPassowrd = Uri.encodeComponent(password);
      final response = await _apiService.dio.get(
        "/api/v1/users/login/$encodedUserName/$encodedPassowrd",
      );
      print("Full response = ${response.data}");
      print("Status code = ${response.statusCode}");
      if (response.statusCode.isSuccess()) {
        final userData = response.data['data'];
        _apiService.setAccessToken(userData['accessToken']);
        return {'success': true, 'user': userData};
      }

      return {'success': false, 'error': 'Invalid credentials'};
    } on DioException catch (e) {
      String error = e.response?.data['message'] ?? e.message ?? 'Login failed';
      return {'success': false, 'error': error};
    }
  }

  Future<Map<String, dynamic>> updateEmail(String? email) async {
    try {
      final response = await _apiService.dio.patch(
        '/api/v1/users',
        data: {'email': email},
      );

      print("Update email response: ${response.statusCode}");
      print("Update email body: ${response.data}");

      if (response.statusCode.isSuccess()) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to update email'};
    } catch (e) {
      print("Failed to update email: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updatePhoneNumber(String? phone) async {
    try {
      final response = await _apiService.dio.patch(
        '/api/v1/users',
        data: {'phoneNumber': phone},
      );

      print("Update phone response: ${response.statusCode}");
      print("Update phone body: ${response.data}");

      if (response.statusCode.isSuccess()) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to update phone'};
    } catch (e) {
      print("Failed to update phone: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.dio.patch('/api/v1/users/refresh');

      print('🔄 Refresh response: ${response.statusCode}');
      print('🔄 Refresh body: ${response.data}');

      if (response.statusCode.isSuccess()) {
        //  استخراج الـ accessToken من response.data['data']
        final newAccessToken = response.data['data']['accessToken'];
        _apiService.setAccessToken(newAccessToken);
        print('Token refreshed successfully');
        return true;
      }
      print(' Refresh failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      print(' Refresh token failed: $e');
      return false;
    }
  }

  //search
  Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final response = await _apiService.dio.get(
        '/api/v1/users/?userName=$query',
        options: Options(
          headers: {'Authorization': 'Bearer ${_apiService.accessToken}'},
        ),
      );

      print("Response data : ${response.data}");
      if (response.statusCode.isSuccess()) {
        final userData = response.data['data']['user'];

        print(
          " User ID from API: ${userData['id'] ?? userData['userId'] ?? 'NO ID!'}",
        );
        return {'success': true, 'user': userData};
      }
      return {'success': false, 'error': 'Failed to search users'};
    } on DioException catch (e) {
      return {'success': false, 'error': e.message ?? 'Search failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  //تحديث الخصوصية

  Future<Map<String, dynamic>> updatePrivacySettings({
    required bool email,
    required bool firstName,
    required bool lastName,
    required bool phoneNumber,
    required bool profileImage,
    required bool lastSeen,
    required bool userName,
  }) async {
    try {
      final response = await _apiService.dio.patch(
        '/api/v1/users/privacySettings',
        data: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'profileImage': profileImage,
          'lastSeen': lastSeen,
          'userName': userName,
        },
      );

      if (response.statusCode.isSuccess()) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to update privacy settings'};
    } on DioException catch (e) {
      return {'success': false, 'error': e.message ?? 'Update failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  //  Logout من سوق الجمعة
  Future<void> logout() async {
    try {
      _apiService.clearAccessToken();
      await _apiService.clearAllCookies();
      print('✅ Local session cleared successfully');
    } catch (e) {
      print('⚠️ Error during local logout: $e');
      _apiService.clearAccessToken();
      await _apiService.clearAllCookies();
    }
  }
}
