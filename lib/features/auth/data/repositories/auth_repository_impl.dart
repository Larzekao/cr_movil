import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    // Verificar conexión
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      // Intentar login remoto
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      final user = result['user'] as UserModel;
      final accessToken = result['access_token'] as String;
      final refreshToken = result['refresh_token'] as String;

      // Guardar en caché
      await localDataSource.cacheUser(user);
      await localDataSource.cacheTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // 🔥 REGISTRAR TOKEN FCM EN EL BACKEND (después del login exitoso)
      try {
        final notificationService = NotificationService();
        final fcmToken = notificationService.fcmToken;

        if (fcmToken != null && fcmToken.isNotEmpty) {
          // Registrar token en background (no bloqueamos el login)
          await remoteDataSource.registerFcmToken(fcmToken);
        }
      } catch (e) {
        // Si falla el registro del FCM, continuamos (no bloquea el login)
      }

      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.errors ?? {}));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Con JWT, el logout es solo del lado del cliente
      // No necesitamos invalidar el token en el servidor
      // El token expirará automáticamente según su tiempo de vida

      // Limpiar caché local (tokens y datos del usuario)
      await localDataSource.clearAuth();

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al cerrar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // Primero verificar si hay tokens (sesión activa)
      final accessToken = await localDataSource.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        // No hay sesión activa
        return const Left(AuthFailure('No hay sesión activa'));
      }

      // Intentar obtener del caché primero
      try {
        final cachedUser = await localDataSource.getCachedUser();

        // Si hay internet, sincronizar con el servidor
        if (await networkInfo.isConnected) {
          try {
            final remoteUser = await remoteDataSource.getCurrentUser();
            await localDataSource.cacheUser(remoteUser);
            return Right(remoteUser);
          } catch (e) {
            // Si falla, usar el caché
            return Right(cachedUser);
          }
        }

        return Right(cachedUser);
      } on CacheException {
        // No hay usuario en caché pero sí hay tokens
        // Intentar obtener del servidor
        if (await networkInfo.isConnected) {
          try {
            final remoteUser = await remoteDataSource.getCurrentUser();
            await localDataSource.cacheUser(remoteUser);
            return Right(remoteUser);
          } catch (e) {
            return const Left(
              AuthFailure('No se pudo obtener información del usuario'),
            );
          }
        }
        return const Left(
          AuthFailure('No hay información del usuario disponible'),
        );
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error al obtener usuario: $e'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await localDataSource.hasSession();
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return const Left(AuthFailure('No hay refresh token disponible'));
      }

      final result = await remoteDataSource.refreshToken(refreshToken);
      final newAccessToken = result['access_token']!;

      await localDataSource.cacheTokens(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
      );

      return const Right(null);
    } on AuthException catch (e) {
      await localDataSource.clearAuth();
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Error al refrescar token: $e'));
    }
  }
}
