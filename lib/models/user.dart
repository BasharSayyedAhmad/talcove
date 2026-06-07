import 'package:talcove/core/constants/auth_method.dart';

class User {
  final String id;
  final String userName;
  final String? email;
  final bool isEmailVisible;
  final bool isPhoneNumberVisible;
  final String? phoneNumber;
  final String? photoUrl;
  final AuthMethod? authType;
  final String? token;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;
  final String? bio;

  User({
    required this.id,
    required this.userName,
    this.isEmailVisible = false,
    this.isPhoneNumberVisible = false,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.authType,
    this.token,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['userId'] ?? json['id'] ?? '';
    print("Loading user: ${json['userName']} -> ID: '$id'");
    return User(
      id: id,
      userName: json['userName'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      isEmailVisible: json['isEmailVisible'] ?? false,
      isPhoneNumberVisible: json['isPhoneNumberVisible'] ?? false,
      authType: json['authType'] != null
          ? AuthMethod.values.firstWhere(
              (e) => e.toString() == 'AuthMethod.${json['authType']}',
              orElse: () => AuthMethod.userNameAndPassword,
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
      'userId': id,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,

      'isEmailVisible': isEmailVisible,
      'isPhoneNumberVisible': isPhoneNumberVisible,
      'authType': authType?.name,
      'token': token,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
      'bio': bio,
    };
  }

  User copyWith({
    String? id,
    String? userName,
    String? email,
    bool? isEmailVisible,
    bool? isPhoneNumberVisible,
    String? phoneNumber,
    String? photoUrl,
    AuthMethod? authType,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVisible: isEmailVisible ?? this.isEmailVisible,
      isPhoneNumberVisible: isPhoneNumberVisible ?? this.isPhoneNumberVisible,
      authType: authType ?? this.authType,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      bio: bio ?? this.bio,
    );
  }
}
