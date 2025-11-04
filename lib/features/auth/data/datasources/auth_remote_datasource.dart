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
        final data = response.data as Map<String, dynamic>;

        // Extraer tenant_id del user object si no está en el nivel superior
        final tenantId = data['tenant_id'] ?? data['user']?['tenant_id'] ?? '';

        return {
          'user': UserModel.fromJson(data['user'] as Map<String, dynamic>),
          'access_token': data['access'] as String,
          'refresh_token': data['refresh'] as String,
          'tenant_id': tenantId,
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
    } catch (e) {
      throw ServerException(message: 'Error de conexión: $e', statusCode: null);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.post(ApiConstants.logout);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Error al cerrar sesión: $e',
        statusCode: null,
      );
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
