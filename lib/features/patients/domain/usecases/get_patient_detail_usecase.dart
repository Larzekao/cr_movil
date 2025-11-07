import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class GetPatientDetailUseCase {
  final PatientRepository repository;

  GetPatientDetailUseCase(this.repository);

  Future<Either<Failure, PatientEntity>> call(String id) async {
    return await repository.getPatientById(id);
  }
}
