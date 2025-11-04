import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Obtiene el usuario actual almacenado
  /// Retorna Either<Failure, UserEntity>
  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getCurrentUser();
  }
}
