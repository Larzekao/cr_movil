import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class CreatePatientUseCase {
  final PatientRepository repository;

  CreatePatientUseCase(this.repository);

  Future<Either<Failure, PatientEntity>> call(
    Map<String, dynamic> patientData,
  ) async {
    return await repository.createPatient(patientData);
  }
}
