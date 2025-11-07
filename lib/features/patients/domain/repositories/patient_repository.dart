import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/patient_entity.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<PatientEntity>>> getPatients({
    int page = 1,
    int pageSize = 10,
    String? search,
  });

  Future<Either<Failure, PatientEntity>> getPatientById(String id);

  Future<Either<Failure, PatientEntity>> createPatient(
    Map<String, dynamic> patientData,
  );

  Future<Either<Failure, PatientEntity>> updatePatient(
    String id,
    Map<String, dynamic> patientData,
  );

  Future<Either<Failure, void>> deletePatient(String id);
}
