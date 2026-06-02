extension HttpStatusExtension on int? {
  bool isSuccess() {
    return this != null && this! >= 200 && this! < 300;
  }

  bool isUnauthorized() {
    return this == 401;
  }

  bool isForbidden() {
    return this == 403;
  }

  bool isNotFound() {
    return this == 404;
  }

  bool isServerError() {
    return this != null && this! >= 500;
  }
}
