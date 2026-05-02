import 'package:talcove/core/constants/auth_method.dart';

class User {
  final String id;
  final String userName;
  final String? email;
  final String? photoUrl;
  final AuthMethod? authType;

  User({
    required this.id,
    required this.userName,
    this.email,
    this.photoUrl,
    this.authType,
  });
}
