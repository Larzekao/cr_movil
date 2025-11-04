import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../config/environment/environment.dart';
import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final Logger _logger = Logger();

  DioClient({required Dio dio, required FlutterSecureStorage storage})
    : _dio = dio,
      _storage = storage {
    _configureDio();
    _addInterceptors();
  }

  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Agregar token JWT
      final token = await _storage.read(key: StorageConstants.accessToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      // Agregar tenant ID
      final tenantId = await _storage.read(key: StorageConstants.tenantId);
      if (tenantId != null && tenantId.isNotEmpty) {
        options.headers['X-Tenant-ID'] = tenantId;
      }

      _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
      _logger.d('REQUEST HEADERS: ${options.headers}');

      handler.next(options);
    } catch (e) {
      _logger.e('Error in request interceptor: $e');
      handler.next(options);
    }
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    _logger.d('RESPONSE DATA: ${response.data}');
    handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    _logger.e(
      'ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}',
    );
    _logger.e('ERROR DATA: ${error.response?.data}');

    // Manejar error 401 (No autorizado) - Refresh token
    if (error.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Reintentar la petición original
        try {
          final response = await _retry(error.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          _logger.e('Error retrying request: $e');
        }
      } else {
        // No se pudo refrescar el token, limpiar sesión
        await _clearSession();
      }
    }

    handler.next(error);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(
        key: StorageConstants.refreshToken,
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.w('No refresh token available');
        return false;
      }

      _logger.i('Attempting to refresh token...');

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access'];

        await _storage.write(
          key: StorageConstants.accessToken,
          value: newAccessToken,
        );

        _logger.i('Token refreshed successfully');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error refreshing token: $e');
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await _storage.read(key: StorageConstants.accessToken);

    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: StorageConstants.accessToken);
    await _storage.delete(key: StorageConstants.refreshToken);
    await _storage.delete(key: StorageConstants.tenantId);
    await _storage.delete(key: StorageConstants.userId);
    _logger.i('Session cleared');
  }

  // Métodos HTTP públicos
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Error de conexión. Verifica tu internet.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['detail'] ??
            error.response?.data?['message'] ??
            'Error del servidor';

        if (statusCode == 401) {
          return AuthException(
            message: 'Sesión expirada. Por favor, inicia sesión nuevamente.',
          );
        } else if (statusCode == 400) {
          final errors = error.response?.data;
          if (errors is Map<String, dynamic>) {
            return ValidationException(errors: errors);
          }
        }

        return ServerException(message: message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return NetworkException(message: 'Petición cancelada');

      default:
        return NetworkException(message: 'Error de red. Verifica tu conexión.');
    }
  }
}
