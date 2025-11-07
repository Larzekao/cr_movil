import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class GetPatientsUseCase {
  final PatientRepository repository;

  GetPatientsUseCase(this.repository);

  Future<Either<Failure, List<PatientEntity>>> call({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    return await repository.getPatients(
      page: page,
      pageSize: pageSize,
      search: search,
    );
  }
}
