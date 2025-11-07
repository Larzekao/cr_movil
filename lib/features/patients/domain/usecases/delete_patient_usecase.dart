import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/patient_repository.dart';

class DeletePatientUseCase {
  final PatientRepository repository;

  DeletePatientUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deletePatient(id);
  }
}
