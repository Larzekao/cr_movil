import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Ejecuta el login con email y password
  /// Retorna Either<Failure, UserEntity>
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    // Validaciones básicas
    if (email.isEmpty) {
      return const Left(ValidationFailure('El email es requerido', {}));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('La contraseña es requerida', {}));
    }

    if (!_isValidEmail(email)) {
      return const Left(
        ValidationFailure('El formato del email no es válido', {}),
      );
    }

    // Ejecutar login
    return await repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
