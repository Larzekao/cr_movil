import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  static bool get isDevelopment => environment == 'development';

  static bool get isProduction => environment == 'production';

  static String get appName => dotenv.env['APP_NAME'] ?? 'CliniDocs Mobile';

  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  static bool get debugMode => dotenv.env['DEBUG_MODE'] == 'true';
}
