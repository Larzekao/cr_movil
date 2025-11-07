import 'package:logger/logger.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Login con email y password
  /// Retorna UserModel y tokens
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  /// Logout - Invalida el token en el servidor
  Future<void> logout();

  /// Obtiene el usuario actual del servidor
  Future<UserModel> getCurrentUser();

  /// Refresca el access token
  Future<Map<String, String>> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;
  final Logger _logger = Logger();

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        // Imprimir la respuesta completa como String
        _logger.d('===== RAW RESPONSE =====');
        _logger.d(response.data.toString());
        _logger.d('===== END RAW RESPONSE =====');

        _logger.d('Login response received: ${response.data}');

        // Validar que response.data sea un Map
        if (response.data is! Map<String, dynamic>) {
          _logger.e('Response data is not a Map: ${response.data.runtimeType}');
          throw ServerException(
            message: 'Formato de respuesta inválido del servidor',
            statusCode: 200,
          );
        }

        final data = response.data as Map<String, dynamic>;

        _logger.d('Login response data keys: ${data.keys}');
        _logger.d('User data: ${data['user']}');
        _logger.d('User data type: ${data['user']?.runtimeType}');

        // Validar que los campos requeridos existan
        if (data['user'] == null) {
          _logger.e('User data is null in response');
          throw ServerException(
            message: 'Datos de usuario no encontrados en la respuesta',
            statusCode: 200,
          );
        }

        if (data['access'] == null || data['refresh'] == null) {
          _logger.e('Tokens missing in response');
          throw ServerException(
            message: 'Tokens de autenticación no encontrados',
            statusCode: 200,
          );
        }

        // Parse user con manejo de errores
        UserModel userModel;
        try {
          _logger.d('Attempting to parse user model...');

          // Validar que user sea un Map
          if (data['user'] is! Map<String, dynamic>) {
            throw ServerException(
              message:
                  'Datos de usuario en formato inválido: ${data['user'].runtimeType}',
              statusCode: 200,
            );
          }

          final userData = data['user'] as Map<String, dynamic>;
          _logger.d('User data complete: $userData');
          _logger.d('Role field: ${userData['role']}');
          _logger.d('Role field type: ${userData['role']?.runtimeType}');
          _logger.d('Role_name field: ${userData['role_name']}');

          userModel = UserModel.fromJson(userData);
          _logger.d('User model parsed successfully: ${userModel.email}');
        } catch (e, stackTrace) {
          _logger.e(
            'Error parsing user model',
            error: e,
            stackTrace: stackTrace,
          );
          throw ServerException(
            message: 'Error al parsear usuario: $e',
            statusCode: 200,
          );
        }

        return {
          'user': userModel,
          'access_token': data['access'] as String,
          'refresh_token': data['refresh'] as String,
        };
      } else {
        throw ServerException(
          message: 'Error al iniciar sesión',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('Unexpected error in login', error: e, stackTrace: stackTrace);
      throw ServerException(message: 'Error de conexión: $e', statusCode: null);
    }
  }

  @override
  Future<void> logout() async {
    // JWT es stateless - no necesita llamar al servidor
    // El logout se maneja eliminando tokens del almacenamiento local
    try {
      _logger.d('Logout: No server call needed for JWT');
      // Si en el futuro se necesita invalidar refresh tokens en el servidor,
      // descomentar la siguiente línea y crear el endpoint en el backend:
      // await client.post(ApiConstants.logout);
    } catch (e) {
      _logger.w('Error during logout cleanup', error: e);
      // No lanzar excepción - el logout local debe funcionar aunque falle la red
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await client.get(ApiConstants.currentUser);

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'Error al obtener usuario actual',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Error de conexión: $e', statusCode: null);
    }
  }

  @override
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        ApiConstants.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        return {'access_token': response.data['access'] as String};
      } else {
        throw AuthException(message: 'Error al refrescar token');
      }
    } catch (e) {
      throw AuthException(message: 'Error al refrescar token: $e');
    }
  }
}
