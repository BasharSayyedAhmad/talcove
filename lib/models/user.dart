import 'package:talcove/core/constants/auth_method.dart';

class User {
  final String id;
  final String userName;
  final String? firstName;
  final String? lastName;
  final String? deviceToken;
  final String? email;
  final bool isEmailVisible;
  final bool isPhoneNumberVisible;
  final String? phoneNumber;
  final String? photoUrl;
  final AuthMethod? authType;
  final String? token;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSeen;
  final String? status;
  final String? bio;

  User({
    required this.id,
    required this.userName,
    this.firstName,
    this.lastName,
    this.deviceToken,
    this.isEmailVisible = false,
    this.isPhoneNumberVisible = false,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.authType,
    this.token,
    this.createdAt,
    this.updatedAt,
    this.lastSeen,
    this.status,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['userId'] ?? json['id'] ?? '';
    print("Loading user: ${json['userName']} -> ID: '$id'");
    return User(
      id: id,
      userName: json['userName'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      deviceToken: json['deviceToken'],
      phoneNumber: json['phoneNumber'],
      photoUrl: () {
        final url = json['profileImage'] ?? json['photoUrl'];
        if (url != null && url.startsWith('http://')) {
          return url.replaceFirst('http://', 'https://');
        }
        return url;
      }(),
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
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : null,
      status: json['status'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'deviceToken': deviceToken,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'profileImage': photoUrl,

      'isEmailVisible': isEmailVisible,
      'isPhoneNumberVisible': isPhoneNumberVisible,
      'authType': authType?.name,
      'token': token,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
      'status': status,
      'bio': bio,
    };
  }

  User copyWith({
    String? id,
    String? userName,
    String? firstName,
    String? lastName,
    String? deviceToken,
    String? email,
    bool? isEmailVisible,
    bool? isPhoneNumberVisible,
    String? phoneNumber,
    String? photoUrl,
    AuthMethod? authType,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
    String? status,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      deviceToken: deviceToken ?? this.deviceToken,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVisible: isEmailVisible ?? this.isEmailVisible,
      isPhoneNumberVisible: isPhoneNumberVisible ?? this.isPhoneNumberVisible,
      authType: authType ?? this.authType,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      bio: bio ?? this.bio,
    );
  }
}
