import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Login con email y password
  /// Retorna Either<Failure, UserEntity>
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Logout - Limpia la sesión
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> logout();

  /// Obtiene el usuario actual almacenado
  /// Retorna Either<Failure, UserEntity>
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Verifica si hay una sesión activa
  /// Retorna true si hay token válido
  Future<bool> isAuthenticated();

  /// Refresca el token de acceso
  /// Retorna Either<Failure, void>
  Future<Either<Failure, void>> refreshToken();
}
