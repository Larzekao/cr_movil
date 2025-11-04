class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;

  AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final Map<String, dynamic> errors;

  ValidationException({required this.errors});

  @override
  String toString() => 'ValidationException: $errors';
}
