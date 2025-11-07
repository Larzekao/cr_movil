class ApiConstants {
  // Base
  static const String baseUrl = '/api';

  // Auth endpoints
  static const String login = '/login/';
  static const String logout = '/logout/';
  static const String refreshToken = '/refresh/';
  static const String register = '/register/';

  // User endpoints
  static const String currentUser = '/users/me/';
  static const String users = '/users/';

  // Patients endpoints
  static const String patients = '/patients/';

  // Clinical Records endpoints
  static const String clinicalRecords = '/clinical-records/';

  // Documents endpoints
  static const String documents = '/documents/';
  static const String uploadDocument = '/documents/upload/';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
