import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:talcove/core/services/api_service.dart';
import 'package:talcove/models/user.dart';

class UserService {
  final Dio _dio = ApiService().dio;
  Future<String?> _getDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print(" Device Token: $token");
      return token;
    } catch (e) {
      print(" Error getting device token: $e");
      return null;
    }
  }

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
      print(" Dio Error: ${e.response?.data ?? e.message}");
    } catch (e) {
      print(" Error: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> updateDeviceToken({String? customToken}) async {
    try {
      final String? token = customToken ?? await _getDeviceToken();
      if (token == null || token.isEmpty) {
        debugPrint(" No device token available to send.");
        return {'success': false, 'error': 'Device token is null or empty'};
      }
      final formData = FormData.fromMap({'deviceToken': token});
      final response = await _dio.patch('/api/v1/users', data: formData);
      debugPrint("Update deviceToken response status: ${response.statusCode}");
      debugPrint("Update deviceToken body: ${response.data}");
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data};
      }

      return {'success': false, 'error': 'Failed to update device token'};
    } catch (e) {
      debugPrint("Failed to update device token: $e");
      return {'success': false, 'error': "An unknown error happened"};
    }
  }
}
