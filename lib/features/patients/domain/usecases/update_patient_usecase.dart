import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class UpdatePatientUseCase {
  final PatientRepository repository;

  UpdatePatientUseCase(this.repository);

  Future<Either<Failure, PatientEntity>> call(
    String id,
    Map<String, dynamic> patientData,
  ) async {
    return await repository.updatePatient(id, patientData);
  }
}
