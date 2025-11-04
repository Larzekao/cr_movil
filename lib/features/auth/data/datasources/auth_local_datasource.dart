import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  /// Guarda el usuario en almacenamiento local
  Future<void> cacheUser(UserModel user);

  /// Obtiene el usuario del almacenamiento local
  Future<UserModel> getCachedUser();

  /// Guarda los tokens de autenticación
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Obtiene el access token
  Future<String?> getAccessToken();

  /// Obtiene el refresh token
  Future<String?> getRefreshToken();

  /// Guarda el tenant ID
  Future<void> cacheTenantId(String tenantId);

  /// Limpia toda la información de autenticación
  Future<void> clearAuth();

  /// Verifica si hay una sesión activa
  Future<bool> hasSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl({required this.storage});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await storage.write(key: StorageConstants.userId, value: user.id);
      await storage.write(key: StorageConstants.userEmail, value: user.email);
      await storage.write(key: 'user_data', value: userJson);
    } catch (e) {
      throw CacheException(message: 'Error al guardar usuario: $e');
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    try {
      final userJson = await storage.read(key: 'user_data');
      if (userJson == null) {
        throw CacheException(message: 'No hay usuario almacenado');
      }
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException(message: 'Error al obtener usuario: $e');
    }
  }

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await storage.write(
        key: StorageConstants.accessToken,
        value: accessToken,
      );
      await storage.write(
        key: StorageConstants.refreshToken,
        value: refreshToken,
      );
    } catch (e) {
      throw CacheException(message: 'Error al guardar tokens: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: StorageConstants.accessToken);
    } catch (e) {
      throw CacheException(message: 'Error al obtener access token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(key: StorageConstants.refreshToken);
    } catch (e) {
      throw CacheException(message: 'Error al obtener refresh token: $e');
    }
  }

  @override
  Future<void> cacheTenantId(String tenantId) async {
    try {
      await storage.write(key: StorageConstants.tenantId, value: tenantId);
    } catch (e) {
      throw CacheException(message: 'Error al guardar tenant ID: $e');
    }
  }

  @override
  Future<void> clearAuth() async {
    try {
      await storage.delete(key: StorageConstants.accessToken);
      await storage.delete(key: StorageConstants.refreshToken);
      await storage.delete(key: StorageConstants.tenantId);
      await storage.delete(key: StorageConstants.userId);
      await storage.delete(key: StorageConstants.userEmail);
      await storage.delete(key: 'user_data');
    } catch (e) {
      throw CacheException(message: 'Error al limpiar autenticación: $e');
    }
  }

  @override
  Future<bool> hasSession() async {
    try {
      final token = await storage.read(key: StorageConstants.accessToken);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
