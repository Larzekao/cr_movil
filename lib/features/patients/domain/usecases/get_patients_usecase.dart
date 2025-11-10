import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/patient_repository.dart';

class GetPatientsUseCase {
  final PatientRepository repository;

  GetPatientsUseCase(this.repository);

  Future<Either<Failure, PaginatedPatients>> call({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? ordering,
  }) async {
    return await repository.getPatients(
      page: page,
      pageSize: pageSize,
      search: search,
      ordering: ordering,
    );
  }
}
