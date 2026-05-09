import 'package:talcove/core/constants/auth_method.dart';

class User {
  final String id;
  final String userName;
  final String? email;
  final String? photoUrl;
  final AuthMethod? authType;
  final String? token; // JWT أو Access Token
  final DateTime? createdAt; // وقت إنشاء الحساب
  final DateTime? updatedAt; // آخر تحديث
  final String? status; // Online / Offline
  final String? bio; // وصف قصير

  User({
    required this.id,
    required this.userName,
    this.email,
    this.photoUrl,
    this.authType,
    this.token,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      authType: json['authType'] != null
          ? AuthMethod.values.firstWhere(
              (e) => e.toString() == 'AuthMethod.${json['authType']}',
            )
          : null,
      token: json['token'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      status: json['status'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'photoUrl': photoUrl,
      'authType': authType?.name,
      'token': token,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
      'bio': bio,
    };
  }
}
